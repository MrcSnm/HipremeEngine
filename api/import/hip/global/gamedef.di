module hip.global.gamedef;
public import hip.api.data.font;
public import hip.api.data.image;


extern(System)
{
    HipFont getDefaultFont();
    HipFont getDefaultFontWithSize(uint size);
    IHipTexture getDefaultTexture();
}