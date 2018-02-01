import ek = ekeymgr;
import ekeymgr.command;
import std.stdio;
import nfctag.nfctag;
import nfctag.lockManager;

void main(string[] args){
	ek.submoduleAdd(new NFCTagModule());
	ek.setLocker(new LockManager());
	execCommand(args);
}
