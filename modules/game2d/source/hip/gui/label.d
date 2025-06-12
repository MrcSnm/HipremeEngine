module hip.gui.label;
public import hip.gui.widget;
public import hip.api.graphics.text;
public import hip.api.graphics.color;
import hip.game2d.text;

class Label : Widget
{
    public HipText txtDraw;
    protected IWidgetRenderer bkgRenderer;

    this(string text)
    {
        this.txtDraw = new HipText();
        this.txtDraw.wordWrap = true;
        this.text = text;
        setAlign(HipTextAlign.centerLeft);
    }
    public Label setColor(HipColor color)
    {
        this.txtDraw.color = color;
        return this;
    }

    public void setBackgroundRenderer(HipColor bkgColor )
    {
        this.bkgRenderer = new DebugWidgetRenderer(bkgColor);
    }

    public void setBackgroundRenderer(IWidgetRenderer bkgRenderer)
    {
        this.bkgRenderer = bkgRenderer;
    }
    public string text(string text)
    {
        txtDraw.text = text;
        txtDraw.getSize(this.width, this.height);
        return text;
    }

    public string text(){return txtDraw.text;}

    public bool wordWrap(){return txtDraw.wordWrap;}
    public bool wordWrap(bool bWordWrap){return txtDraw.wordWrap = bWordWrap;}

    public Label setAlign(HipTextAlign align_)
    {
        txtDraw.setAlign(align_);
        txtDraw.getSize(this.width, this.height);
        return this;
    }

    public Label setSize(int width, int height)
    {
        txtDraw.bounds = Size(width, height);
        txtDraw.getSize(this.width, this.height);
        return this;
    }
    private void getTextPosition(out int x, out int y)
    {
        getPositionFromAlignment(
            worldTransform.x, worldTransform.y, 
            txtDraw.width,  txtDraw.height, 
            txtDraw.align_,
            x, y, 
            txtDraw.bounds
        );
    }

    override void onRender()
    {
        int bkgX = void, bkgY = void;
        getTextPosition(bkgX, bkgY);
        txtDraw.setPosition(worldTransform.x, worldTransform.y);
        if(bkgRenderer !is null) bkgRenderer.render(bkgX, bkgY, txtDraw.width, txtDraw.height);
        txtDraw.draw();
    }
}