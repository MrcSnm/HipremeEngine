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

private ReportSection* getSection(string title, string file, size_t line)
{
    foreach(i, ref s; sections)
        if(s.title == title)
            return &sections[i];
    sections ~= ReportSection(title, file, line, null);
    return &sections[$-1];
}

///Buffers a key/value until flushReport is called at the end of startup.
///__FILE__/__LINE__ default to the caller, so the table title can be clicked.
void reportRow(Args...)(string section, string key, Args args,
    string file = __FILE__, size_t line = __LINE__)
{
    import hip.util.string : BigString;
    // BigString lives on the stack, so copy its slice before storing it.
    getSection(section, file, line).rows ~= ReportRow(key, BigString(args).toString.dup);
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
}
