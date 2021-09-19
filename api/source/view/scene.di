// D import file generated from 'source\view\scene.d'
module view.scene;
import view.layer;
class Scene
{
	Layer[] layerStack;
	public void init();
	public void pushLayer(Layer l);
	public void update(float dt);
	public void render();
	public void dispose();
	public void onResize(uint width, uint height);
}
