// D import file generated from 'source\hip\util\concurrency.d'
module hip.util.concurrency;
version (HipConcurrency)
{
	struct Atomic(T)
	{
		import core.atomic;
		private T value;
		auto opAssign(T)(T value)
		{
			atomicStore(this.value, value);
			return value;
		}
		private @property T v()
		{
			return atomicLoad(value);
		}
		alias v this;
}
	struct Volatile(T)
	{
		import core.volatile;
		private T value;
		auto synchronized opAssign(T)(T value)
		{
			volatileStore(&this.value, value);
			return value;
		}
		private synchronized @property T v()
		{
			return volatileLoad(value);
		}
		alias v this;
}
	import core.thread;
	import core.sync.mutex : Mutex;
	import core.sync.semaphore : Semaphore;
	class DebugMutex
	{
		private string lastFileLock;
		private size_t lastLineLock;
		private ulong lastID;
		private Mutex mtx;
		this()
		{
			mtx = new Mutex;
		}
		void lock(string file = __FILE__, size_t line = __LINE__);
		void unlock();
	}
	class HipWorkerThread : Thread
	{
		private struct WorkerJob
		{
			string name;
			void delegate() task;
			void delegate(string taskName) onTaskFinish;
		}
		private WorkerJob[] jobsQueue;
		private Semaphore semaphore;
		private bool isAlive;
		private DebugMutex mutex;
		private HipWorkerPool pool;
		this(HipWorkerPool pool = null)
		{
			super(&run);
			if (pool)
				this.pool = pool;
			isAlive = true;
			semaphore = new Semaphore;
			mutex = new DebugMutex;
		}
		void finish();
		bool isIdle();
		private bool isIdleImpl();
		void pushTask(string name, void delegate() task, void delegate(string taskName) onTaskFinish = null);
		void startWorking();
		void await(bool rethrow = true);
		void run();
		private void onAnyException(bool isError, string message);
		void dispose();
	}
	class HipWorkerPool
	{
		HipWorkerThread[] threads;
		protected Semaphore awaitSemaphore;
		protected void delegate()[] finishHandlersOnMainThread;
		protected DebugMutex handlersMutex;
		private struct Task
		{
			string name;
			void delegate() task;
			void delegate(string taskName) onTaskFinish = null;
		}
		private Task[] mainThreadTasks;
		private uint awaitCount = 0;
		this(size_t poolSize)
		{
			threads = new HipWorkerThread[](poolSize);
			handlersMutex = new DebugMutex;
			for (size_t i = 0;
			 i < poolSize; i++)
			{
				threads[i] = new HipWorkerThread(this);
			}
			awaitSemaphore = new Semaphore(0);
		}
		protected void onHipThreadError(HipWorkerThread worker, bool isError, string message);
		void await();
		HipWorkerThread pushTask(string name, void delegate() task, void delegate(string taskName) onTaskFinish = null, bool isOnFinishOnMainThread = false);
		protected void executeMainThreadTasks();
		void startWorking();
		void delegate(string name) notifyOnFinish(void delegate(string taskName) onFinish);
		bool isIdle();
		void pollFinished();
		void dispose();
	}
}
