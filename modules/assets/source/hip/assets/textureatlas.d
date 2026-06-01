/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.assets.textureatlas;
public import hip.api.data.textureatlas;
import hip.assets.texture;
import hip.api.data.asset;


class HipTextureAtlas : HipAsset, IHipTextureAtlas
{
    import hip.assets.image;
    string atlasPath;
    string[] texturePaths;
    IHipTexture texture;
    AtlasFrame[string] _frames;

    ref inout(AtlasFrame[string]) frames() inout {return _frames;}

    this()
    {
        super("TextureAtlas");
        _typeID = assetTypeID!HipTextureAtlas;
    }

    string getTexturePath () const
    {
        return texturePaths[0];
    }


    bool loadTexture (in Image image)
    {
        import hip.assets.texture;
        texture = new HipTexture(image);
        if(!texture.hasSuccessfullyLoaded)
            return false;
        foreach(k, ref v; frames)
        {
            v.region = new HipTextureRegion(texture,
                cast(uint)v.frame.x, cast(uint)v.frame.y,
                cast(uint)(v.frame.x + v.frame.width),
                cast(uint)(v.frame.y + v.frame.height)
            );
        }
        return true;
    }

    static HipTextureAtlas readJSON (const ubyte[] data, string atlasPath, string texturePath)
    {
        import hip.data.json;
        import hip.assets.texture;
        HipTextureAtlas ret = new HipTextureAtlas();
        ret.texturePaths~= texturePath;
        ret.atlasPath = atlasPath;

        JSONValue json = parseJSON(cast(string)data);
        if(json["frames"].type == JSONType.array)
        {
            foreach(f; json["frames"].array)
            {
                AtlasFrame a;
                a.filename = f["filename"].str;
                a.rotated  = f["rotated"].boolean;
                a.trimmed  = f["trimmed"].boolean;
                JSONValue frameRect = f["frame"].object;
                a.frame = AtlasRect(
                    cast(uint)frameRect["x"].integer,
                    cast(uint)frameRect["y"].integer,
                    cast(uint)frameRect["w"].integer,
                    cast(uint)frameRect["h"].integer
                );
                frameRect = f["spriteSourceSize"].object;
                a.spriteSourceSize = AtlasRect(
                    cast(uint)frameRect["x"].integer,
                    cast(uint)frameRect["y"].integer,
                    cast(uint)frameRect["w"].integer,
                    cast(uint)frameRect["h"].integer
                );
                frameRect = f["sourceSize"].object;
                a.sourceSize = AtlasSize(cast(uint)frameRect["w"].integer, cast(uint)frameRect["h"].integer);
                ret.frames[a.filename] = a;
            }
        }
        else
        {
            JSONValue frames = json["frames"].object;
            JSONValue meta = json["meta"].object;
            foreach(string frameName, JSONValue f; frames)
            {
                AtlasFrame a;
                a.filename = frameName;
                a.rotated  = f["rotated"].boolean;
                a.trimmed  = f["trimmed"].boolean;
                JSONValue frameRect = f["frame"].object;
                a.frame = AtlasRect(
                    cast(uint)frameRect["x"].integer,
                    cast(uint)frameRect["y"].integer,
                    cast(uint)frameRect["w"].integer,
                    cast(uint)frameRect["h"].integer
                );
                frameRect = f["spriteSourceSize"].object;
                a.spriteSourceSize = AtlasRect(
                    cast(uint)frameRect["x"].integer,
                    cast(uint)frameRect["y"].integer,
                    cast(uint)frameRect["w"].integer,
                    cast(uint)frameRect["h"].integer
                );
                frameRect = f["sourceSize"].object;
                a.sourceSize = AtlasSize(cast(uint)frameRect["w"].integer, cast(uint)frameRect["h"].integer);
                ret.frames[frameName] = a;
            }
        }

        return ret;
    }

    /**
    *   If no texturePath is given, it will try spritesheetPath<.png>
    *   I found a txt file that is parsed as:
    *
`spriteName = x y width height`
    */
    // static HipTextureAtlas readSpritesheet (string spritesheetPath, string texturePath = "")
    // {
    //TODO: FIX HIPFS
    //     import hip.filesystem.hipfs;
    //     string data;
    //     if(!HipFS.readText(spritesheetPath))
    //     {
    //         import hip.error.handler;
    //         ErrorHandler.showWarningMessage("Could not find spritesheet from path ", spritesheetPath);
    //         return null;
    //     }
    //     import hip.util.path;
    //     if(texturePath == "")
    //     {
    //         texturePath = spritesheetPath.dup.extension(".png");
    //     }

    //     return readSpritesheet(cast(ubyte[])data, spritesheetPath, texturePath);
    // }

    static HipTextureAtlas readSpritesheet (const ubyte[] data, string spritesheetPath, string texturePath)
    {
        import hip.util.string:splitRange, trim, isNumber;
        import hip.assets.texture;

        string toParse = cast(string)data;

        HipTextureAtlas atlas = new HipTextureAtlas();
        atlas.atlasPath = spritesheetPath;
        atlas.texturePaths~= texturePath;


        foreach(line; splitRange(toParse, "\n"))
        {
            import hip.util.algorithm;
            import hip.util.conv;
            import hip.console.log;
            line = line.trim();
            auto lineDataRange = splitRange(line, " ");
            lineDataRange.popFront;
            string frame = lineDataRange.front;
            if(frame != "")
            {
                while(!lineDataRange.empty && !lineDataRange.front.isNumber)
                {
                    lineDataRange.popFront; //Find a number
                }
                int x = void, y = void, width = void, height = void;
                lineDataRange.map((string data) => to!int(data)).put(&x, &y, &width, &height);
                AtlasFrame atlasFrame;
                atlasFrame.spriteSourceSize = AtlasRect(x, y, width, height);
                atlasFrame.frame = AtlasRect(x, y, width, height);
                atlasFrame.sourceSize = AtlasSize(width, height);
                atlasFrame.filename = frame;
                atlas.frames[frame] = atlasFrame;
            }
        }
        return atlas;
    }


    static HipTextureAtlas readFromMemory (const ubyte[] data, string atlasPath, string texturePath = ":IGNORE")
    {
        import hip.util.path;
        switch(atlasPath.extension)
        {
            case "xml":
                return HipTextureAtlas.readXML(data, atlasPath, texturePath);
            case "atlas":
                return HipTextureAtlas.readAtlas(data, atlasPath);
            case "json":
                return HipTextureAtlas.readJSON(data, atlasPath, texturePath == ":IGNORE" ? "" : texturePath);
            default:
                return HipTextureAtlas.readSpritesheet(data, atlasPath, texturePath == ":IGNORE" ? "" : texturePath);
        }
    }

    /**
    *   Used for the following type of XML (Parsed without a real XML parser):
    ```xml
       <TextureAtlas imagePath="image.png">
           <SubTexture name="sub.png" x="0" y="0" width="0" height="0"/>
       </TextureAtlas>
    ```
    */
    static HipTextureAtlas readXML (const ubyte[] data, string atlasPath, string texturePath = ":IGNORE")
    {
        import hip.assets.texture;
        import hip.util.string;
        import hip.util.path;
        import hip.util.conv;
        string dataToParse = cast(string)data;
        import hip.console.log;
        //TODO: Fix .after (as it only executes startsWith and is returning null)
        dataToParse = dataToParse.findAfter("imagePath=");
        if(texturePath == ":IGNORE")
            texturePath = atlasPath.dup.extension(".png");
        else
            texturePath = dataToParse.between("\"", "\"");
        HipTextureAtlas atlas = new HipTextureAtlas();
        atlas.texturePaths~= texturePath;
        dataToParse = dataToParse.findAfter(">");

        foreach(line; dataToParse.splitRange("\n"))
        {
            line = line.trim();
            if(!line)
                continue;
            if(line.startsWith("</TextureAtlas>"))
                break;
            string name = (line = line.findAfter("name=")).between(`"`, `"`);
            int x = (line = line.findAfter("x=")).between(`"`, `"`).to!int;
            int y = (line = line.findAfter("y=")).between(`"`, `"`).to!int;
            int width = (line = line.findAfter("width=")).between(`"`, `"`).to!int;
            int height = (line = line.findAfter("height=")).between(`"`, `"`).to!int;

            AtlasFrame frame;
            frame.filename = name;
            frame.frame = AtlasRect(x, y, width, height);
            frame.spriteSourceSize = AtlasRect(x, y, width, height);
            frame.sourceSize = AtlasSize(width, height);
            atlas.frames[frame.filename] = frame;
        }
        return atlas;
    }


    static HipTextureAtlas readAtlas (const ubyte[] data, string atlasPath)
    {
        import hip.util.string : countUntil, splitRange, trim;
        import hip.util.conv : to;
        import std.range:refRange;

        HipTextureAtlas ret = new HipTextureAtlas();
        ret.atlasPath = atlasPath;
        string atlasFile = cast(string)data;

        auto lineRange = splitRange(atlasFile, "\n");
        enum FileDataInfo : uint
        {
            imageName,
            size,
            format,
            filter,
            repeat
        }
        FileDataInfo dataInfo = FileDataInfo.imageName;
            import hip.console.log;

        while(!lineRange.empty)
        {
            string line = lineRange.front;
            if(line.trim.length == 0)
                break;
            switch(dataInfo++)
            {
                case FileDataInfo.imageName:
                    ret.texturePaths~= line;
                    break;
                case FileDataInfo.size:
                case FileDataInfo.format:
                case FileDataInfo.filter:
                case FileDataInfo.repeat:
                default:
                    break;
            }
            lineRange.popFront();
        }

        enum LineInfo : uint
        {
            frameName,
            rotation,
            xy,
            size,
            orig,
            offset,
            index
        }

        LineInfo li;
        string frameName;
        bool rotate;
        int x, y;
        int sizeW, sizeH;
        int origX, origY;
        int offX, offY;

        foreach(line; lineRange)
        {
            line = line.trim;
            if(line.length == 0)
            {
                li = LineInfo.frameName;
                if(frameName.length)
                {
                    ret.frames[frameName] = AtlasFrame(
                        frameName,
                        rotate,
                        false,
                        frame: AtlasRect(x, y, sizeW, sizeH),
                        spriteSourceSize: AtlasRect(offX, offY, sizeW, sizeH),
                        sourceSize: AtlasSize(sizeW, sizeH),
                    );
                    rotate = false;
                    frameName = null;
                    x = y = sizeW = sizeH = origX = origY = offX = offY = 0;
                }
                continue;
            }
            final switch(li)
            {
                case LineInfo.frameName:
                    frameName = line;
                    break;
                case LineInfo.rotation:
                    rotate = to!bool(line["rotate: ".length..$]);
                    break;
                case LineInfo.xy:
                    string xy = line["xy: ".length..$];
                    ptrdiff_t commaIndex = xy.countUntil(',');
                    x = to!int(xy[0..commaIndex]);
                    //To account space must increate 2
                    y = to!int(xy[commaIndex+2..$]);
                    break;
                case LineInfo.size:
                    string size = line["size: ".length..$];
                    ptrdiff_t commaIndex = size.countUntil(',');
                    sizeW = to!int(size[0..commaIndex]);
                    //To account space must increate 2
                    sizeH = to!int(size[commaIndex+2..$]);
                    break;
                case LineInfo.orig:
                    string orig = line["orig: ".length..$];
                    ptrdiff_t commaIndex = orig.countUntil(',');
                    origX = to!int(orig[0..commaIndex]);
                    //To account space must increate 2
                    origY = to!int(orig[commaIndex+2..$]);
                    break;
                case LineInfo.offset:
                    string offset = line["offset: ".length..$];
                    ptrdiff_t commaIndex = offset.countUntil(',');
                    offX = to!int(offset[0..commaIndex]);
                    //To account space must increate 2
                    offY = to!int(offset[commaIndex+2..$]);
                    break;
                case LineInfo.index:
                    break;
            }
            li++;
        }
        return ret;
    }


    override void onFinishLoading(){}
    override void onDispose(){}
    override bool isReady() const {return texture !is null && frames.length > 0;}


    alias frames this;
}