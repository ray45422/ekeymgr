module servo;
import std.stdio;
import core.thread;
import core.time;
import dgpio;

class Servo{
	private GPIO gpio;
	private uint cycle;
	private ubyte angle = 0;
	private uint ontime;
	private Thread thread;
	private Duration detachTime;
	private bool stop = true;
	this(){
	}
	void attach(ubyte pin){
			detach();
			gpio = new GPIO(pin);
			gpio.setOutput();
	}
	void detach(){
		if(!(gpio is null)){
			gpio.deactivate();
		}
		stop = true;
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
		if(stop){
			thread = new Thread(&servoWrite).start();
		}
	}
	ubyte read(){
		return angle;
	}
	void setAutoDetach(Duration time){
		detachTime = time;
	}
	private void servoWrite(){
		stop=false;
		MonoTime before = MonoTime.currTime;
		MonoTime after = MonoTime.currTime();
		Duration timeElapsed;
		if(detachTime == timeElapsed){//detachTimeが0か判別
			while(!stop){
				writePulse();
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
