/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hipengine;
// version (HipremeAudio)
// {
// 	public import hipaudio;
// }
// version (HipremeRenderer)
// {
// 	public import hiprenderer;
// }
version (HipremeG2D)
{
	public import hipengine.api.graphics.color;
	public import hipengine.api.renderer.texture;
	public import hipengine.api.graphics.g2d.hipsprite;
}
//View + Renderer
public import hipengine.api.graphics.g2d.renderer2d;
public import hipengine.api.view;


version(HipremeEngineDef)
{
	public import hipengine.api.math;
	// public import math.vector;
	
	//Input
	public import HipInput = hipengine.api.input;
	alias initInput = HipInput.initInput;

	import hipengine.internal;
	public import hipengine.internal:initializeHip;
}
else
{

	//Math
	public import hipengine.api.math;

	//Input
	public import HipInput = hipengine.api.input;
	alias initInput = HipInput.initInput;

	import hipengine.internal;
	public import hipengine.internal:initializeHip;
}

version(Script) void function(string s) log;
void initConsole()
{
	version(Script){loadSymbol!log;}
}

mixin template HipEngineMain(alias StartScene)
{
	version(Script)
	{
		__gshared AScene _exportedScene;
		version(Windows)
		{
			import core.sys.windows.dll;
			mixin SimpleDllMain;
		}
		export extern(C) AScene HipremeEngineGameInit(){return _exportedScene = new StartScene();}
		export extern(C) void HipremeEngineGameDestroy(){if(_exportedScene)destroy(_exportedScene);_exportedScene=null;}
	}
	else
		alias HipEngineMainScene  = StartScene;
}