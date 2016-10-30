module ekeymgr.systemdaemon;
import ekeymgr.userdaemon;
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
			p.send(exec(args)?"0":"1");
		}
	}
private:
	string socket_name = "/run/ekeymgr.sock";
	Address address;
	Socket socket;
	bool running = true;
	UserDaemon userdaemon;
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
	bool exec(string[] args){
		auto f = &stop;
		f = null;
		switch(args[0]){
			case "open":
				if(args.length > 1 && !auth(args)){
					break;
				}
				f = &userdaemon.open;
				break;
			case "close":
				if(args.length > 1 && !auth(args)){
					break;
				}
				f = &userdaemon.close;
				break;
			case "toggle":
				if(args.length > 1 && !auth(args)){
					break;
				}
				f = &userdaemon.toggle;
				break;
			case "stop":
				stop();
				return true;
			default:
				break;
		}
		if(f is null){
			return false;
		}else{
			Thread t = new Thread(f);
			t.start();
			return true;
		}
	}
	void stop(){
		running = false;
		userdaemon.stop;
	}
	bool auth(string[] args){
		if(args.length != 3){
			return false;
		}
		import ekeymgr.auth;
		Auth auth = new Auth();
		return auth.auth(args[1], args[2]) == 0;
	}
}
