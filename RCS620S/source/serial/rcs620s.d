module serial.rcs620s;
import std.stdio;
import std.array;
import std.conv;
import core.thread;
import serial.device;

class RCS620S{
	private SerialPort port;
	this(string path){
		this(new SerialPort(path, dur!("msecs")(10), dur!("msecs")(10)));
	}
	this(SerialPort port){
		this.port=port;
		this.port.speed(BaudRate.BR_115200);
	}
	bool init(){
		ubyte[] command = [0xd4, 0x32, 0x02, 0x00, 0x00, 0x00];
		ubyte[] response = rwCommand(command);
		writeArray(response);
		if(response.length==0){
			return false;
		}
		return true;
	}
	ubyte[] rwCommand(ubyte[] command){
		if(command.length <= 255){
			/* normal frame */
			ubyte[] buf = [0x00, 0x00, 0xff, cast(ubyte)command.length,cast(ubyte)-command.length];
			ubyte dcs=calcDCS(command);
			command = buf ~ command;
			buf = [dcs,0x00];
			command = command ~ buf;
			port.write(command);
			ubyte[256] read;
			ulong readed;
			try{
				readed = port.read(read);
			}catch(TimeoutException e){
				return [];
			}
			buf = read[0..readed];
			return buf;
		}else{
			/* extended frame*/
		}
		return [];
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
