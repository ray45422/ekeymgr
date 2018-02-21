module ekeymgr.submodule;
public import ekeymgr.submodule.TCPServer;
import core.thread;
import std.concurrency: initOnce;
import ekeymgr.cli.log;

interface Submodule{
public:
	void main();
	void stop();
	bool isAutoRestart();
	string name();
}

void submoduleAdd(Submodule submodule){
	submodules.add(new SubmoduleThread(submodule));
}

void startSubmodule(){
	foreach(ref s; submodules.original){
		debugLog("start submodule:", s.name);
		s.start();
	}
	isRunning = true;
	while(isRunning){
		submoduleCheckRestart();
		Thread.sleep(dur!("seconds")(1));
	}
}
public void stopSubmodule(){
	isRunning = false;
	foreach(ref s; submodules.original){
		debugLog("stop submodule:", s.name);
		s.stop();
	}
}

extern(C) nothrow @system @nogc
public void sigStop(int signal){
	isRunning = false;
}

private __gshared bool isRunning;
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
		if(!this.isRunning && submodule.isAutoRestart){
			debugLog("restart submodule:", submodule.name);
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
private void submoduleCheckRestart(){
	foreach(ref s; submodules.original){
		s.autoRestart();
	}
}
