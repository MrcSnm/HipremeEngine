module metal;

version(D_ObjectiveC)
{
    import core.attribute;

    extern(Objective-C):



    struct MTLResourceOptions
    {
        extern initialize(uint rawValue) @selector("init");
    }

    extern class NSString
    {
        static NSString stringWithCString(char* stringWithCString, size_t encoding);
        static size_t defaultCStringEncoding();
        void dealloc();
    }

    extern class MTLLibrary
    {
        MTLFunction newFunctionWithName(NSString);

        void release();
    }

    extern class NSError
    {

    }
    extern class MTLRenderPipelineState
    {
        static MTLRenderPipelineState alloc() @selector("alloc");
        MTLRenderPipelineState init() @selector("init");

        NSString label;
        MTLFunction vertexFunction;
        MTLFunction fragmentFunction;
        MTLVertexDescriptor vertexDescriptor;

        void release();
    }

    extern class MTLRenderCommandEncoder
    {
        NSString label;

        void setViewport(MTLViewport);
        void setRendererPipelineState(pipelineState);
        void setCullMode(MTLCullMode);
        void setVertexBuffer(MTLBuffer vertexBuffer, int offset, int index);
        void drawIndexedPrimitives(MTLPrimitiveType, int indexCount, MTLIndexType indexType, MTLBuffer indexBuffer, int indexBufferOffset);
        void endEncoding();
        void presentDrawable();
        void commit();
    }

    extern class MTLVertexDescriptor
    {
        static MTLVertexDescriptor vertexDescriptor() @selector("vertexDescriptor");
    }
    extern class MTLFunction
    {

    }

    struct MTLClearColor
    {
        float red, green, blue, alpha;
    }
    extern class MTLRenderPassDescriptor
    {
        static MTLRenderPassDescriptor renderPassDescriptor();


        colorAttachments
    }
    extern class MTLCommandBuffer
    {
        MTLCommandQueue newCommandQueue() @selector("newCommandQueue");
        MTLBuffer newBufferWithLength(size_t size, MTLResourceOptions options) @selector("newBufferWithLength");
        MTLLibrary newLibraryWithSource(NSString, options, NSError error);
        MTLRenderCommandEncoder renderCommandEncoderWithDescriptor(MTLRenderPassDescriptor renderPassDescriptor);
        void release();
    }

    MTLCommandBuffer MTLCreateSystemDefaultDevice();


    extern class MTLCommandQueue
    {
        void release();
    }


    extern class MTLBuffer
    {
        void* contents;
        void setLabel(NSString) @selector("setLabel:");
    }
}