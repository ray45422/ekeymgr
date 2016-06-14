#! /usr/bin/python
import serial
import rc620
s=serial.Serial("/dev/ttyAMA0",115200)
s.timeout=0.5
print(type(s))
r=rc620.Rc620(s)

p=[0xd4,0x32,0x02,0x00,0x00,0x00]
str=r.rwCommand(p)
r.printData(str)
p=[0xd4,0x32,0x05,0x00,0x00,0x00]
str=r.rwCommand(p)
r.printData(str)
p=[0xd4,0x32,0x81,0xb7]
str=r.rwCommand(p)
r.printData(str)
s.close()
