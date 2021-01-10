module util.file;
import std.file;
import util.system;

string getFileContent(string path)
{
    path = sanitizePath(path);
    if(!exists(path))
        return "";
    
    return readText(path);
}