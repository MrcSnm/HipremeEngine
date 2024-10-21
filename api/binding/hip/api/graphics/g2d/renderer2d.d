/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.api.graphics.g2d.renderer2d;

import hip.api.internal;
public import hip.api.data.image;
public import hip.api.graphics.color;
public import hip.api.renderer.texture;
public import hip.api.data.font;
public import hip.api.graphics.text;
public import hip.api.graphics.g2d.animation;
public import hip.api.graphics.g2d.g2d_binding;

version(ScriptAPI)
{
	version = DefineOverloadings;
	version(Have_util) version = DefineCreateFromAtlas;
}


version(DefineOverloadings)
{
	private alias G2D = hip.api.graphics.g2d.g2d_binding;
	///Sets the font for the next drawText commands
	void setFont(IHipFont font){G2D.setFont(font);}
	void setFont(typeof(null)){G2D.setFont(cast(IHipFont)null);}
	///Sets the font using HipAssetManager.loadFont
	void setFont(IHipAssetLoadTask task){G2D.setFontDeferred(task);}

	//Float overloading for drawLine
	void drawLine(float x1, float y1, float x2, float y2, HipColor color = HipColor.no)
	{
		hip.api.graphics.g2d.g2d_binding.drawLine(cast(int)x1, cast(int)y1, cast(int)x2, cast(int)y2, color);
	}
	void drawRectangle(float x, float y, float width, float height, HipColor color = HipColor.no)
	{
		hip.api.graphics.g2d.g2d_binding.drawRectangle(cast(int)x, cast(int)y, cast(int)width, cast(int)height, color);
	}

	///Circle API
		void drawCircle(int x, int y, int radius, HipColor color = HipColor.no, int precision = 24)
		{
			hip.api.graphics.g2d.g2d_binding.drawEllipse(x, y, radius, radius, 360, color, precision);
		}
		void drawCircle(float x, float y, float radius, HipColor color = HipColor.no, int precision = 24)
		{
			hip.api.graphics.g2d.g2d_binding.drawEllipse(cast(int)x, cast(int)y, cast(int)radius, cast(int)radius, 360, color, precision);
		}

		void fillCircle(int x, int y, int radius, HipColor color = HipColor.no, int precision = 24)
		{
			hip.api.graphics.g2d.g2d_binding.fillEllipse(cast(int)x, cast(int)y, cast(int)radius, cast(int)radius, 360, color, precision);
		}
		void fillCircle(float x, float y, float radius, HipColor color = HipColor.no, int precision = 24)
		{
			hip.api.graphics.g2d.g2d_binding.fillEllipse(cast(int)x, cast(int)y, cast(int)radius, cast(int)radius, 360, color, precision);
		}
	///

	///Float overloading for fillEllipse
	void fillEllipse(float x, float y, float width, float height, int degrees = 360,  HipColor color = HipColor.no, int precision = 24)
	{
		hip.api.graphics.g2d.g2d_binding.fillEllipse(cast(int)x, cast(int)y, cast(int)width, cast(int)height, degrees, color, precision);
	}

	///Float overloading for drawEllipse
	void drawEllipse(float x, float y, float width, float height, int degrees = 360, HipColor color = HipColor.no, int precision = 24)
	{
		hip.api.graphics.g2d.g2d_binding.drawEllipse(cast(int)x, cast(int)y, cast(int)width, cast(int)height, degrees, color, precision);
	}

	///Float overloading for fillRectangle
	void fillRectangle(float x, float y, float width, float height, HipColor color = HipColor.no)
	{
		hip.api.graphics.g2d.g2d_binding.fillRectangle(cast(int)x, cast(int)y, cast(int)width, cast(int)height, color);
	}

	version(Have_util)
	{
		import hip.util.reflection:isTypeArrayOf;

		pragma(inline, true)
		{
			//Struct compatible with float[2] or float[2]
			void drawLine(T)(in T start, in T end, HipColor color = HipColor.no)
			if(isTypeArrayOf!(float, T, 2))
			{
				const float[2] s = *cast(const(float[2])*)cast(const(void*))&start;
				const float[2] e = *cast(const(float[2])*)cast(const(void*))&end;
				drawLine(s[0], s[1], e[0], e[1], color);
			}
			///Struct compatible with float[4] or float[4]
			void fillRectangle(T)(in T r, HipColor color = HipColor.no)
			if(isTypeArrayOf!(float, T, 4))
			{
				const float[4] a = *cast(const(float[4]*))cast(const(void*))&r;
				fillRectangle(a[0], a[1], a[2], a[3], color);
			}
			void drawRectangle(T)(in T r, HipColor color = HipColor.no)
			if(isTypeArrayOf!(float, T, 4))
			{
				const float[4] a = *cast(const(float[4]*))cast(const(void*))&r;
				drawRectangle(a[0], a[1], a[2], a[3], color);
			}
		}
		
		///Rect overload for fillRectangle
	}
}

version(DefineCreateFromAtlas)
{
	/**
	*   Creates an IHipAnimation from a loaded texture atlas.
	*   Its frames will be checked such as `mySprite${frameNumber}`.
	*   The animation will be named as the string without the number.
	*/
	static IHipAnimation createFromAtlas(IHipTextureAtlas atlas, string animationName, uint framesPerSecond = 24)
	{
		import hip.util.string:getNumericEnding, lastIndexOf;
		import hip.util.algorithm;
		import hip.api.graphics.g2d.renderer2d;
		import std.algorithm:sort;

		IHipAnimation anim = newHipAnimation(animationName);
		foreach(string frameName; sort(atlas.frames.keys))
		{
			AtlasFrame* frame = frameName in atlas;
			string name = frameName;
			int index = frameName.lastIndexOf(frameName.getNumericEnding);
			if(index != -1)
				name = frameName[0..index];
			IHipAnimationTrack track = anim.getTrack(name);
			if(track is null)
			{
				anim.addTrack(track = newHipAnimationTrack(name, framesPerSecond, HipAnimationLoopingMode.reset));
			}
			track.addFrames(HipAnimationFrame(frame.region, HipColor.white, [0,0]));

		}
		return anim;
	}
}
