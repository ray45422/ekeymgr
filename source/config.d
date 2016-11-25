module ekeymgr.config;
import std.stdio;
import std.conv;
import std.file:exists;
import mysql.d;
import variantconfig;

immutable string configFile = "/etc/ekeymgr/ekeymgr.conf";
string mySQLServerAddress;
uint mySQLServerPort;
string mySQLServerUserName;
string mySQLServerPassword;
string mySQLServerDatabase;
uint room_id = 1;
string room_name = "";

bool init(){
	if(!exists(configFile)){
		"Config file does not exist".writeln;
	}
	VariantConfig configs;
	configs.loadFile(configFile);
	mySQLServerAddress = configs.get("mySQLServerAddress", "127.0.0.1").toString;
	mySQLServerPort = configs.get("mySQLServerPort", 3306).coerce!int;
	mySQLServerUserName = configs.get("mySQLServerUserName", "ekeymgr").toString;
	mySQLServerPassword = configs.get("mySQLServerPassword", "ekeymgr").toString;
	mySQLServerDatabase = configs.get("mySQLServerDatabase", "ekeymgr").toString;
	room_id = configs.get("room_id", 1).coerce!int;
	if(!getRoomName()){
		return false;
	}
	return true;
}

T load(T = string)(string key, const T defaultValue = T.init){
	VariantConfig configs;
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
