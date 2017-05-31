module ekeymgr.client;
static import config = ekeymgr.config;
import std.stdio;
import std.string;

int connect(string[] args){
	import std.socket;
	import core.time;
	import std.array;
	auto address = new InternetAddress(config.ekeymgrServerAddress, config.ekeymgrServerPort);
	auto socket = new TcpSocket(AddressFamily.INET);
	socket.setOption(SocketOptionLevel.SOCKET, SocketOption.RCVTIMEO, dur!("seconds")(10));
	socket.setOption(SocketOptionLevel.SOCKET, SocketOption.SNDTIMEO, dur!("seconds")(10));
	try{
		socket.connect(address);
	}catch(SocketOSException e){
		stderr.writeln(e.msg);
		stderr.writeln("Run \'systemctl start ekeymgr.service\' or \'ekeymgr daemon\' as root.");
		return 1;
	}
	scope(exit) socket.close;
	string str = args[1];
	for(int i = 2; i < args.length; ++i){
		str = str ~ " " ~ args[i];
	}
	socket.send(str);
	auto buf = new char[255];
	socket.receive(buf);
	string[] receive = format(buf).split('\n');
	if(receive.length == 0){
		return 1;
	}else{
		string code = receive[0];
		receive = receive[1..receive.length];
		foreach(msg ; receive){
			msg.writeln;
			stdout.flush;
		}
		if(code != "0"){
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
