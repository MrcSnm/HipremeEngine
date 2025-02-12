/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.concurrency.thread;
import hip.concurrency.mutex;
import hip.config.opts;

static if(HipConcurrency)
{
    import core.thread;
    import core.atomic;
    import core.sync.semaphore:Semaphore;

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
        private bool isAlive = false;

        private int jobsCount;
        private DebugMutex mutex;
        private HipWorkerPool pool;
        private ThreadID mainThreadID;


        this(HipWorkerPool pool = null, ThreadID mainThreadID = ThreadID.init)
        {
            super(&run);
            if(pool)
                this.pool = pool;
            isAlive = true;
            semaphore = new Semaphore;
            this.mainThreadID = mainThreadID;
            mutex = new DebugMutex(mainThreadID);
        }
        /**
        *   This thread goes into an invalid state after finishing it. It should not be used anymore
        */
        void finish()
        {
            isAlive.atomicStore = false;
            semaphore.notify;
        }
        bool isIdle()
        {
            return atomicLoad(jobsCount) == 0;
        }
        /**
        *   Synchronized push on queue
        */
        void pushTask(string name, void delegate() task, void delegate(string taskName) onTaskFinish = null)
        {
            if(isAlive.atomicLoad)
            {
                mutex.lock();
                jobsQueue~= WorkerJob(name, task, onTaskFinish);
                jobsCount++;
                mutex.unlock();
                semaphore.notify();
            }
            else
            {
                import hip.console.log;
                logln("Thread is not alive to get tasks.");
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
                if(!isIdle)
                {
                    mutex.lock();
                    WorkerJob job = jobsQueue[0];
                    jobsQueue = jobsQueue[1..$];
                    mutex.unlock();
                    try
                    {
                        job.task();
                        if(job.onTaskFinish != null)
                            job.onTaskFinish(job.name);
                        atomicFetchSub(jobsCount, 1);
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
                }
                semaphore.wait;
            }
        }

        private void onAnyException(bool isError, string message)
        {
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
        protected void delegate()[] onAllTasksFinishHandlers;
        protected DebugMutex handlersMutex;

        private struct Task
        {
            string name;
            void delegate() task;
            void delegate(string taskName) onTaskFinish = null;

            void execTask()
            {
                task();
                if(onTaskFinish)
                    onTaskFinish(name);
            }
        }
        private Task[] mainThreadTasks;
        private uint awaitCount = 0;
        private shared size_t tasksCount;


        this(size_t poolSize)
        {
            threads = new HipWorkerThread[](poolSize);
            import hip.concurrency.internal:thisThreadID;
            auto mainId = thisThreadID;
            handlersMutex = new DebugMutex(mainId);
            for(size_t i = 0; i < poolSize; i++)
                threads[i] = new HipWorkerThread(this, mainId);
            awaitSemaphore = new Semaphore(0);
        }

        void addOnAllTasksFinished(void delegate() onAllFinished)
        {
            if(tasksCount == 0)
                onAllFinished();
            else
                onAllTasksFinishHandlers~= onAllFinished;
        }

        protected void onHipThreadError(HipWorkerThread worker, bool isError, string message)
        {
            if(awaitCount > 0)
            {
                awaitSemaphore.notify();
            }
            import hip.util.array;
            import hip.console.log;
            logln("Worker ", worker.jobsQueue[0].name, " failed with ", isError ? "error" : "exception", ":", message);
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
                        awaitSemaphore.notify;
                    });
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
        *   Adds a task to the pool. If no idle worker is available, the task is executed on the main thread.
        *   Keep in mind that pushin task is not enough. You need to call `startWorking()` to make it active after pushing tasks
        * Params:
        *   name = The name of the task.
        *   task = The task to execute.
        *   onTaskFinish = Callback to execute when the task completes.
        *   isOnFinishOnMainThread = If true, the callback is executed on the main thread.
        *
        * Returns:
        *   The worker thread handling the task or null if the task will be executed on main thread
        */
        HipWorkerThread pushTask(string name, void delegate() task, void delegate(string taskName) onTaskFinish = null, bool isOnFinishOnMainThread = false)
        {
            atomicFetchAdd(tasksCount, 1);
            foreach(i, thread; threads)
            {
                if(thread.isIdle)
                {
                    import hip.console.log;
                    logln("Thread [", i, "] handling task ", name);
                    if(onTaskFinish !is null && isOnFinishOnMainThread)
                        thread.pushTask(name, task, notifyOnFinishOnMainThread(onTaskFinish));
                    else
                        thread.pushTask(name, task, notifyOnFinish(onTaskFinish));
                    return thread;
                }
            }
            handlersMutex.lock();
            scope(exit) handlersMutex.unlock();
            //Execute a main thread task if it had anything.
            mainThreadTasks~= Task(name, task, notifyOnFinish(onTaskFinish));
            return null;
        }

        protected void executeMainThreadTasks()
        {
            handlersMutex.lock();
            Task[] tasks;
            if(mainThreadTasks.length != 0)
            {
                tasks = mainThreadTasks.dup;
                mainThreadTasks.length = 0;
            }
            handlersMutex.unlock();
            foreach(t; tasks)
                t.execTask();
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

        void delegate(string name) notifyOnFinish(void delegate(string taskName) onFinish = null)
        {
            return (name)
            {
                if(onFinish)
                    onFinish(name);
                atomicFetchSub(tasksCount, 1);
            };
        }

        void delegate(string name) notifyOnFinishOnMainThread(void delegate(string taskName) onFinish, bool finished = true)
        {
            return (name)
            {
                handlersMutex.lock();
                    finishHandlersOnMainThread~= ()
                    {
                        onFinish(name);
                        if(finished)
                            atomicFetchSub(tasksCount, 1);
                    };
                handlersMutex.unlock();
            };
        }

        bool isIdle()
        {
            return atomicLoad(tasksCount) == 0;
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
                if(tasksCount == 0 && onAllTasksFinishHandlers.length)
                {
                    foreach(onAllFinish; onAllTasksFinishHandlers)
                        onAllFinish();
                    onAllTasksFinishHandlers.length = 0;
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
    
    class HipWorkerPool
    {
        private HipWorkerThread thread;
        protected void delegate()[] onAllTasksFinishHandlers;
        private void delegate()[] finishHandlersOnMainThread;
        size_t tasksCount = 0;
        void addOnAllTasksFinished(void delegate() onAllFinished)
        {
            if(tasksCount == 0)
                onAllFinished();
            else
                onAllTasksFinishHandlers~= onAllFinished;
        }

        this(size_t poolSize)
        {
            thread = new HipWorkerThread(this, ulong.max);
        }
        void delegate(string name) notifyOnFinishOnMainThread(void delegate(string taskName) onFinish, bool finished = true)
        {
            return (name)
            {
                finishHandlersOnMainThread~= ()
                {
                    onFinish(name); 
                    if(finished)
                        tasksCount--;
                };
            };
        }

        void delegate(string name) notifyOnFinish(void delegate(string taskName) onFinish)
        {
            return (name)
            {
                if(onFinish) onFinish(name);
                version(WebAssembly){}
                else
                    tasksCount--;
            };
        }
        final void signalTaskFinish()
        {
            assert(tasksCount > 0, "Tried to signal task finish without tasks.");
            tasksCount--;
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
            if(tasksCount == 0 && onAllTasksFinishHandlers.length)
            {
                foreach(onAllFinish; onAllTasksFinishHandlers)
                    onAllFinish();
                onAllTasksFinishHandlers.length = 0;
            }
        }
        final HipWorkerThread pushTask(string name, void delegate() task, void delegate(string taskName) onTaskFinish = null, bool isOnFinishOnMainThread = true)
        {
            tasksCount++;
            version(WebAssembly)
                assert(onTaskFinish is null, "Can't have an onTaskFinish on Wasm, implement it on a higher level using notfyOnFinish.");
            thread.pushTask(name, task, notifyOnFinish(onTaskFinish));
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

        this(HipWorkerPool pool, ulong id){}
        final void pushTask(string name, void delegate() task, void delegate(string taskName) onTaskFinish = null)
        {
            tasks~= WorkerTask(task, onTaskFinish, name);
        }

        final void startWorking()
        {
            foreach(task; tasks)           
            {
                task.execTask();
                if(task.onTaskFinish)
                    task.onTaskFinish(task.name);
            }
            tasks.length = 0;
        }

        bool isIdle(){return tasks.length == 0;}
    }
}