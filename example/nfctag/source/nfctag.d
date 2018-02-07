module nfctag.nfctag;
import ek = ekeymgr;
import ekeymgr.submodule;
import std.stdio;
import std.string;
import core.thread;
import serial.device;
import serial.rcs620s;
import dgpio;

class NFCTagModule: Submodule{
public:
	public void main(){
		setup();
		while(running){
			loop();
		}
	}
	bool isAutoRestart(){
		return true;
	}
	string name(){
		return "nfctag";
	}
	void open(){
		ek.open();
		lcdUpdate();
	}
	void close(){
		ek.close();
		lcdUpdate();
	}
	void toggle(){
		ek.toggle();
		lcdUpdate;
	}
	void stop(){
		running = false;
	}
	bool isLock(){
		return !ek.isOpen();
	}
private:
	RCS620S rcs620s;
	SerialPort lcd;
	GPIO sw;
	GPIO buz;
	string roomName;
	string openMsg;
	string closeMsg;
	string failMsg;
	void setup(){
		sw = new GPIO(2);
		sw.setInput();
		buz = new GPIO(22);
		buz.setOutput();
		roomName = ek.config.load("room_name");
		openMsg = ek.config.load("openMsg", "Welcome!!");
		closeMsg = ek.config.load("closeMsg", "See you...");
		failMsg = ek.config.load("failMsg", "Auth Failed");
		lcd = new SerialPort(ek.config.load("lcdPath", "/dev/ttyUSB1"));
		lcd.speed(BaudRate.BR_9600);
		rcs620s = new RCS620S(ek.config.load("rcs620sPath", "/dev/ttyUSB2"));
		clearDisplay();
		lcd.write("init");
		while(!rcs620s.init()){
			Thread.sleep(dur!("msecs")(1000));
			lcd.write(".");
		}
		ek.open();
	}
	private void loop(){
		lcdUpdate();
		ek.debugLog("polling start");
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
			return;
		}
		ek.traceLog("tag detected");
		auto ad = ek.authServiceId("FeliCa", arrayHex(rcs620s.idm));
		if(ad !is null){
			if(sw.isHigh()){
				clearDisplay();
				lcd.write("PleaseCloseDoor");
			}
			while(sw.isHigh() && running){
				buzzer();
			}
			buz.setLow();
			string disp_name = ad.getDispname;
			clearDisplay();
			lcd.write(ek.isOpen?closeMsg:openMsg);
			setPos(cast(ubyte)(16-disp_name.length),1);
			lcd.write(disp_name);
			ek.toggle(ad);
		}else{
			clearDisplay();
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
		lcd.write(ek.isOpen?"open":"close");
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
