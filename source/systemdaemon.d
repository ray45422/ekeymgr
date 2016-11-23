module ekeymgr.systemdaemon;
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
		address = new UnixAddress(socket_name);
		socket = new Socket(AddressFamily.UNIX, SocketType.STREAM);
		if(exists(socket_name)){
			try{
				socket.connect(address);
			}catch(SocketOSException e){
				e.msg.writeln;
				("remove " ~ socket_name ~ " and binding socket...").writeln;
				if(e.errorCode == 111){
					remove(socket_name);
				}
			}
		}
		try{
			socket.bind(address);
		}catch(SocketOSException e){
			e.msg.writeln;
			exit(EXIT_FAILURE);
		}
		auto n = getAttributes(socket_name);
		setAttributes(socket_name, n | ((1<<9)-1));
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
		("listening on " ~ socket_name).writeln;
		scope(exit) socket.close();
		scope(exit) remove(socket_name);
		while(running){
			auto p = socket.accept;
			scope(exit) p.close();
			auto buf = new char[255];
			p.receive(buf);
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
	string socket_name = "/run/ekeymgr.sock";
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
					break;
				}
				f = &userdaemon.open;
				break;
			case "close":
				if(args.length < 4 && !auth(args)){
					break;
				}
				f = &userdaemon.close;
				break;
			case "toggle":
				if(args.length < 4 && !auth(args)){
					break;
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
			_auth.addLog(userdaemon.isLock);
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
