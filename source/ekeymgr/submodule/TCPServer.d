module ekeymgr.submodule.TCPServer;
import config = ekeymgr.config;
import ekeymgr.submodule;
import ekeymgr.net.auth;
import std.stdio;
import std.socket;
import std.file;
import std.string;
import std.array;
import std.getopt;
import core.stdc.stdlib;
import core.thread;
class TCPServer:Submodule{
public:
	~this(){
		stop();
	}
	void main(){
		address = new InternetAddress(config.load!ushort("ekeymgrServerPort"));
		socket = new TcpSocket(AddressFamily.INET);
		socket.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
		socket.bind(address);
		socket.listen(1);
		("listening on " ~ address.toString).writeln;
		stdout.flush;
		scope(exit) socket.close();
		while(running){
			auto p = socket.accept;
			new Session(p).start();
		}
	}
	void stop(){
		import ekeymgr.net.client;
		running = false;
		connect("status", string[].init);
	}
	bool isAutoRestart(){
		return true;
	}
private:
	Address address;
	Socket socket;
	bool running = true;
}
class Session: Thread{
public:
	this(Socket socket){
		this.socket = socket;
		super(&receive);
	}
private:
	Socket socket;
	string remoteAddress;
	string localAddress;
	bool serviceIdAuthFlag = false;
	void receive(){
		serviceIdAuthFlag = false;
		auto buf = new char[255];
		socket.receive(buf);
		format(buf).writeln;
		stdout.flush;
		string[] args = format(buf).split;
		remoteAddress = socket.remoteAddress.toHostNameString;
		localAddress = socket.localAddress.toHostNameString;
		parse(args);
		socket.close();
	}
	string parse(string[] args){
		try{
			getopt(args, "service-id-auth", &serviceIdAuthFlag);
		}catch(Exception e){
		}
		ExecResult result;
		if(remoteAddress == localAddress || remoteAddress == "127.0.0.1"){
			result = exec(args);
		}else{
			if(args[0] == "stop"){
				result = new ExecResult(false, "Not allow to stop from outside.");
			}else if(remoteAddress == config.load("mySQLServerAddress") || args[0] == "status"){
				result = exec(args);
			}else if(args.length != 3){
				result = new ExecResult(false, "Authentication required.");
			}else{
				result = exec(args);
			}
		}
		string msg = "";
		if(result.isSuccess){
			msg = "0\n";
		}else{
			msg = "1\n";
		}
		return msg ~ result.msg;
	}
	Auth _auth;
	string format(char[] buf){
		for(int i = 0; i < buf.length; ++i){
			if(buf[i] == 255){
				buf = buf[0..i];
				break;
			}
		}
		import std.conv;
	  	return buf.to!string.chomp;
	}
	ExecResult exec(string[] args){
		if(args.length == 0){
			return new ExecResult(false, "Too few arguments;");
		}
		switch(args[0]){
			case "open":
				if(args.length < 4 && !auth(args)){
					return new ExecResult(false,"Authentication failure");
				}
				ekeymgr.open();
				break;
			case "close":
				if(args.length < 4 && !auth(args)){
					return new ExecResult(false,"Authentication failure");
				}
				ekeymgr.close();
				break;
			case "toggle":
				if(args.length < 4 && !auth(args)){
					return new ExecResult(false,"Authentication failure");
				}
				ekeymgr.toggle();
				break;
			case "status":
				//string msg = "status:" ~ (userdaemon.isLock?"Lock":"Open");
				string msg = "";
				return new ExecResult(true, msg);
			case "stop":
				"stopping daemon...".writeln;
				stdout.flush();
				ekeymgr.stop();
				return new ExecResult(true, "stopping daemon...");
			default:
				return new ExecResult(false, "Unknown operation " ~ args[0]);
		}
		return new ExecResult(true, "");
	}
	bool auth(string[] args){
		_auth = new Auth();
		bool result = true;
		if(args.length == 3){
			if(serviceIdAuthFlag){
				result = _auth.authServiceId(args[1], args[2]) == 0;
			}else{
				result = _auth.authUserId(args[1], args[2]) == 0;
			}
		}
		return result;
	}
}
class ExecResult{
public:
	this(){
	}
	this(bool isSuccess, string msg){
		this.isSuccess = isSuccess;
		this.msg = msg;
	}
	bool isSuccess = false;
	string msg = "";
}
