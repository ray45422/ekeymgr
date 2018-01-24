module ekeymgr.config;
import std.stdio;
import std.conv;
import std.file:exists;
import mysql.d;
import properd;

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
private string[string] configs;

bool init(){
	if(!exists(configFile)){
		stderr.writeln("Config file does not exist");
	}
	static string[string] conf;
	configs = readProperties(configFile);
	mySQLServerAddress = configs.as!string("mySQLServerAddress", "127.0.0.1");
	mySQLServerPort = configs.as!uint("mySQLServerPort", 3306);
	mySQLServerUserName = configs.as!string("mySQLServerUserName", "ekeymgr");
	mySQLServerPassword = configs.as!string("mySQLServerPassword", "ekeymgr");
	mySQLServerDatabase = configs.as!string("mySQLServerDatabase", "ekeymgr");
	ekeymgrServerAddress = configs.as!string("ekeymgrServerAddress", "localhost");
	ekeymgrServerPort = configs.as!ushort("ekeymgrServerPort", 1756);
	room_id = configs.as!uint("room_id", 1);
	if(!getRoomName()){
		return false;
	}
	return true;
}

T load(T = string)(string key, const T defaultValue = T.init){
	return configs.as!T(key, defaultValue);
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
			stderr.writeln("room_id:" ~ room_id_str ~ " was not found");
			return false;
		}
		room_name = rows.row["room_name"].dup;
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
		auto address = new InternetAddress(mySQLServerAddress, cast(ushort)mySQLServerPort);
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
		mysql.connect(mySQLServerAddress, mySQLServerPort, mySQLServerUserName, mySQLServerPassword, mySQLServerDatabase);
		auto rows = mysql.query("UPDATE rooms SET ip_address='" ~ selfAddress ~ "' WHERE rooms.room_id=" ~ room_id_str);
		rows.writeln;
		stdout.flush;
	}catch(MysqlDatabaseException e){
		stderr.writeln(e.msg);
		return false;
	}
	return true;
}
