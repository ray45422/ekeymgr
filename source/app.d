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
			import ekeymgr.daemon;
			"test".writeln;
			Daemon daemon = new Daemon();
			daemon.main();
			break;
		default:
			break;
	}
	return 0;
}
