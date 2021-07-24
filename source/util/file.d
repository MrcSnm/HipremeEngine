module util.file;
import std.file;
import util.system;
import util.string;

string getFileContent(string path, bool noCarriageReturn = true)
{
    path = sanitizePath(path);
    if(!exists(path))
        return "";
    string content = readText(path);
    return (noCarriageReturn) ? content.replaceAll('\r') : content;
}