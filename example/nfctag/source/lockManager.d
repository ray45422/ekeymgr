module nfctag.lockManager;
import ekeymgr.locker;
import servo;
import dgpio;
class LockManager: Locker{
private:
	bool lock;
	Servo servo;
	GPIO sw;
	const ubyte servo_default = 90;
	const ubyte servo_open = 0;
	const ubyte servo_close = 180;
	const ubyte servo_pin = 17;
public:
	void setup(){
		import core.time;
		servo = new Servo()
			.setAutoStop(dur!("seconds")(1))
			.setSleepOffset(dur!("usecs")(150))
			.setRange(700, 2300);
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
	bool open(){
		if(sw.isHigh()){return false;}
		servo.attach(servo_pin);
		servo.write(servo_open);
		servo.write(servo_default);
		servo.detach();
		lock = false;
		return true;
	}
	bool close(){
		if(sw.isHigh()){return false;}
		servo.attach(servo_pin);
		servo.write(servo_close);
		servo.write(servo_default);
		servo.detach();
		lock = true;
		return true;
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
	bool isOpen(){
		return !lock;
	}
	void setLock(bool status){
		lock = status;
	}
}
