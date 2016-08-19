import std.stdio;
import core.thread;
import serial.device;
import serial.rcs620s;
void main()
{
	auto rcs620s = new RCS620S("/dev/ttyUSB0");

	Thread.sleep(dur!("seconds")(2));//Arduinoのリセット待ち
	"start init".writeln;
	while(!rcs620s.init()){
		Thread.sleep(dur!("msecs")(500));
	}
	"init success".writeln;
	"polling start".writeln;
	while(!rcs620s.polling()){
		Thread.sleep(dur!("msecs")(500));
		rcs620s.rfOff();
	}
	"polling success".writeln;
	"id:".write;
	rcs620s.writeArray(rcs620s.idm);
	"pmm:".write;
	rcs620s.writeArray(rcs620s.pmm);
	rcs620s.close();
}
