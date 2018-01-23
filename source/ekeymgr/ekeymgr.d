module ekeymgr.ekeymgr;
import core.thread;
import ekeymgr.submodule;

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
void start(){
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
void submoduleAdd(Submodule submodule){
	submodules[] = new SubmoduleThread(submodule);
}
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
