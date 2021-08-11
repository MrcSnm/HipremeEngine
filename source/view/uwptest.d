module view.uwptest;
import def.debugging.log;
import view.scene;
class UwpTestScene : Scene
{
    this()
    {
        import std.file;
        import std.conv:to;

        rawlog("Working dir: ", getcwd());
        rawlog(to!string(read("C:\\Users\\Hipreme\\source\\repos\\CoreApp1\\x64\\Debug\\CoreApp1\\AppX\\renderer.conf")));
    }
}