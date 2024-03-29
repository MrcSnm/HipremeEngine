module hip.assets.font;
import hip.asset;
import hip.font.ttf;
import hip.font.bmfont;
public import hip.api.data.font;


class HipFontAsset : HipAsset, IHipFont
{
    import hip.util.reflection;
    mixin(ForwardInterface!("font", IHipFont));

    IHipFont font;
    this(IHipFont font)
    {
        super("Font");
        this._typeID = assetTypeID!HipFontAsset;
        this.font = font;
    }
    override void onFinishLoading(){}
    override void onDispose(){}
    bool isReady(){return font.texture !is null;}
}