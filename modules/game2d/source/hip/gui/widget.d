module hip.gui.widget;

/**
 * Whenever implementing layouts, only modify worldTransform.
 * Never modify local transform from other places. Only world transform is valid.
 */
class Widget
{
    struct Bounds
    {
        int x, y, width, height;
    }
    struct Transform
    {
        int x, y;
        float rotation = 0, scaleX = 1, scaleY = 1;
    }
    int width, height;

    protected Widget parent;
    protected Widget[] children;
    protected Transform worldTransform;
    protected Transform localTransform;
    protected bool visible = true;
    protected bool propagates = true;
    protected bool isDirty = true;


    Bounds getWorldBounds()
    {
        Bounds b = Bounds(worldTransform.x, worldTransform.y, width, height);
        Bounds unmod = b;
        import hip.api;
        foreach(ch; children)
        {
            import hip.math.utils:min, max;
            Bounds chBounds = ch.getWorldBounds;
            b.x = min(b.x, chBounds.x);
            b.y = min(b.y, chBounds.y);
            b.width = max(b.width, chBounds.width+chBounds.x - unmod.x);
            b.height = max(b.height, chBounds.height+chBounds.y - unmod.y);
        }
        return b;
    }

    Widget findWidgetAt(float[2] pos){return findWidgetAt(cast(int)pos[0], cast(int)pos[1]);}
    Widget findWidgetAt(int x, int y)
    {
        import hip.math.collision;
        foreach_reverse(w; children)
        {
            Bounds wb = w.getWorldBounds();
            if(w.visible && isPointInRect(x, y, wb.x, wb.y, wb.width, wb.height))
            {
                if(w.propagates)
                    return w.findWidgetAt(x, y);
                return w;
            }
        }

        Bounds wb = getWorldBounds();
        return isPointInRect(x, y, wb.x, wb.y, wb.width, wb.height) ? this : null;
    }

    Bounds getLocalBounds(){return Bounds(localTransform.x,localTransform.y,width,height);}

    void setPosition(int x, int y)
    {
        isDirty = true;
        localTransform.x = x;
        localTransform.y = y;
        setChildrenDirty();
    }

    protected void setChildrenDirty()
    {
        foreach(ch; children)
        {
            ch.isDirty = true;
            ch.setChildrenDirty();
        }
    }

    private Widget getDirtyRoot()
    {
        Widget curr = parent;
        Widget last = curr;
        while(curr && curr.isDirty)
        {
            last = curr;
            curr = curr.parent;
        }
        return curr is null ? last : curr;
    }

    private void updateWorldTransform(in Transform* parentTransform)
    {
        if(parentTransform is null)
            worldTransform = localTransform;
        else
        {
            alias p = parentTransform;
            worldTransform.x = p.x+localTransform.x;
            worldTransform.y = p.y+localTransform.y;
            worldTransform.rotation = p.rotation+localTransform.rotation;
            worldTransform.scaleX = p.scaleX*localTransform.scaleX;
            worldTransform.scaleY = p.scaleY*localTransform.scaleY;
        }
        isDirty = false;
        foreach(ch; children)
            ch.updateWorldTransform(&worldTransform);
    }
    private void recalculateWorld()
    {
        if(isDirty)
        {
            Widget root = getDirtyRoot();
            if(root)
                root.updateWorldTransform(root.parent ? &root.parent.worldTransform : null);
            else
                updateWorldTransform(parent ? &parent.worldTransform : null);
        }
    }

    void addChild(scope Widget[] widgets...)
    {
        foreach(w; widgets) addChild(w);
    }
    void addChild(Widget w)
    {
        children~= w;
        w.isDirty = true;
        w.parent = this;
        w.setChildrenDirty();
    }

    void removeChild(Widget child)
    {
        import hip.util.array;
        if(!remove(children, child))
            throw new Exception("Doesn't contain child.");
        child.parent = null;
        setChildrenDirty();
    }

    void setParent(Widget w)
    {
        w.addChild(this);
    }

    //Event Methods
        void onFocusEnter()
        {
            isFocused = true;
        }
        void onFocusExit()
        {
            isFocused = false;
        }

        void onScroll(float[3] currentScroll, float[3] lastScroll)
        {
            setPosition(
                cast(int)(localTransform.x + currentScroll[0] - lastScroll[0]),
                cast(int)(localTransform.y + currentScroll[1] - lastScroll[1])
            );
        }
        ///Executed the first time the mouse enters in the widget's boundaries
        void onMouseEnter(){}
        ///Executed when the mouse goes down inside the widget
        void onMouseDown(){}
        ///Executed when both a mousedown and mouseup is executed when mouse is over this widget
        void onMouseClick(){}
        ///If onMouseDown was executed, onMouseUp will be called even if the mouse is not inside the widget
        void onMouseUp(){}
        void onMouseMove(){}
        private int dragOffsetX, dragOffsetY;
        void onDragStart(int x, int y)
        {
            dragOffsetX = worldTransform.x - x;
            dragOffsetY = worldTransform.y - y;
        }
        void onDragged(int x, int y)
        {
            import hip.api;
            setPosition(x + dragOffsetX, y + dragOffsetY);
        }
        void onDragEnd(){}
        ///Returns whether it accepted the receive
        bool onDropReceived(Widget w){return false;}
        void onMouseExit(){}
        bool isDraggable;
        bool isFocused;
    //End Event Methods


    void update()
    {
        foreach(ch; children) ch.update();
    }

    protected void preRender(){recalculateWorld();}
    protected void render()
    {
        preRender();
        onRender();
        foreach(ch; children)
            if(ch.visible) ch.render();
    }
    abstract void onRender();
}

interface IWidgetRenderer
{
    void render(int x, int y, int width, int height);
}

class DebugWidgetRenderer : IWidgetRenderer
{
    import hip.api.graphics.color;
    import hip.math.random;
    HipColor color;
    this()
    {
        color[] = Random.rangeub(0, 255);
    }
    this(HipColor color){this.color = color;}

    void render(int x, int y, int width, int height)
    {
        import hip.api.graphics.g2d.renderer2d;
        fillRoundRect(x,y,width,height, 4, color);
    }
}