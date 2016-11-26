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
shared uint room_id;
shared string room_name = "";

bool init(){
	if(!exists(configFile)){
		"Config file does not exist".writeln;
	}
	configs.loadFile(configFile);
	mySQLServerAddress = load("mySQLServerAddress", "127.0.0.1");
	mySQLServerPort = load("mySQLServerPort", 3306);
	mySQLServerUserName = load("mySQLServerUserName", "ekeymgr");
	mySQLServerPassword = load("mySQLServerPassword", "ekeymgr");
	mySQLServerDatabase = load("mySQLServerDatabase", "ekeymgr");
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
		import std.stdio;
		e.msg.writeln;
		return false;
	}
	return true;
}
