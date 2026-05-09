/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.game.shader;
public import hip.api.renderer.shadervar : ShaderVariablesLayout, ShaderVar;
public import hip.api.renderer.shadervar;
public import hip.api.renderer.core;

import hip.api.data.commons:IReloadable;
import hip.api.renderer.texture;
import hip.math.matrix;
import hip.error.handler;
import hip.api.renderer.shadervar;
import hip.api.renderer.shader;
// import hip.hiprenderer.renderer;
import hip.util.file;
import hip.util.string:indexOf;
public import hip.api.renderer.shader;



public class Shader : IReloadable
{
    import hip.util.data_structures;
    import hip.config.renderer;
    
    alias shaderBinder = DelayedBindable!(Shader, !UseDelayedUnbind, BindReplacesUnbind, 1,
        (Shader s){s.shaderProgram.bind();},
        (Shader s){s.shaderProgram.unbind();}
    );

    HipShaderProgram shaderProgram;
    ShaderVariablesLayout[string] layouts;
    private ShaderVariablesLayout[] layoutsArray;
    protected HipShaderTexture[] textures;
    protected ShaderVariablesLayout defaultLayout;
    string shaderPath;

    protected string internalShaderSource;
    private bool _isInstanced;
    private bool isDirty = true;

    this()
    {
        import hip.api.renderer.core;
        // SetGlobalHipRenderer(hip.api.renderer.core.HipRenderer());
        shaderProgram = HipRenderer.createShader();
        shaderProgram.setDirtyReference(&isDirty);
    }
    this(string shaderSource, bool isInstanced = false)
    {
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
        if(!shaderProgram.buildShader(shaderSource, shaderPath, isInstanced))
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
    bool reload()
    {
        return loadShader(internalShaderSource) == ShaderStatus.SUCCESS;
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
        layout.lock(this.shaderProgram);
        shaderProgram.createVariablesBlock(layout);
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
        shaderBinder.bind(this);
    }
    void unbind()
    {
        shaderBinder.unbind(this);
    }
    void setBlending(HipBlendFunction src, HipBlendFunction dest, HipBlendEquation eq)
    {
        shaderProgram.setBlending(src, dest, eq);
    }

    void sendVars()
    {
        if(!isDirty)
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
        shaderProgram.sendVars(layoutsArray);
        isDirty = false;
    }

    /**
    *  Bind array of textures.
    *   - This is handled a little different than simply blindly binding *  to each slot.
    *   Since OpenGL, Direct3D and Metal handles that differently, a more general solution is required.
    */
    void bindArrayOfTextures(IHipTexture[] textures, string varName)
    {
        shaderProgram.bindArrayOfTextures(textures, varName);
    }
    void onRenderFrameEnd()
    {
        shaderProgram.onRenderFrameEnd();
    }

    static Shader fromShaderPreset(HipShaderPresets shaderPreset, HipRendererType type = HipRendererType.None)
    {
        import hip.hiprenderer.initializer;
        import hip.util.conv:to;
        import hip.console.log;
        if(type == HipRendererType.None)
            type = HipRenderer.getType();

        Shader ret = new Shader();
        DefaultShader shaderInfo = HipDefaultShaders[type][shaderPreset];
        bool isInstanced = shaderInfo.isInstanced && shaderInfo.isInstanced();


        ShaderStatus status = ret.loadShader(shaderInfo.shaderSource(), shaderInfo.path~"."~shaderPreset.to!string, isInstanced);
        if(status != ShaderStatus.SUCCESS)
            logln("Failed loading shaders with status ", status, " at preset ", shaderPreset, " on "~shaderInfo.path);
        return ret;
    }
}