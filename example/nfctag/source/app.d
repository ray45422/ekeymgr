import ek = ekeymgr;
import ekeymgr.cli;
import std.stdio;
import nfctag.nfctag;
import nfctag.lockManager;

void main(string[] args){
	ek.submoduleAdd(new NFCTagModule());
	ek.setLocker(new LockManager());
	runCommandLine(args);
}
