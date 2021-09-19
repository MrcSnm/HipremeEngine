// D import file generated from 'source\view\uwptest.d'
module view.uwptest;
import console.log;
import view.scene;
class UwpTestScene : Scene
{
	this()
	{
		import data.hipfs;
		string strData;
		HipFS.readText("assets/graphics/sprite.png", strData);
		rawlog("Working dir: ", HipFS.getcwd());
		rawlog(strData);
	}
}
