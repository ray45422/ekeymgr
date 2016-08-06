module serial.rcs620s;
import std.stdio;
import std.array;
import std.conv;
import core.thread;
import serial.device;

class RCS620S{
	private const uint RCS620S_DEFAULT_TIMEOUT = 1000;
	private const uint RCS620S_MAX_CARD_RESPONSE_LEN = 254;
	private const uint RCS620S_MAX_RW_RESPONSE_LEN = 265;
	private SerialPort port;
	this(string path){
		this(new SerialPort(path, dur!("msecs")(50), dur!("msecs")(50)));
	}
	this(SerialPort port){
		this.port=port;
		this.port.speed(BaudRate.BR_115200);
	}
	bool init(){
		ubyte[] ret;

		/* RFConfiguration (various timings) */
		ret = rwCommand([0xd4, 0x32, 0x02, 0x00, 0x00, 0x00]);
		if(ret.length == 0 || ret.length !=2 || !cmp(ret, [0xd5, 0x33], 2)){
			return false;
		}
		"v:".write;
		writeArray(ret);
		/* RFConfiguration (max retries) */
		ret = rwCommand([0xd4, 0x32, 0x05, 0x00, 0x00, 0x00]);
		if(ret.length == 0 || ret.length !=2 || !cmp(ret, [0xd5, 0x33], 2)){
			return false;
		}
		"r:".write;
		writeArray(ret);
		/* RFConfiguration (additional wait time = 24ms) */
		ret = rwCommand([0xd4, 0x32, 0x81, 0xb7]);
		if(ret.length == 0 || ret.length !=2 || !cmp(ret, [0xd5, 0x33], 2)){
			return false;
		}
		"w:".write;
		writeArray(ret);
		return true;
	}
	ubyte[] rwCommand(ubyte[] command){
		ubyte[] buf;
		ubyte dcs;
		ubyte[] response;
		uint responsLen;
		if(command.length <= 255){
			/* normal frame */
			//ubyte[] response;
			//ulong readed=0;
			buf = [0x00, 0x00, 0xff, cast(ubyte)command.length,cast(ubyte)-command.length];
			dcs=calcDCS(command);
			command = buf ~ command;
			buf = [dcs,0x00];
			command = command ~ buf;
			port.write(command);
		} else {
			/* extended frame*/
		}

		/* receive ACK */
		buf = readSerial(6);
		if(buf.length==0 || !cmp(buf, [0x00, 0x00, 0xff, 0x00, 0xff, 0x00],6)){
			cancel("ACK");
			return [];
		}

		/* receive response */
		buf = readSerial(5);
		if(buf.length == 0){
			cancel("receive");
			return [];
		} else if(!cmp(buf, [0x00, 0x00, 0xff],3)){
			return [];
		}
		if(buf[3] == 0xff && buf[4] == 0xff){
			/* extended frame */
		} else {
			/* normal frame */
			if(((buf[3] + buf[4]) & 0xff) != 0){
				return [];
			}
			responsLen = buf[3];
		}
		if(responsLen > RCS620S_MAX_RW_RESPONSE_LEN){
			return [];
		}

		response = readSerial(responsLen);
		if(response.length == 0){
			cancel("receive data");
			return [];
		}

		dcs = calcDCS(response);

		buf = readSerial(2);
		if(buf.length == 0 || buf[0] != dcs || buf[1] != 0x00){
			cancel("can't receive postamble");
			return [];
		}

		return response;
	}
	private ubyte[] readSerial(ulong len){
		ubyte[] receive = new ubyte[len];
		ulong readed;
		try{
			readed = port.read(receive);
		}catch(TimeoutException e){
			return [];
		}
		if(readed == len){
			return receive;
		}
		return [];
	}
	private void cancel(string message){
		/*"cancel: ".write;
		message.writeln;*/
		cancel();
	}
	private void cancel(){
		/* transmit ACK */
		ubyte[RCS620S_MAX_RW_RESPONSE_LEN] trash;
		port.write([0x00, 0x00, 0xff, 0x00, 0xff, 0x00]);
		Thread.sleep(dur!("msecs")(1));
		try{
			port.read(trash);
		}catch(TimeoutException e){}
	}
	private bool cmp(ubyte[] data1, ubyte[] data2, ulong len){
		len--;
		return data1[0..len] == data2[0..len];
	}
	private ubyte calcDCS(ubyte[] data){
		ubyte sum = 0;
		for(ulong i = 0; i < data.length; ++i){
			sum += data[i];
		}
		return cast(ubyte)-(sum & 0xff);
	}
	private void writeArray(ubyte[] data){
		"[".write;
		foreach(ubyte n; data){
			writef("%2x,", n);
		}
		"]".writeln;
	}
	void close(){
		port.close();
	}
}
