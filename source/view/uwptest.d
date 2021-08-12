module view.uwptest;
import def.debugging.log;
import view.scene;
class UwpTestScene : Scene
{
    this()
    {
        import data.hipfs;
        import std.conv:to;
        string strData;

        HipFS.readText("renderer.conf", strData);
        rawlog("Working dir: ", getcwd());
        rawlog(strData);
    }
}