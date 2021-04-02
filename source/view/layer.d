module view.layer;

enum LayerFlags : int
{
    none = 0,
    dirty = 1,
    visible = 1 << 1,
    baked = 1 << 2
}

abstract class Layer
{

    public this(string name){this.name = name;}
    public void onAttach();
    public void onDettach();
    public void onEnter();
    public void onExit();
    public void onUpdate(float dt);
    public void onRender();
    public void onDestroy();

    public string name;
    public int flags;

}