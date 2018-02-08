module ekeymgr.submodule.TCPServer;
import ek = ekeymgr;
import ekeymgr.submodule;
import ekeymgr.net.auth;
import std.socket;
import std.string;
import std.getopt;
import std.algorithm;
import std.json;
import core.thread;

class TCPServer:Submodule{
public:
	~this(){
		stop();
	}
	void main(){
		ek.traceLog("TCP Server setup");
		address = new InternetAddress(ek.config.load!ushort("ekeymgrServerPort"));
		socket = new TcpSocket(AddressFamily.INET);
		socket.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
		socket.bind(address);
		socket.listen(1);
		ek.infoLog("listening on " ~ address.toString);
		scope(exit) socket.close();
		while(running){
			auto p = socket.accept;
			new Session(p).start();
		}
	}
	void stop(){
		import ekeymgr.net.client;
		ek.traceLog("TCP Server stop");
		running = false;
		connect("status", string[].init, true);
	}
	bool isAutoRestart(){
		return true;
	}
	string name(){
		return "TCPServer";
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
		string jsonStr = format(buf);
		remoteAddress = socket.remoteAddress.toHostNameString;
		localAddress = socket.localAddress.toHostNameString;
		socket.send(parse(jsonStr));
		socket.close();
	}
	string parse(string jsonStr){
		JSONValue json = parseJSON(jsonStr);
		ek.traceLog(json);
		ExecResult result;
		if(remoteAddress == localAddress || remoteAddress == "127.0.0.1"){
			result = exec(json);
		}else{
			if(json["command"].str == "stop"){
				result = new ExecResult(false, "Not allow to stop from outside.");
			}else if(remoteAddress == ek.config.load("mySQLServerAddress") || json["command"].str == "status"){
				result = exec(json);
			}else if(!json.object.keys.canFind("auth")){
				result = new ExecResult(false, "Authentication required.");
			}else{
				result = exec(json);
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
	ExecResult exec(JSONValue json){
		JSONValue authJson;
		bool isExistAuthData = false;
		if(json.object.keys.canFind("auth")){
			authJson = json["auth"];
			isExistAuthData = true;
		}
		switch(json["command"].str){
			case "open":
				if(!isExistAuthData){
					ekeymgr.open();
					break;
				}
				auto ad = ek.auth(authJson);
				if(ad is null){
					return new ExecResult(false,"Authentication failure");
				}
				if(!ekeymgr.open(ad)){
					return new ExecResult(false, "Key operation failure");
				}
				break;
			case "close":
				if(!isExistAuthData){
					ekeymgr.close();
					break;
				}
				auto ad = ek.auth(authJson);
				if(ad is null){
					return new ExecResult(false,"Authentication failure");
				}
				if(!ekeymgr.close(ad)){
					return new ExecResult(false, "Key operation failure");
				}
				break;
			case "toggle":
				if(!isExistAuthData){
					ekeymgr.toggle();
					break;
				}
				auto ad = ek.auth(authJson);
				if(ad is null){
					return new ExecResult(false,"Authentication failure");
				}
				if(!ekeymgr.toggle(ad)){
					return new ExecResult(false, "Key operation failure");
				}
				break;
			case "status":
				string msg = "status:" ~ (ek.isOpen?"Open":"Close");
				return new ExecResult(true, msg);
			case "stop":
				ek.infoLog("stopping daemon...");
				ekeymgr.stop();
				return new ExecResult(true, "stopping daemon...");
			default:
				return new ExecResult(false, "Unknown operation " ~ json["command"].str);
		}
		return new ExecResult(true, "");
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
