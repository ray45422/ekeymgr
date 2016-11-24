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
	VariantConfig configs = VariantConfig(configFile);
	mySQLServerAddress = configs.getValue("mySQLServerAddress", Variant("127.0.0.1")).toString;
	mySQLServerPort = configs.getValue("mySQLServerPort", Variant(3306)).toInt;
	mySQLServerUserName = configs.getValue("mySQLServerUserName", Variant("ekeymgr")).toString;
	mySQLServerPassword = configs.getValue("mySQLServerPassword", Variant("ekeymgr")).toString;
	mySQLServerDatabase = configs.getValue("mySQLServerDatabase", Variant("ekeymgr")).toString;
	room_id = configs.getValue("room_id", Variant(1)).toInt;
	if(!getRoomName()){
		return false;
	}
	return true;
}

Variant load(string key, Variant defaultValue = Variant(0)){
	VariantConfig configs = VariantConfig(configFile);
	return configs.getValue(key, defaultValue);
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
