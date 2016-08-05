module serial.rcs620s;
import std.stdio;
import std.array;
import std.conv;
import serial.device;

class RCS620S{
	SerialPort port;
	this(SerialPort port){
		this.port=port;
	}
	bool init(){
		ubyte[] command = [0xd4, 0x32, 0x02, 0x00, 0x00, 0x00];
		ubyte[] buf = rwCommand(command);
		if(buf.length==0){
			return false;
		}
		return true;
	}
	ubyte[] rwCommand(ubyte[] command){
		if(command.length <= 255){
			ubyte[] buf = [0x00, 0x00, 0xff, cast(ubyte)command.length];
			command = buf ~ command;
			buf = [calcDCS(command),0x00];
			command = command ~ buf;
			port.write(command);
			ubyte[256] read;
			ulong readed;
			try{
				readed=port.read(read);
			}catch(TimeoutException e){
				return [];
			}
			buf = read[0..readed];
			return buf;
		}
		return [];
	}
	private ubyte calcDCS(ubyte[] data){
		ulong length = data.length.to!int;
		byte sum = 0;
		for(ulong i=0;i<length;++i){
			sum += data[i];
		}
		return cast(ubyte)-(sum & 0xff);
	}
}
