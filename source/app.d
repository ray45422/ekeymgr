import std.stdio;
import std.string;
import std.getopt;

int main(string[] args)
{
	string versionString = "0.0.0";
	/*オプション処理*/
	bool versionFlag = false;
	try{
		getopt(args,
			"v",&versionFlag,
			"version",&versionFlag);
	}catch(GetOptException e){
		e.msg.writeln;
		return 1;
	}catch(std.conv.ConvException e){
		"Sorry. Please use single character options.".writeln;
		return 1;
	}
	if(versionFlag){
		("ekeymgr "~versionString).writeln;
		return 0;
	}
	/*各種処理開始*/
	if(args.length == 1){
		return 0;
	}
	switch(args[1]){
		case "daemon":
			import ekeymgr.userdaemon;
			UserDaemon userdaemon = new UserDaemon();
			userdaemon.main();
			break;
		case "auth":
			if(args.length != 4){
				"Too few arguments.".writeln;
				return 1;
			}
			import ekeymgr.auth;
			Auth auth = new Auth();
			return auth.auth(args[2], args[3]);
		case "open":
			import ekeymgr.lockmanager;
			LockManager lockMan = new LockManager();
			if(!(args.length > 2 && auth(args))){
				break;
			}
			lockMan.open();
			break;
		case "close":
			import ekeymgr.lockmanager;
			LockManager lockMan = new LockManager();
			if(!(args.length > 2 && auth(args))){
				break;
			}
			lockMan.close();
			break;
		case "toggle":
			import ekeymgr.lockmanager;
			LockManager lockMan = new LockManager();
			if(!(args.length > 2 && auth(args))){
				break;
			}
			lockMan.toggle();
			break;
		default:
			break;
	}
	return 0;
}
bool auth(string[] args){
	if(args.length !=4){
		"Too few arguments.".writeln;
		return false;
	}
	import ekeymgr.auth;
	Auth auth = new Auth();
	return auth.auth(args[2], args[3]) != 0;
}
