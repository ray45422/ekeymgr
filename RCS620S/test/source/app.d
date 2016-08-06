import std.stdio;
import core.thread;
import serial.device;
import serial.rcs620s;
void main()
{
	auto rcs620s = new RCS620S("/dev/ttyACM0");

	Thread.sleep(dur!("seconds")(2));//Arduinoのリセット待ち
	"start init".writeln;
	while(!rcs620s.init()){
		Thread.sleep(dur!("msecs")(500));
	}
	"init success".writeln;
	rcs620s.close();
}
