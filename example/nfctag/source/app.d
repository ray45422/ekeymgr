import ek = ekeymgr;
import ekeymgr.cli;
import std.stdio;
import nfctag.nfctag;
import nfctag.lockManager;

int main(string[] args){
	ek.submoduleAdd(new NFCTagModule());
	ek.setLocker(new LockManager());
	return runCommandLine(args);
}
