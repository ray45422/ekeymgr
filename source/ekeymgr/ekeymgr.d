module ekeymgr.ekeymgr;
import core.thread;
public import ekeymgr.submodule;
public import locker = ekeymgr.locker.lockManager;
public import config = ekeymgr.config;

void start(){
	config.init();
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

bool open(){
	return locker.open();
}
bool close(){
	return locker.close();
}
bool toggle(){
	return locker.open();
}

void submoduleAdd(Submodule submodule){
	submodules.add(new SubmoduleThread(submodule));
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
	import std.concurrency: initOnce;
	static __gshared Submodules sub;
	return initOnce!sub(new Submodules);
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
