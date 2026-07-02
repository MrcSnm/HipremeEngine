module hip.api.renderer.shadereffect;
import hip.api.renderer.core_;
import hip.api.renderer.shadervar;

struct ShaderEffect
{
    HipRendererType type;
    ShaderSourceResource[] sources;
    private string[] mainArguments;
    private string[] effectParamsDefinition;
    private string[] effectParamsCall;
    private string fxSource;

    @disable this();

    this(HipRendererType type)
    {
        this.type = type;
        this.effectParamsCall~= "fx";
        this.effectParamsDefinition~= "EffectInput fx";
    }
    ShaderEffect addSource(string source)
    {
        fxSource~= source;
        return this;
    }

    string getSource()
    {
        return fxSource;
    }

    string getEffectParamsDefinition()
    {
        import hip.util.array;
        return "#define EFFECT_PARAMS "~effectParamsDefinition.join(",")~"\n";
    }

    string getMainArguments()
    {
        import hip.util.array;
        return mainArguments.join(",");
    }
    string getEffectParamsCall()
    {
        import hip.util.array;
        return effectParamsCall.join(",");
    }
    string getGlobalDefinitions()
    {
        import hip.util.string;
        BigString ret;
        ret~= getEffectParamsDefinition;
        ret~= "\n";
        foreach(s; sources)
            ret~= s.extraSource;
        return ret.toString.dup;
    }

    void addUbo(ShaderVariablesLayout layout)
    {
        import hip.util.string;
        ShaderSourceResource src;
        src.extraSource~= SmallString("\n//======= Auto Generated UBO (Binding ", layout.bindPoint, ")=======\n").toString;
        layout.generateUbo(type, src);
        effectParamsCall~= layout.instanceName;
        final switch(type)
        {
            case HipRendererType.GL3:
                break;
            case HipRendererType.D3D11:
                effectParamsDefinition~= SmallString(layout.name,"Buffer ",layout.instanceName).toString.dup;
                break;
            case HipRendererType.Metal:
                effectParamsDefinition~= SmallString("constant ",layout.name,"& ",layout.instanceName).toString.dup;
                mainArguments~= SmallString(",constant ", layout.name, "& ", layout.instanceName, " [[buffer(", layout.bindPoint, ")]]").toString.dup;
                break;
            case HipRendererType.None:
                break;
        }
        sources ~= src;
    } 
}