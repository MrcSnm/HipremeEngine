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
        foreach(ch; children)
        {
            import hip.api;
            if(!ch.visible) continue;
            ch.worldTransform.x = ch.localTransform.x + x;
            ch.worldTransform.y = ch.localTransform.y + y;
            if(dir == Direction.horizontal)
                x+= spacing + ch.width;
            else 
                y+= spacing + ch.height;
        }
    }
    override void preRender()
    {
        super.preRender();
        updateLayout();
    }
}