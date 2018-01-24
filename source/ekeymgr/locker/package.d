module ekeymgr.locker;

interface Locker{
	bool open();
	bool close();
	bool isOpen();
}
class DefaultLocker: Locker{
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
