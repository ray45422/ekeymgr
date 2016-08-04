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
		ubyte[] test = [0xd4, 0x32, 0x02, 0x00, 0x00, 0x00];
		ubyte [20] a;
		ulong ret = 0;
		rwCommand(test);
		try{
			ret=port.read(a);
		}catch(TimeoutException e){
			"data num:".write;
			ret.writeln;
			e.writeln();
			return false;
		}
		return true;
	}
	string rwCommand(ubyte[] command){
		if(command.length <= 255){
			ubyte[] buf = [0x00, 0x00, 0xff, command.length.to!ubyte];
		}
		return "yet";
	}
	private ubyte calcDCS(byte[] data){
		int length = data.length.to!int;
		byte sum = 0;
		for(int i=0;i<length;++i){
			sum += data[i];
		}
		return -(sum & 0xff).to!ubyte;
	}
}
