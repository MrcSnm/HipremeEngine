/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.api.view.layer;
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