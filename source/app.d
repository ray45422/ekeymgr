static import config = ekeymgr.config;
import std.stdio;
import std.getopt;

int main(string[] args)
{
	string versionString = "0.0.0";
	/*オプション処理*/
	bool versionFlag = false;
	bool userDaemonFlag = false;
	bool serviceIdAuthFlag = false;
	try{
		getopt(args,
			"v",&versionFlag,
			"version",&versionFlag,
			"user", &userDaemonFlag,
			"service-id-auth", &serviceIdAuthFlag);
	}catch(GetOptException e){
		stderr.writeln(e.msg);
		return 1;
	}catch(std.conv.ConvException e){
		"Sorry. Please use single character options.".writeln;
		return 1;
	}
	if(versionFlag){
		("ekeymgr "~versionString).writeln;
		stdout.flush;
		return 0;
	}
	/*各種処理開始*/
	if(args.length == 1){
		return 0;
	}
	if(!config.init()){
		"Setup failed".writeln;
		stdout.flush;
		return 1;
	}
	switch(args[1]){
		case "daemon":
			if(!userDaemonFlag){
				import ekeymgr.systemdaemon;
				SystemDaemon systemdaemon = new SystemDaemon();
				if(!config.setRoomIPAddress(false)){
					return false;
				}
				systemdaemon.main();
				config.setRoomIPAddress(true);
			}else{
				import ekeymgr.userdaemon;
				UserDaemon userdaemon = new UserDaemon();
				userdaemon.main();
			}
			return 0;
		case "auth":
			if(args.length != 4){
				"Too few arguments.".writeln;
				stdout.flush;
				return 1;
			}
			import ekeymgr.auth;
			Auth auth = new Auth();
			if(serviceIdAuthFlag){
				return auth.authServiceId(args[2], args[3]);
			}else{
				return auth.authUserId(args[2], args[3]);
			}
		case "hashGen":
			static import cipher = ekeymgr.cipher;
			return cipher.hashGen();
		default:
			break;
	}
	static import client = ekeymgr.client;
	if(serviceIdAuthFlag){
		args = args ~ "--service-id-auth";
	}
	return client.connect(args);
}
