/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.systems.compilewatcher;

version(Load_DScript):
import fswatch;
import std.concurrency;
import hip.util.path;
import std.datetime.stopwatch;
import core.time:Duration,dur;
import hip.util.system;

pragma(inline, true) private bool hasExtension(string file, ref immutable(string[]) extensions)
{
    file = extension(file);
    foreach(e;extensions) if(file == e) return true;
    return false;
}


//Don't wait at all
private __gshared Duration timeout = dur!"nsecs"(-1);

enum WatchFSDelay = 250;

void watchFs(Tid tid, string watchDir,
immutable(string[]) acceptedExtensions, immutable(string[]) ignoreDirs)
{
    import core.thread.osthread:Thread;
    bool shouldWatchFS = true;
    FileWatch watcher = FileWatch(watchDir, true);
    auto stopwatch = StopWatch(AutoStart.yes);
    long lastTime = stopwatch.peek.total!"msecs";
    string lastEventPath;
    while (shouldWatchFS)
	{
        receiveTimeout(timeout, 
        (bool exit) //The data is not important at all
        {
            shouldWatchFS = false;
        });
		foreach (event; watcher.getEvents())
		{
            // if (event.type == FileChangeEventType.create) Although creation is important, it only makes sense
            //When it is imported by any module, so, modify only
            if (event.type == FileChangeEventType.modify)
            {
                if(hasExtension(event.path,acceptedExtensions))
                {
                    lastTime = stopwatch.peek.total!"msecs";
                    lastEventPath = event.path;
                }
                // send(tid, event.path);
            }
            // else if (event.type == FileChangeEventType.remove) Remove should not trigger compilation
        }
        if(lastEventPath && stopwatch.peek.total!"msecs" - lastTime > WatchFSDelay)
        {
            send(tid, lastEventPath);
            lastEventPath = null;
        }
        // if (event.type == FileChangeEventType.rename) (Rename should not compile, it is not important)
        // else if (event.type == FileChangeEventType.createSelf) The folder should not be created while watching
        // else if (event.type == FileChangeEventType.removeSelf) It should not be removed while watching

        Thread.sleep(dur!"msecs"(30)); //Saves a lot of CPU Time
    }
    stopwatch.stop();
    send(tid, true);
}

class CompileWatcher
{
    string watchDir;
    string[] acceptedExtensions;
    string[] ignoredDirs;
    void function(string fileName) handler;
    Tid worker;

    bool isRunning = false;

    this(string watchDir, void function(string fileName) handler = null, 
    string[] acceptedExtensions = [], string[] ignoredDirs = [])
    {
        this.watchDir = watchDir;
        foreach(ext; acceptedExtensions)
        {
            if(ext[0] != '.')
                this.acceptedExtensions~= '.' ~ ext;
            else
                this.acceptedExtensions~=ext;
        }
        this.ignoredDirs = ignoredDirs;
        this.handler = handler;
    }

    CompileWatcher run()
    {
        assert(!isRunning,  "CompileWatcher is already running");
        // assert(handler != null, "CompileWatcher must have some handler before running");
        isRunning = true;
        worker = spawn(&watchFs, thisTid, watchDir, 
        acceptedExtensions.idup, ignoredDirs.idup);
        return this;
    }
    void stop()
    {
        if(isRunning)
            send(worker, true);
    }

    string update()
    {
        string ret;
        if(isRunning)
        {
            receiveTimeout(timeout, 
            (string file)
            {
                ret = file;
            });
        }
        return ret;
    }

    ~this()
    {
        stop();
    }
}