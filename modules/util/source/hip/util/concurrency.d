/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.util.concurrency;

version(HipConcurrency)
{

    /**
    *   Test for wrapping atomic operations in a structure
    */
    struct Atomic(T)
    {
        import core.atomic;
        private T value;

        auto opAssign(T)(T value)
        {       
            atomicStore(this.value, value);
            return value;
        }
        private @property T v(){return atomicLoad(value);}
        alias v this;

    }

    ///Tries to implement a `volatile` java style
    struct Volatile(T)
    {
        import core.volatile;
        private T value;

        auto synchronized opAssign(T)(T value)
        {    
            volatileStore(&this.value, value);
            return value;
        }
        private @property synchronized T v(){return volatileLoad(value);}
        alias v this;   
    }

    import core.thread;
    import core.sync.mutex : Mutex;
    import core.sync.semaphore:Semaphore;

    class DebugMutex
    {
        private string lastFileLock;
        private size_t lastLineLock;
        private ulong lastID;
        private Mutex mtx;
        this()
        {
            mtx = new Mutex();
        }
        void lock(string file = __FILE__, size_t line = __LINE__)
        {
            import std.process:thisThreadID;
            if(lastLineLock == 0)
            {
                lastFileLock = file;
                lastLineLock = line;
                lastID = thisThreadID;
            }
            else
            {
                version(Desktop)
                {
                    import std.stdio;
                    writeln("Tried to lock a locked mutex at ", lastFileLock, ":",lastLineLock, " Thread(",lastID,")", " Current Thread is ",thisThreadID);
                }
            }
            mtx.lock();
        }
        void unlock()
        {
            version(Desktop)
            {
                if(lastLineLock == 0)
                {
                    import std.stdio;
                    writeln("Tried to unlock an unlocked mutex");
                }
            }
            lastFileLock = null;
            lastLineLock = 0;
            mtx.unlock();
        }

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
            if(pool)
                this.pool = pool;
            isAlive = true;
            semaphore = new Semaphore;
            mutex = new DebugMutex();
        }
        /**
        *   This thread goes into an invalid state after finishing it. It should not be used anymore
        */
        void finish()
        {
            mutex.lock();
            isAlive = false;
            semaphore.notify;
            mutex.unlock();
        }
        bool isIdle()
        {
            mutex.lock();
            bool ret = isIdleImpl();
            mutex.unlock();
            return ret;
        }
        private bool isIdleImpl()
        {
            return jobsQueue.length == 0;
        }
        /**
        *   Synchronized push on queue
        */
        void pushTask(string name, void delegate() task, void delegate(string taskName) onTaskFinish = null)
        {
            if(isAlive)
            {
                mutex.lock();
                jobsQueue~= WorkerJob(name, task, onTaskFinish);
                mutex.unlock();
                semaphore.notify();
            }
            else
            {
                import std.stdio;
                writeln("Thread is not alive to get tasks.");
            }
        }

        void startWorking()
        {
            if(!isRunning)
                start();
        }
        void await(bool rethrow = true)
        {
            // pushTask("await", () => finish);
            // join(rethrow);
        }

        void run()
        {
            while(isAlive)
            {
                mutex.lock();
                if(!isIdleImpl)
                {
                    WorkerJob job = jobsQueue[0];
                    mutex.unlock();
                    import std.stdio;
                    try
                    {
                        job.task();
                        if(job.onTaskFinish != null)
                        {
                            job.onTaskFinish(job.name);
                        }
                    }
                    catch(Error e)
                    {
                        onAnyException(true, e.toString());
                        return;
                    }
                    catch(Exception e)
                    {
                        onAnyException(false, e.toString());
                        return;
                    }
                    mutex.lock();
                    jobsQueue = jobsQueue[1..$];
                    mutex.unlock();
                }
                else
                    mutex.unlock();
                semaphore.wait;
            }
        }

        private void onAnyException(bool isError, string message)
        {
            import std.stdio;
            isAlive = false;
            if(pool)
                pool.onHipThreadError(this, isError,message);
        }
        void dispose()
        {
            finish();
            destroy(semaphore);
            destroy(mutex);
        }
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
            handlersMutex = new DebugMutex ();
            for(size_t i = 0; i < poolSize; i++)
                threads[i] = new HipWorkerThread(this);
            awaitSemaphore = new Semaphore(0);
        }

        protected void onHipThreadError(HipWorkerThread worker, bool isError, string message)
        {
            if(awaitCount > 0)
            {
                awaitSemaphore.notify();
            }
            import hip.util.array;
            import std.stdio;
            writeln("Worker failed with ", isError ? "error" : "exception", ":", message);
            threads.remove(worker);
        }
        void await()
        {
            awaitCount = 0;
            foreach(thread; threads)
            {
                if(!thread.isIdle)
                {
                    thread.pushTask("Await", ()
                    {
                        awaitSemaphore.notify;}
                    );
                    awaitCount++;
                }
            }
            startWorking();
            while(awaitCount > 0)
            {
                awaitSemaphore.wait();
                awaitCount--;
            }
        }
        /**
        *   If there is no idle thread, null will be returned and the task and onFinish callbacks will be executed on that same thread.
        *   - Keep in mind that pushin task is not enough. You need to call startWorking() to make it active after pushing tasks
        */
        HipWorkerThread pushTask(string name, void delegate() task, void delegate(string taskName) onTaskFinish = null, bool isOnFinishOnMainThread = false)
        {
            foreach(thread; threads)
            {
                if(thread.isIdle)
                {
                    if(onTaskFinish !is null && isOnFinishOnMainThread)
                        thread.pushTask(name, task, notifyOnFinish(onTaskFinish));
                    else
                        thread.pushTask(name, task, onTaskFinish);
                    return thread;
                }
            }
            //Execute a main thread task if it had anything.
            handlersMutex.lock();
            mainThreadTasks~= Task(name, task, onTaskFinish);
            handlersMutex.unlock();
            return null;
        }

        protected void executeMainThreadTasks()
        {
            handlersMutex.lock();
            if(mainThreadTasks.length != 0)
            {
                foreach(mainThreadTask; mainThreadTasks)
                {
                    mainThreadTask.task();
                    if(mainThreadTask.onTaskFinish != null)
                        mainThreadTask.onTaskFinish(mainThreadTask.name);
                }
                mainThreadTasks.length = 0;
            }
            handlersMutex.unlock();
        }

        /**
        *   This function should be called every time you push a task.
        */
        void startWorking()
        {
            foreach(thread; threads)
                if(!thread.isIdle)
                    thread.startWorking();
            executeMainThreadTasks();
        }

        void delegate(string name) notifyOnFinish(void delegate(string taskName) onFinish)
        {
            return (name)
            {
                // imported!"std.stdio".writeln("Finished ", name);

                handlersMutex.lock();
                    finishHandlersOnMainThread~= (){onFinish(name);};
                handlersMutex.unlock();
            };
        }

        bool isIdle()
        {
            foreach(thread; threads)
                if(!thread.isIdle)
                    return false;
            return true;
        }

        void pollFinished()
        {
            handlersMutex.lock();
                if(finishHandlersOnMainThread.length)
                {
                    foreach(finishHandler; finishHandlersOnMainThread)
                        finishHandler();
                    finishHandlersOnMainThread.length = 0;
                }
            handlersMutex.unlock();

        }

        void dispose()
        {
            foreach(thread; threads)
                thread.dispose();
            destroy(threads);
            destroy(awaitSemaphore);
            destroy(handlersMutex);
        }
    }

}
else
{
    class DebugMutex
    {
        final void lock(){}
        final void unlock(){}
    }
    class HipWorkerPool
    {
        private HipWorkerThread thread;
        private void delegate()[] finishHandlersOnMainThread;
        this(size_t poolSize)
        {
            thread = new HipWorkerThread(this);
        }
        void delegate(string name) notifyOnFinish(void delegate(string taskName) onFinish)
        {
            return (name)
            {
                finishHandlersOnMainThread~= (){onFinish(name);};
            };
        }
        final void await()
        {
            version(WebAssembly) assert(false, "Code using await does not work on WebAssembly.");
        }
        final void pollFinished()
        {
            if(finishHandlersOnMainThread.length)
            {
                foreach(handler; finishHandlersOnMainThread)
                    handler();
                finishHandlersOnMainThread.length = 0;
            }
        }
        final HipWorkerThread pushTask(string name, void delegate() task, void delegate(string taskName) onTaskFinish = null, bool isOnFinishOnMainThread = true)
        {
            version(WebAssembly)
                assert(onTaskFinish is null, "Can't have an onTaskFinish on Wasm, implement it on a higher level using notfyOnFinish.");
            thread.pushTask(name, task, onTaskFinish);
            return thread;
        }
        final void startWorking(){thread.startWorking();}
        final void finish(){}
        final bool isIdle(){return thread.isIdle;}
        final void dispose(){}
    }
    class HipWorkerThread
    {
        struct WorkerTask
        {
            void delegate() task;
            void delegate(string taskName) onTaskFinish;
            string name;
        }
        WorkerTask[] tasks;

        this(HipWorkerPool pool){}
        final void pushTask(string name, void delegate() task, void delegate(string taskName) onTaskFinish = null)
        {
            tasks~= WorkerTask(task, onTaskFinish, name);
        }

        final void startWorking()
        {
            foreach(task; tasks)           
            {
                task.task();
                if(task.onTaskFinish)
                    task.onTaskFinish(task.name);
            }
            tasks.length = 0;
        }

        bool isIdle(){return tasks.length == 0;}
    }
}