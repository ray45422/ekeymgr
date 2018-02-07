module ekeymgr.ekeymgr;
import core.thread;
import std.concurrency: initOnce;
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
	addLog(ad);
	return open();
}
bool close(){
	return lockManager.close();
}
bool close(AuthData ad){
	addLog(ad);
	return close();
}
bool toggle(){
	return lockManager.toggle();
}
bool toggle(AuthData ad){
	addLog(ad);
	return toggle();
}
bool isOpen(){
	return lockManager.isOpen();
}
AuthData authServiceId(string service, string id){
	Auth auth = new Auth();
	int ret = auth.authServiceId(service, id);
	if(ret != 0){
		return null;
	}
	return auth.getLastAuthData;
}

private LockManager lockManager(){
	static __gshared LockManager lm;
	return initOnce!lm(new LockManager());
}
