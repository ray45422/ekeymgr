import ek = ekeymgr;
import ekeymgr.cli;
import ekeymgr.submodule;
import ekeymgr.locker;
import ekeymgr.net.auth;
import std.stdio;

class JTalkModule: Submodule{
	void main(){
	}
	void stop(){
	}
	bool isAutoRestart(){
		return false;
	}
	string name(){
		return "JTalk";
	}
	void onKeyEvent(ek.KeyEvent ek, AuthData ad){
	}
}

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
