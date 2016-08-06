#! /usr/bin/python
import serial
import rcs620s
s = serial.Serial("/dev/ttyACM0", 115200)
s.timeout = 1
r = rcs620s.Rc620s(s)

p = [0xd4, 0x32, 0x02, 0x00, 0x00, 0x00]
str = r.rwCommand(p)
r.printData(str)
p = [0xd4, 0x32, 0x05, 0x00, 0x00, 0x00]
str = r.rwCommand(p)
r.printData(str)
p = [0xd4, 0x32, 0x81, 0xb7]
str = r.rwCommand(p)
r.printData(str)
s.close()
