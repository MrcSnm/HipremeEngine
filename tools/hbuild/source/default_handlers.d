module default_handlers;
import std.file;
import std.process;
import std.path;

bool openDefaultBrowser(string link)
{
	string command;
	version(Windows) command = "explorer";
	else version(linux) command = "xdg-open";
	else version(OSX) command = "open";
	return executeShell(command~" "~link).status == 0;
}

version(Windows)
bool getDefaultSourceEditor(string referenceFile, out string defaultTextEditor)
{
    import core.sys.windows.shellapi;
    import std.string;
    char[256] output;
    void* err = FindExecutableA(toStringz(buildNormalizedPath(referenceFile)), null, output.ptr);
    if(err <= SE_ERR_ACCESSDENIED)
        return false;
    defaultTextEditor = fromStringz(output).idup;
    return true;
}
else version(OSX)
{
    import objc.runtime;
    import objc.meta;
    alias selector = objc.meta.selector;

    @ObjectiveC extern(C++) final
    {
        class NSWorkspace
        {
            @selector("sharedWorkspace")
            static NSWorkspace sharedWorkspace();

            @selector("URLForApplicationToOpenURL:")
            NSURL URLForApplicationToOpenURL(NSURL);
        }
    }
    mixin ObjcLinkModule!(default_handlers);
    mixin ObjcInitSelectors!(__traits(parent, {}));

    bool getDefaultSourceEditor(string referenceFile, out string defaultTextEditor)
    {
        string base = NSWorkspace.sharedWorkspace.URLForApplicationToOpenURL(
            NSURL.fileURLWithPath(referenceFile.ns)).path.toString;
        if(base.length == 0) return false;
        static bool isExecutable(string name){return name.extension == null;}
        if(base.extension == ".app")
        {
            base~= "/Contents/MacOS/";
            foreach(DirEntry e; dirEntries(base, SpanMode.shallow))
            {
                if(isExecutable(e.name))
                {
                    defaultTextEditor = e.name;
                    break;
                }
            }
        }
        return true;
    }
}
else version(linux)
{
    bool getDefaultSourceEditor(string referenceFile, out string defaultTextEditor)
    {
        return false;
    }
}

