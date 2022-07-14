module hip.extensions.file;

import hip.filesystem.hipfs;


//Definitions
import hip.data.assets.image;
bool loadFromFile(Image image, string path)
{
    ubyte[] data;
    if(!HipFS.read(path, data))
        return false;
    return image.loadFromMemory(data);
}

import hip.hiprenderer.texture;
bool loadFromFile(Texture texture, string path)
{
    Image img = new Image(path);
    if(!img.loadFromFile(path))
    {
        destroy(img);
        return false;
    }
    return texture.load(img);
}


import hip.font.bmfont;
bool loadFromFile(HipBitmapFont font, string atlasPath)
{
    ubyte[] data;
    if(!HipFS.read(atlasPath, data))
        return false;
    font.readAtlas(atlasPath);
    font.readTexture();
    return true;
}

import hip.font.ttf;
bool loadFromFile(Hip_TTF_Font font, string path)
{
    ubyte[] data;
    if(!HipFS.read(path, data))
        return false;
    return font.loadFromMemory(data);
}

bool load(Hip_TTF_Font font){return font.loadFromFile(font.path);}

import hip.data.ini;
bool loadFromFile(out IniFile ini, string path)
{
    string data;
    if(!HipFS.readText(path, data))
        return false;
    ini = IniFile.parse(cast(string)data);
    return ini.noError;
}

import hip.data.assetpacker;
bool loadFromFile(HapFile hapFile, string path)
{
    ubyte[] data;
    if(!HipFS.read(path, data))
        return false;
    hapFile = new HapFile(path);
    hapFile.loadFromMemory(data);
    return true;
}
