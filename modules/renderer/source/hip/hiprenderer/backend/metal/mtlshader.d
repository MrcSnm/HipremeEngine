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
        return string.init; // TODO: implement
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
        return string.init; // TODO: implement
    }

    override string getGeometryBatchVertex()
    {
        return string.init; // TODO: implement
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
    MTLBuffer uniformbuffer;

    MTLRenderPipelineDescriptor pipelineDescriptor;
    MTLRenderPipelineState pipelineState;

    this()
    {
        descriptor = MTLRenderPipelineDescriptor.alloc.initialize;
        pipelineState = MTLRenderPipelineState.alloc.init;
    }
}



__gshared HipMTLShader boundShader;

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
        HipMTLVertexShader f = cast(HipMTLFragmentShader)fs;

        string shaderSource = v.shaderSource~f.shaderSource;
        scope(exit)
        {
            import core.memory;
            GC.free(shaderSource);
        }

        NSError err;
        MTLCompileOptions opts = MTLCompileOptions.alloc.initialize;
        p.library = newLibraryWithSource(shaderSource.ns, opts, &err);

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
        encoder.setRenderPipelineState(mtlShader.state);
        encoder.setFragmentBuffer(mtlShader.uniformbuffer, 0, 0);
        boundShader = this;
    }

    void unbind(ShaderProgram program)
    {
        encoder.setRenderPipelineState(null);
        encoer.setFragmentBuffer(null, 0, 0);
        if(boundShader is this) boundShader = null;
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
        uniformBuffer = device.newBuffer(layout.getLayoutSize(), MTLResourceOptions.DefaultCache);
    }

    void sendVars(ref ShaderProgram prog, ShaderVariablesLayout[string] layouts)
    {
        import core.stdc.string;

        HipMTLShaderProgram mtlShader = cast(HipMTLShaderProgram)prog;
        foreach(layout; layouts)
        {
            memcpy(mtlShader.uniformbuffer.contents, layout.getBlockData, layout.getLayoutSize);
        }
    }

    void initTextureSlots(ref ShaderProgram prog, IHipTexture texture, string varName, int slotsCount)
    {
        
    }

    void dispose(ref ShaderProgram){}
}