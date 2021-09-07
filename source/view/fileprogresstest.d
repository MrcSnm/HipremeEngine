/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module view.fileprogresstest;
import std.stdio;
import console.log;
import util.file;
import util.time;
import view;

class FileProgressTest : Scene
{
    this()
    {
        import std.file :read;
        float msecs;
        msecs = HipTime.getCurrentTimeAsMilliseconds();
        ubyte[] dt = cast(ubyte[])read("test.zip");
        rawlog("NonFile took ", HipTime.getCurrentTimeAsMilliseconds() - msecs, "ms");

        msecs = HipTime.getCurrentTimeAsMilliseconds();



        File f = File("test.zip", "r");
        ulong sz = f.size;
        ubyte[] data = new ubyte[sz];
        f.rawRead(data);
        f.close();
        rawlog("NonProgression took ", HipTime.getCurrentTimeAsMilliseconds() - msecs, "ms");


        FileProgression fp = new FileProgression("test.zip", 10);
        msecs = HipTime.getCurrentTimeAsMilliseconds();
        while(fp.update()){}
        rawlog("Progression took ", HipTime.getCurrentTimeAsMilliseconds() - msecs, "ms");

    }
    override void render()
    {

    }
}