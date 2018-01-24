module ekeymgr.crypto.hash;
import std.stdio;
import std.digest.sha;
import std.conv : hexString;


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

int hashGen(){
	import std.string;
	while(true){
		auto str = readln.chomp;
		if(str == ""){
			break;
		}
		auto hash = new Hash(str);
		hash.generate.writeln;
		stdout.flush;
	}
	return 0;
}

unittest
{
	auto hash = new Hash("abc");
	assert(hash.generate() == "49B346DABA11964AC8CCC932BE76E84666AA5DE22B48B1060A7756C1F452DE7FV1");
}
