module ekeymgr.submodule;
public import ekeymgr.submodule.TCPServer;

interface Submodule{
public:
	void main();
	void stop();
	bool isAutoRestart();
	string name();
}
