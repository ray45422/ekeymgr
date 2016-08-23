import std.stdio;
import std.string;
import core.thread;
import serial.device;
import serial.rcs620s;
SerialPort lcd;
void main()
{
	lcd = new SerialPort("/dev/ttyUSB1");
	lcd.speed(BaudRate.BR_9600);
	clearDisplay();
	auto rcs620s = new RCS620S("/dev/ttyUSB0");
	"start init".writeln;
	lcd.write("init");
	while(!rcs620s.init()){
		Thread.sleep(dur!("msecs")(500));
		lcd.write(".");
	}
	clearDisplay();
	lcd.write("init success!");
	setPos(0,1);
	lcd.write("polling start");
	"init success".writeln;
	"polling start".writeln;
	while(!rcs620s.polling()){
		Thread.sleep(dur!("msecs")(500));
		rcs620s.rfOff();
	}
	clearDisplay();
	lcd.write("polling success");
	setPos(0,1);
	lcd.write(arrayHex(rcs620s.idm));
	"polling success".writeln;
	"id:".write;
	rcs620s.writeArray(rcs620s.idm);
	"pmm:".write;
	rcs620s.writeArray(rcs620s.pmm);
	rcs620s.close();
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
