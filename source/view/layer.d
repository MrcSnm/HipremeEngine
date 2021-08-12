/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

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