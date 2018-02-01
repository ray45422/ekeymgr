module ekeymgr.config;
import std.stdio;
import std.conv;
import std.file:exists;
import mysql.d;

immutable string configFile = "/etc/ekeymgr/ekeymgr.conf";
private class Config{
	this(){
		import properd;
		conf = readProperties(configFile);
	}
	private string[string] conf;
	void set(T = string)(string key, T value){
		this.conf[key] = value.to!string;
	}
	T get(T = string)(string key, const T defaultValue = T.init){
		return conf[key].to!T;
	}
}
private Config configs(){
	import std.concurrency: initOnce;
	static __gshared Config conf;
	return initOnce!conf(new Config());
}

bool init(){
	if(!exists(configFile)){
		stderr.writeln("Config file does not exist");
	}
	if(!getRoomName()){
		return false;
	}
	return true;
}

T load(T = string)(string key, const T defaultValue = T.init){
	return configs.get(key,defaultValue);
}
void set(T = string)(string key, T value){
	configs.set(key, value);
}

bool getRoomName(){
	string room_id = load("room_id");
	Mysql mysql = new Mysql();
	mysql.setConnectTimeout(2);
	try{
		mysql.connect(load("mySQLServerAddress"), load!ushort("mySQLServerPort"), load("mySQLServerUserName"), load("mySQLServerPassword"), load("mySQLServerDatabase"));
		auto rows = mysql.query("SELECT rooms.room_name FROM rooms WHERE rooms.room_id='" ~ room_id ~ "'");
		if(rows.length == 0){
			import std.stdio;
			stderr.writeln("room_id:" ~ room_id ~ " was not found");
			return false;
		}
		configs.set("room_name", rows.row["room_name"].dup);
	}catch(MysqlDatabaseException e){
		stderr.writeln(e.msg);
		return false;
	}
	return true;
}
bool setRoomIPAddress(bool isClose){
	string selfAddress;
	if(isClose){
		selfAddress = "NULL";
	}else{
		import std.socket;
		import core.time;
		auto address = new InternetAddress(load("mySQLServerAddress"), load!ushort("mySQLServerPort"));
		auto socket = new TcpSocket(AddressFamily.INET);
		socket.setOption(SocketOptionLevel.SOCKET, SocketOption.RCVTIMEO, dur!("seconds")(1));
		socket.setOption(SocketOptionLevel.SOCKET, SocketOption.SNDTIMEO, dur!("seconds")(1));
		try{
			socket.connect(address);
			selfAddress = socket.localAddress.toAddrString;
			socket.close();
		}catch(Exception e){
			stderr.writeln(e.msg);
			return false;
		}
	}
	Mysql mysql = new Mysql();
	mysql.setConnectTimeout(2);
	try{
		mysql.connect(load("mySQLServerAddress"), load!ushort("mySQLServerPort"), load("mySQLServerUserName"), load("mySQLServerPassword"), load("mySQLServerDatabase"));
		auto rows = mysql.query("UPDATE rooms SET ip_address='" ~ selfAddress ~ "' WHERE rooms.room_id=" ~ load("room_id"));
		stdout.flush;
	}catch(MysqlDatabaseException e){
		stderr.writeln(e.msg);
		return false;
	}
	return true;
}
