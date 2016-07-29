import std.stdio;
import core.thread;
import serial.device;

void main()
{
	auto port=new SerialPort("/dev/ttyACM0", dur!("msecs")(10), dur!("msecs")(10));
	port.speed(BaudRate.BR_115200);

	Thread.sleep(dur!("seconds")(2));//Arduinoのリセット待ち
	ubyte [20] a;
	ulong ret=0;
	ubyte[] test=[0xd4, 0x32, 0x02, 0x00, 0x00, 0x00];
	port.write(test);
	while(ret==0){
		try{
			ret=port.read(a);//Arduino経由だとなぜか読めない(USBシリアル変換ケーブルが届くのを待つ)
		}catch(TimeoutException e){
			ret.writeln;
			Thread.sleep(dur!("msecs")(500));
			port.write(test);
			//e.writeln();
		}
	}
	ret.writeln;
	a.writeln;
	port.close();
}

class RCS620S{
	SerialPort port;
	this(SerialPort port){
		this.port=port;
	}
}
