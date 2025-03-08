module hip.extensions.file;

import hip.filesystem.hipfs;
import hip.filesystem.extension;

import hip.assets.image;
mixin HipFSExtend!(Image, FileReadResult.free, "", void delegate(IImage img), void delegate()) mxImg;
alias loadFromFile = mxImg.loadFromFile;

import hip.assets.texture;
bool loadFromFile(HipTexture texture, string path)
{
    Image img = new Image(path);
    if(!img.loadFromFile(path, (IImage _img){texture.load(_img);}, ()
    {
        import hip.console.log;
        loglnError("Could not load image from path ", path);
    }))
        {
            destroy(img);
            return false;
        }
    return true;
}



import hip.font.ttf;
mixin HipFSExtend!(Hip_TTF_Font, FileReadResult.free, "path") mxTtf;
alias loadFromFile = mxTtf.loadFromFile;
alias load = mxTtf.load;