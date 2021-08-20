/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

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
    /**
    *   Managed by the event dispatcher
    */
    public void onResize(uint width, uint height){}

}