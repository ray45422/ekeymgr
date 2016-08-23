import std.stdio;
import core.thread;
import servo;

void main()
{
	Servo servo=new Servo();
	servo.setAutoDetach(dur!("msecs")(2000));
	servo.writeMicroseconds(2000);
	Thread.sleep(dur!("seconds")(1));
	servo.detach;
}
