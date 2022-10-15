module hip.extensions.file;

import hip.filesystem.hipfs;
import hip.filesystem.extension;

import hip.assets.image;
mixin HipFSExtend!(Image) mxImg;
alias loadFromFile = mxImg.loadFromFile;

import hip.assets.texture;
bool loadFromFile(HipTexture texture, string path)
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
    if(!font.loadAtlas(cast(string)data, atlasPath))
        return false;
    Image img = new Image(font.getTexturePath);
    if(!img.loadFromMemory(HipFS.read(font.getTexturePath)))
        return false;
    return font.loadTexture(new HipTexture(img));
}

import hip.font.ttf;
mixin HipFSExtend!(Hip_TTF_Font, "path") mxTtf;
alias loadFromFile = mxTtf.loadFromFile;
alias load = mxTtf.load;

import hip.data.ini;
bool loadFromFile(out IniFile ini, string path)
{
    string data;
    if(!HipFS.readText(path, data))
        return false;
    ini = IniFile.parse(cast(string)data, path);
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
