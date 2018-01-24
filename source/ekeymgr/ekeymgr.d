module ekeymgr.ekeymgr;
import core.thread;
public import ekeymgr.submodule;
public import locker = ekeymgr.locker.lockManager;
public import config = ekeymgr.config;

void start(){
	config.init();
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
	submodules ~= new SubmoduleThread(submodule);
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
private SubmoduleThread[] submodules;
private bool isRunning;
private void startSubmodule(){
	foreach(SubmoduleThread s; submodules){
		s.start();
	}
}
private void submoduleCheckRestart(){
	foreach(SubmoduleThread s; submodules){
		s.autoRestart();
	}
}
private void stopSubmodule(){
	foreach(SubmoduleThread s; submodules){
		s.stop();
	}
}
