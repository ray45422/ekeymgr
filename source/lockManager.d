module ekeymgr.lockmanager;
import servo;
class LockManager{
private:
	bool lock;
	Servo servo;
	const ubyte servo_default = 90;
	const ubyte servo_open = 0;
	const ubyte servo_close = 180;
	const ubyte servo_pin = 17;
public:
	this(){
		import core.time;
		servo = new Servo();
		servo.setAutoStop(dur!("seconds")(1));
	}
	void init(){
		servo.attach(servo_pin);
		servo.write(servo_default);
	}
	void open(){
		servo.attach(servo_pin);
		servo.write(servo_open);
		servo.write(servo_default);
		servo.detach();
	}
	void close(){
		servo.attach(servo_pin);
		servo.write(servo_close);
		servo.write(servo_default);
		servo.detach();
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
