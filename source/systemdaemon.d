module ekeymgr.systemdaemon;
static import config = ekeymgr.config;
import ekeymgr.userdaemon;
import ekeymgr.auth;
import std.stdio;
import std.socket;
import std.file;
import std.string;
import std.array;
import core.thread;
import core.stdc.stdlib;
class SystemDaemon{
public:
	this(){
		address = new InternetAddress(config.ekeymgrServerPort);
		socket = new TcpSocket(AddressFamily.INET);
		socket.bind(address);
		try{
			userdaemon = new UserDaemon();
		}catch(Exception e){
			e.msg.writeln;
			exit(EXIT_FAILURE);
		}
	}
	~this(){
		stop();
	}
	void main(){
		Thread t = new Thread(&userdaemon.main).start;
		socket.listen(1);
		("listening on " ~ address.toString).writeln;
		scope(exit) socket.close();
		while(running){
			auto p = socket.accept;
			scope(exit) p.close();
			auto buf = new char[255];
			p.receive(buf);
			format(buf).writeln;
			string[] args = format(buf).split;
			ExecResult result = exec(args);
			string msg = "";
			if(result.isSuccess){
				msg = "0\n";
			}else{
				msg = "1\n";
			}
			p.send(msg ~ result.msg);
		}
		t.join;
	}
private:
	Address address;
	Socket socket;
	bool running = true;
	UserDaemon userdaemon;
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
		auto f = &stop;
		f = null;
		switch(args[0]){
			case "open":
				if(args.length < 4 && !auth(args)){
					return new ExecResult(false,"Authentication failure");
				}
				f = &userdaemon.open;
				break;
			case "close":
				if(args.length < 4 && !auth(args)){
					return new ExecResult(false,"Authentication failure");
				}
				f = &userdaemon.close;
				break;
			case "toggle":
				if(args.length < 4 && !auth(args)){
					return new ExecResult(false,"Authentication failure");
				}
				f = &userdaemon.toggle;
				break;
			case "status":
				string msg = "status:" ~ (userdaemon.isLock?"Lock":"Open");
				return new ExecResult(true, msg);
			case "stop":
				"stopping daemon...".writeln;
				stop();
				return new ExecResult(true, "stopping daemon...");
			default:
				break;
		}
		if(f is null){
			return new ExecResult(false, "Unknown operation " ~ args[0]);
		}else{
			Thread t = new Thread(f);
			t.start().join;
			if(!(_auth is null)){
				_auth.addLog(userdaemon.isLock);
			}
			return new ExecResult(true, "");
		}
	}
	void stop(){
		running = false;
		userdaemon.stop;
	}
	bool auth(string[] args){
		_auth = new Auth();
		bool result;
		if(args.length != 3){
			result = _auth.auth("ekeymgr","ekeymgr") == 0;
		}else{
			result = _auth.auth(args[1], args[2]) == 0;
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
