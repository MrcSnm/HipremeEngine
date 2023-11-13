module hip.console.log;


void logln(Args...)(Args a, string file = __FILE__, string func = __PRETTY_FUNCTION__, ulong line = __LINE__);
void loglnInfo(Args...)(Args a, string file = __FILE__, string func = __PRETTY_FUNCTION__, ulong line = __LINE__);
void loglnWarn(Args...)(Args a, string file = __FILE__, string func = __PRETTY_FUNCTION__, ulong line = __LINE__);
void loglnError(Args...)(Args a, string file = __FILE__, string func = __PRETTY_FUNCTION__, ulong line = __LINE__);
void hiplog(Args...)(Args a, string file = __FILE__,string func = __PRETTY_FUNCTION__,ulong line = __LINE__);
void rawlog(Args...)(Args a);