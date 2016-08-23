module servo;
import std.stdio;
import core.thread;
import core.time;
import dgpio;

class Servo{
	private GPIO gpio;
	private uint cycle=20000;
	private ubyte angle = 0;
	private uint ontime;
	private Thread thread;
	private Duration stopTime;
	private bool stop = true;
	this(){
	}
	void attach(ubyte pin){
			detach();
			gpio = new GPIO(pin);
			gpio.setOutput();
	}
	void detach(){
		stop=true;
		Thread.sleep(dur!("usecs")(cycle));
		if(!(gpio is null)){
			gpio.deactivate();
		}
	}
	void write(ubyte angle){
		this.angle = angle;
		ontime = 1000+cast(uint)(angle/90.0*500);
		writeMicroseconds(ontime);
	}
	void writeMicroseconds(uint time){
		if(time>cycle){
			time=cycle;
		}
		ontime = time;
		MonoTime before = MonoTime.currTime;
		MonoTime after = MonoTime.currTime();
		Duration timeElapsed;
		stop=false;
		if(detachTime == timeElapsed){
			if(stop){
				thread = new Thread(&servoWrite).start();
			}
		}else{
			while(!stop){
				writePulse();
				after = MonoTime.currTime;
				timeElapsed = after - before;
				if(timeElapsed > detachTime){
					"detach".writeln;
					break;
				}
			}
		}
	}
	ubyte read(){
		return angle;
	}
	void setAutoStop(Duration time){
		detachTime = time;
	}
	private void servoWrite(){
		while(!stop){
			writePulse();
		}
	}
	private void writePulse(){
		gpio.setHigh();
		Thread.sleep(dur!("usecs")(ontime));
		gpio.setLow();
		Thread.sleep(dur!("usecs")(cycle-ontime));
	}
	~this(){
		if(!(gpio is null)){
			gpio.deactivate();
		}
	}
}
