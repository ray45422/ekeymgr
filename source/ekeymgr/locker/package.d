module ekeymgr.locker;

interface Locker{
	void setup();
	void stop();
	bool open();
	bool close();
	bool isOpen();
}
class DefaultLocker: Locker{
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
	bool open(){
		return commandExec(Command.open);
	}
	bool close(){
		return commandExec(Command.close);
	}
	bool toggle(){
		return commandExec(Command.toggle);
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
	bool commandExec(Command command){
		if(lock){
			return false;
		}
		lock = true;
		bool ret;
		switch(command){
			case Command.open:
				ret = locker.open();
				break;
			case Command.close:
				ret = locker.close();
				break;
			case Command.toggle:
				if(locker.isOpen){
					ret = locker.close();
				}else{
					ret = locker.open();
				}
				break;
			default:
				break;
		}
		lock = false;
		return ret;
	}
}
