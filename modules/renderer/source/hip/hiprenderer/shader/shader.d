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


interface IShader
{
    VertexShader createVertexShader();
    FragmentShader createFragmentShader();
    ShaderProgram createShaderProgram();

    bool compileShader(FragmentShader fs, string shaderSource);
    bool compileShader(VertexShader vs, string shaderSource);
    bool linkProgram(ref ShaderProgram program, VertexShader vs,  FragmentShader fs);
    void setCurrentShader(ShaderProgram program);
    void sendVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset);
    int  getId(ref ShaderProgram prog, string name);

    ///Used as intermediary for deleting non program intermediary in opengl
    void deleteShader(FragmentShader* fs);
    ///Used as intermediary for deleting non program intermediary in opengl
    void deleteShader(VertexShader* vs);

    void createVariablesBlock(ref ShaderVariablesLayout layout);
    void sendVars(ref ShaderProgram prog, in ShaderVariablesLayout[string] layouts);

    ///This function is actually required when working with multiple slots on D3D11.
    void initTextureSlots(ref ShaderProgram prog, IHipTexture texture, string varName, int slotsCount);
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

    public void setVertexVar(T)(string name, T val)
    {
        ShaderVar* v = findByName(name);
        if(v != null)
        {
            ErrorHandler.assertLazyExit(v.shaderType == ShaderTypes.VERTEX, "Variable named "~name~" must be from Vertex Shader");
            v.set(val);
        }
        else
            ErrorHandler.showWarningMessage("Shader Vertex Var not set on shader loaded from '"~vertexShaderPath~"'",
            "Could not find shader var with name "~name~
            ((layouts.length == 0) ?". Did you forget to addVarLayout on the shader?" :
            "Did you forget to add a layout namespace to the var name?"
            ));
    }
    public void setFragmentVar(T)(string name, T val)
    {
        ShaderVar* v = findByName(name);
        if(v != null)
        {
            ErrorHandler.assertLazyExit(v.shaderType == ShaderTypes.FRAGMENT, "Variable named "~name~" must be from Fragment Shader");
            v.set(val);
        }
        else
            ErrorHandler.showWarningMessage("Shader Fragment Var not set on shader loaded from '"~fragmentShaderPath~"'",
            "Could not find shader var with name "~name~
            ((layouts.length == 0) ?". Did you forget to addVarLayout on the shader?" :
            "Did you forget to add a layout namespace to the var name?"
            ));
    }

    protected ShaderVar* findByName(string name) @nogc
    {
        int accessorSeparatorIndex = name.indexOf(".");

        bool isDefault = accessorSeparatorIndex == -1;
        if(isDefault)
        {
            ShaderVarLayout* sL = name in defaultLayout.variables;
            if(sL !is null)
                return sL.sVar;
        }
        else
        {
            ShaderVariablesLayout* l = (name[0..accessorSeparatorIndex] in layouts);
            if(l !is null)
            {
                ShaderVarLayout* sL = name[accessorSeparatorIndex+1..$] in l.variables;
                if(sL !is null)
                    return sL.sVar;
            }
        }
        return null;
    }
    public ShaderVar* get(string name){return findByName(name);}


    public void addVarLayout(ShaderVariablesLayout layout)
    {
        ErrorHandler.assertLazyExit((layout.name in layouts) is null, "Shader: VariablesLayout '"~layout.name~"' is already defined");
        if(defaultLayout is null)
            defaultLayout = layout;
        layouts[layout.name] = layout;
        layout.lock();
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

    void bind()
    {
        shaderImpl.setCurrentShader(shaderProgram);
        HipRenderer.exitOnError();
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
        ErrorHandler.assertLazyExit(defaultLayout.variables[member].sVar.set(value), "Invalid value of type "~
        T.stringof~" passed to "~defaultLayout.name~"."~member);
    }

    void sendVars()
    {
        shaderImpl.sendVars(shaderProgram, layouts);
        HipRenderer.exitOnError();
    }

    /**
    *   Bind the texture into all texutre slots. This is required for getting rid of D3D11 warning (which is checked as an error and thus exits the engine)
    *   varName is currently unused
    */
    void initTextureSlots(IHipTexture texture, string varName, int slotsCount)
    {
        shaderImpl.initTextureSlots(shaderProgram, texture, varName, slotsCount);
        HipRenderer.exitOnError();
    }


    protected void deleteShaders()
    {
        shaderImpl.deleteShader(&fragmentShader);
        shaderImpl.deleteShader(&vertexShader);
        HipRenderer.exitOnError();
    }
    
    bool reload()
    {
        vertexShader = shaderImpl.createVertexShader();
        fragmentShader = shaderImpl.createFragmentShader();
        shaderProgram = shaderImpl.createShaderProgram();

        return loadShaders(internalVertexSource, internalFragmentSource) == ShaderStatus.SUCCESS;
    }
    

}
