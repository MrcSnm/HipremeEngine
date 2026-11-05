module hip.hiprenderer.backend.metal.mtlbuffer;
import metal;
import hip.hiprenderer;
import hip.hiprenderer.backend.metal.mtlrenderer;

MTLResourceOptions mtlOptions(HipResourceUsage usage)
{
    final switch(usage)
    {
        case HipResourceUsage.Dynamic:
            return MTLResourceOptions.StorageModeShared;
        case HipResourceUsage.Immutable:
            return MTLResourceOptions.StorageModePrivate;
        case HipResourceUsage.Default:
            return MTLResourceOptions.DefaultCache;
    }
}

final class HipMTLBuffer : HipRendererBuffer
{
    MTLBuffer buffer;
    MTLCommandQueue cmdQueue;
    MTLResourceOptions options;
    MTLDevice device;
    size_t size;

    this(MTLDevice device, MTLCommandQueue cmdQueue, size_t size, HipResourceUsage usage, HipRendererBufferType type)
    {
        this.device = device;
        this.cmdQueue = cmdQueue;
        options = usage.mtlOptions;
        this.size = size;
        this.buffer = device.newBuffer(size, options);
        _type = type;
    }
    this(MTLDevice device, MTLCommandQueue cmdQueue, const(ubyte)[] data, HipResourceUsage usage, HipRendererBufferType type)
    {
        _type = type;
        options = usage.mtlOptions;
        this.device = device;
        this.cmdQueue = cmdQueue;
        this.size = data.length;
        if(options == MTLResourceOptions.StorageModePrivate)
            buffer = device.newBuffer(size, options);
        setData(data);
    }
    override void bind(){}
    override void unbind(){}
    override void setData(const void[] data)
    {
        if(options == MTLResourceOptions.StorageModePrivate)
        {
            MTLBuffer temp = device.newBuffer(data.ptr, data.length, MTLResourceOptions.StorageModeShared);
            MTLCommandBuffer cmdBuffer = cmdQueue.defaultCommandBuffer();
            MTLBlitCommandEncoder cmdEncoder = cmdBuffer.blitCommandEncoder;
            cmdEncoder.copyFromBuffer(temp, 0, buffer, 0, data.length);
            cmdEncoder.endEncoding();
            cmdBuffer.commit();
            cmdBuffer.waitUntilCompleted();
            if(cmdBuffer.error)
                NSLog("Command Buffer Error: %@".ns, cmdBuffer.error);
        }
        else
        {
            if(buffer) buffer.release();
            buffer = device.newBuffer(data.ptr, data.length, options);
            size = data.length;
        }
        if(buffer is null)
            throw new Error("Could not create buffer.");
    }

    override ubyte[] getBuffer(){return cast(ubyte[])buffer.contents[0..size];}
    override void unmapBuffer(){}

    override void updateData(int offset, const void[] data)
    {
        buffer.contents[offset..offset+data.length] = data[];
    }

    override void dispose()
    {
        if(buffer)
            buffer.release();
        buffer = null;
        size = 0;
    }
}