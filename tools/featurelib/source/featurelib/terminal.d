module featurelib.terminal;

import std.conv : text;
static import std.stdio;

enum Color
{
    default_,
    red,
    green,
    yellow,
    blue,
    cyan,
    magenta,
}

/// Minimal backend a host application must provide. Map these to its own terminal.
interface TerminalBackend
{
    void write(const(char)[] text);
    void writeln(const(char)[] text);
    void writelnError(const(char)[] text);
    void writelnHighlighted(const(char)[] text);
    void writelnSuccess(const(char)[] text);
    string getline(const(char)[] message);
    int cursorY();
    void moveTo(int x, int y);
    void clearToEndOfLine();
    void clear();
    void flush();
    void hideCursor();
    void showCursor();
    void color(Color main, Color secondary);
}

/// Input used for explicit user permission. Kept separate because hosts usually
/// own raw terminal input independently from output.
interface ConsoleInput
{
    dchar getch();
}

/// Ergonomic wrapper over TerminalBackend. Mirrors the hbuild terminal API so
/// feature code reads the same: `t.writeln(...)`, `t.writelnError(...)`.
struct Terminal
{
    private TerminalBackend backend;

    this(TerminalBackend backend)
    {
        this.backend = backend;
    }

    bool valid() const { return backend !is null; }

    void write(A...)(A args)
    {
        if (!backend) return;
        static if (A.length) backend.write(text(args));
    }

    void writeln(A...)(A args)
    {
        if (!backend) return;
        static if (A.length) backend.writeln(text(args));
        else backend.writeln("");
    }

    void writelnError(A...)(A args)
    {
        if (!backend) return;
        static if (A.length) backend.writelnError(text(args));
        else backend.writelnError("");
    }

    void writelnHighlighted(A...)(A args)
    {
        if (!backend) return;
        static if (A.length) backend.writelnHighlighted(text(args));
        else backend.writelnHighlighted("");
    }

    void writelnSuccess(A...)(A args)
    {
        if (!backend) return;
        static if (A.length) backend.writelnSuccess(text(args));
        else backend.writelnSuccess("");
    }

    string getline(const(char)[] message) { return backend ? backend.getline(message) : null; }
    int cursorY() { return backend ? backend.cursorY() : 0; }
    void moveTo(int x, int y) { if (backend) backend.moveTo(x, y); }
    void clearToEndOfLine() { if (backend) backend.clearToEndOfLine(); }
    void clear() { if (backend) backend.clear(); }
    void clearLine()
    {
        int y = cursorY();
        moveTo(0, y);
        clearToEndOfLine();
        flush();
    }
    void flush() { if (backend) backend.flush(); }
    void hideCursor() { if (backend) backend.hideCursor(); }
    void showCursor() { if (backend) backend.showCursor(); }
    void color(Color main, Color secondary) { if (backend) backend.color(main, secondary); }
}

/// For embedding/tests where no output is wanted.
class NullTerminalBackend : TerminalBackend
{
    void write(const(char)[] text) {}
    void writeln(const(char)[] text) {}
    void writelnError(const(char)[] text) {}
    void writelnHighlighted(const(char)[] text) {}
    void writelnSuccess(const(char)[] text) {}
    string getline(const(char)[] message) { return null; }
    int cursorY() { return 0; }
    void moveTo(int x, int y) {}
    void clearToEndOfLine() {}
    void clear() {}
    void flush() {}
    void hideCursor() {}
    void showCursor() {}
    void color(Color main, Color secondary) {}
}

/// Basic stdout backend. Hosts with a richer terminal (colors, cursor control)
/// should implement TerminalBackend themselves.
class StdoutTerminalBackend : TerminalBackend
{
    void write(const(char)[] text) { std.stdio.write(text); }
    void writeln(const(char)[] text) { std.stdio.writeln(text); }
    void writelnError(const(char)[] text) { std.stdio.stderr.writeln(text); }
    void writelnHighlighted(const(char)[] text) { std.stdio.writeln(text); }
    void writelnSuccess(const(char)[] text) { std.stdio.writeln(text); }

    string getline(const(char)[] message)
    {
        import std.string : strip;
        if (message.length)
        {
            write(message);
            flush();
        }
        return std.stdio.readln().strip.idup;
    }

    int cursorY() { return 0; }
    void moveTo(int x, int y) {}
    void clearToEndOfLine() { std.stdio.write("\x1b[K"); }
    void clear() { std.stdio.write("\x1b[2J\x1b[H"); std.stdio.stdout.flush; }
    void flush() { std.stdio.stdout.flush; }
    void hideCursor() { std.stdio.write("\x1b[?25l"); }
    void showCursor() { std.stdio.write("\x1b[?25h"); }
    void color(Color main, Color secondary) {}
}

class NullConsoleInput : ConsoleInput
{
    dchar getch() { return '\0'; }
}

/// shortcut: line-based input; hosts that need single-key input should supply
/// their own ConsoleInput (hbuild already does).
class StdinConsoleInput : ConsoleInput
{
    dchar getch()
    {
        auto line = std.stdio.readln();
        return line.length ? line[0] : '\0';
    }
}

bool pollForExecutionPermission(ref Terminal t, ConsoleInput input, string operation)
{
    t.writelnHighlighted(operation ~ " [Y]es/[N]o");
    t.flush();
    while (true)
    {
        switch (input.getch())
        {
            case 'y', 'Y': return true;
            case 'n', 'N': return false;
            default: break;
        }
    }
}

package(featurelib) class RecordingTerminalBackend : TerminalBackend
{
    string[] calls;

    void write(const(char)[] text) { calls ~= "write"; }
    void writeln(const(char)[] text) { calls ~= "writeln"; }
    void writelnError(const(char)[] text) { calls ~= "writelnError"; }
    void writelnHighlighted(const(char)[] text) { calls ~= "writelnHighlighted"; }
    void writelnSuccess(const(char)[] text) { calls ~= "writelnSuccess"; }
    string getline(const(char)[] message) { calls ~= "getline"; return "line"; }
    int cursorY() { calls ~= "cursorY"; return 7; }
    void moveTo(int x, int y) { calls ~= "moveTo"; }
    void clearToEndOfLine() { calls ~= "clearToEndOfLine"; }
    void clear() { calls ~= "clear"; }
    void flush() { calls ~= "flush"; }
    void hideCursor() { calls ~= "hideCursor"; }
    void showCursor() { calls ~= "showCursor"; }
    void color(Color main, Color secondary) { calls ~= "color"; }
}

unittest
{
    auto rec = new RecordingTerminalBackend();
    Terminal t = Terminal(rec);
    t.moveTo(2, 3);
    t.clearToEndOfLine();
    t.clearLine();
    t.clear();
    t.color(Color.green, Color.default_);
    t.hideCursor();
    t.showCursor();
    t.flush();

    assert(rec.calls == [
        "moveTo",
        "clearToEndOfLine",
        "cursorY",
        "moveTo",
        "clearToEndOfLine",
        "flush",
        "clear",
        "color",
        "hideCursor",
        "showCursor",
        "flush",
    ]);
}
