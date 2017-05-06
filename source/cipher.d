module ekeymgr.cipher;
import std.stdio;
import std.digest.sha;
import std.conv : hexString;

class Encrypt{
	string encrypt(){
		return "";
	}
	string decrypt(){
		return "";
	}
}

class Hash{
public:
	this(string data){
		this.data = data;
	}
	enum Versions{
		V1,
		Latest = V1	//newest version//
	};
	string generate(Versions ver= Versions.Latest){
		string result;
		switch(ver){
			case Versions.V1:
				result = data;
				for(int i = 0; i < 3; ++i){
					result = toHexString(sha256Of(result));
				}
				result ~= "V1";
				break;
			default:
				break;
		}
		return result.dup;
	}
	
private:
	string data;
}

unittest
{
	auto hash = new Hash("abc");
	assert(hash.generate() == "49B346DABA11964AC8CCC932BE76E84666AA5DE22B48B1060A7756C1F452DE7FV1");
}
