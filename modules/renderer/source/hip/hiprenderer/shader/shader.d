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

public class Shader : IReloadable
{
    ShaderProgram shaderProgram;
    ShaderVariablesLayout[string] layouts;
    protected HipShaderTexture[] textures;
    protected ShaderVariablesLayout defaultLayout;
    //Optional
    IShader shaderImpl;
    string shaderPath;

    protected string internalShaderSource;
    private bool isUseCall = false;

    this(IShader shaderImpl)
    {
        this.shaderImpl = shaderImpl;
    }
    this(IShader shaderImpl, string shaderSource)
    {
        this(shaderImpl);
        ShaderStatus status = loadShader(shaderSource);
        if(status != ShaderStatus.SUCCESS)
        {
            import hip.console.log;
            logln("Failed loading shaders");
        }
    }

    ShaderStatus loadShader(string shaderSource, string shaderPath = "")
    {
        this.internalShaderSource = shaderSource;
        this.shaderPath = shaderPath;
        shaderProgram = shaderImpl.buildShader(shaderSource, shaderPath);
        if(shaderProgram is null)
            return ShaderStatus.LINK_ERROR;
        return ShaderStatus.SUCCESS;
    }

    ShaderStatus loadShaderFromFile(string shaderPath)
    {
        this.shaderPath = shaderPath;
        return loadShader(getFileContent(shaderPath), shaderPath);
    }

    ShaderStatus reloadShaders()
    {
        return loadShaderFromFile(this.shaderPath);
    }

    void setVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset)
    {
        shaderImpl.sendVertexAttribute(layoutIndex, valueAmount, dataType, normalize, stride, offset);
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
        addUsedTextures(textures);
    }


    public void addVarLayout(ShaderVariablesLayout layout)
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

    /**
     * This creates a state in the current shader to which block will be accessed
     * when using setVertexVar(".property"). If no default block is set ("")
     * .property will always access the first block defined
     * Params:
     *   blockName = Which block will be accessed with .property
     */
    public void setDefaultBlock(string blockName){defaultLayout = layouts[blockName];}

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

    auto opDispatch(string member)()
    {
        static if(member == "useLayout")
        {
            isUseCall = true;
            return this;
        }
        else
        {
            if(isUseCall)
            {
                setDefaultBlock(member);
                isUseCall = false;
                ShaderVar s;
                return s;
            }
            return defaultLayout.variables[member].sVar;
        }
    }
    auto opDispatch(string member, T)(T value)
    {
        if(!defaultLayout.variables[member].sVar.set(value, false))
        {
            ErrorHandler.assertExit(false, "Invalid value of type "~
            T.stringof~" passed to "~defaultLayout.name~"."~member);
        }
    }

    void sendVars()
    {
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
        shaderImpl.sendVars(shaderProgram, layouts);
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