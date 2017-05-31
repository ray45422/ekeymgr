module ekeymgr.auth;
static import config = ekeymgr.config;
import std.stdio;
import std.datetime;
import std.conv;
import mysql.d;

class Auth{
public:
	this(){
		writeln("connecting database...");
		stdout.flush;
		mysql = new Mysql();
		mysql.setConnectTimeout(2);
		try{
			mysql.connect(config.mySQLServerAddress, config.mySQLServerPort, config.mySQLServerUserName, config.mySQLServerPassword, config.mySQLServerDatabase);
		}catch(MysqlDatabaseException e){
			import std.stdio;
			import core.stdc.stdlib;
			stderr.writeln(e.msg);
			exit(EXIT_FAILURE);
		}
		writeln("connected");
		stdout.flush;
	}
	byte authServiceId(string service_name, string id){
		byte ret = auth(AuthType.ServiceId, service_name, id);
		if(ret == 64){
			addFailLog(service_name, id);
		}
		return ret;
	}
	byte authUserId(string user, string id){
		return auth(AuthType.UserId, user, id);
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
			stderr.writeln(e.msg);
			return false;
		}
		return true;
	}
	bool isSuccess(){
		return _isSuccess;
	}
private:
	const static string SQLselect = "SELECT users.user_id,users.user_name,users.disp_name,
		authdata.id,authdata.auth_id,
		services.service_name,services.service_id,
		rooms.room_id,
		validated_timestamp.timestamp,
		validated_timestamp_scheduled.days,validated_timestamp_scheduled.start_time,validated_timestamp_scheduled.end_time ";
	const static string SQLjoin = "FROM rooms
		LEFT JOIN rooms_users ON (rooms.room_id=rooms_users.room_id)
		JOIN authdata ON (rooms_users.user_id=authdata.user_id)
		LEFT JOIN (users,services)
			ON (authdata.user_id=users.user_id AND authdata.service_id=services.service_id)
		LEFT JOIN (validated_timestamp,auth_timestamp)
			ON (authdata.auth_id=auth_timestamp.auth_id AND validated_timestamp.timestamp_id=auth_timestamp.timestamp_id)
		LEFT JOIN (validated_timestamp_scheduled,auth_timestamp_scheduled)
			ON (authdata.auth_id=auth_timestamp_scheduled.auth_id AND validated_timestamp_scheduled.timestamp_scheduled_id=auth_timestamp_scheduled.timestamp_scheduled_id) ";
	const static string SQLjoinGroup = "FROM rooms
		LEFT JOIN rooms_groups ON (rooms_groups.room_id=rooms.room_id)
		LEFT JOIN groups_users ON (rooms_groups.group_id=groups_users.group_id)
		JOIN authdata ON (groups_users.user_id=authdata.user_id)
		LEFT JOIN (users,services)
			ON (authdata.user_id=users.user_id AND authdata.service_id=services.service_id)
		LEFT JOIN (validated_timestamp,auth_timestamp)
			ON (authdata.auth_id=auth_timestamp.auth_id AND validated_timestamp.timestamp_id=auth_timestamp.timestamp_id)
		LEFT JOIN (validated_timestamp_scheduled,auth_timestamp_scheduled)
			ON (authdata.auth_id=auth_timestamp_scheduled.auth_id AND validated_timestamp_scheduled.timestamp_scheduled_id=auth_timestamp_scheduled.timestamp_scheduled_id) ";
	const static string SQLwherePre = "WHERE (
			(validated_timestamp.timestamp IS NULL AND validated_timestamp_scheduled.days IS NULL) OR
			(validated_timestamp.timestamp>=TIMESTAMP(NOW()))
			OR (validated_timestamp_scheduled.days LIKE CONCAT('%',DAYOFWEEK(NOW()),'%') AND validated_timestamp_scheduled.start_time<=TIME(NOW()) AND validated_timestamp_scheduled.end_time>=TIME(NOW())))AND ";
	Mysql mysql;
	AuthData lastAuthData;
	bool _isSuccess;
	enum AuthType{
		UserId,
		ServiceId
	}
	byte auth(AuthType type, string name, string id){
		MysqlResult rows;
		string SQLwhere;
		switch(type){
			case AuthType.UserId:
				//SQLwhere = " authdata.user_id='" ~ user ~ "' AND authdata.id='" ~ id ~ "'";
				SQLwhere = " authdata.user_id='" ~ name ~ "'";
				break;
			case AuthType.ServiceId:
				//SQLwhere = " services.service_name='" ~ service_name ~ "' AND authdata.id='" ~ id ~ "'";
				SQLwhere = " services.service_name='" ~ name ~ "'";
				break;
			default:
				break;
		}

		//normal authentication
		try{
			rows = inquery(SQLselect ~ SQLjoin ~ SQLwherePre ~ SQLwhere ~
				" AND authdata.valid_flag=1 AND rooms.room_id='" ~ config.room_id_str ~ "'"
			);
		}catch(MysqlDatabaseException e){
			return 1;
		}
		if(rows.length != 0){
			if(idMatch(rows, id)){
				return 0;
			}
		}

		//group authentication
		try{
			rows = inquery(SQLselect ~ SQLjoinGroup ~ SQLwherePre ~ SQLwhere ~
				" AND authdata.valid_flag=1 AND rooms.room_id='" ~ config.room_id_str ~ "'"
			);
		}catch(MysqlDatabaseException e){
			return 1;
		}
		if(rows.length != 0){
			if(idMatch(rows, id)){
				return 0;
			}
		}
		//match IDs not found
		_isSuccess = false;
		return 64;
	}
	bool idMatch(MysqlResult rows, string id){
		import ekeymgr.cipher;
		auto hash = new Hash(id);
		id = hash.generate;
		foreach(MysqlRow row; rows){
			if(row["id"] == id){
				record(new AuthData(row));
				return true;
			}
		}
		return false;
	}
	MysqlResult inquery(string statement){
		MysqlResult rows;
		try{
			rows = mysql.query(statement);
		}catch(MysqlDatabaseException e){
			stderr.writeln(e.msg);
			_isSuccess = false;
			throw e;
		}
		return rows;
	}
	void record(AuthData data){
		lastAuthData = data;
		_isSuccess = true;
	}
	bool addFailLog(string service_name,string id){
		try{
			auto rows = mysql.query("SELECT services.service_id FROM services WHERE services.service_name='" ~ service_name ~ "'");
			if(rows.length == 0){
				return false;
			}
			string service_id = rows.row["service_id"];
			mysql.query("INSERT INTO `fail_logs` (`log_id`,`time`,`service_id`,`id`,`room_id`) VALUES(NULL,CURRENT_TIMESTAMP,'" ~ service_id ~ "','" ~ id ~ "','" ~ config.room_id_str ~ "')");
		}catch(MysqlDatabaseException e){
			stderr.writeln(e.msg);
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
	}
	string getName(){
		return user_name;
	}
	string getDispname(){
		return disp_name;
	}
	void write(){
		writefln("user_id: %s, user_name:%s, disp_name:%s, auth_id:%s, room_id:%s, id:%s, service_name:%s, service_id:%s",
			user_id,
			user_name,
			disp_name,
			auth_id,
			room_id,
			id,
			service_name,
			service_id);
		stdout.flush;
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
}
