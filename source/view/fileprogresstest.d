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
import def.debugging.log;
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
        rawlog("NonFile took ", Time.getCurrentTime() - msecs, "ms");

        msecs = Time.getCurrentTime();



        File f = File("test.zip", "r");
        ulong sz = f.size;
        ubyte[] data = new ubyte[sz];
        f.rawRead(data);
        f.close();
        rawlog("NonProgression took ", Time.getCurrentTime() - msecs, "ms");


        FileProgression fp = new FileProgression("test.zip", 10);
        msecs = Time.getCurrentTime();
        while(fp.update()){}
        rawlog("Progression took ", Time.getCurrentTime() - msecs, "ms");

    }
    override void render()
    {

    }
}