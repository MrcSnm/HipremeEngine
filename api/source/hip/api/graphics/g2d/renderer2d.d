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

version(HipGraphicsAPI):

import hip.api.internal;
public import hip.api.data.image;
public import hip.api.graphics.color;
public import hip.api.renderer.texture;
public import hip.api.graphics.g2d.hipsprite;
public import hip.api.data.font;
public import hip.api.graphics.text;
public import hip.api.graphics.g2d.binding;
version(Script)
{
	///Sets the font for the next drawText commands
	void setFont(HipFont font){hip.api.graphics.g2d.binding._setFont(font);}
	///Sets the font for the next drawText commands
	void setFont(typeof(null) _){hip.api.graphics.g2d.binding.setFontNull(null);}
	///Sets the font using HipAssetManager.loadFont
	void setFont(IHipAssetLoadTask task){hip.api.graphics.g2d.binding.setFontDeferred(task);}
}