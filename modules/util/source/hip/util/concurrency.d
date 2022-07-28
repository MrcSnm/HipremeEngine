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

version(HipConcurrency):

/**
*   Creates a function definition for shared an unshared.
*/
mixin template concurrent(string func)
{
    mixin(func);
    mixin("shared "~func);
}

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
    private int currentTask = 0;
    private Mutex mutex;



    this()
    {
        super(&run);
        isAlive = true;
        semaphore = new Semaphore;
        mutex = new Mutex();
    }
    /**
    *   This thread goes into an invalid state after finishing it. It should not be used anymore
    */
    void finish()
    {
        mutex.lock;
        isAlive = false;
        semaphore.notify;
        mutex.unlock;
    }
    bool isIdle()
    {
        mutex.lock();
        bool ret = jobsQueue.length == currentTask;
        mutex.unlock();
        return ret;
    }
    /**
    *   Synchronized push on queue
    */
    void pushTask(string name, void delegate() task, void delegate(string taskName) onTaskFinish = null)
    {
        mutex.lock();
        assert(isAlive, "Can't push a task to a worker that is has finished/awaited");
        jobsQueue~= WorkerJob(name, task, onTaskFinish);
        semaphore.notify();
        if(!isRunning)
            start();
        mutex.unlock();
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
                WorkerJob job = jobsQueue[currentTask];
                mutex.unlock();
                job.task();
                if(job.onTaskFinish != null)
                    job.onTaskFinish(job.name);
                currentTask++;
            }
            semaphore.wait;
        }
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
    protected Mutex handlersMutex;

    this(size_t poolSize)
    {
        threads = new HipWorkerThread[](poolSize);
        handlersMutex = new Mutex();
        for(size_t i = 0; i < poolSize; i++)
            threads[i] = new HipWorkerThread();
    }
    void await()
    {
        uint idleCount = 0;
        foreach(thread; threads)
        {
            if(!thread.isIdle)
            {
                thread.pushTask("Await", (){awaitSemaphore.notify;});
                idleCount++;
            }
        }
        if(idleCount != 0)
        {
            awaitSemaphore = new Semaphore(idleCount);
            awaitSemaphore.wait();
        }
    }
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
        task();
        if(onTaskFinish != null)
            onTaskFinish(name);
        return null;
    }

    void delegate(string name) notifyOnFinish(void delegate(string taskName) onFinish)
    {
        return (name)
        {
            imported!"std.stdio".writeln("Finished ", name);

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
            foreach(finishHandler; finishHandlersOnMainThread)
                finishHandler();
            if(finishHandlersOnMainThread.length)
            {
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