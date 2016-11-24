module servo;
import std.stdio;
import core.thread;
import core.time;
import dgpio;

class Servo{
public:
	this(){
	}
	~this(){
		if(!(gpio is null)){
			gpio.deactivate();
		}
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
		if(stopTime == timeElapsed){
			if(stop){
				thread = new Thread(&servoWrite).start();
			}
		}else{
			while(!stop){
				writePulse();
				after = MonoTime.currTime;
				timeElapsed = after - before;
				if(timeElapsed > stopTime){
					break;
				}
			}
		}
	}
	ubyte read(){
		return angle;
	}
	void setAutoStop(Duration time){
		stopTime = time;
	}
private:
	GPIO gpio;
	uint cycle=20000;
	ubyte angle = 0;
	uint ontime;
	Thread thread;
	Duration stopTime;
	bool stop = true;
	void servoWrite(){
		while(!stop){
			writePulse();
		}
	}
	void writePulse(){
		gpio.setHigh();
		Thread.sleep(dur!("usecs")(ontime));
		gpio.setLow();
		Thread.sleep(dur!("usecs")(cycle-ontime));
	}
}
