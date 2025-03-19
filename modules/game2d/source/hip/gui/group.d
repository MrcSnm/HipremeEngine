module hip.gui.group;
import hip.gui.widget;

/**
 * Defines a non rendering widget which is solely used for positioning purposes
 */
class Group : Widget
{
    protected Widget[] renderFlatTree;

    /** 
     * If you don't have overlapping sprites, you may flatten the tree for rendering.
     * This beyond increasing iteration speed since there will be less recursive calls,
     * it is also possible to sort by batch types.
     */
    void flattenRenderTree(scope TypeInfo[] renderOrder...)
    {
        import core.memory;
        if(renderFlatTree !is null)
            GC.free(renderFlatTree.ptr);
        Widget[] flattened;
        static void flattenImpl(ref Widget[] arr, Widget w)
        {
            foreach(c; w.children)
                flattenImpl(arr, c);
            arr~= w;
        }
        flattenImpl(flattened, this);

        import hip.util.algorithm;
        import hip.util.array:array;


        renderFlatTree = quicksort(flattened, (Widget a, Widget b) @nogc
        {
            TypeInfo aI = typeid(a), bI = typeid(b);
            foreach(v; renderOrder)
            {
                if(bI is v)
                    return true;
                if(aI is v)
                    return false;
            }
            return true;
        });
    }
    
    override void onRender(){}

    override final void render()
    {
        if(renderFlatTree !is null)
        {
            preRender();
            foreach(ch; renderFlatTree)
            {
                if(ch.visible)
                {
                    ch.preRender();
                    ch.onRender();
                }
            }
        }
        else
            super.render();
    }
}