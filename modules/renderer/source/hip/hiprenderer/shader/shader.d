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
public import hip.hiprenderer.shader.shadervar :
ShaderHint, ShaderVariablesLayout, ShaderVar;

import hip.api.data.commons:IReloadable;
import hip.api.renderer.texture;
import hip.math.matrix;
import hip.error.handler;
import hip.hiprenderer.shader.shadervar;
import hip.hiprenderer.backend.gl.glshader;
import hip.hiprenderer.shader;
import hip.hiprenderer.renderer;
import hip.util.file;
import hip.util.string:indexOf;

enum ShaderStatus
{
    SUCCESS,
    VERTEX_COMPILATION_ERROR,
    FRAGMENT_COMPILATION_ERROR,
    LINK_ERROR,
    UNKNOWN_ERROR
}

enum ShaderTypes
{
    VERTEX,
    FRAGMENT,
    GEOMETRY, //Unsupported yet
    NONE 
}

enum HipShaderPresets
{
    DEFAULT,
    FRAME_BUFFER,
    GEOMETRY_BATCH,
    SPRITE_BATCH,
    BITMAP_TEXT,
    NONE
}

/** 
 * This interface is currrently a Shader factory.
 */
interface IShader
{
    VertexShader createVertexShader();
    FragmentShader createFragmentShader();
    ShaderProgram createShaderProgram();

    bool compileShader(FragmentShader fs, string shaderSource);
    bool compileShader(VertexShader vs, string shaderSource);
    bool linkProgram(ref ShaderProgram program, VertexShader vs,  FragmentShader fs);

    void setBlending(ShaderProgram prog, HipBlendFunction src, HipBlendFunction dst, HipBlendEquation eq);
    void bind(ShaderProgram program);
    void unbind(ShaderProgram program);
    void sendVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset);
    int  getId(ref ShaderProgram prog, string name);
    

    ///Used as intermediary for deleting non program intermediary in opengl
    void deleteShader(FragmentShader* fs);
    ///Used as intermediary for deleting non program intermediary in opengl
    void deleteShader(VertexShader* vs);

    void createVariablesBlock(ref ShaderVariablesLayout layout);
    bool setShaderVar(ShaderVar* sv, ShaderProgram prog, void* value);
    void sendVars(ref ShaderProgram prog, ShaderVariablesLayout[string] layouts);

    /** 
     * Each graphics API has its own way to bind array of textures, thus, this version was required.
     */
    void bindArrayOfTextures(ref ShaderProgram prog, IHipTexture[] textures, string varName);
    void dispose(ref ShaderProgram);
}

abstract class VertexShader
{
    abstract string getDefaultVertex();
    abstract string getFrameBufferVertex();
    abstract string getGeometryBatchVertex();
    abstract string getSpriteBatchVertex();
    abstract string getBitmapTextVertex();
}
abstract class FragmentShader
{
    abstract string getDefaultFragment();
    abstract string getFrameBufferFragment();
    abstract string getGeometryBatchFragment();
    abstract string getSpriteBatchFragment();
    abstract string getBitmapTextFragment();
}

abstract class ShaderProgram
{
    string name;
}


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

    void setFromPreset(HipShaderPresets preset = HipShaderPresets.DEFAULT)
    {
        ShaderStatus status = ShaderStatus.SUCCESS;
        fragmentShaderPath="hip.hiprenderer.backend.";
        switch(HipRenderer.getRendererType())
        {
            case HipRendererType.D3D11:
                fragmentShaderPath~= "d3d.shader";
                break;
            case HipRendererType.GL3:
                fragmentShaderPath~= "gl3.shader";
                break;
            case HipRendererType.METAL:
                fragmentShaderPath~= "metal.shader";
                break;
            default:break;
        }

        switch(preset) with(HipShaderPresets)
        {
            case SPRITE_BATCH:
                fragmentShaderPath~= ".SPRITE_BATCH";
                status = loadShaders(vertexShader.getSpriteBatchVertex(), fragmentShader.getSpriteBatchFragment(), fragmentShaderPath);
                break;
            case FRAME_BUFFER:
                fragmentShaderPath~= ".FRAME_BUFFER";
                status = loadShaders(vertexShader.getFrameBufferVertex(), fragmentShader.getFrameBufferFragment(), fragmentShaderPath);
                break;
            case GEOMETRY_BATCH:
                fragmentShaderPath~= ".GEOMETRY_BATCH";
                status = loadShaders(vertexShader.getGeometryBatchVertex(), fragmentShader.getGeometryBatchFragment(), fragmentShaderPath);
                break;
            case BITMAP_TEXT:
                fragmentShaderPath~= ".BITMAP_TEXT";
                status = loadShaders(vertexShader.getBitmapTextVertex(), fragmentShader.getBitmapTextFragment(), fragmentShaderPath);
                break;
            case DEFAULT:
                fragmentShaderPath~= ".DEFAULT";
                status = loadShaders(vertexShader.getDefaultVertex(),fragmentShader.getDefaultFragment(), fragmentShaderPath);
                break;
            case NONE:
            default:
                break;
        }
        vertexShaderPath = fragmentShaderPath;
        
        if(status != ShaderStatus.SUCCESS)
        {
            import hip.console.log;
            logln("Failed loading shaders with status ", status, " at preset ", preset, " on "~fragmentShaderPath);
        }
    }

    ShaderStatus loadShaders(string vertexShaderSource, string fragmentShaderSource, string shaderPath = "")
    {
        this.internalVertexSource = vertexShaderSource;
        this.internalFragmentSource = fragmentShaderSource;

        shaderProgram.name = shaderPath;
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
        ShaderVar* v = tryGetShaderVar(name, ShaderTypes.VERTEX);
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
                " Did you forget to add a layout namespace to the var name?"
                ));
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
        ShaderVar* v = tryGetShaderVar(name, ShaderTypes.FRAGMENT);
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

    protected ShaderVar* findByName(string name, out bool isUnused) @nogc
    {
        int accessorSeparatorIndex = name.indexOf(".");

        bool isDefault = accessorSeparatorIndex == -1;
        if(isDefault)
        {
            ShaderVarLayout* sL = name in defaultLayout.variables;
            if(sL !is null)
                return sL.sVar;
            isUnused = defaultLayout.isUnused(name);
        }
        else
        {
            ShaderVariablesLayout* l = (name[0..accessorSeparatorIndex] in layouts);
            if(l !is null)
            {
                ShaderVarLayout* sL = name[accessorSeparatorIndex+1..$] in l.variables;
                if(sL !is null)
                    return sL.sVar;
                isUnused = l.isUnused(name[accessorSeparatorIndex+1..$]);
            }
        }
        return null;
    }
    public ShaderVar* get(string name)
    {
        bool ignored;
        return findByName(name, ignored);
    }


    public void addVarLayout(ShaderVariablesLayout layout)
    {
        ErrorHandler.assertLazyExit((layout.name in layouts) is null, "Shader: VariablesLayout '"~layout.name~"' is already defined");
        if(defaultLayout is null)
            defaultLayout = layout;
        layouts[layout.name] = layout;
        layout.lock(this);
        shaderImpl.createVariablesBlock(layout);
    }

    /** 
     * This creates a state in the current shader to which block will be accessed
     * when using setVertexVar(".property"). If no default block is set ("")
     * .property will always access the first block defined
     * Params:
     *   blockName = Which block will be accessed with .property
     */
    public void setDefaultBlock(string blockName){defaultLayout = layouts[blockName];}

    void bind(){shaderImpl.bind(shaderProgram);}
    void unbind(){shaderImpl.unbind(shaderProgram);}
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
            return *defaultLayout.variables[member].sVar;
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
    

}
