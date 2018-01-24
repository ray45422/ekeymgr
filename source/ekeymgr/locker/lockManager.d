module ekeymgr.locker.lockManager;
import ekeymgr.locker;

void setLocker(Locker _locker){
	locker = _locker;
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

private __gshared Locker locker = new DefaultLocker();
private bool status = true;
private bool lock = false;
private enum Command{
	open,
	close,
	toggle
};
private bool commandExec(Command command){
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