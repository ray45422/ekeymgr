module servo;
import std.stdio;
import std.conv;
import std.math;
import std.traits;
import core.thread;
import core.time;
import dgpio;

class Servo{
public:
	this(){
		thread = new Thread({});
	}
	~this(){
		if(!(gpio is null)){
			gpio.deactivate();
		}
	}
	Servo attach(ubyte pin){
			detach();
			gpio = new GPIO(pin);
			gpio.setOutput();
			return this;
	}
	Servo detach(){
		stop=true;
		Thread.sleep(cycle);
		if(!(gpio is null)){
			gpio.deactivate();
		}
		return this;
	}
	void write(ubyte angle){
		this.angle = angle;
		uint time = angle.map!double(0, 180, pulseRange[0], pulseRange[1], false).to!uint;
		writeMicroseconds(time);
	}
	void writeMicroseconds(uint time){
		ontime = dur!("usecs")(time);
		if(ontime > cycle){
			ontime=cycle;
		}
		if(ontime < offset){
			ontime = offset;
		}
		MonoTime before = MonoTime.currTime();
		MonoTime after = MonoTime.currTime();
		Duration timeElapsed;
		stop=false;
		if(thread.isRunning){
			return;
		}
		if(stopTime == timeElapsed){
			if(!stop){
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
	Servo setAutoStop(Duration time){
		stopTime = time;
		return this;
	}
	Servo setSleepOffset(Duration offset){
		this.offset = offset;
		return this;
	}
	Servo setRange(uint start, uint end){
		pulseRange = [start, end];
		return this;
	}
private:
	GPIO gpio;
	ubyte angle = 0;
	Thread thread;
	uint[2] pulseRange = [1000,2000];
	Duration cycle = dur!("msecs")(20);
	Duration ontime = Duration.zero();
	Duration offset = Duration.zero();
	Duration stopTime = Duration.zero();
	bool stop = true;
	void servoWrite(){
		while(!stop){
			writePulse();
		}
	}
	void writePulse(){
		gpio.setHigh();
		Thread.sleep(ontime - offset);
		gpio.setLow();
		Thread.sleep(cycle - ontime - offset);
	}
}

// armos
// Copyright © 2015, tanitta
// This software is released under the BSL License - Version 1.0.
// boost.org/LICENSE_1_0.txt


/++
指定した範囲内に収まる値を返します．
Params:
v = ソースとなる値
min = vの最小値
max = vの最大値
+/
pure T clamp(T)(in T v, in T min, in T max){
    if (v < min) {
        return min;
    }else if(max < v){
        return max;
    }else{
        return v;
    }
}

/++
+/
pure T map(T)(in T v1, in T v1_min, in T v1_max, in T v2_min, in T v2_max, bool isClamp = true){
    T epsilon;
    static if(isIntegral!T){
        epsilon = 0;
    }else{
        epsilon = T.epsilon;
    }
    if(( v1_max - v1_min ).abs <= epsilon){
        return v2_min;
    }else{
        if(isClamp){
            return clamp( (v1 - v1_min) * (v2_max - v2_min) / (v1_max - v1_min) + v2_min, v2_min, v2_max);
        }else{
            return (v1 - v1_min) * (v2_max - v2_min) / (v1_max - v1_min) + v2_min;
        }
    }
}


unittest{
    assert(0.5.map(0.0, 1.0, 1.0, 2.0) == 1.5);
    assert(0.5.clamp(-0.5, 2.0) == 0.5);
    assert((-1.0).clamp(-0.5, 2.0) == -0.5);
    assert((3.0).clamp(-0.5, 2.0) == 2.0);

}
