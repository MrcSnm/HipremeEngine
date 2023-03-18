module hip.hiprenderer.backend.metal.mtlshader;

import hip.hiprenderer;
import hip.console.log;
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
        return q{
fragment float4 fragment_main(
    FragmentInput in [[stage_in]],
    FragmentUniforms& u
    texture2d<float> uBufferTexture [[texture(0)]],
    sampler uBufferTextureSampler [[sampler(0)]]
)
{
    return uBufferTexture.sample(uBufferTextureSampler, in.inTexST) * u.uColor;
}  
};
    }

    override string getGeometryBatchFragment()
    {
        return q{

struct FragmentUniforms
{
    float4 uGlobalColor;
};

fragment float4 fragment_main(
    FragmentInput in [[stage_in]],
    constant FragmentUniforms& uniforms [[buffer(0)]]
)
{
    return in.inVertexColor * uniforms.uGlobalColor;
}
};
    }

    override string getSpriteBatchFragment()
    {
        return q{
struct FragmentUniforms
{
    float4 uBatchColor;
};
fragment float4 fragment_main(
    FragmentInput in [[stage_in]],
    array<texture2d<float>, 3> uTex [[texture(0)]],
    array<sampler, 3> uSampler [[sampler(0)]]
)
{
    int texID = int(in.inTexID);
    return uTex[texID].sample(uSampler[texID], in.inTexST)* in.inVertexColor * u.uBatchColor;
}
};
    }

    override string getBitmapTextFragment()
    {
        return q{
struct FragmentUniforms
{
    float4 uColor;
};
fragment float4 fragment_main(
    FragmentInput in [[stage_in]],
    constant FragmentUniforms& u [[buffer(0)]],
    texture2d<float> uTex [[texture(0)]],
    sampler uTexSampler [[sampler(0)]]
)
{
    float r = uTex.sample(uTexSampler,in.inTexST);
    return float4(r,r,r,r)*u.uColor;
}
};
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
        return `
#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct VertexInput
{
    float2 vPosition;
    float2 vTexST;
};
struct FragmentInput
{
    ///Unused
    float4 position [[position]];
    float2 inTexST;
}; 

vertex FragmentInput vertex_main(
    uint vertexID [[vertex_id]],
    VertexInput* input [[buffer(1)]]
)
{
    FragmentInput out;
    out.position = float4(input[vertexID].vPosition, 0.0, 1.0);
    out.inTexST = input[vertexID].vTexST;
    return out;
}
`;
    }

    override string getGeometryBatchVertex()
    {
        return `

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct VertexInput
{
    float3 vPosition;
    float4 vColor;
};
struct VertexUniforms
{
    float4x4 uProj;
    float4x4 uModel;
    float4x4 uView;
};
struct FragmentInput
{
    float4 position [[position]];
    float4 inVertexColor;
}; 

vertex FragmentInput vertex_main(
    uint vertexID [[vertex_id]],
    constant VertexUniforms& u [[buffer(0)]],
    const device VertexInput* input [[buffer(1)]]
)
    {
        FragmentInput out;
        VertexInput v = input[vertexID];
        out.position = u.uProj*u.uView*u.uModel*float4(v.vPosition, 1.0);
        out.inVertexColor = v.vColor;
        return out;
    }
`;
    }

    override string getSpriteBatchVertex()
    {
        return `
#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;
struct VertexInput
{
    float3 vPosition;
    float4 vColor;
    float2 vTexST;
    float vTexID;
};
struct VertexUniforms
{
    float4x4 uProj;
    float4x4 uModel;
    float4x4 uView;
};
struct FragmentInput
{
    float4 position [[position]];
    float4 inVertexColor;
    float2 inTexST;
    float inTexID;
};

vertex FragmentInput vertex_main(
    uint vertexID [[vertex_id]],
    constant VertexUniforms& u [[buffer(0)]],
    device VertexInput* input [[buffer(1)]]
)
{
    FragmentInput out;
    VertexInput v = input[vertexID];
    out.position = u.uProj*u.uView*u.uModel*float4(v.vPosition, 1.0);
    out.inVertexColor = v.vColor;
    out.inTexST = v.vTexST;
    out.inTexID = v.vTexID;
    return out;
}
`;
    }
    override string getBitmapTextVertex()
    {
        return `
#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct VertexInput
{
    float2 vPosition;
    float2 vTexST;
};
struct VertexUniforms
{
    float4x4 uModel;
    float4x4 uView;
    float4x4 uProj;
};
struct FragmentInput
{
    float4 position [[position]];
    float2 inTexST;
};
vertex FragmentInput vertex_main(
    uint vertexID [[vertex_id]],
    constant VertexUniforms& u [[buffer(0)]],
    device VertexInput* input [[buffer(1)]]
)
{
    FragmentInput out;
    out.position = u.uProj * u.uView * u.uModel * float4(input[vertexID], 1.0);
    out.inTexST = input[vertexID].vTexST;
    return out;
}`;
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
        return new HipMTLShaderProgram();
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
        MTLCompileOptions opts = MTLCompileOptions.alloc.initialize;
        p.library = device.newLibraryWithSource(shaderSource.ns, opts, &err);

        if(p.library is null || err !is null)
        {
            loglnError("Could not compile shader.");
            err.print();
            return false;
        }
        p.fragmentShaderFunction = p.library.newFunctionWithName("fragment_main".ns);
        if(p.fragmentShaderFunction is null)
        {
            loglnError("fragment_main() not found.");
            return false;
        }
        p.vertexShaderFunction = p.library.newFunctionWithName("vertex_main".ns);
        if(p.vertexShaderFunction is null)
        {
            loglnError("vertex_main() not found.");
            return false;
        }

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
        HipMTLShaderProgram s = cast(HipMTLShaderProgram)(layout.getShader()).shaderProgram;
        layout.setAdditionalData(cast(void*)buffer, true);
        final switch(layout.shaderType)
        {
            case ShaderTypes.VERTEX:
                s.uniformBufferVertex = buffer;
                break;
            case ShaderTypes.FRAGMENT:
                s.uniformBufferFragment = buffer;
                break;
            case ShaderTypes.GEOMETRY:
            case ShaderTypes.NONE:
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