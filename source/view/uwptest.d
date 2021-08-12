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

        HipFS.readText("assets/graphics/sprite.png", strData);
        rawlog("Working dir: ", getcwd());
        rawlog(strData);
    }
}