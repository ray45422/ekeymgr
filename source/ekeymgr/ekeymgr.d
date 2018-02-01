module ekeymgr.ekeymgr;
import core.thread;
import std.concurrency: initOnce;
import ekeymgr.locker;
import ekeymgr.submodule;
import config = ekeymgr.config;

void start(){
	config.init();
	lockManager.setup();
	submoduleAdd(new ekeymgr.submodule.TCPServer.TCPServer());
	startSubmodule();
	isRunning = true;
	while(isRunning){
		submoduleCheckRestart();
		Thread.sleep(dur!"seconds"(1));
	}
	stopSubmodule();
}
void stop(){
	isRunning = false;
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
	return lockManager.open();
}
bool isOpen(){
	return lockManager.isOpen();
}

void submoduleAdd(Submodule submodule){
	submodules.add(new SubmoduleThread(submodule));
}
private LockManager lockManager(){
	static __gshared LockManager lm;
	return initOnce!lm(new LockManager());
}
private class SubmoduleThread: Thread{
	Submodule submodule;
	this(Submodule submodule){
		this.submodule = submodule;
		super(&submodule.main);
	}
	void stop(){
		submodule.stop();
	}
	void autoRestart(){
		if(!this.isRunning){
			this.start();
		}
	}
}
private class Submodules{
	private SubmoduleThread[] submodules;
	ref SubmoduleThread[] original(){
		return submodules;
	}
	void add(SubmoduleThread t){
		submodules ~= t;
	}
}
private Submodules submodules(){
	static __gshared Submodules sub;
	return initOnce!sub(new Submodules());
}

private __gshared bool isRunning;
private void startSubmodule(){
	foreach(ref s; submodules.original){
		s.start();
	}
}
private void submoduleCheckRestart(){
	foreach(ref s; submodules.original){
		s.autoRestart();
	}
}
private void stopSubmodule(){
	foreach(ref s; submodules.original){
		s.stop();
	}
}
