module hip.gui.linear_layout;
public import hip.gui.widget;
import hip.gui.group;


class LinearLayout : Group
{
    enum Direction
    {
        horizontal,
        vertical
    }

    protected Direction dir;
    protected int spacing = 0;
    protected int padding = 0;

    public void setDirection(Direction d)
    {
        dir = d;
        updateLayout();
    }
    void setSpacing(int spacing)
    {
        this.spacing = spacing;
        updateLayout();
    }
    void setPadding(int padding)
    {
        this.padding = padding;
        updateLayout();
    }

    alias addChild = Widget.addChild;
    override void addChild(Widget w)
    {
        super.addChild(w);
        updateLayout();
    }


    void updateLayout()
    {
        int x, y;
        int maxWidth, maxHeight;
        foreach(ch; children)
        {
            import hip.api;
            if(!ch.visible) continue;
            if(dir == Direction.horizontal)
            {
                ch.localTransform.x = x;
                if(ch.height > maxHeight)
                    maxHeight = ch.height;
                x+= spacing + ch.width;
                maxWidth = x;
            }
            else
            {
                ch.localTransform.y = y;
                if(ch.width > maxWidth)
                    maxWidth = ch.width;
                y+= spacing + ch.height;
                maxHeight = y;
            }
        }
        width = maxWidth;
        height = maxHeight;
        setChildrenDirty();
    }
    override void preRender()
    {
        super.preRender();
        updateLayout();
    }
}