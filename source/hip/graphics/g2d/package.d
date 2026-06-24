/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.graphics.g2d;

public import hip.graphics.g2d.textrenderer,
    hip.graphics.g2d.geometrybatch,
    hip.graphics.g2d.spritebatch,
    hip.hiprenderer.viewport,
    hip.assets.texture,
    hip.assets.textureatlas,
    hip.graphics.g2d.tilemap;


public import HipRenderer2D = hip.graphics.g2d.renderer2d;
import hip.game.shader;
import hip.api.renderer.core_;

Shader createShader(HipShaderPresets shaderPreset, HipRendererType type = HipRendererType.None)
{
    import hip.util.conv:to;
    import hip.console.log;

    Shader ret = new Shader();
    DefaultShader shaderInfo = getDefaultShaderSource(shaderPreset, type);
    bool isInstanced = shaderInfo.isInstanced;


    ShaderStatus status = ret.loadShader(shaderInfo.shaderSource(), shaderInfo.path~"."~shaderPreset.to!string, isInstanced);
    if(status != ShaderStatus.SUCCESS)
        logln("Failed loading shaders with status ", status, " at preset ", shaderPreset, " on "~shaderInfo.path);
    return ret;
}

DefaultShader getDefaultShaderSource(HipShaderPresets shaderPreset, HipRendererType type = HipRendererType.None)
{
    import hip.hiprenderer.initializer;
    if(type == HipRendererType.None)
        type = HipRenderer.getType();

    return HipDefaultShaders[type][shaderPreset];
}