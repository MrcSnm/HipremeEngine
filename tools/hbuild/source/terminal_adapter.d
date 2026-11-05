module terminal_adapter;

static import arsd.terminal;
import core.sync.mutex : Mutex;
import featurelib.terminal : TerminalBackend, ConsoleInput, Color;

private arsd.terminal.Color toArsd(Color c)
{
    final switch (c)
    {
        case Color.default_: return arsd.terminal.Color.DEFAULT;
        case Color.red: return arsd.terminal.Color.red;
        case Color.green: return arsd.terminal.Color.green;
        case Color.yellow: return arsd.terminal.Color.yellow;
        case Color.blue: return arsd.terminal.Color.blue;
        case Color.cyan: return arsd.terminal.Color.cyan;
        case Color.magenta: return arsd.terminal.Color.magenta;
    }
}

class ArsdTerminalBackend : TerminalBackend
{
    private arsd.terminal.Terminal* term;
    private Mutex mtx;

    this(arsd.terminal.Terminal* term)
    {
        this.term = term;
        mtx = new Mutex();
    }

    ~this()
    {
        if (term)
        {
            term.showCursor();
            destroy(*term);
            term = null;
        }
    }

    void write(const(char)[] text) { synchronized (mtx) term.write(text); }
    void writeln(const(char)[] text) { synchronized (mtx) term.writeln(text); }

    void writelnError(const(char)[] text)
    {
        synchronized (mtx)
            withArsdColor(arsd.terminal.Color.red, text);
    }

    void writelnHighlighted(const(char)[] text)
    {
        synchronized (mtx)
            withArsdColor(arsd.terminal.Color.yellow, text);
    }

    void writelnSuccess(const(char)[] text)
    {
        synchronized (mtx)
            withArsdColor(arsd.terminal.Color.green, text);
    }

    private void withArsdColor(arsd.terminal.Color c, const(char)[] text)
    {
        term.color(c, arsd.terminal.Color.DEFAULT);
        term.writeln(text);
        term.color(arsd.terminal.Color.DEFAULT, arsd.terminal.Color.DEFAULT);
    }

    string getline(const(char)[] message)
    {
        synchronized (mtx)
            return term.getline(message.idup);
    }

    int cursorY()
    {
        synchronized (mtx)
        {
            try term.updateCursorPosition();
            catch (Exception) return 0;
            return term.cursorY;
        }
    }

    void moveTo(int x, int y) { synchronized (mtx) term.moveTo(x, y); }
    void clearToEndOfLine() { synchronized (mtx) term.clearToEndOfLine(); }
    void clear() { synchronized (mtx) term.clear(); }

    void flush()
    {
        synchronized (mtx)
        {
            term.flush();
            try term.updateCursorPosition();
            catch (Exception) {}
        }
    }

    void hideCursor() { synchronized (mtx) term.hideCursor(); }
    void showCursor() { synchronized (mtx) term.showCursor(); }

    void color(Color main, Color secondary)
    {
        synchronized (mtx)
            term.color(toArsd(main), toArsd(secondary));
    }
}

class ArsdConsoleInput : ConsoleInput
{
    private arsd.terminal.RealTimeConsoleInput* input;

    this(arsd.terminal.RealTimeConsoleInput* input)
    {
        this.input = input;
    }

    ~this()
    {
        if (input)
        {
            destroy(*input);
            input = null;
        }
    }

    dchar getch()
    {
        return input.getch();
    }
}
