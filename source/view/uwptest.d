/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

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