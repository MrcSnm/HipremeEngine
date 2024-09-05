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

import core.thread;

pragma(inline, true) private bool hasExtension(string file, ref immutable(string[]) extensions)
{
    import hip.util.path;
    file = extension(file);
    foreach(e;extensions) if(file == e) return true;
    return false;
}

class WatcherThread : Thread
{
    string watchDir;
    immutable(string[]) acceptedExtensions, ignoreDirs;
    private bool shouldWatchFS = true;
    CompileWatcher compileWatcher;
    this(string watchDir, immutable(string[]) acceptedExtensions, immutable(string[]) ignoreDirs, CompileWatcher cmpWatcher)
    {
        super(&run);
        this.watchDir = watchDir;
        this.acceptedExtensions = acceptedExtensions;
        this.ignoreDirs = ignoreDirs;
        this.compileWatcher = cmpWatcher;
    }

    void stop()
    {
        this.shouldWatchFS = false;
    }
    void run()
    {
        import core.time:dur;
        import fswatch;
        FileWatch watcher = FileWatch(watchDir, true);
        string lastEventPath;

        while (shouldWatchFS)
        {
            bool gotNew;
        	foreach (event; watcher.getEvents())
        	{
                // if (event.type == FileChangeEventType.create) Although creation is important, it only makes sense
                //When it is imported by any module, so, modify only
                if (event.type == FileChangeEventType.modify)
                {
                    if(hasExtension(event.path,acceptedExtensions))
                    {
                        if(lastEventPath != event.path)
                        {
                            lastEventPath = event.path;
                            gotNew = true;
                        }
                    }
                    // send(tid, event.path);
                }
                // else if (event.type == FileChangeEventType.remove) Remove should not trigger compilation
            }
            if(gotNew)
                compileWatcher.onFileEvent(lastEventPath);
            Thread.sleep(dur!"msecs"(1));
            // if (event.type == FileChangeEventType.rename) (Rename should not compile, it is not important)
            // else if (event.type == FileChangeEventType.createSelf) The folder should not be created while watching
            // else if (event.type == FileChangeEventType.removeSelf) It should not be removed while watching
        }
    }
}

private alias CMutex = void*;

///Use these property and function for not allocating closures everytime
class CompileWatcher
{

    string watchDir;
    string[] acceptedExtensions;
    string[] ignoredDirs;


    void function(string fileName) handler;
    WatcherThread watcherThread;
    string lastFile;

    private CMutex _cmutex;

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

    private auto mutex()()
    {
        import core.sync.mutex;
        return cast(Mutex)_cmutex;
    }

    CompileWatcher run()
    {
        import core.sync.mutex;
        assert(!isRunning,  "CompileWatcher is already running");
        // assert(handler != null, "CompileWatcher must have some handler before running");
        isRunning = true;
        watcherThread = new WatcherThread(watchDir, acceptedExtensions.idup, ignoredDirs.idup, this);
        this._cmutex = cast(CMutex)(new Mutex());
        return this;
    }
    private void onFileEvent(string fileName)
    {
        mutex.lock();
        if(fileName != lastFile)
            this.lastFile = fileName.dup;
        mutex.unlock();
    }
    void stop()
    {
        if(isRunning)
            watcherThread.stop();
    }

    string update()
    {
        return lastFile;
    }

    ~this()
    {
        stop();
    }
}