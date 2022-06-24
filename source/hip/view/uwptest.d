/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.view.uwptest;
import hip.console.log;
import hip.view.scene;
class UwpTestScene : Scene
{
    this()
    {
        import hip.filesystem.hipfs;
        string strData;

        HipFS.readText("assets/graphics/sprite.png", strData);
        rawlog("Working dir: ", HipFS.getcwd());
        rawlog(strData);
    }
}