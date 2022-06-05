/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.hipengine.api.view.scene;
public import hip.hipengine.api.view.layer;

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
    final string getName(){return this.classinfo.name;}
}