module view.fileprogresstest;
import std.stdio;
import util.file;
import util.time;
import view;

class FileProgressTest : Scene
{
    this()
    {
        import std.file :read;
        float msecs;
        msecs = Time.getCurrentTime();
        ubyte[] dt = cast(ubyte[])read("test.zip");
        writeln("NonFile took ", Time.getCurrentTime() - msecs, "ms");

        msecs = Time.getCurrentTime();



        File f = File("test.zip", "r");
        ulong sz = f.size;
        ubyte[] data = new ubyte[sz];
        f.rawRead(data);
        f.close();
        writeln("NonProgression took ", Time.getCurrentTime() - msecs, "ms");


        FileProgression fp = new FileProgression("test.zip", 10);
        msecs = Time.getCurrentTime();
        while(fp.update()){}
        writeln("Progression took ", Time.getCurrentTime() - msecs, "ms");

    }
    override void render()
    {

    }
}