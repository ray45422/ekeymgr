import std.stdio;
import std.string;
import core.thread;
import serial.device;
import serial.rcs620s;
import servo;

class Daemon{
	RCS620S rcs620s;
	SerialPort lcd;
	Servo servo;
	this(){
		servo=new Servo();
		servo.setAutoStop(dur!("seconds")(1));
		servo.attach(17);
		servo.write(180);
		lcd = new SerialPort("/dev/ttyUSB1");
		lcd.speed(BaudRate.BR_9600);
		rcs620s = new RCS620S("/dev/ttyUSB0");
		lcd.write("init");
		while(!rcs620s.init()){
			Thread.sleep(dur!("msecs")(500));
			lcd.write(".");
		}
	}
	public void loop(){
		{
			clearDisplay();
			lcd.write("polling start");
			"polling start".writeln;
			while(!rcs620s.polling()){
				Thread.sleep(dur!("msecs")(500));
				rcs620s.rfOff();
			}
			clearDisplay();
			lcd.write("polling success");
			setPos(0,1);
			lcd.write(arrayHex(rcs620s.idm));
			servo.write(0);
			Thread.sleep(dur!("msecs")(500));
			servo.write(180);
		}
		clearDisplay();
		servo.detach();
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
