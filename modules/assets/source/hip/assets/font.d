module hip.assets.font;
import hip.asset;
import hip.font.ttf;
import hip.font.bmfont;
import hip.hipengine.api.data.font;


class HipFontAsset : HipAsset, IHipFont
{
    IHipFont font;
    this(){super("Font");}
    override void onFinishLoading()
    {
        
    }

    override void onDispose()
    {
        
    }

    bool load()
    {
        return bool.init; // TODO: implement
    }
    bool isReady()
    {
        return bool.init; // TODO: implement
    }


    import hip.util.reflection;

    mixin(ForwardInterface!("font", IHipFont));
    // final int getKerning(dchar current, dchar next){return _font.getKerning(current, next);}

    // final void calculateTextBounds(in dstring text, ref uint[] linesWidths, out int maxWidth, out int height)
    // {
    //     return _font.calculateTextBounds(text, linesWidths, maxWidth, height);
    // }

    // /////////Properties /////////
    // HipFontChar[dchar] characters(){return _font.characters;}
    // uint spaceWidth(){return _font.spacewidth;}
    // uint spaceWidth(uint newWidth){return _font.spaceWidth = newWidth;}
    // uint lineBreakHeight(){return _font.lineBreakHeight;}
    // uint lineBreakHeight(uint newHeight){return _font.lineBreakHeight = newHeight;}
    
}