module implementations.renderer.shader.shader;
import math.matrix;
import bindbc.opengl;
import error.handler;
import implementations.renderer.shader.shadervar;
public import implementations.renderer.shader.shadervar :
ShaderHint, ShaderVariablesLayout, ShaderVar;
import implementations.renderer.backend.gl.shader;
import implementations.renderer.shader;
import implementations.renderer.renderer;
import util.file;

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

abstract class ShaderProgram{}


public class Shader
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
            import def.debugging.log;
            logln("Failed loading shaders");
        }
    }

    void setFromPreset(HipShaderPresets preset = HipShaderPresets.DEFAULT)
    {
        ShaderStatus status = ShaderStatus.SUCCESS;
        switch(preset) with(HipShaderPresets)
        {
            case SPRITE_BATCH:
                status = loadShaders(vertexShader.getSpriteBatchVertex(), fragmentShader.getSpriteBatchFragment());
                break;
            case FRAME_BUFFER:
                status = loadShaders(vertexShader.getFrameBufferVertex(), fragmentShader.getFrameBufferFragment());
                break;
            case GEOMETRY_BATCH:
                status = loadShaders(vertexShader.getGeometryBatchVertex(), fragmentShader.getGeometryBatchFragment());
                break;
            case BITMAP_TEXT:
                status = loadShaders(vertexShader.getBitmapTextVertex(), fragmentShader.getBitmapTextFragment());
                break;
            case DEFAULT:
                status = loadShaders(vertexShader.getDefaultVertex(),fragmentShader.getDefaultFragment());
                break;
            case NONE:
            default:
                break;
        }
        if(status != ShaderStatus.SUCCESS)
        {
            import def.debugging.log;
            logln("Failed loading shaders with status ", status, " at preset ", preset);
        }
    }

    ShaderStatus loadShaders(string vertexShaderSource, string fragmentShaderSource)
    {
        if(!shaderImpl.compileShader(vertexShader, vertexShaderSource))
            return ShaderStatus.VERTEX_COMPILATION_ERROR;
        if(!shaderImpl.compileShader(fragmentShader, fragmentShaderSource))
            return ShaderStatus.FRAGMENT_COMPILATION_ERROR;
        if(!shaderImpl.linkProgram(shaderProgram, vertexShader, fragmentShader))
            return ShaderStatus.LINK_ERROR;
        deleteShaders();
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
        import std.stdio;
        if(v == null)
        {
            import std.stdio : writeln;
            writeln(name);
        }
        else
        {
            assert(v.shaderType == ShaderTypes.VERTEX, "Variable named "~name~" must be from Vertex Shader");
            v.set(val);
        }
    }
    public void setFragmentVar(T)(string name, T val)
    {
        ShaderVar* v = findByName(name);
        assert(v.shaderType == ShaderTypes.FRAGMENT, "Variable named "~name~" must be from Vertex Shader");
        v.set(val);
    }

    protected ShaderVar* findByName(string name)
    {
        import std.array : split;
        string[] names = name.split(".");
        bool isDefault = names[0] == "";

        if(isDefault)
        {
            import std.stdio;
            ShaderVarLayout* sL = names[1] in defaultLayout.variables;
            if(sL !is null)
                return sL.sVar;
        }
        else
        {
            ShaderVariablesLayout* l = (names[0] in layouts);
            if(l !is null)
            {
                ShaderVarLayout* sL = names[1] in l.variables;
                if(sL !is null)
                    return sL.sVar;
            }
        }
        return null;
    }

    public ShaderVar* get(string name){return findByName(name);}

    // public void setVertexVar(T)(string name, T val)
    // {

    // }

    public void addVarLayout(ShaderVariablesLayout layout)
    {
        assert((layout.name in layouts) is null, "Shader: VariablesLayout '"~layout.name~"' is already defined");
        if(defaultLayout is null)
            defaultLayout = layout;
        layouts[layout.name] = layout;
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
        assert(defaultLayout.variables[member].sVar.set(value), "Invalid value of type "~
        T.stringof~" passed to "~defaultLayout.name~"."~member);
    }

    void sendVars()
    {
        shaderImpl.sendVars(shaderProgram, layouts);
    }


    protected void deleteShaders()
    {
        shaderImpl.deleteShader(&fragmentShader);
        shaderImpl.deleteShader(&vertexShader);
    }

}
