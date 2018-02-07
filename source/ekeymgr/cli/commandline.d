module ekeymgr.cli.commandline;
import std.stdio;
import std.getopt;
import std.algorithm.iteration: filter;
import std.algorithm.comparison: equal;
import std.algorithm.searching: canFind;
import ek = ekeymgr;
import ekeymgr.locker;

alias SubCommand = int delegate(string[] args);
void addSubCommand(string name, SubCommand command){
	subCommands[name] = command;
}
int runCommandLine(string[] args){
	import std.array;
	args = args[1..$];
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
		try{
			getopt(args,
				config.passThrough,
				"version|v", &versionShow
			);
		}catch(GetOptException e){
		}
		return 0;
	}
	/* subcommand is set */
	if(!ek.config.init()){
		stderr.writeln("Setup failed");
		return 1;
	}
	ubyte logLevel = 0;
	getopt(args,
			config.caseSensitive, config.bundling, config.passThrough,
			"verbose+", &logLevel,
			"v+", &logLevel);
	ek.config.set("logLevel", logLevel);
	args = args.filter!(a => a != subCommand).array;
	return execSubCommand(subCommand, args);
}

private SubCommand[string] subCommands;
private int execSubCommand(string name, string[] args){
	if(!subCommands.keys.canFind(name)){
		import client = ekeymgr.net.client;
		return client.connect(name, args);
	}
	return subCommands[name](args);
}
private string searchSubcommand(string[] args){
	foreach(string arg; args){
		if(arg[0] !=  '-'){
			return arg;
		}
	}
	return null;
}
private void addPresetSubCommand(){
	addSubCommand("version", (string[] args){
		import ekeymgr.version_;
		"ekeymgr version ".write;
		ekeymgrVersion.writeln;
		return 0;
	});
	addSubCommand("daemon", (string[] args){
		if(!ek.config.setRoomIPAddress(false)){
			return false;
		}
		ek.start();
		ek.config.setRoomIPAddress(true);
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
		import ekeymgr.net.auth;
		Auth auth = new Auth();
		if(isServiceIdAuth){
			auto service = args[0];
			auto id = args[1];
			return auth.authServiceId(service, id);
		}else{
			auto user = args[0];
			auto id = args[1];
			return auth.authUserId(user, id);
		}
	});
	addSubCommand("hashGen", (string[] args){
		static import crypto = ekeymgr.crypto;
		return crypto.hashGen();
	});
}
