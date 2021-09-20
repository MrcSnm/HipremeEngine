module hipengine.api.view.layer;
enum LayerFlags : int
{
	none = 0,
	dirty = 1,
	visible = 1 << 1,
	baked = 1 << 2,
}

interface ILayer
{
	void onAttach();
	void onDettach();
	void onEnter();
	void onExit();
	void onUpdate(float dt);
	void onRender();
	void onDestroy();
}
abstract class Layer : ILayer
{
    public string name;
    public int flags;
    public this(string name){this.name = name;}
}