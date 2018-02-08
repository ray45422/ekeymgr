module ekeymgr.net.client;
import ek = ekeymgr;
import std.stdio;
import std.string;
import std.json;

int connect(string command, string[] args, bool msgDump = false){
	import std.socket;
	import core.time;
	import std.array;
	auto address = new InternetAddress(ek.config.load("ekeymgrServerAddress"), ek.config.load!ushort("ekeymgrServerPort"));
	auto socket = new TcpSocket(AddressFamily.INET);
	socket.setOption(SocketOptionLevel.SOCKET, SocketOption.RCVTIMEO, dur!("seconds")(10));
	socket.setOption(SocketOptionLevel.SOCKET, SocketOption.SNDTIMEO, dur!("seconds")(10));
	try{
		socket.connect(address);
	}catch(SocketOSException e){
		ek.errorLog(e.msg);
		ek.infoLog("Run \'systemctl start ekeymgr.service\' or \'ekeymgr daemon\' as root.");
		return 1;
	}
	scope(exit) socket.close;
	socket.send(argsToJson(command, args).toString);
	auto buf = new char[255];
	socket.receive(buf);
	string jsonReceive = format(buf);
	if(jsonReceive.length == 0){
		return 1;
	}
	JSONValue result = parseJSON(jsonReceive);
	if(result["successful"].type == JSON_TYPE.FALSE){
		return 1;
	}
	auto msg = result["message"].str;
	if(msg.length != 0){
		msg.writeln;
	}
	return 0;
}
JSONValue argsToJson(string command, string[] args){
	import std.algorithm;
	import std.getopt;
	JSONValue jv;
	jv["command"] = command;
	switch(command){
		case "toggle":
		case "open":
		case "close":
			string[string] auth;
			bool isServiceId = false;
			args = "dummy" ~ args;
			getopt(args, config.passThrough, "service-id-auth", &isServiceId);
			args = args[1..$];
			int n = 0;
			foreach(arg; args){
				if(!args.startsWith("-")){
					n++;
				}
			}
			if(n < 2){
				break;
			}
			for(int i = 0; i < args.length; i++){
				string arg = args[i];
				if(arg.startsWith("-")){
					continue;
				}
				if(auth.length == 1){
					auth["id"] = arg;
					args = args.remove(i);
					i--;
					jv.object["auth"] = auth;
					break;
				}
				if(auth.length == 0){
					if(isServiceId){
						auth["service"] = arg;
					}else{
						auth["user"] = arg;
					}
					args = args.remove(i);
					i--;
					continue;
				}
			}
			break;
		default:
			break;
	}
	if(args.length != 0){
		jv.object["args"] = args;
	}
	return jv;
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
