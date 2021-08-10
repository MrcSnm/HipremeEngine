module view.scene;
import view.layer;

class Scene
{
    Layer[] layerStack;

    public void init(){}

    public void pushLayer(Layer l)
    {
        layerStack~= l;
        l.onAttach();
    }

    public final void update(float dt)
    {
        foreach(ref l; layerStack)
            l.onUpdate(dt);
    }

    public void render()
    {
        foreach(ref l; layerStack)
        {
            if((l.flags & LayerFlags.visible) != 0)
                l.onRender();
        }
    }
    /**
    *   Managed by the event dispatcher
    */
    public void onResize(uint width, uint height){}

}