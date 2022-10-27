/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.global.gamedef;
import hip.systems.game;
import hip.event.handlers.inputmap;
import hip.config.opts;
import hip.api.data.font;
import hip.api.data.image;

//Default assets
struct HipDefaultAssets
{
   private __gshared IImage _texture;
   private __gshared HipFont _font;

   static const(IImage) texture(){return cast(const)_texture;}
   static const(IHipFont) font(){return cast(const)_font;}

   immutable static string textureData = import(HIP_DEFAULT_TEXTURE);
   immutable static string fontData = import(HIP_DEFAULT_FONT);
}


public:
    immutable static enum ENGINE_NAME = "Hipreme Engine";
    static int SCREEN_WIDTH = 800;
    static int SCREEN_HEIGHT = 600;
    ///Globally shared for accessing it on Android Game Thread
   __gshared GameSystem sys;
   __gshared HipInputMap map;

   __gshared float g_deltaTime = 0;




bool loadDefaultAssets()
{
   import hip.font.ttf;
   import hip.assets.image;

   auto font = new Hip_TTF_Font(HIP_DEFAULT_FONT, HIP_DEFAULT_FONT_SIZE);
   if(!font.loadFromMemory(cast(ubyte[])HipDefaultAssets.fontData))
      return false;
   HipDefaultAssets._font = font;

   auto image = new Image(HIP_DEFAULT_TEXTURE);
   if(!image.loadFromMemory(cast(ubyte[])HipDefaultAssets.textureData))
      return false;

   HipDefaultAssets._texture = image;
   return true;
}

export extern(System)
{
   const(IHipFont) getDefaultFont()
   {
      return HipDefaultAssets.font;
   }
   /**
   *  Use this instead of getDefaultFont.getFontWithSize, as it changes its internal state.
   */
   IHipFont getDefaultFontWithSize(uint size)
   {
      return HipDefaultAssets._font.getFontWithSize(size);
   }
   const(IHipTexture) getDefaultTexture()
   {
      import hip.graphics.g2d.sprite;
      return HipSprite.getDefaultTexture();
   }
}


float getDisplayDPI(uint displayIndex = 0)
{
   float diagonalDPI;
   float verticalDPI;
   float horizontalDPI;
   // SDL_GetDisplayDPI(displayIndex, &diagonalDPI, &horizontalDPI, &verticalDPI);

   return horizontalDPI;
}

