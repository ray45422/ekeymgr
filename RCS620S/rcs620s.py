class Rc620s:
	def __init__(self,serial):
		self.serial=serial

	def rwCommand(self,command):
		buf=[0x00,0x00,0xff,len(command)]
		dcs=self.calcDCS(command);
		buf.append(0b11111111-buf[3]+1)
		buf.extend(command)
		command=buf
		#writeCommand(buf)
		#writeCommand(command)
		buf=[dcs,0x00]
		command.extend(buf)
		print("send command")
		self.writeCommand(command)
		print("receive response")
		str=self.serial.read(256)
		#if str.index("\x"):
			#print("match")
		return str

	def calcDCS(self,data):
		length=len(data)
		sum=0
		for i in range(0,length):
			sum+=data[i]
		r=0b11111111-(sum & 0b11111111)+1
		return r

	def writeCommand(self,buf):
		self.serial.write(buf)
		self.printData(buf)

	def printData(self,data):
		str=""
		for v in data:
			tmp="%x" % v
			str=str+"\\x"+tmp
		print(str)
