module ekeymgr.auth;
import std.stdio;
import std.datetime;
import std.conv;
import mysql.d;

class Auth{
	Mysql mysql;
	AuthData lastAuthData;
	this(){
		writeln("connecting database...");
		mysql = new Mysql();
		mysql.setConnectTimeout(2);
		try{
			mysql.connect("127.0.0.1",3306,"ekeymgr","ekeymgr","ekeymgr");
		}catch(MysqlDatabaseException e){
			import std.stdio;
			import core.stdc.stdlib;
			e.msg.writeln;
			exit(EXIT_FAILURE);
		}
		writeln("connected");
	}
	byte auth(string service_name, string service_id){
		MysqlResult rows;
		try{
			rows = mysql.query("SELECT services.*, authdata.*, users.* FROM authdata, services, users WHERE services.service_id=authdata.service_id AND services.service_name=\'" ~ service_name ~ "\' AND authdata.id=\'" ~ service_id ~ "\' AND authdata.user_id = users.user_id");
		}catch(MysqlDatabaseException e){
			e.msg.writeln;
			return 1;
		}
		foreach(MysqlRow auth; rows){
			//writefln("%s %s %s %s %s %s",auth["user_name"],auth["service_name"],auth["service_id"],auth["valid_flag"],auth["valid_count"],auth["valid_time"]);
			//new AuthData(auth).write;
			//writefln("%s %s",auth["id"],auth["service_name"]);
		}
		if(rows.length != 1){
			return 64;//合致するIDが見つからない
		}
		lastAuthData = new AuthData(rows.row);
		return 0;//合致するIDが見つかった
	}
	AuthData getLastAuthData(){
		return lastAuthData;
	}
}
class AuthData{
	private int user_id;
	private string user_name;
	private string disp_name;
	private string service_name;
	private string service_id;
	private bool valid_flag;
	private int valid_count;
	private string valid_time;
	this(MysqlRow result){
		user_id = result["user_id"].to!int;
		user_name = result["user_name"];
		disp_name = result["disp_name"];
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
		return user_name;
	}
	public string getDispname(){
		return disp_name;
	}
	public void write(){
		writefln("user_id: %s, username:%s, dispname:%s, service_name:%s, service_id:%s, valid_flag:%s, valid_count:%s, valid_time:%s",user_id,user_name,disp_name,service_name,service_id,valid_flag,valid_count,valid_time);
	}
}
