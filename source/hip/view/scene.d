/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.view.scene;
public import hip.hipengine.api.view.scene;
public import hip.view.layer;


class Scene : AScene
{
    public void init(){}
    public void pushLayer(Layer l)
    {
        layerStack~= l;
        l.onAttach();
    }
    public void update(float dt)
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
    public void dispose(){}
    /**
    *   Managed by the event dispatcher
    */
    public void onResize(uint width, uint height){}
 
}