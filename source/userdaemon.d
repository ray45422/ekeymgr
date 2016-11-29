module ekeymgr.userdaemon;
import std.stdio;
import std.string;
import std.variant;
import core.thread;
import serial.device;
import serial.rcs620s;
import ekeymgr.lockmanager;
import dgpio;
static import config = ekeymgr.config;

class UserDaemon{
public:
	this(){
		sw = new GPIO(2);
		sw.setInput();
		buz = new GPIO(22);
		buz.setOutput();
		roomName = config.room_name;
		openMsg = config.load("openMsg", "Welcome!!");
		closeMsg = config.load("closeMsg", "See you...");
		failMsg = config.load("failMsg", "Auth Failed");
		lockMan = new LockManager();
		lcd = new SerialPort(config.load("lcdPath", "/dev/ttyUSB1"));
		lcd.speed(BaudRate.BR_9600);
		rcs620s = new RCS620S(config.load("rcs620sPath", "/dev/ttyUSB2"));
		clearDisplay();
		lcd.write("init");
		while(!rcs620s.init()){
			Thread.sleep(dur!("msecs")(500));
			lcd.write(".");
		}
		while(sw.isHigh()){
			buzzer();
		}
		buz.setLow();
		lockMan.close();
		lockMan.init();
	}
	public void main(){
		while(running){
			loop();
		}
	}
	void open(){
		lockMan.open();
		lcdUpdate();
	}
	void close(){
		lockMan.close();
		lcdUpdate();
	}
	void toggle(){
		lockMan.toggle();
		lcdUpdate;
	}
	void stop(){
		running = false;
	}
	bool isLock(){
		return lockMan.isLock();
	}
private:
	RCS620S rcs620s;
	SerialPort lcd;
	LockManager lockMan;
	GPIO sw;
	GPIO buz;
	string roomName;
	string openMsg;
	string closeMsg;
	string failMsg;
	private void loop(){
		lcdUpdate();
		"polling start".writeln;
		while(!rcs620s.polling() && running){
			Thread.sleep(dur!("msecs")(500));
			rcs620s.rfOff();
		}
		if(!running){
			clearDisplay();
			lcd.write("service not");
			setPos(0,1);
			lcd.write("available");
			lcd.close();
			rcs620s.close();
			sw.deactivate;
			buz.deactivate;
			lockMan.stop;
			return;
		}
		import ekeymgr.auth;
		Auth auth = new Auth();
		int ret = auth.auth("FeliCa",arrayHex(rcs620s.idm));
		clearDisplay();
		if(ret == 0){
			if(sw.isHigh()){
				clearDisplay();
				lcd.write("PleaseCloseDoor");
			}
			while(sw.isHigh() && running){
				buzzer();
			}
			buz.setLow();
			AuthData ad = auth.getLastAuthData;
			string disp_name = ad.getDispname;
			lcd.write(lockMan.isLock?openMsg:closeMsg);
			setPos(cast(ubyte)(16-disp_name.length),1);
			lcd.write(disp_name);
			lockMan.toggle();
			auth.addLog(lockMan.isLock);
		}else{
			lcd.write(failMsg);
			setPos(0,1);
			lcd.write(arrayHex(rcs620s.idm));
			Thread.sleep(dur!("seconds")(2));
		}
	}
	private void buzzer(){
		if(buz.isHigh()){
			buz.setLow();
		}else{
			buz.setHigh();
		}
		Thread.sleep(dur!("msecs")(50));
	}
	private void lcdUpdate(){
		clearDisplay();
		lcd.write(roomName);
		setPos(10, 1);
		lcd.write(lockMan.isLock?"close":"open");
	}
	private void clearDisplay(){
		ubyte[2] buf=[0x1b,0x43];
		lcd.write(buf);
	}
	void setPos(ubyte x,ubyte y){
		ubyte[4] buf=[0x1b,0x47,cast(ubyte)(0x40+x),cast(ubyte)(0x40+y)];
		lcd.write(buf);
	}
	string arrayHex(ubyte[] a){
		string str="";
		foreach(uint n;a){
			string b=format("%x",n);
			if(b.length==1){
				b="0"~b;
			}
			str~=b;
		}
		return str;
	}
private:
	bool running = true;
}
