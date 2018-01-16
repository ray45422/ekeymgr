module ekeymgr.command;
import std.stdio;
import std.getopt;
import std.array;
import std.algorithm.iteration: filter;
import std.algorithm.comparison: equal;
import std.algorithm.searching: canFind;

alias SubCommand = int delegate(string[] args);
private SubCommand[string] subCommands;
void addSubCommand(string name, SubCommand command){
	subCommands[name] = command;
}
private int execSubCommand(string name, string[] args){
	if(!subCommands.keys.canFind(name)){
		import client = ekeymgr.client;
		return client.connect(name, args);
	}
	return subCommands[name](args);
}
string searchSubcommand(string[] args){
	foreach(string arg; args[1..$]){
		if(arg[0] !=  '-'){
			return arg;
		}
	}
	return null;
}
void addPresetSubCommand(){
	addSubCommand("version", (string[] args){
		import ekeymgr.version_;
		"ekeymgr version ".write;
		ekeymgrVersion.writeln;
		return 0;
	});
	addSubCommand("daemon", (string[] args){
		import ekeymgr.systemdaemon;
		import config = ekeymgr.config;
		SystemDaemon systemdaemon = new SystemDaemon();
		if(!config.setRoomIPAddress(false)){
			return false;
		}
		systemdaemon.main();
		config.setRoomIPAddress(true);
		return 0;
	});
	addSubCommand("auth", (string[] args){
		bool isServiceIdAuth = false;
		getopt(args,
			"service-id-auth", &isServiceIdAuth);
		if(args.length != 3){
			"Too few arguments.".writeln;
			stdout.flush;
			return 1;
		}
		import ekeymgr.auth;
		Auth auth = new Auth();
		if(isServiceIdAuth){
			auto service = args[1];
			auto id = args[2];
			return auth.authServiceId(service, id);
		}else{
			auto user = args[1];
			auto id = args[2];
			return auth.authUserId(user, id);
		}
	});
	addSubCommand("hashGen", (string[] args){
		static import cipher = ekeymgr.cipher;
		return cipher.hashGen();
	});
}
int execCommand(string[] args){
	addPresetSubCommand();
	string subCommand = searchSubcommand(args);
	/* no subcommand */
	if(subCommand is null){
		void versionShow(){
			import ekeymgr.version_;
			"ekeymgr version ".write;
			ekeymgrVersion.writeln;
		}
		if(args.length == 1){
			versionShow();
			return 2;
		}
		getopt(args,
			"version|v", &versionShow
		);
		return 0;
	}
	/* subcommand is set */
	import config = ekeymgr.config;
	if(!config.init()){
		stderr.writeln("Setup failed");
		return 1;
	}
	args = args.filter!(a => a != subCommand).array;
	return execSubCommand(subCommand, args);
}
