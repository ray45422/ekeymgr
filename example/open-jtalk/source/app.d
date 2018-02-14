import ek = ekeymgr;
import openjtalk.jtalk;
import ekeymgr.locker;
import ekeymgr.cli;
import std.stdio;

class LockerTest: Locker{
	void setup(){
	}
	void stop(){
	}
	bool open(){
		_isOpen = true;
		return true;
	}
	bool close(){
		_isOpen = false;
		return true;
	}
	bool isOpen(){
		return true;
	}
private:
	bool _isOpen = true;
}
int main(string[] args){
	ek.submoduleAdd(new JTalkModule());
	ek.setLocker(new LockerTest());
	return runCommandLine(args);
}
