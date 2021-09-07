/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module graphics.g2d.textureatlas;
import util.file;
import std.conv:to;
import std.algorithm : countUntil;
import util.string;
import std.file;
import data.hipfs;
import hiprenderer.texture;
import math.rect;

struct AtlasFrame
{
    string filename;
    bool rotated;
    bool trimmed;

    Rect frame;
    Rect spriteSourceSize;
    Size sourceSize;
    TextureRegion region;

    alias region this;
}

class TextureAtlas
{
    string atlasPath;
    string[] texturePaths;
    AtlasFrame[string] frames;
    Texture texture;

    static TextureAtlas readJSON(ubyte[] data, string atlasPath, string texturePath)
    {
        import std.json;
        TextureAtlas ret = new TextureAtlas();
        ret.texturePaths~= texturePath;
        ret.atlasPath = atlasPath;

        ret.texture = new Texture(texturePath);

        JSONValue json = parseJSON(cast(string)data);
        JSONValue[] frames = json["frames"].array;
        foreach(f; frames)
        {
            AtlasFrame a;
            a.filename = f["filename"].str;
            a.rotated  = f["rotated"].boolean;
            a.trimmed  = f["trimmed"].boolean;
            JSONValue frameRect = f["frame"].object;
            a.frame = Rect(
                cast(uint)frameRect["x"].integer,
                cast(uint)frameRect["y"].integer,
                cast(uint)frameRect["w"].integer,
                cast(uint)frameRect["h"].integer
            );
            frameRect = f["spriteSourceSize"].object;
            a.spriteSourceSize = Rect(
                cast(uint)frameRect["x"].integer,
                cast(uint)frameRect["y"].integer,
                cast(uint)frameRect["w"].integer,
                cast(uint)frameRect["h"].integer
            );
            frameRect = f["sourceSize"].object;
            a.sourceSize = Size(cast(uint)frameRect["w"].integer, cast(uint)frameRect["h"].integer);
            a.region = new TextureRegion(ret.texture,
            cast(uint)a.frame.x,
            cast(uint)a.frame.y,
            cast(uint)a.frame.x + cast(uint)a.frame.w,
            cast(uint)a.frame.y + cast(uint)a.frame.h);

            ret.frames[a.filename] = a;
        }

        return ret;
    }
    static TextureAtlas readJSON(string atlasPath, string texturePath="")
    {
        ubyte[] data;
        HipFS.read(atlasPath, data);
        if(texturePath == "")
            texturePath = atlasPath[0..atlasPath.lastIndexOf(".")]~".png";
        return readJSON(data, atlasPath, texturePath);
    }

    static TextureAtlas readAtlas(string atlasPath)
    {
        import std.array : split;
        TextureAtlas ret = new TextureAtlas();
        ret.atlasPath = atlasPath;
        string[] lines;
        string atlasFile = getFileContent(atlasPath);
        lines = atlasFile.split("\n");
        int i = 0;
        while(lines[i] == "")
            i++;
        string textureName = lines[i++];
        ret.texturePaths~= textureName;
        string sizeText = lines[i++];
        string format = lines[i++];
        string filter = lines[i++];
        string repeat = lines[i++];
    
        const int offset = i;

        for(; i < lines.length-offset; i+= 7)
        {
            AtlasFrame frame;
            frame.trimmed = false;
            frame.filename = lines[i];

            string rotate = lines[i+1];
                rotate = rotate[rotate.countUntil(":")+2 .. $];
            frame.rotated = to!bool(rotate);

            string xy = lines[i+2];
                xy = xy[xy.countUntil(":")+2 .. $];

            long commaIndex = xy.countUntil(',');
            int x = to!int(xy[0..commaIndex]);
            //To account space must increate 2
            int y = to!int(xy[commaIndex+2..$]);
            
            string size = lines[i+3];
                size = size[size.countUntil(":")+2 .. $];

            commaIndex = size.countUntil(',');
            int sizeW = to!int(size[0..commaIndex]);
            int sizeH = to!int(size[commaIndex+2..$]);

            string orig = lines[i+4];
                orig = orig[orig.countUntil(":")+2 .. $];

            commaIndex = orig.countUntil(',');
            int origX = to!int(orig[0..commaIndex]);
            int origY = to!int(orig[commaIndex+2..$]);

            string _offset = lines[i+5];
                _offset = _offset[_offset.countUntil(":")+2 .. $];

            commaIndex = _offset.countUntil(',');
            int _offsetX = to!int(_offset[0..commaIndex]);
            int _offsetY = to!int(_offset[commaIndex+2..$]);

            string index = lines[i+6];
                index = index[index.countUntil(":")+2 .. $];

            frame.frame = Rect(x, y, sizeW, sizeH);
            frame.spriteSourceSize = Rect(_offsetX, _offsetY, sizeW, sizeH);
            frame.sourceSize = Size(sizeW, sizeH);
            ret.frames[frame.filename] = frame;
        }
        return ret;
    }

    static bool read(string fileName)
    {
        import std.string : lastIndexOf;
        long ind = fileName.lastIndexOf(".");
        if(ind == -1)
            return false;

        string temp = fileName[ind..$];
        switch(temp)
        {
            case "atlas":
                return true;
            case "tps":
                return true;
            default:
                return false;
        }
    }

    alias frames this;
}