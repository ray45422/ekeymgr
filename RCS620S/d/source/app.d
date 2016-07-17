import std.stdio;
import onyx.serial;

void main()
{
	auto port=OxSerialPort("/dev/ttyACM0", Speed.S115200, Parity.none, 1000);
	port.open();
	auto rcs620s=new RCS620S(port);
	ubyte[] test=[0xd4, 0x32, 0x02, 0x00, 0x00, 0x00];
	port.write(test);
	port.close();
}

class RCS620S{
	OxSerialPort port;
	this(OxSerialPort port){
		this.port=port;
	}
}
