module ekeymgr.ekeymgr;
import core.thread;
import std.concurrency: initOnce;
import std.json;
import std.algorithm: canFind;
import ekeymgr.locker;
import ekeymgr.net.auth;
import ekeymgr.submodule;
import ekeymgr.cli.log;
import config = ekeymgr.config;

void start(){
	config.init();
	lockManager.setup();
	submoduleAdd(new ekeymgr.submodule.TCPServer.TCPServer());
	startSubmodule();
	stopSubmodule();
	lockManager.stop();
}
void stop(){
	stopSubmodule;
}
void setLocker(Locker l){
	lockManager.setLocker(l);
}
bool open(){
	return lockManager.open();
}
bool open(AuthData ad){
	bool ret = lockManager.open(ad);
	if(!ret){
		return ret;
	}
	addLog(ad);
	return ret;
}
bool close(){
	return lockManager.close();
}
bool close(AuthData ad){
	bool ret = lockManager.close(ad);
	if(!ret){
		return ret;
	}
	addLog(ad);
	return ret;
}
bool toggle(){
	return lockManager.toggle();
}
bool toggle(AuthData ad){
	bool ret = lockManager.toggle(ad);
	if(!ret){
		return ret;
	}
	addLog(ad);
	return ret;
}
bool isOpen(){
	return lockManager.isOpen();
}
JSONValue keyData(){
	JSONValue jv = ["isOpen": isOpen];
	jv.object["roomName"] = config.load("roomName", "");
	jv.object["roomID"] = config.load!int("room_id");
	return jv;
}
AuthData auth(JSONValue jsonAuth){
	string[] keys = jsonAuth.object.keys;
	if(keys.canFind("user") && keys.canFind("id")){
		string user = jsonAuth["user"].str;
		string id = jsonAuth["id"].str;
		return authUserId(user, id);
	}
	if(keys.canFind("service") && keys.canFind("id")){
		string service = jsonAuth["service"].str;
		string id = jsonAuth["id"].str;
		return authServiceId(service, id);
	}
	return null;
}
AuthData authServiceId(string service, string id){
	Auth auth = new Auth();
	int ret = auth.authServiceId(service, id);
	if(ret != 0){
		return null;
	}
	return auth.getLastAuthData;
}
AuthData authUserId(string user, string id){
	Auth auth = new Auth();
	int ret = auth.authUserId(user, id);
	if(ret != 0){
		return null;
	}
	return auth.getLastAuthData;
}

private LockManager lockManager(){
	static __gshared LockManager lm;
	return initOnce!lm(new LockManager());
}
