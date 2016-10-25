module ekeymgr.daemon;
import std.stdio;
import std.string;
import core.thread;
import serial.device;
import serial.rcs620s;
import ekeymgr.lockmanager;

class Daemon{
	RCS620S rcs620s;
	SerialPort lcd;
	LockManager lockMan;
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
	public void main(){
		for(;;){
			loop();
		}
	}
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
		int ret = new Auth().auth("FeliCa",arrayHex(rcs620s.idm));
		clearDisplay();
		lcd.write("polling success");
		setPos(0,1);
		if(ret == 0){
			lcd.write(lockMan.isLock?"welcome":"good bye");
			lockMan.toggle();
		}else{
			lcd.write("Auth failed");
		}
	}
	void stop(){
		clearDisplay();
		lcd.close();
		rcs620s.close();
	}
	private void clearDisplay(){
		ubyte[2] buf=[0x1b,0x43];
		lcd.write(buf);
	}
	private void setPos(ubyte x,ubyte y){
		ubyte[4] buf=[0x1b,0x47,cast(ubyte)(0x40+x),cast(ubyte)(0x40+y)];
		lcd.write(buf);
	}
	private string arrayHex(ubyte[] a){
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
