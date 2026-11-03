module hip.console.report;

private struct ReportRow
{
    string key;
    string value;
}

private struct ReportSection
{
    string title;
    string file;
    size_t line;
    ReportRow[] rows;
}

private __gshared ReportSection[] sections;
private __gshared bool flushed;

///True after the startup report has been printed at least once.
bool reportWasFlushed(){return flushed;}

private ReportSection* getSection(string title, string file, size_t line)
{
    foreach(i, ref s; sections)
        if(s.title == title)
            return &sections[i];
    sections ~= ReportSection(title, file, line, null);
    return &sections[$-1];
}

private void addRow(string section, string key, string value, string file, size_t line)
{
    getSection(section, file, line).rows ~= ReportRow(key, value);
}

///Buffers a key/value until flushReport is called at the end of startup.
///__FILE__/__LINE__ default to the caller, so the table title can be clicked.
void reportRow(Args...)(string section, string key, Args args,
    string file = __FILE__, size_t line = __LINE__)
{
    import hip.util.string : BigString;
    // BigString lives on the stack, so copy its slice before storing it.
    addRow(section, key, BigString(args).toString.dup, file, line);
}

///Convenience timer that appends a "timings" row on each report() call.
struct ReportTimer
{
    private long last;

    static ReportTimer start()
    {
        ReportTimer ret;
        ret.last = now();
        return ret;
    }

    void report(string name, string file = __FILE__, size_t line = __LINE__)
    {
        long elapsed = lap();
        if(elapsed < 0)
            return;
        import hip.util.string : BigString;
        addRow("timings", name, BigString(elapsed, " ms").toString.dup, file, line);
    }

    private static long now()
    {
        import hip.util.time : HipTime;
        return HipTime.tryGetCurrentTimeAsMsLong();
    }

    ///Returns the elapsed ms since the last lap, or -1 without a time source.
    long lap()
    {
        long current = now();
        if(current < 0 || last < 0)
        {
            last = current;
            return -1;
        }
        long elapsed = current - last;
        last = current;
        return elapsed;
    }
}

private string repeatChar(char c, size_t count)
{
    char[] ret;
    ret.length = count;
    ret[] = c;
    return cast(string)ret;
}

private string padRight(string value, size_t width)
{
    if(value.length >= width)
        return value;
    import core.stdc.string : memcpy;
    char[] ret;
    ret.length = width;
    ret[] = ' ';
    memcpy(ret.ptr, value.ptr, value.length);
    return cast(string)ret;
}

///Prints every buffered section as an aligned key/value table.
void flushReport()
{
    import hip.console.log : rawlog;
    import hip.util.string : BigString;
    if(sections.length == 0)
        return;

    string output;
    foreach(s; sections)
    {
        if(output.length != 0)
            output ~= "\n";

        size_t keyWidth, valueWidth;
        foreach(r; s.rows)
        {
            if(r.key.length > keyWidth) keyWidth = r.key.length;
            if(r.value.length > valueWidth) valueWidth = r.value.length;
        }

        output ~= "[" ~ s.title ~ "]  " ~ BigString(s.file, ":", s.line).toString ~ "\n";
        output ~= "+" ~ repeatChar('-', keyWidth + 2) ~ "+" ~ repeatChar('-', valueWidth + 2) ~ "+\n";
        foreach(r; s.rows)
            output ~= "| " ~ padRight(r.key, keyWidth) ~ " | " ~ padRight(r.value, valueWidth) ~ " |\n";
        output ~= "+" ~ repeatChar('-', keyWidth + 2) ~ "+" ~ repeatChar('-', valueWidth + 2) ~ "+\n";
    }

    if(output.length != 0 && output[$-1] == '\n')
        output = output[0..$-1];
    rawlog(output);
    sections = null;
    flushed = true;
}
