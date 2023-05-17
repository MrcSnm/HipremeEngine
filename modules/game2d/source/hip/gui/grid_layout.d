module hip.gui.grid_layout;
public import hip.gui.widget;

class GridLayout : Widget
{
    enum Direction
    {
        horizontal, vertical
    }

    protected int spacingX, spacingY, maxChildrenInCurrentDirection;
    protected Direction plotDirection;

    this(int maxChildren, Direction d = Direction.horizontal)
    {
        setPlottingDirection(d);
        setMaxChildrenInCurrentDirection(maxChildren);
    }
    

    void setPlottingDirection(Direction d)
    {
        plotDirection = d;
        updateLayout();
    }

    void setMaxChildrenInCurrentDirection(int maxChildren)
    {
        maxChildrenInCurrentDirection = maxChildren;
        updateLayout();
    }
    void setSpacing(int spx, int spy)
    {
        spacingX = spx;
        spacingY = spy;
        updateLayout();
    }
    final void setSpacing(int spx){setSpacing(spx, spx);}
    

    protected void updateLayout()
    {
        int childX, childY;

        foreach(i, ch; children)
        {
            childX = cast(int)(i % maxChildrenInCurrentDirection) * spacingX;
            childY = cast(int)(i / maxChildrenInCurrentDirection) * spacingY;
            if(plotDirection == Direction.vertical)
            {
                int temp = childX;
                childX = childY;
                childY = temp;
            }
            ch.setPosition(childX, childY);
        }
    }
    alias addChild = Widget.addChild;
    override void addChild(Widget w)
    {
        super.addChild(w);
        updateLayout();
    }
    override void onRender()
    {
        foreach(ch; children) if(ch.visible)
            ch.render();
        import hip.api;
        Bounds b = getWorldBounds;
        drawRectangle(b.x, b.y, b.width, b.height, HipColor.green);
    }
}