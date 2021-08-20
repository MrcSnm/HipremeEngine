module preparesdl;
import std;
import core.thread.osthread;

string SDL_zip = "SDL_deps.zip";
string project_dir = "./SDL2/android-project/app/jni/";

static enum string[string] targetLinks = 
{
    string[string] _;
    _["SDL2"] = "SDL2",
    _["SDL2_image"] = "SDL2_image-2.0.5";
    _["SDL2_mixer"] = "SDL2_mixer-2.0.4";
    _["SDL2_net"] = "SDL2_net-2.0.1";
    _["SDL2_ttf"] = "SDL2_ttf-2.0.15";
    return _;
}();

class UnzipperThread : Thread
{
    uint count = 0;
    string[] files;
    string zipName;
    this(string name)
    {
        super(&run);
        zipName = name;
    }
    void run()
    {
        auto zip = new ZipArchive(read(zipName));
        foreach(name, am; zip.directory)
        {
            string mdir = name[0..lastIndexOf(name, "/")+1];
            if(mdir!=name)
            {
                if(exists(name))
                    count++;
                else
                {
                    mkdirRecurse(mdir);
                    files~=name;
                    std.file.write(name, zip.expand(am));
                }
            }
        }
    }
}

/**
*   Windows requires admin privilleges
*/
void portablesymlink(string original, string target)
{
    const(char[])[] cmd;
    original = original.asNormalizedPath.array;
    target = target.asNormalizedPath.array;
    version(Windows)
    {
        cmd = ["mklink", "/D", getcwd()~"\\"~target, getcwd()~"\\"~original ];
        const auto ret = executeShell(cmd.join(" "));
        if(ret.status != 0)
            throw new Error("Could not create a symbolic link from " ~ original ~ " to "~target);
    }
    else
    {
        cmd = ["ln", "-s", getcwd()~"/"~original, target];
        const auto ret = execute(cmd);
        if(ret.status != 0)
            throw new Error("Could not create a symbolic link from " ~ original ~ " to "~target);
    }
}



void main()
{
    UnzipperThread t = new UnzipperThread(SDL_zip);
    uint count;
    writeln("Starting file read "~SDL_zip);

    t.start();
    string toPrint;
    while(t.isRunning)
    {
        if(count < t.files.length)
        {
            toPrint = t.files[count++];
            writeln(toPrint);
        }
    }
    if(count != t.files.length)
    {
        writeln(t.files.length, " files were expanded. ", count, " names was shown");
    }
    count = t.count;
    if(count != 0)
    {
        writeln("\nSkipped "~to!string(count)~" files");
    }
writeln(r"
--------------------------------------------------
Finished extracting zip, writing symbolic links
-------------------------------------------------");


foreach(linkName, directoryName; targetLinks)
{
    string target = project_dir~linkName;
    if(!exists(target))
    {
        portablesymlink(directoryName, target);
        writeln("Generating Symlink from '"~directoryName~"' to "~target);
    }
    else
    {
        writeln("Symlink '"~linkName~"' already exists");
    }
}

writeln(r"
--------------------------------------------------
Finished generating symbolic links
-------------------------------------------------");

}