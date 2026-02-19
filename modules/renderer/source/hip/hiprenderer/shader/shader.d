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
    VertexShader vertexShader;
    FragmentShader fragmentShader;
    ShaderProgram shaderProgram;
    ShaderVariablesLayout[string] layouts;
    protected ShaderVariablesLayout defaultLayout;
    //Optional
    IShader shaderImpl;
    string fragmentShaderPath;
    string vertexShaderPath;

    protected string internalVertexSource;
    protected string internalFragmentSource;
    private bool isUseCall = false;

    this(IShader shaderImpl)
    {
        this.shaderImpl = shaderImpl;
        vertexShader = shaderImpl.createVertexShader();
        fragmentShader = shaderImpl.createFragmentShader();
        shaderProgram = shaderImpl.createShaderProgram();
    }
    this(IShader shaderImpl, string vertexSource, string fragmentSource)
    {
        this(shaderImpl);
        ShaderStatus status = loadShaders(vertexSource, fragmentSource);
        if(status != ShaderStatus.SUCCESS)
        {
            import hip.console.log;
            logln("Failed loading shaders");
        }
    }

    ShaderStatus loadShaders(string vertexShaderSource, string fragmentShaderSource, string shaderPath = "")
    {
        this.internalVertexSource = vertexShaderSource;
        this.internalFragmentSource = fragmentShaderSource;

        vertexShaderPath = fragmentShaderPath = shaderProgram.name = shaderPath;
        if(!shaderImpl.compileShader(vertexShader, vertexShaderSource))
            return ShaderStatus.VERTEX_COMPILATION_ERROR;
        if(!shaderImpl.compileShader(fragmentShader, fragmentShaderSource))
            return ShaderStatus.FRAGMENT_COMPILATION_ERROR;
        if(!shaderImpl.linkProgram(shaderProgram, vertexShader, fragmentShader))
            return ShaderStatus.LINK_ERROR;
        // deleteShaders();
        return ShaderStatus.SUCCESS;
    }

    ShaderStatus loadShadersFromFiles(string vertexShaderPath, string fragmentShaderPath)
    {
        this.vertexShaderPath = vertexShaderPath;
        this.fragmentShaderPath = fragmentShaderPath;
        return loadShaders(getFileContent(vertexShaderPath), getFileContent(fragmentShaderPath));
    }

    ShaderStatus reloadShaders()
    {
        return loadShadersFromFiles(this.vertexShaderPath, this.fragmentShaderPath);
    }

    void setVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset)
    {
        shaderImpl.sendVertexAttribute(layoutIndex, valueAmount, dataType, normalize, stride, offset);
    }


    /**
     * If validateData is true, it will compare if the data has changed for choosing whether it should or not
     send to the GPU.
     * Params:
     *   name =
     *   val =
     *   validateData =
     */
    public void setVertexVar(T)(string name, T val, bool validateData = false)
    {
        ShaderVar* v = tryGetShaderVar(name, ShaderTypes.vertex);
        if(v != null)
        {
            v.set(val, validateData);
        }
    }

    private ShaderVar* tryGetShaderVar(string name, ShaderTypes type)
    {
        import hip.util.conv:to;
        bool isUnused;
        ShaderVar* v = findByName(name, isUnused);

        if(v is null)
        {
            if(!isUnused)
                ErrorHandler.showWarningMessage("Shader " ~ type.to!string ~ " Var not set on shader loaded from '"~fragmentShaderPath~"'",
                "Could not find shader var with name "~name~
                ((layouts.length == 0) ?". Did you forget to addVarLayout on the shader?" :
                " Did you forget to add a layout namespace to the var name?")
                );
            return null;
        }
        if(v.shaderType != type)
        {
            import hip.console.log;
            logln = v.shaderType;
            ErrorHandler.assertExit(false, "Variable named "~name~" must be from " ~ type.to!string ~ " Shader");
        }
        return v;
    }
    /**
     * If validateData is true, it will compare if the data has changed for choosing whether it should or not
     send to the GPU.
     * Params:
     *   name =
     *   val =
     *   validateData =
     */
    public void setFragmentVar(T)(string name, T val, bool validateData = false)
    {
        ShaderVar* v = tryGetShaderVar(name, ShaderTypes.fragment);
        if(v != null)
        {
            if(v.isBlackboxed)
            {
                if(shaderImpl.setShaderVar(v,shaderProgram, cast(void*)&val))
                    v.isDirty = true;
            }
            else
                v.set(val, validateData);
        }
    }

    public void setFragmentVar(T)(ShaderVar* v, T val, bool validateData = false)
    {
        if(v.isBlackboxed)
        {
            if(shaderImpl.setShaderVar(v,shaderProgram, cast(void*)&val))
                v.isDirty = true;
        }
        else
            v.set(val, validateData);
    }

    protected ShaderVar* findByName(string name, out bool isUnused) @nogc
    {
        int accessorSeparatorIndex = name.indexOf(".");

        bool isDefault = accessorSeparatorIndex == -1;
        if(isDefault)
        {
            ShaderVarLayout* sL = name in defaultLayout.variables;
            if(sL !is null)
                return &sL.sVar;
            isUnused = defaultLayout.isUnused(name);
        }
        else
        {
            ShaderVariablesLayout* l = (name[0..accessorSeparatorIndex] in layouts);
            if(l !is null)
            {
                ShaderVarLayout* sL = name[accessorSeparatorIndex+1..$] in l.variables;
                if(sL !is null)
                    return &sL.sVar;
                isUnused = l.isUnused(name[accessorSeparatorIndex+1..$]);
            }
        }
        return null;
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

    /**
     * Use that instead of setVertexVar or setFragmentVar if you wish more performance.
     * Params:
     *   name = The name of the variable
     * Returns: The Shader Variable reference
     */
    public ShaderVar* get(string name, ShaderTypes type)
    {
        ShaderVar* ret = tryGetShaderVar(name, type);
        if(!ret)
        {
            import hip.util.string:join;
            import hip.util.conv:to;
            throw new Exception(
                "Could not find variable named '"~name~"'.\n\tDefault Layout: ["~this.defaultLayout.name~
                "].\n\tShader Path: "~ (type == ShaderTypes.fragment ? fragmentShaderPath : vertexShaderPath) ~
                "\\tnExisting Variables in shader type "~type.to!string~":\n\t  "~getExistingVariableNames(type).join("\n\t  ")
            );
        }
        return ret;
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
                if(varLayout.sVar.isDirty)
                {
                    if(varLayout.sVar.type == UniformType.floating3x3)
                        varLayout.sVar.set(HipRenderer.getMatrix(varLayout.sVar.get!Matrix3), false);
                    else if(varLayout.sVar.type == UniformType.floating4x4)
                        varLayout.sVar.set(HipRenderer.getMatrix(varLayout.sVar.get!Matrix4), false);
                    if(varLayout.sVar.usesMaxTextures)
                        varLayout.sVar.set(HipRenderer.getMaxSupportedShaderTextures(), true);
                }
            }
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


    protected void deleteShaders()
    {
        shaderImpl.deleteShader(&fragmentShader);
        shaderImpl.deleteShader(&vertexShader);
    }

    bool reload()
    {
        vertexShader = shaderImpl.createVertexShader();
        fragmentShader = shaderImpl.createFragmentShader();
        shaderProgram = shaderImpl.createShaderProgram();

        return loadShaders(internalVertexSource, internalFragmentSource) == ShaderStatus.SUCCESS;
    }

    void onRenderFrameEnd()
    {
        shaderImpl.onRenderFrameEnd(shaderProgram);
    }

}
