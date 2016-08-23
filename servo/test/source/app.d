import std.stdio;
import core.thread;
import servo;

void main()
{
	Servo servo=new Servo();
	servo.attach(17);
	//servo.setAutoDetach(dur!("msecs")(2000));
	servo.write(0);
	Thread.sleep(dur!("seconds")(1));
	servo.write(90);
	Thread.sleep(dur!("seconds")(1));
	servo.write(180);
	Thread.sleep(dur!("seconds")(1));
	servo.detach();
	"end".writeln;
}
