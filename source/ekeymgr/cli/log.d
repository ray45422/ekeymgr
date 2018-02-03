module ekeymgr.cli.log;
import config = ekeymgr.config;
import std.stdio;

void errorLog(T...)(T msgs){
	stderr.write("[ERROR]");
	foreach(ref msg; msgs){
		stderr.write(" " ~ msg);
	}
	stderr.writeln();
}
void infoLog(T...)(T msgs){
	log(LogLevel.INFO, msgs);
}
void debugLog(T...)(T msgs){
	log(LogLevel.DEBUG, msgs);
}
void traceLog(T...)(T msgs){
	log(LogLevel.TRACE, msgs);
}

private void log(T...)(LogLevel level, T msgs){
	ubyte logLevel = config.load!ubyte("logLevel");
	if(level <= logLevel){
		stdout.write("[" ~ logLevelName[level] ~ "]");
		foreach(ref msg; msgs){
			stdout.write(" " ~ msg);
		}
		stdout.writeln();
		stdout.flush;
	}
}
private enum LogLevel{
	INFO = 0,
	DEBUG = 1,
	TRACE = 2
}
private auto logLevelName = ["INFO", "DEBUG", "TRACE"];
