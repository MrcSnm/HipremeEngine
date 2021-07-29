module view.fileprogresstest;
import std.stdio;
import util.file;
import util.time;
import view;

class FileProgressTest : Scene
{
    this()
    {
        float msecs;
        msecs = Time.getCurrentTime();
        File f = File("test.zip", "r");
        ulong sz = f.size;
        ubyte[] data = new ubyte[sz];
        f.rawRead(data);
        f.close();
        writeln("NonProgression took ", Time.getCurrentTime() - msecs, "ms");


        FileProgression fp = new FileProgression("test.zip");
        msecs = Time.getCurrentTime();
        while(fp.update()){}
        writeln("Progression took ", Time.getCurrentTime() - msecs, "ms");

        writeln(fp.getProgress());

    }
    override void render()
    {

    }
}