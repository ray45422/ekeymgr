module ekeymgr.auth;
import std.stdio;
import std.datetime;
import std.conv;
import mysql.d;

class Auth{
public:
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
	byte auth(string service_name, string id){
		MysqlResult rows;
		try{
			//rows = mysql.query("SELECT services.*, authdata.*, users.* FROM authdata, services, users WHERE services.service_id=authdata.service_id AND services.service_name=\'" ~ service_name ~ "\' AND authdata.id=\'" ~ service_id ~ "\' AND authdata.user_id = users.user_id AND valid_flag = \'1\'");
			rows = mysql.query("SELECT users.user_id,users.user_name,users.disp_name,
				authdata.id,authdata.auth_id,
				services.service_name,services.service_id,
				rooms.room_id,
				available_count.count,
				validated_timestamp.timestamp,
				validated_timestamp_scheduled.days,validated_timestamp_scheduled.start_hours,validated_timestamp_scheduled.end_hours
				FROM rooms
				LEFT JOIN rooms_users ON (rooms.room_id=rooms_users.room_id)
				JOIN authdata ON (rooms_users.user_id=authdata.user_id)
				LEFT JOIN (users,services)
					ON (authdata.user_id=users.user_id AND authdata.service_id=services.service_id)
				LEFT JOIN (available_count,auth_count)
					ON (authdata.auth_id=auth_count.auth_id AND available_count.count_id=auth_count.count_id)
				LEFT JOIN (validated_timestamp,auth_timestamp)
					ON (authdata.auth_id=auth_timestamp.auth_id AND validated_timestamp.timestamp_id=auth_timestamp.timestamp_id)
				LEFT JOIN (validated_timestamp_scheduled,auth_timestamp_scheduled)
					ON (authdata.auth_id=auth_timestamp_scheduled.auth_id AND validated_timestamp_scheduled.timestamp_scheduled_id=auth_timestamp_scheduled.timestamp_scheduled_id) "~
				"WHERE services.service_name='" ~ service_name ~ "' AND authdata.id='" ~ id ~ "' AND authdata.valid_flag=1"
			);
		}catch(MysqlDatabaseException e){
			e.msg.writeln;
			_isSuccess = false;
			return 1;
		}
		if(rows.length != 1){
			_isSuccess = false;
			addFailLog(service_name, id);
			return 64;//合致するIDが見つからない
		}
		lastAuthData = new AuthData(rows.row);
		//lastAuthData.write();
		_isSuccess = true;
		return 0;//合致するIDが見つかった
	}
	AuthData getLastAuthData(){
		return lastAuthData;
	}
	bool addLog(bool isLock){
		if(lastAuthData is null){
			return false;
		}
		string auth_id = lastAuthData.auth_id;
		string room_id = lastAuthData.room_id;
		string is_lock = isLock?"1":"0";
		try{
			mysql.query("INSERT INTO `logs` (`log_id`, `time`, `auth_id`, `room_id`, `is_lock`) VALUES (NULL, CURRENT_TIMESTAMP, '" ~ auth_id ~ "', '" ~ room_id ~ "','" ~ is_lock ~ "')");
		}catch(MysqlDatabaseException e){
			e.msg.writeln;
			return false;
		}
		return true;
	}
	bool isSuccess(){
		return _isSuccess;
	}
private:
	Mysql mysql;
	AuthData lastAuthData;
	bool _isSuccess;
	bool addFailLog(string service_name,string id){
		try{
			auto rows = mysql.query("SELECT services.service_id FROM services WHERE services.service_name='" ~ service_name ~ "'");
			string service_id = rows.row["service_id"];
			mysql.query("INSERT INTO `fail_logs` (`log_id`,`time`,`service_id`,`id`) VALUES(NULL,CURRENT_TIMESTAMP,'" ~ service_id ~ "','" ~ id ~ "')");
		}catch(MysqlDatabaseException e){
			e.msg.writeln;
			return false;
		}
		return true;
	}
}
class AuthData{
public:
	this(MysqlRow result){
		user_id = result["user_id"];
		user_name = result["user_name"];
		disp_name = result["disp_name"];
		auth_id = result["auth_id"];
		room_id = result["room_id"];
		id = result["id"];
		service_name = result["service_name"];
		service_id = result["service_id"];
		count = result["count"];
	}
	void update(){
		if(count == ""){
			/*回数更新処理*/
		}
	}
	string getName(){
		return user_name;
	}
	string getDispname(){
		return disp_name;
	}
	void write(){
		writefln("user_id: %s, user_name:%s, disp_name:%s, auth_id:%s, room_id:%s, id:%s, service_name:%s, service_id:%s, count:%s",
			user_id,
			user_name,
			disp_name,
			auth_id,
			room_id,
			id,
			service_name,
			service_id,
			count);
	}
private:
	string user_id;
	string user_name;
	string disp_name;
	string auth_id;
	string room_id;
	string id;
	string service_name;
	string service_id;
	string count;
}
