import ek = ekeymgr;
import std.stdio;
import nfctag.nfctag;

void main(){
	ek.submoduleAdd(new NFCTagModule());
	ek.start();
}
