module hip.global.gamedef;
public import hip.api.data.font;
public import hip.api.data.image;


extern(System)
{
    IHipFont getDefaultFont();
    IHipFont getDefaultFontWithSize(uint size);
    IHipTexture getDefaultTexture();
}