module hip.extensions.file;

version(none):
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
    ubyte[] data;
    if(!HipFS.read(path, data))
        return false;
    return texture.load(null);
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
    void[] data;
    if(!HipFS.read(path, data))
        return false;
    hapFile = new HapFile(data);
    return true;
}
