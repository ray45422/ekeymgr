import std.stdio;
import std.string;
import std.conv;
import core.thread;
import servo;

void main()
{
	Servo servo=new Servo()
		.setSleepOffset(dur!("usecs")(150))
		.setRange(500, 2500);
	//servo.setAutoStop(dur!("seconds")(60));
	while(true){
		int a = readln.chomp.to!int;
		if(a == 47){
			break;
		}
		servo.detach();
		Thread.sleep(dur!("msecs")(1));
		servo.attach(17);
		servo.write(a.to!ubyte);
	}
	servo.detach();
	"end".writeln;
}
