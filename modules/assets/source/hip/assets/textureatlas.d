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
import hip.asset;
public import hip.api.data.textureatlas;


class HipTextureAtlas : HipAsset, IHipTextureAtlas
{
    import hip.assets.image;
    string atlasPath;
    string[] texturePaths;
    IHipTexture texture;
    AtlasFrame[string] _frames;

    ref AtlasFrame[string] frames(){return _frames;}

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

    static HipTextureAtlas readJSON (ubyte[] data, string atlasPath, string texturePath)
    {
        import hip.data.json;
        import hip.assets.texture;
        HipTextureAtlas ret = new HipTextureAtlas();
        ret.texturePaths~= texturePath;
        ret.atlasPath = atlasPath;

        import hip.console.log;

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
    static HipTextureAtlas readSpritesheet (string spritesheetPath, string texturePath = "")
    {
        import hip.filesystem.hipfs;
        string data;
        if(!HipFS.readText(spritesheetPath, data))
        {
            import hip.error.handler;
            ErrorHandler.showWarningMessage("Could not find spritesheet from path ", spritesheetPath);
            return null;
        }
        import hip.util.path;
        if(texturePath == "")
        {
            texturePath = spritesheetPath.dup.extension(".png");
        }

        return readSpritesheet(cast(ubyte[])data, spritesheetPath, texturePath);
    }

    static HipTextureAtlas readSpritesheet (ubyte[] data, string spritesheetPath, string texturePath)
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


    /**
    *   Used for the following type of XML (Parsed without a real XML parser):
    ```xml
       <TextureAtlas imagePath="image.png">
           <SubTexture name="sub.png" x="0" y="0" width="0" height="0"/>
       </TextureAtlas>
    ```
    */
    static HipTextureAtlas readXML (string atlasPath, string texturePath = ":IGNORE")
    {
        import hip.filesystem.hipfs;
        string data;
        if(!HipFS.readText(atlasPath, data))
        {
            import hip.error.handler;
            ErrorHandler.showWarningMessage("Could not find atlas XML with path ", atlasPath);
            return null;
        }
        return readXML(cast(ubyte[])data, atlasPath, texturePath);
    }

    static HipTextureAtlas read (string atlasPath, string texturePath = ":IGNORE")
    {
        import hip.util.path;
        switch(atlasPath.extension)
        {
            case "xml":
                return HipTextureAtlas.readXML(atlasPath, texturePath);
            case "atlas":
                return HipTextureAtlas.readAtlas(atlasPath);
            case "json":
                return HipTextureAtlas.readJSON(atlasPath, texturePath == ":IGNORE" ? "" : texturePath);
            default:
                return HipTextureAtlas.readSpritesheet(atlasPath, texturePath == ":IGNORE" ? "" : texturePath);
        }
    }

    static HipTextureAtlas readXML (ubyte[] data, string atlasPath, string texturePath = ":IGNORE")
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
    
    static HipTextureAtlas readJSON (string atlasPath, string texturePath="")
    {
        import hip.util.path;
        import hip.filesystem.hipfs;

        string data;
        if(!HipFS.readText(atlasPath, data))
        {
            import hip.error.handler;
            ErrorHandler.showWarningMessage("Could not atlas JSON from path ", atlasPath);
            return null;
        }
        if(texturePath == "")
            texturePath = atlasPath.dup.extension("png");
        return readJSON(cast(ubyte[])data, atlasPath, texturePath);
    }

    static HipTextureAtlas readAtlas (ubyte[] data, string atlasPath)
    {
        import hip.util.string : split, countUntil;
        import hip.util.conv : to;

        HipTextureAtlas ret = new HipTextureAtlas();
        ret.atlasPath = atlasPath;
        string atlasFile = cast(string)data;

        string[] lines = atlasFile.split("\n");
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

            ptrdiff_t commaIndex = xy.countUntil(',');
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

            frame.frame = AtlasRect(x, y, sizeW, sizeH);
            frame.spriteSourceSize = AtlasRect(_offsetX, _offsetY, sizeW, sizeH);
            frame.sourceSize = AtlasSize(sizeW, sizeH);
            ret.frames[frame.filename] = frame;
        }
        return ret;
    }

    static HipTextureAtlas readAtlas (string atlasPath)
    {
        import hip.filesystem.hipfs;
        import hip.error.handler;
        string data;

        if(!HipFS.readText(atlasPath, data))
        {
            ErrorHandler.showWarningMessage("Could not load HipTextureAtlas atlas from path ", atlasPath);
            return null;
        }
        return readAtlas(cast(ubyte[])data, atlasPath);
    }
    
    override void onFinishLoading(){}
    override void onDispose(){}
    bool isReady(){return texture !is null && frames.length > 0;}
    

    alias frames this;
}