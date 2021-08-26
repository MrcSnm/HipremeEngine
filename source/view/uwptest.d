/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module view.uwptest;
import def.debugging.log;
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