/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.shader.shader;
public import hip.api.renderer.shadervar : ShaderVariablesLayout, ShaderVar;
public import hip.api.renderer.shadervar;

import hip.api.data.commons:IReloadable;
import hip.api.renderer.texture;
import hip.math.matrix;
import hip.error.handler;
import hip.api.renderer.shadervar;
import hip.hiprenderer.shader;
import hip.hiprenderer.renderer;
import hip.util.file;
import hip.util.string:indexOf;
public import hip.api.renderer.shader;


private __gshared ShaderProgram lastBoundShader;
private __gshared Shader last;

public class Shader : IReloadable
{
    ShaderProgram shaderProgram;
    ShaderVariablesLayout[string] layouts;
    private ShaderVariablesLayout[] layoutsArray;
    protected HipShaderTexture[] textures;
    protected ShaderVariablesLayout defaultLayout;
    //Optional
    IShader shaderImpl;
    string shaderPath;

    protected string internalShaderSource;
    private bool isUseCall = false;
    private bool _isInstanced;
    private bool isDirty = true;

    this(IShader shaderImpl)
    {
        this.shaderImpl = shaderImpl;
        shaderImpl.setDirtyReference(&isDirty);
    }
    this(IShader shaderImpl, string shaderSource, bool isInstanced = false)
    {
        this(shaderImpl);
        ShaderStatus status = loadShader(shaderSource, null, isInstanced);
        if(status != ShaderStatus.SUCCESS)
        {
            import hip.console.log;
            logln("Failed loading shaders");
        }
    }

    bool isInstanced() const => _isInstanced;

    ShaderStatus loadShader(string shaderSource, string shaderPath = "", bool isInstanced = false)
    {
        this.internalShaderSource = shaderSource;
        this.shaderPath = shaderPath;
        _isInstanced = isInstanced;
        shaderProgram = shaderImpl.buildShader(shaderSource, shaderPath, isInstanced);
        if(shaderProgram is null)
            return ShaderStatus.LINK_ERROR;
        return ShaderStatus.SUCCESS;
    }

    ShaderStatus loadShaderFromFile(string shaderPath, bool isInstanced = false)
    {
        this.shaderPath = shaderPath;
        return loadShader(getFileContent(shaderPath), shaderPath, isInstanced);
    }

    ShaderStatus reloadShaders()
    {
        return loadShaderFromFile(this.shaderPath);
    }


   
    /** 
     * This function is mostly used for debug information
     * Returns: The Variable names.
     */
    private string[] getExistingVariableNames(ShaderTypes type) const
    {
        string[] ret;
        foreach(k, v; layouts)
        {
            if(v.shaderType == type)
            {
                ret~= v.variables.keys;
            }
        }
        return ret;
    }

    public ShaderVariablesLayout getBuffer(string name)
    {
        ShaderVariablesLayout* ret = name in layouts;
        if(ret) return *ret;
        return null;
    }

    public void setup(Uniforms...)(HipRendererInfo info, scope HipShaderTexture[] textures...)
    {
        static foreach(u; Uniforms)
            addVarLayout(ShaderVariablesLayout.from!(u)(info));
        layoutsArray = layouts.values;
        addUsedTextures(textures);
    }


    private void addVarLayout(ShaderVariablesLayout layout)
    {
        ErrorHandler.assertLazyExit((layout.name in layouts) is null, "Shader: VariablesLayout '"~layout.name~"' is already defined");
        if(defaultLayout is null)
            defaultLayout = layout;
        layouts[layout.name] = layout;
        layout.lock(this.shaderImpl);
        shaderImpl.createVariablesBlock(layout, shaderProgram);
    }
    public void addUsedTextures(scope HipShaderTexture[] textures...)
    {
        this.textures~= textures;
        foreach (t; textures)
        {
            import std.stdio;
            writeln = t.texture is null;
        }
    }


    void bind()
    {
        static if(UseDelayedUnbinding)
        {
            if(lastBoundShader is shaderProgram)
                return;
            if(lastBoundShader !is null)
                shaderImpl.unbind(lastBoundShader);
            lastBoundShader = shaderProgram;
        }
        shaderImpl.bind(shaderProgram);
    }
    void unbind()
    {
        static if(UseDelayedUnbinding)
            return;
        shaderImpl.unbind(shaderProgram);
    }
    void setBlending(HipBlendFunction src, HipBlendFunction dest, HipBlendEquation eq)
    {
        shaderImpl.setBlending(shaderProgram, src, dest, eq);
    }

    void sendVars()
    {
        if(!isDirty && lastBoundShader is shaderProgram)
            return;
        foreach(string key, ShaderVariablesLayout value; layouts)
        {
            if(!value.isDirty)
                continue;
            foreach(ref ShaderVarLayout varLayout; value.variables)
            {
                if(varLayout.sVar.type == UniformType.floating3x3)
                    varLayout.sVar.set(HipRenderer.getMatrix(varLayout.sVar.get!Matrix3), false);
                else if(varLayout.sVar.type == UniformType.floating4x4)
                    varLayout.sVar.set(HipRenderer.getMatrix(varLayout.sVar.get!Matrix4), false);
                if(varLayout.sVar.usesMaxTextures)
                    varLayout.sVar.set(HipRenderer.getMaxSupportedShaderTextures(), true);
            }
        }
        foreach(i, HipShaderTexture tex; textures)
        {
            tex.texture.bind(tex.bindPoint == -1 ? cast(int)i : tex.bindPoint);
        }
        shaderImpl.sendVars(shaderProgram, layoutsArray);
        isDirty = false;
    }

    /**
    *  Bind array of textures.
    *   - This is handled a little different than simply blindly binding *  to each slot.
    *   Since OpenGL, Direct3D and Metal handles that differently, a more general solution is required.
    */
    void bindArrayOfTextures(IHipTexture[] textures, string varName)
    {
        shaderImpl.bindArrayOfTextures(shaderProgram, textures, varName);
    }



    bool reload()
    {
        return loadShader(internalShaderSource) == ShaderStatus.SUCCESS;
    }

    void onRenderFrameEnd()
    {
        shaderImpl.onRenderFrameEnd(shaderProgram);
    }

}