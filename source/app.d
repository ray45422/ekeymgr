import std.stdio;
import std.string;
import std.getopt;

int main(string[] args)
{
	string versionString = "0.0.0";
	/*オプション処理*/
	bool versionFlag = false;
	bool userDaemonFlag = false;
	try{
		getopt(args,
			"v",&versionFlag,
			"version",&versionFlag,
			"user", &userDaemonFlag);
	}catch(GetOptException e){
		e.msg.writeln;
		return 1;
	}catch(std.conv.ConvException e){
		"Sorry. Please use single character options.".writeln;
		return 1;
	}
	if(versionFlag){
		("ekeymgr "~versionString).writeln;
		return 0;
	}
	/*各種処理開始*/
	if(args.length == 1){
		return 0;
	}
	switch(args[1]){
		case "daemon":
			if(!userDaemonFlag){
				import ekeymgr.systemdaemon;
				SystemDaemon systemdaemon = new SystemDaemon();
				systemdaemon.main();
			}else{
				import ekeymgr.userdaemon;
				UserDaemon userdaemon = new UserDaemon();
				userdaemon.main();
			}
			return 0;
		case "auth":
			if(args.length != 4){
				"Too few arguments.".writeln;
				return 1;
			}
			import ekeymgr.auth;
			Auth auth = new Auth();
			return auth.auth(args[2], args[3]);
		default:
			break;
	}
	{
		import std.socket;
		import core.time;
		auto name = "/run/ekeymgr.sock";
		auto address = new UnixAddress(name);
		auto socket = new Socket(AddressFamily.UNIX, SocketType.STREAM);
		socket.setOption(SocketOptionLevel.SOCKET, SocketOption.RCVTIMEO, dur!("seconds")(10));
		socket.setOption(SocketOptionLevel.SOCKET, SocketOption.SNDTIMEO, dur!("seconds")(10));
		socket.connect(address);
		scope(exit) socket.close;
		string str = args[1];
		for(int i = 2; i < args.length; ++i){
			str = str ~ " " ~ args[i];
		}
		socket.send(str);
		auto buf = new char[255];
		socket.receive(buf);
		if(format(buf) == "1"){
			"error".writeln;
			return 1;
		}
	}
	return 0;
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
