module featurelib.download;

import std.conv : to;
import std.datetime.stopwatch : StopWatch, AutoStart;
import std.file;
import std.path : dirName;
import featurelib.terminal : Terminal, Color, ConsoleInput, pollForExecutionPermission;

/// Same as std.net.curl.download, but reports progress and returns the elapsed
/// download time in milliseconds.
size_t downloadWithProgress(
    string url,
    string saveToPath,
    void delegate(float) onProgress,
    size_t updateDelay = 125)
{
    import core.time : dur;
    import std.concurrency : receiveOnly, receiveTimeout, send, spawn, ownerTid;
    import std.net.curl : HTTP;
    import std.stdio : File;

    size_t received, contentLength;
    HTTP conn = HTTP();
    conn.url = url;

    string targetDir = dirName(saveToPath);
    if (!std.file.exists(targetDir))
        std.file.mkdirRecurse(targetDir);

    string tempSave = saveToPath ~ ".tmp";

    static void writer(string path)
    {
        auto f = File(path, "wb");
        while (true)
        {
            immutable(ubyte)[] data = receiveOnly!(immutable(ubyte)[]);
            if (data.length == 0)
                break;
            f.rawWrite(data);
        }
        ownerTid.send(true);
    }

    auto writerTid = spawn(&writer, tempSave);
    StopWatch updateDelayChecker = StopWatch(AutoStart.yes);
    size_t downloadTime;

    conn.onReceive = (ubyte[] data)
    {
        if (contentLength == 0)
            contentLength = conn.responseHeaders["content-length"].to!size_t;
        received += data.length;
        if (updateDelayChecker.peek.total!"msecs" >= updateDelay || received == contentLength)
        {
            downloadTime += updateDelayChecker.peek.total!"msecs";
            onProgress(contentLength ? cast(float) received / contentLength : 0f);
            updateDelayChecker.reset();
        }
        send(writerTid, data.idup);
        return data.length;
    };

    conn.perform();
    send(writerTid, (immutable(ubyte)[]).init);
    receiveTimeout(dur!"msecs"(1000), (bool) {});
    rename(tempSave, saveToPath);
    return downloadTime;
}

size_t downloadWithProgressBar(
    ref Terminal t,
    string url,
    string saveToPath,
    size_t updateDelay = 125)
{
    t.hideCursor();
    scope (exit)
    {
        t.showCursor();
        t.writeln("");
    }
    return downloadWithProgress(url, saveToPath, (float progress) {
        terminalProgressBar(t, progress);
    }, updateDelay);
}

private void terminalProgressBar(ref Terminal t, float percentage, ubyte ticksCount = 32)
{
    assert(percentage <= 1.0 && percentage >= 0, "Invalid percentage.");

    ubyte drawnTicks = cast(ubyte) (ticksCount * percentage);
    t.write("\r");
    t.clearToEndOfLine();
    t.write("<");
    foreach (int i; 0 .. ticksCount)
    {
        t.color(i < drawnTicks ? Color.green : Color.red, Color.default_);
        t.write(i < drawnTicks ? "=" : ".");
    }
    t.color(Color.default_, Color.default_);
    t.write("> (", percentage * 100, "%)");
    t.flush();
}

bool downloadFileIfNotExists(
    string purpose,
    string link,
    string outputName,
    ref Terminal t,
    ConsoleInput input)
{
    string targetDir = dirName(outputName);
    if (!std.file.exists(targetDir))
        std.file.mkdirRecurse(targetDir);

    if (!std.file.exists(outputName))
    {
        if (!pollForExecutionPermission(t, input,
            "Your system will download a file: " ~ purpose ~ "(" ~ link ~ ")"))
            return false;
        t.writelnHighlighted("Download started.");
        t.flush();
        size_t time = downloadWithProgressBar(t, link, outputName);
        t.writelnSuccess("\nDownload succeeded after ", time.to!string, " msecs!");
        t.flush();
    }
    return true;
}

unittest
{
    import featurelib.terminal : RecordingTerminalBackend;
    import std.algorithm : canFind;

    auto rec = new RecordingTerminalBackend();
    Terminal t = Terminal(rec);
    terminalProgressBar(t, 0.5f, 4);

    assert(rec.calls.length >= 2);
    assert(rec.calls[0] == "write");
    assert(rec.calls[1] == "clearToEndOfLine");
    assert(!rec.calls.canFind("cursorY"));
    assert(!rec.calls.canFind("moveTo"));
}
