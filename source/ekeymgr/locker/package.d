module ekeymgr.locker;
import ek = ekeymgr;
import ekeymgr.net.auth: AuthData;
import ekeymgr.submodule;

interface Locker{
	void setup();
	void stop();
	bool open();
	bool close();
	bool isOpen();
}
class LockManager{
public:
	void setLocker(Locker _locker){
		locker = _locker;
	}
	void setup(){
		locker.setup();
	}
	void stop(){
		locker.stop();
	}
	bool open(AuthData ad = null){
		return commandExec(Command.open, ad);
	}
	bool close(AuthData ad = null){
		return commandExec(Command.close, ad);
	}
	bool toggle(AuthData ad = null){
		return commandExec(Command.toggle, ad);
	}
	bool isOpen(){
		return locker.isOpen();
	}
private:
	Locker locker = new DefaultLocker();
	bool status = true;
	bool lock = false;
	static enum Command{
		open,
		close,
		toggle
	};
	bool commandExec(Command command, AuthData ad){
		if(lock){
			ek.debugLog("key is working now");
			return false;
		}
		lock = true;
		bool ret;
		switch(command){
			case Command.open:
				ret = locker.open();
				if(ret){
					onKeyEvent(ek.KeyEvent.KEY_OPEN, ad);
				}
				break;
			case Command.close:
				ret = locker.close();
				if(ret){
					onKeyEvent(ek.KeyEvent.KEY_CLOSE, ad);
				}
				break;
			case Command.toggle:
				lock = false;
				if(locker.isOpen){
					ret = commandExec(Command.close, ad);
				}else{
					ret = commandExec(Command.open, ad);
				}
				break;
			default:
				break;
		}
		lock = false;
		return ret;
	}
}
private class DefaultLocker: Locker{
	void setup(){
	}
	void stop(){
	}
	bool open(){
		return false;
	}
	bool close(){
		return false;
	}
	bool isOpen(){
		return false;
	}
}
