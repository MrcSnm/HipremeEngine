module hip.gui.scroll_area;
import hip.gui.widget;
import hip.gui.button;


interface IRawScrollable
{
    void onRawScroll(float[3] scroll);
}

class ScrollArea : Widget, IRawScrollable
{
    private static IWidgetRenderer DebugRenderer()
    {
        import hip.api.graphics.g2d.renderer2d;
        __gshared DebugWidgetRenderer dbgRenderer;
        if(dbgRenderer is null) dbgRenderer = new DebugWidgetRenderer(HipColor(85,85,85,85));
        return dbgRenderer;
    }
    private IWidgetRenderer renderer;
    private float scrollRate = -10, currentScroll = 0, lastScroll = 0;

    this(int width, int height)
    {
        this.width = width;
        this.height = height;
        renderer = DebugRenderer();
    }

    override Bounds getWorldBounds(){return Bounds(worldTransform.x, worldTransform.y, width, height);}
    void setRenderer(IWidgetRenderer renderer)
    {
        assert(renderer !is null);
        this.renderer = renderer;
    }

    void setScrollRate(float rate)
    {
        this.scrollRate = rate;
    }

    void setScroll(float scroll)
    {
        lastScroll = currentScroll;
        currentScroll = scroll;
        foreach(ch; children)
            ch.onScroll([0,currentScroll,0], [0,lastScroll,0]);
    }

    void onRawScroll(float[3] scroll)
    {
        import hip.api;
        setScroll(currentScroll + scroll[1]*scrollRate);
    }

    override void onRender()
    {
        import hip.api.graphics.g2d.renderer2d;

        setStencilTestingEnabled(true);
        setStencilTestingFunction(HipStencilTestingFunction.Always, 1, 0xFF);
        setStencilOperation(HipStencilOperation.Keep, HipStencilOperation.Keep, HipStencilOperation.Replace);
        setRendererColorMask(0,0,0,0);
        fillRectangle(worldTransform.x, worldTransform.y, width, height);
        setRendererColorMask(1,1,1,1);
        setStencilTestingFunction(HipStencilTestingFunction.Equal, 1, 0xFF);
        renderer.render(worldTransform.x, worldTransform.y, width, height);
        foreach(ch; children)
            ch.render();

        setStencilTestingEnabled(false);
    }
}

import hip.gui.linear_layout;
import hip.gui.group;
class ScrollBar : LinearLayout
{
    private
    {
        Button backward;
        Button thumb;
        Button forward;
    }

    ///Used to keep the layout size fixed
    private Widget thumbFixer;
    private int barSize = 50;
    private int barRate = 1;
    private float barScale = 1;
    private int[2] buttonsDimensions;

    void setButtonsSize(int width, int height)
    {
        forward.width  = backward.width  = width;
        forward.height = backward.height = height;
    }

    void setBarSize(int size)
    {
        barSize = size;
        setDimensionFromDirection(size);
    }

    void setTarget(int* target)
    {
        backward.setOnClick((){*target = *target - barRate;});
        forward.setOnClick((){*target = *target + barRate;});
    }

    private void setDimensionFromDirection(int dimensionSize)
    {
        if(dir == LinearLayout.Direction.horizontal)
        {
            thumb.width = cast(int)(dimensionSize * barScale);
            thumbFixer.width = dimensionSize;
        }
        else
        {
            thumb.height = cast(int)(dimensionSize * barScale);
            thumbFixer.height = dimensionSize;
        }
    }

    void setBarScale(int itemsShowing, int itemsCount)
    {
        barScale = cast(float)itemsShowing / itemsCount;
        setDimensionFromDirection(this.barSize);
    }

    this(LinearLayout.Direction direction)
    {
        setDirection(direction);
        thumbFixer = new Group();
        thumbFixer.addChild(thumb = new Button(0,0, 50, 50));
        backward = new Button(0,0, 50, 50);
        forward = new Button(0,0, 50, 50);

        addChild(backward, thumbFixer, forward);
    }
}