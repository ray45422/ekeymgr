module ekeymgr.auth;
import std.stdio;
import std.datetime;
import std.conv;
import mysql.d;

class Auth{
	Mysql mysql;
	this(){
		writeln("connecting database...");
		mysql = new Mysql("192.168.32.123",3306,"ekeymgr","ekeymgr","ekeymgr");
		writeln("connected");
	}
	byte auth(string service_name, string service_id){
		MysqlResult rows;
		try{
			rows = mysql.query("SELECT authdata.*, users.username, users.dispname FROM authdata, users WHERE users.user_id = authdata.user_id");
		}catch(MysqlDatabaseException e){
			e.msg.writeln;
			return 1;
		}
		foreach(MysqlRow auth; rows){
			//writefln("%s %s %s %s %s %s",auth["username"],auth["service_name"],auth["service_id"],auth["valid_flag"],auth["valid_count"],auth["valid_time"]);
			new AuthData(auth).write;
		}
		return 0;
	}
}
class AuthData{
	private int user_id;
	private string username;
	private string dispname;
	private string service_name;
	private string service_id;
	private bool valid_flag;
	private int valid_count;
	private string valid_time;
	this(MysqlRow result){
		user_id = result["user_id"].to!int;
		username = result["username"];
		dispname = result["dispname"];
		service_name = result["service_name"];
		service_id = result["service_id"];
		if(result["valid_flag"] == ""){
			valid_flag = false;
		}else{
			valid_flag = result["valid_flag"].to!int == 1;
		}
		if(result["valid_count"] == ""){
			valid_count = -1;
		}else{
			valid_count = result["valid_count"].to!int;
		}
		valid_time = result["valid_time"];
	}
	public void update(){
		if(valid_count == -1 || valid_count >0){
			valid_flag = true;
		}

	}
	public bool isValid(){
		return valid_flag;
	}
	public string getName(){
		return username;
	}
	public string getDispname(){
		return dispname;
	}
	public void write(){
		writefln("user_id: %s, username:%s, dispname:%s, service_name:%s, service_id:%s, valid_flag:%s, valid_count:%s, valid_time:%s",user_id,username,dispname,service_name,service_id,valid_flag,valid_count,valid_time);
	}
}
