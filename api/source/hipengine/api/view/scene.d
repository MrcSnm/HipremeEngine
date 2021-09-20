module hipengine.api.view.scene;
public import hipengine.api.view.layer;

interface IScene
{
    void init();
    void pushLayer(Layer l);
    void update(float dt);
    void render();
    void dispose();
    void onResize(uint width, uint height);
}

abstract class AScene : IScene
{
    Layer[] layerStack;
}