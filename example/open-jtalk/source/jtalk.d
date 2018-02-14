module openjtalk.jtalk;
import ek = ekeymgr;
import ekeymgr.submodule;
import ekeymgr.net.auth;
import std.stdio;
import core.thread;

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
	void onKeyEvent(ek.KeyEvent ke, AuthData ad){
		ek.traceLog("in");
		new JTalkThread(ke, ad).start();
	}
}
class JTalkThread: Thread{
	this(ek.KeyEvent ke, AuthData ad){
		this.ke = ke;
		this.ad = ad;
		super(&run);
	}
private:
	ek.KeyEvent ke;
	AuthData ad;
	void run(){
		import std.process;
		import std.file;
		import std.string;
		string openMsgJp = ek.config.load("openMsgJp", "ようこそ");
		string closeMsgJp = ek.config.load("closeMsgJp", "さようなら");
		ek.traceLog("jtalk start");
		auto pipes = pipeProcess("jtalk", Redirect.stdin);
		scope(exit) wait(pipes.pid);
		ek.traceLog("jtalk process start");
		if(ad is null){
			pipes.stdin.writeln(openMsgJp);
			ek.traceLog("no auth data");
		}else{
			ad.write;
			string[] name = ad.getName.split(" ");
			ek.traceLog(name);
			pipes.stdin.writeln(openMsgJp, "、", name[0], "さん");
		}
		pipes.stdin.flush();
		pipes.stdin.close();
		wait(pipes.pid);
		if(!exists("/tmp/out.wav")){
			ek.traceLog("file not exist");
			return;
		}
		auto aplay = execute(["aplay", "/tmp/out.wav"]);
	}
}
