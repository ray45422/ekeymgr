module ekeymgr.ekeymgr;
import core.thread;
import std.concurrency: initOnce;
import ekeymgr.locker;
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
bool close(){
	return lockManager.close();
}
bool toggle(){
	return lockManager.toggle();
}
bool isOpen(){
	return lockManager.isOpen();
}

private LockManager lockManager(){
	static __gshared LockManager lm;
	return initOnce!lm(new LockManager());
}
