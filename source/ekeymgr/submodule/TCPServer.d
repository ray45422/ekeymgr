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
	void onKeyEvent(ek.KeyEvent ke, AuthData ad){
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
		JSONValue result = parseJSON(`{"successful": false, "message":""}`);
		if(remoteAddress == localAddress || remoteAddress == "127.0.0.1"){
			result = exec(json);
		}else{
			if(json["command"].str == "stop"){
				result["message"] = "Not allow to stop from outside.";
			}else if(remoteAddress == ek.config.load("mySQLServerAddress") || json["command"].str == "status"){
				result = exec(json);
			}else if(!json.object.keys.canFind("auth")){
				result["message"] = "Authentication required.";
			}else{
				result = exec(json);
			}
		}
		ek.traceLog(result);
		return result.toString;
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
	JSONValue exec(JSONValue json){
		JSONValue authJson;
		JSONValue result = parseJSON(`{"successful": false, "message":""}`);
		bool isExistAuthData = false;
		if(json.object.keys.canFind("auth")){
			authJson = json["auth"];
			isExistAuthData = true;
		}
		switch(json["command"].str){
			case "open":
				if(!isExistAuthData){
					if(!ekeymgr.open()){
						result["message"] = "Key operation failure";
						result.object["key"] = ek.keyData();
						return result;
					}
					result["successful"] = true;
					result.object["key"] = ek.keyData();
					return result;
				}
				auto ad = ek.auth(authJson);
				if(ad is null){
					result["message"] = "Authentication failure";
					return result;
				}
				if(!ekeymgr.open(ad)){
					result["message"] = "Key operation failure";
					result.object["key"] = ek.keyData();
					return result;
				}
				result["successful"] = true;
				result.object["key"] = ek.keyData();
				return result;
			case "close":
				if(!isExistAuthData){
					if(!ekeymgr.close()){
						result["message"] = "Key operation failure";
						result.object["key"] = ek.keyData();
						return result;
					}
					result["successful"] = true;
					result.object["key"] = ek.keyData();
					return result;
				}
				auto ad = ek.auth(authJson);
				if(ad is null){
					result["message"] = "Authentication failure";
					return result;
				}
				if(!ekeymgr.close(ad)){
					result["message"] = "Key operation failure";
					result.object["key"] = ek.keyData();
					return result;
				}
				result["successful"] = true;
				result.object["key"] = ek.keyData();
				return result;
			case "toggle":
				if(!isExistAuthData){
					if(!ekeymgr.toggle()){
						result["message"] = "Key operation failure";
						result.object["key"] = ek.keyData();
						return result;
					}
					result["successful"] = true;
					result.object["key"] = ek.keyData();
					return result;
				}
				auto ad = ek.auth(authJson);
				if(ad is null){
					result["message"] = "Authentication failure";
					return result;
				}
				if(!ekeymgr.toggle(ad)){
					result["message"] = "Key operation failure";
					result.object["key"] = ek.keyData();
					return result;
				}
				result["successful"] = true;
				result.object["key"] = ek.keyData();
				return result;
			case "status":
				result["successful"] = true;
				result["message"] = "status:" ~ (ek.isOpen?"Open":"Close");
				result.object["key"] = ek.keyData();
				return result;
			case "stop":
				ek.infoLog("stopping daemon...");
				ekeymgr.stop();
				result["successful"] = true;
				result["message"] = "stopping daemon...";
				return result;
			default:
				result["message"] = "Unknown operation " ~ json["command"].str;
				return result;
		}
	}
}
