module hip.hiprenderer.backend.metal.mtlshader;

import hip.hiprenderer;
import metal;
import metal.metal;


class HipMTLFragmentShader : FragmentShader
{
    this(MTLDevice device){}
    string shaderSource;
    override string getDefaultFragment()
    {
        return string.init; // TODO: implement
    }

    override string getFrameBufferFragment()
    {
        return string.init; // TODO: implement
    }

    override string getGeometryBatchFragment()
    {
        return q{

fragment float4 fragment_main(FragmentInput in [[stage_in]])
{
    return in.inVertexColor * uGlobalColor;
}
};
    }

    override string getSpriteBatchFragment()
    {
        return string.init; // TODO: implement
    }

    override string getBitmapTextFragment()
    {
        return string.init; // TODO: implement
    }
}

class HipMTLVertexShader : VertexShader
{
    this(MTLDevice device){}
    string shaderSource;
    override string getDefaultVertex()
    {
        return string.init; // TODO: implement
    }

    override string getFrameBufferVertex()
    {
        return q{

struct VertexInput
{

};
struct FragmentInput
{
    ///Unused
    float4 position [[position]];
    float4 inVertexColor;
}; 

vertex 
};
    }

    override string getGeometryBatchVertex()
    {
        return q{
struct VertexInput
{
    float3 vPositionn;
    float4 vColor;
};
struct Uniforms
{
    float4x4 uProj;
    float4x4 uModel;
    float4x4 uView;
};
struct FragmentInput
{
    float4 position [[position]];
    float4 inColor;
}; 

vertex FragmentInput vertex_main(
    uint vertexID [[vertex_id]],
    constant VertexInput* input [[buffer(0)]],
    constant Uniforms* uniforms [[buffer(1)]]
)
    {
        FragmentInput out;
        VertexInput v = input[vertexID];
        out.position = uProj*uView*uModel*float4(v.vPosition, 1.0);
        out.inColor = v.vColor;
        return out;
    }
};
    }

    override string getSpriteBatchVertex()
    {
        return string.init; // TODO: implement
    }

    override string getBitmapTextVertex()
    {
        return string.init; // TODO: implement
    }
}

class HipMTLShaderProgram : ShaderProgram
{
    MTLLibrary library;
    MTLFunction vertexShaderFunction;
    MTLFunction fragmentShaderFunction;
    MTLBuffer uniformBufferVertex;
    MTLBuffer uniformBufferFragment;

    MTLRenderPipelineDescriptor pipelineDescriptor;
    MTLRenderPipelineState pipelineState;

    this()
    {
        pipelineDescriptor = MTLRenderPipelineDescriptor.alloc.initialize;
        pipelineState = MTLRenderPipelineState.alloc.init;
    }
}



__gshared HipMTLShaderProgram boundShader;

class HipMTLShader : IShader
{
    MTLDevice device;
    MTLRenderCommandEncoder encoder;

    this(MTLDevice device, MTLRenderCommandEncoder encoder)
    {
        this.device = device;
        this.encoder = encoder;
    }

    VertexShader createVertexShader()
    {
        return new HipMTLVertexShader(device);
    }

    FragmentShader createFragmentShader()
    {
        return new HipMTLFragmentShader(device);
    }

    ShaderProgram createShaderProgram()
    {
        return ShaderProgram.init; // TODO: implement
    }

    bool compileShader(FragmentShader fs, string shaderSource)
    {
        (cast(HipMTLFragmentShader)fs).shaderSource = shaderSource;
        return true;
    }

    bool compileShader(VertexShader vs, string shaderSource)
    {
        (cast(HipMTLVertexShader)vs).shaderSource = shaderSource;
        return true;
    }

    bool linkProgram(ref ShaderProgram program, VertexShader vs, FragmentShader fs)
    {
        HipMTLShaderProgram p = cast(HipMTLShaderProgram)program;

        HipMTLVertexShader v = cast(HipMTLVertexShader)vs;
        HipMTLFragmentShader f = cast(HipMTLFragmentShader)fs;

        string shaderSource = v.shaderSource~f.shaderSource;
        scope(exit)
        {
            import core.memory;
            GC.free(cast(void*)shaderSource.ptr);
        }

        NSError err;
        MTLCompileOptions opts = cast(MTLCompileOptions)MTLCompileOptions.alloc.initialize;
        p.library = device.newLibraryWithSource(shaderSource.ns, opts, &err);

        if(p.library is null || err !is null)
            return false;
        p.fragmentShaderFunction = p.library.newFunctionWithName("fragment_main".ns);
        if(p.fragmentShaderFunction is null)
            return false;
        p.vertexShaderFunction = p.library.newFunctionWithName("vertex_main".ns);
        if(p.vertexShaderFunction is null)
            return false;

        p.pipelineDescriptor.label = "HipremeShader".ns;
        p.pipelineDescriptor.vertexFunction = p.vertexShaderFunction;
        p.pipelineDescriptor.fragmentFunction = p.fragmentShaderFunction;
        p.pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.BGRA8Unorm_sRGB;
        p.pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormat.Depth32Float_Stencil8;
        p.pipelineDescriptor.stencilAttachmentPixelFormat = MTLPixelFormat.Depth32Float_Stencil8;
        
        return true;
    }

    void bind(ShaderProgram program)
    {
        HipMTLShaderProgram mtlShader = cast(HipMTLShaderProgram)program;
        encoder.setRenderPipelineState(mtlShader.pipelineState);
        if(mtlShader.uniformBufferVertex)
            encoder.setVertexBuffer(mtlShader.uniformBufferVertex, 0, 0);
        if(mtlShader.uniformBufferFragment)
            encoder.setFragmentBuffer(mtlShader.uniformBufferFragment, 0, 0);
        boundShader = mtlShader;
    }

    void unbind(ShaderProgram program)
    {
        encoder.setRenderPipelineState(null);
        encoder.setVertexBuffer(null, 0, 0);
        encoder.setFragmentBuffer(null, 0, 0);
        if(boundShader is program) boundShader = null;
    }

    void sendVertexAttribute(uint layoutIndex, int valueAmount, uint dataType, bool normalize, uint stride, int offset)
    {
        
    }

    int getId(ref ShaderProgram prog, string name)
    {
        return int.init; // TODO: implement
    }

    void deleteShader(FragmentShader* fs){}
    void deleteShader(VertexShader* vs){}
    void createVariablesBlock(ref ShaderVariablesLayout layout)
    {
        MTLBuffer buffer = device.newBuffer(layout.getLayoutSize(), MTLResourceOptions.DefaultCache);
        Shader s = layout.getShaderOwner();
        layout.setAdditionalData(cast(void*)buffer, true);
        final switch(layout.shaderType)
        {
            case ShaderTypes.VERTEX:
                s.uniformBufferVertex = buffer;
                break;
            case ShaderTypes.FRAGMENT:
                s.uniformBufferFragment = buffer;
                break;
        }
    }
    void sendVars(ref ShaderProgram prog, ShaderVariablesLayout[string] layouts)
    {
        import core.stdc.string;

        HipMTLShaderProgram mtlShader = cast(HipMTLShaderProgram)prog;
        foreach(layout; layouts)
        {
            MTLBuffer uniformBuffer = cast(MTLBuffer)layout.getAdditionalData();
            memcpy(uniformBuffer.contents, layout.getBlockData, layout.getLayoutSize);
        }
    }

    void initTextureSlots(ref ShaderProgram prog, IHipTexture texture, string varName, int slotsCount)
    {
        
    }

    void dispose(ref ShaderProgram){}
}