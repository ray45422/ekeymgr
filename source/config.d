module ekeymgr.config;
import std.stdio;
import std.conv;
import std.file:exists;
import mysql.d;
import variantconfig;

private VariantConfig configs;
immutable string configFile = "/etc/ekeymgr/ekeymgr.conf";
shared string mySQLServerAddress;
shared uint mySQLServerPort;
shared string mySQLServerUserName;
shared string mySQLServerPassword;
shared string mySQLServerDatabase;
shared string ekeymgrServerAddress;
shared ushort ekeymgrServerPort;
shared uint room_id;
shared string room_name = "";

bool init(){
	auto a = cast(int)cast(ushort)1756;
	if(!exists(configFile)){
		"Config file does not exist".writeln;
	}
	configs.loadFile(configFile);
	mySQLServerAddress = load("mySQLServerAddress", "127.0.0.1");
	mySQLServerPort = load("mySQLServerPort", 3306);
	mySQLServerUserName = load("mySQLServerUserName", "ekeymgr");
	mySQLServerPassword = load("mySQLServerPassword", "ekeymgr");
	mySQLServerDatabase = load("mySQLServerDatabase", "ekeymgr");
	ekeymgrServerAddress = load("ekeymgrServerAddress", "localhost");
	ekeymgrServerPort = load("ekeymgrServerPort", "1756").to!ushort;
	room_id = load("room_id", 1);
	if(!getRoomName()){
		return false;
	}
	return true;
}

T load(T = string)(string key, const T defaultValue = T.init){
	configs.loadFile(configFile);
	return configs.get(key, defaultValue).coerce!T;
}

string room_id_str(){
	return room_id.to!string;
}

bool getRoomName(){
	Mysql mysql = new Mysql();
	mysql.setConnectTimeout(2);
	try{
		mysql.connect(mySQLServerAddress, mySQLServerPort, mySQLServerUserName, mySQLServerPassword, mySQLServerDatabase);
		auto rows = mysql.query("SELECT rooms.room_name FROM rooms WHERE rooms.room_id='" ~ room_id_str ~ "'");
		if(rows.length == 0){
			import std.stdio;
			("room_id:" ~ room_id_str ~ " was not found").writeln;
			return false;
		}
		room_name = rows.row["room_name"];
	}catch(MysqlDatabaseException e){
		e.msg.writeln;
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
		auto address = new InternetAddress(mySQLServerAddress, cast(ushort)mySQLServerPort);
		auto socket = new TcpSocket(AddressFamily.INET);
		socket.setOption(SocketOptionLevel.SOCKET, SocketOption.RCVTIMEO, dur!("seconds")(1));
		socket.setOption(SocketOptionLevel.SOCKET, SocketOption.SNDTIMEO, dur!("seconds")(1));
		try{
			socket.connect(address);
			selfAddress = socket.localAddress.toAddrString;
			socket.close();
		}catch(Exception e){
			e.msg.writeln;
			return false;
		}
	}
	Mysql mysql = new Mysql();
	mysql.setConnectTimeout(2);
	try{
		mysql.connect(mySQLServerAddress, mySQLServerPort, mySQLServerUserName, mySQLServerPassword, mySQLServerDatabase);
		auto rows = mysql.query("UPDATE rooms SET ip_address='" ~ selfAddress ~ "' WHERE rooms.room_id=" ~ room_id_str);
		rows.writeln;
	}catch(MysqlDatabaseException e){
		e.msg.writeln;
		return false;
	}
	return true;
}
