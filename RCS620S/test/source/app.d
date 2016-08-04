import std.stdio;
import core.thread;
import serial.device;
import serial.rcs620s;
void main()
{
	auto port = new SerialPort("/dev/ttyACM0", dur!("msecs")(10), dur!("msecs")(10));
	port.speed(BaudRate.BR_115200);
	auto rcs620s = new RCS620S(port);

	Thread.sleep(dur!("seconds")(2));//Arduinoのリセット待ち
	"start init".writeln;
	while(!rcs620s.init()){
		Thread.sleep(dur!("msecs")(500));
	}
	"init success".writeln;
	port.close();
}
