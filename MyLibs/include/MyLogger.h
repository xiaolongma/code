#ifndef MYLOGGER_H
#define MYLOGGER_H

#define _ELPP_THREAD_SAFE
#define _ELPP_STACKTRACE_ON_CRASH
#define _ELPP_LOGGING_FLAGS_FROM_ARG
#define _ELPP_NO_DEFAULT_LOG_FILE
#define _ELPP_DISABLE_DEBUG_LOGS

#define _ELPP_STL_LOGGING


#include "easylogging++.h"
#include "MyOMP.h"


enum LogType {DEBUG=-1, INFO=0, WARNING=1, ERROR=2, FATAL=3};

class MyLog {
public:
	MyLog( const std::string logname ) : MyLog( 0, nullptr, logname ) {}
	MyLog( int argc = 0, char* argv[] = nullptr, const std::string logname = "" ) 
		: logname(logname), _messages( omp_get_max_threads() ) {
		Init( argc, argv );
	}
	~MyLog() { flushall(); }

	void Rename( const std::string lognamein = "" ) {
		logname = lognamein;
		Init(0, nullptr);
	}

	void Hold( const LogType& logtype, const std::string& msgin, const std::string& funcname="" ) {
		auto& msgV = _messages.at( omp_get_thread_num() );
		msgV.push_back( Message{logtype, msgin, funcname} );
		if( logtype == FATAL ) flush();
	}

	void flush( int thread_num = -1 ) {
		int ithread = thread_num>=0&&thread_num<_messages.size() ? 
						  thread_num : omp_get_thread_num();
		auto& msgV = _messages.at( ithread );
		#pragma omp critical
		{
		for( auto& msg : msgV ) {
			std::string logcontents ( "(" + msg.funcname + " thread" + std::to_string(ithread) + "): " + msg.info );
			switch(msg.ltype) {
				case(DEBUG):	CLOG(DEBUG, logid.c_str())		<< logcontents;
					break;
				case(INFO):		CLOG(INFO, logid.c_str())		<< logcontents;
					break;
				case(WARNING):	CLOG(WARNING, logid.c_str())	<< logcontents;
					break;
				case(ERROR):	CLOG(ERROR, logid.c_str())		<< logcontents;
					break;
				case(FATAL):	CLOG(FATAL, logid.c_str())		<< logcontents;
			}
		}
		msgV.clear();
		} // omp critical
	}

	void flushall() {
		for(int ithread=0; ithread<_messages.size(); ithread++)
			flush(ithread);
	}


private:
	std::string logname, logid;

	struct Message {
		Message( const LogType& ltypein, const std::string& infoin, const std::string& funcnamein )
		: ltype{ltypein}, info{infoin}, funcname(funcnamein) {}
		LogType ltype;
		std::string info;
		std::string funcname;
	};

	std::vector< std::vector<Message> > _messages;

	void Init( int argc = 0, char* argv[] = nullptr ) {
		/* initialize logger */
		if( argc != 0 && argv != nullptr ) {
			_START_EASYLOGGINGPP(argc, argv);
		}

		/* flag settings */
		el::Loggers::addFlag(el::LoggingFlag::ColoredTerminalOutput);
		el::Loggers::addFlag(el::LoggingFlag::LogDetailedCrashReason);
		//el::Loggers::addFlag(el::LoggingFlag::ImmediateFlush);

		/* acquire one logger per threads */ /*
		for(int ithread=0; ithread<omp_get_max_threads(); ithread++)
			el::Loggers::getLogger( tid(ithread).c_str() ); */

		/* configure loggers */
		el::Configurations elconfig;
		elconfig.setToDefault();
		elconfig.set(el::Level::Global, el::ConfigurationType::Format, "%level%msg\t[%datetime{%a, %b %d, %Y  %H:%m:%s.%g}] {logger %logger}");			// global logging format
		elconfig.set(el::Level::Debug, el::ConfigurationType::Format, "%level%msg\t[%datetime{%a, %b %d, %Y  %H:%m:%s.%g}] {%loc  %logger}");	// debug logging format
		elconfig.set(el::Level::Global, el::ConfigurationType::LogFlushThreshold, "0");																		// global logging flush freq
		if( logname.empty() ) {
			elconfig.set(el::Level::Global, el::ConfigurationType::ToFile, "false");
			logid = "default";
		} else {
			elconfig.set(el::Level::Global, el::ConfigurationType::Filename, logname + ".out");																	// global logging file
			elconfig.set(el::Level::Error, el::ConfigurationType::Filename, logname + ".err");
			elconfig.set(el::Level::Fatal, el::ConfigurationType::Filename, logname + ".err");
			elconfig.set(el::Level::Debug, el::ConfigurationType::Filename, logname + ".dbg");
			logid = logname;
			std::replace( logid.begin(), logid.end(), '/', '_' );
			el::Loggers::getLogger( logid );		// acquire a new logger
		}
		el::Loggers::reconfigureLogger(logid, elconfig);
		//el::Loggers::reconfigureAllLoggers(elconfig);

	}

};

#ifndef EASYLOG_INITIALIZED
_INITIALIZE_EASYLOGGINGPP
#define EASYLOG_INITIALIZED
#endif

#define FuncName __FUNCTION__

#endif
