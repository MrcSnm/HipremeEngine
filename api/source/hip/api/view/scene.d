/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.api.view.scene;
public import hip.api.view.layer;
public import hip.api.data.commons:IHipPreloadable;

interface IScene : IHipPreloadable
{
    void initialize();
    void pushLayer(Layer l);
    void update(float dt);
    void render();
    void dispose();
    void onResize(uint width, uint height);
}

abstract class AScene : IScene
{
    Layer[] layerStack;
    void pushLayer(Layer l)
    {
	    //Intentionally blank for now.
    }


    void preload(){assert(false, "use `mixin Preload;` to implement that function");}
    string[] getAssetsForPreload(){assert(false, "use `mixin Preload;` to implement that function");};
    final string getName(){return this.classinfo.name;}
}
