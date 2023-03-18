module hipreme_engine;
import metal;

extern(C) int getDNumber(){return 500;}


void print(string str)
{
    NSLog(str.ns);
}



const float[] vertexData = [
    0.0, 1.0, 0.0,
    -1.0, -1.0, 0.0,
    1.0, -1.0, 0.0
];


enum metalVertexShader = q{

vertex float4 basic_vertex(
    const device packed_float3* vertex_array [[buffer(0)]],
    unsigned int vid [[vertex_id]]
)
{
    return float4(vertex_array[vid], 1.0);
}

};

enum metalFragmentShader = q{

fragment half4 basic_fragment()
{
    return half4(1.0);
}

};


import metal;

__gshared MTLBuffer vertexBuffer;
__gshared MTLRenderPipelineDescriptor pipelineDescriptor;
__gshared MTLCommandQueue commandQueue;
__gshared MTLRenderPipelineState state;

enum DefaultPixelFormat = MTLPixelFormat.BGRA8Unorm_sRGB;

extern(C) void initMetal(MTLDevice device)
{
    import std.conv:to;
    print("Initializing Metal!");
    vertexBuffer = device.newBuffer(vertexData.ptr, float.sizeof*vertexData.length, MTLResourceOptions.DefaultCache);

    NSError err;
    MTLLibrary defaultLibrary = device.newLibraryWithSource((metalVertexShader ~ metalFragmentShader).ns, null, &err);
    if(err !is null || defaultLibrary is null)
    {
        NSLog("Error compiling shader %@".ns, err);
        return;
    }

    print("Getting vertex and fragment shaders");
    MTLFunction fragmentProgram = defaultLibrary.newFunctionWithName("basic_fragment".ns);
    MTLFunction vertexProgram = defaultLibrary.newFunctionWithName("basic_vertex".ns);

    if(fragmentProgram is null)
        print("Could not get fragment shader");
    if(vertexProgram is null)
        print("Coult not get vertex shader");

    print("Creating VertexFormat");

    MTLVertexDescriptor descriptor = MTLVertexDescriptor.vertexDescriptor;

    enum POSITION = 0;
    enum BufferIndexMeshPositions = 0;
    descriptor.attributes[POSITION].format = MTLVertexFormat.float3;
    descriptor.attributes[POSITION].offset = 0;
    descriptor.attributes[POSITION].bufferIndex = BufferIndexMeshPositions;

    descriptor.layouts[POSITION].stepRate = 1;
    descriptor.layouts[POSITION].stepFunction = MTLVertexStepFunction.PerVertex;
    descriptor.layouts[POSITION].stride = float.sizeof*3;


    print("Creating PipelineDescriptor");
    pipelineDescriptor = MTLRenderPipelineDescriptor.alloc.initialize;
    pipelineDescriptor.label = "TestProgram".ns;
    pipelineDescriptor.vertexFunction = vertexProgram;
    pipelineDescriptor.fragmentFunction = fragmentProgram;
    pipelineDescriptor.vertexDescriptor = descriptor;
    pipelineDescriptor.colorAttachments[0].pixelFormat = DefaultPixelFormat;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormat.Depth32Float_Stencil8;
    pipelineDescriptor.stencilAttachmentPixelFormat = MTLPixelFormat.Depth32Float_Stencil8;

    state = device.newRenderPipelineStateWithDescriptor(pipelineDescriptor, &err);

    if(state is null || err !is null)
    {
        NSLog("Failed to create RenderPipelineDescriptor %@".ns, err);
        return;
    }


    commandQueue = device.newCommandQueue();

}

extern(C) void hipMetalRender(MTKView view)
{
    MTLRenderPassDescriptor desc = view.currentRenderPassDescriptor;
    if(desc is null) return;

    MTLCommandBuffer cmdBuffer = commandQueue.commandBuffer();
    cmdBuffer.label = "MyCommand".ns;


    MTLRenderCommandEncoder encoder = cmdBuffer.renderCommandEncoderWithDescriptor(desc);

    encoder.setRenderPipelineState(state);
    encoder.setVertexBuffer(vertexBuffer, 0, 0);

    encoder.drawPrimitives(MTLPrimitiveType.Triangle, 0, 9);

    encoder.endEncoding();
    cmdBuffer.presentDrawable(view.currentDrawable);
    cmdBuffer.commit();

    // desc.colorAttachments[0].texture = 
}