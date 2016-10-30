module ekeymgr.userdaemon;
import std.stdio;
import std.string;
import core.thread;
import serial.device;
import serial.rcs620s;
import ekeymgr.lockmanager;

class UserDaemon{
public:
	this(){
		lockMan = new LockManager();
		lcd = new SerialPort("/dev/ttyUSB1");
		lcd.speed(BaudRate.BR_9600);
		rcs620s = new RCS620S("/dev/ttyUSB0");
		clearDisplay();
		lcd.write("init");
		while(!rcs620s.init()){
			Thread.sleep(dur!("msecs")(500));
			lcd.write(".");
		}
		lockMan.init();
	}
	void main(){
		for(;;){
			loop();
		}
	}
	void stop(){
		clearDisplay();
		lcd.close();
		rcs620s.close();
	}
private:
	RCS620S rcs620s;
	SerialPort lcd;
	LockManager lockMan;
	private void loop(){
		clearDisplay();
		lcd.write("welcome");
		setPos(0,1);
		lcd.write(lockMan.isLock?"close":"open");
		"polling start".writeln;
		while(!rcs620s.polling()){
			Thread.sleep(dur!("msecs")(500));
			rcs620s.rfOff();
		}
		import ekeymgr.auth;
		Auth auth = new Auth();
		int ret = auth.auth("FeliCa",arrayHex(rcs620s.idm));
		AuthData ad = auth.getLastAuthData;
		clearDisplay();
		if(ret == 0){
			string disp_name = ad.getDispname;
			lcd.write(lockMan.isLock?"welcome":"good bye");
			setPos(0,1);
			lcd.write("" ~ disp_name);
			lockMan.toggle();
		}else{
			lcd.write("Auth failed");
		}
	}
	void clearDisplay(){
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
}
