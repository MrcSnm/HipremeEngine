
module jni.android.looper;
extern (C) 
{
	struct ALooper;
	ALooper* ALooper_forThread();
	enum 
	{
		ALOOPER_PREPARE_ALLOW_NON_CALLBACKS = 1 << 0,
	}
	ALooper* ALooper_prepare(int opts);
	enum 
	{
		ALOOPER_POLL_WAKE = -1,
		ALOOPER_POLL_CALLBACK = -2,
		ALOOPER_POLL_TIMEOUT = -3,
		ALOOPER_POLL_ERROR = -4,
	}
	void ALooper_acquire(ALooper* looper);
	void ALooper_release(ALooper* looper);
	enum 
	{
		ALOOPER_EVENT_INPUT = 1 << 0,
		ALOOPER_EVENT_OUTPUT = 1 << 1,
		ALOOPER_EVENT_ERROR = 1 << 2,
		ALOOPER_EVENT_HANGUP = 1 << 3,
		ALOOPER_EVENT_INVALID = 1 << 4,
	}
	alias ALooper_callbackFunc = int function(int fd, int events, void* data);
	int ALooper_pollOnce(int timeoutMillis, int* outFd, int* outEvents, void** outData);
	int ALooper_pollAll(int timeoutMillis, int* outFd, int* outEvents, void** outData);
	void ALooper_wake(ALooper* looper);
	int ALooper_addFd(ALooper* looper, int fd, int ident, int events, ALooper_callbackFunc callback, void* data);
	int ALooper_removeFd(ALooper* looper, int fd);
}
