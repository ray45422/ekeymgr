module ekeymgr.lockmanager;
import servo;
import dgpio;
class LockManager{
private:
	bool lock;
	Servo servo;
	GPIO sw;
	const ubyte servo_default = 90;
	const ubyte servo_open = 0;
	const ubyte servo_close = 180;
	const ubyte servo_pin = 17;
public:
	this(){
		import core.time;
		servo = new Servo();
		servo.setAutoStop(dur!("seconds")(1));
		sw = new GPIO(2);
		sw.setInput();
	}
	void init(){
		if(sw.isHigh()){return;}
		servo.attach(servo_pin);
		servo.write(servo_default);
	}
	void stop(){
		servo.detach();
	}
	void open(){
		if(sw.isHigh()){return;}
		servo.attach(servo_pin);
		servo.write(servo_open);
		servo.write(servo_default);
		servo.detach();
		lock = false;
	}
	void close(){
		if(sw.isHigh()){return;}
		servo.attach(servo_pin);
		servo.write(servo_close);
		servo.write(servo_default);
		servo.detach();
		lock = true;
	}
	void toggle(){
		if(lock){
			open();
		}else{
			close();
		}
	}
	bool isLock()const{
		return lock;
	}
	void setLock(bool status){
		lock = status;
	}
}
