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
import core.sync.semaphore:Semaphore;

class HipWorkerThread : Thread
{
    private struct WorkerJob
    {
        string name;
        void delegate() task;
        void delegate(string taskName) onTaskFinish;
    }
    private __gshared WorkerJob[] jobsQueue;
    private __gshared Semaphore semaphore;
    private __gshared bool isAlive;
    protected int currentTask = 0;


    this()
    {
        super(&run);
        isAlive = true;
        semaphore = new Semaphore;
    }

    void finish(){isAlive = false;}
    bool isIdle(){return jobsQueue.length == currentTask;}

    void pushTask(string name, void delegate() task, void delegate(string taskName) onTaskFinish = null)
    {
        assert(isAlive, "Can't push a task to a worker that is has finished/awaited");
        jobsQueue~= WorkerJob(name, task, onTaskFinish);
        semaphore.notify();
        if(!isRunning)
            start();
    }
    void await(bool rethrow = true)
    {
        pushTask("await", () => finish);
        join(rethrow);
    }

    void run()
    {
        while(isAlive)
        {
            import std.stdio;
            if(!isIdle)
            {
                WorkerJob job = jobsQueue[currentTask];
                job.task();
                if(job.onTaskFinish != null)
                    job.onTaskFinish(job.name);
                currentTask++;
                writeln("Finished ", job.name);
            }
            else
                semaphore.wait();
        }
    }
}

class HipWorkerPool
{
    HipWorkerThread[] threads;
    protected Semaphore awaitSemaphore;
    this(size_t poolSize)
    {
        threads = new HipWorkerThread[](poolSize);
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
    HipWorkerThread pushTask(string name, void delegate() task, void delegate(string taskName) onTaskFinish = null)
    {
        foreach(thread; threads)
        {
            if(thread.isIdle)
            {
                thread.pushTask(name, task, onTaskFinish);
                return thread;
            }
        }
        task();
        if(onTaskFinish != null)
            onTaskFinish(name);
        return null;
    }
    bool isIdle()
    {
        size_t count = 0;
        foreach(thread; threads)
            count+= int(thread.isIdle);
        return count == threads.length;
    }
}