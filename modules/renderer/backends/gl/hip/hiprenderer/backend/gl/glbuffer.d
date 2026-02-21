module hip.hiprenderer.backend.gl.glbuffer;
import hip.hiprenderer.renderer;
import hip.api.renderer.vertex;
import hip.hiprenderer.backend.gl.glrenderer;

GLenum getBufferType(HipRendererBufferType type)
{
    final switch ( type )
    {
        case HipRendererBufferType.vertex:
            return GL_ARRAY_BUFFER;
        case HipRendererBufferType.index:
            return GL_ELEMENT_ARRAY_BUFFER;
        case HipRendererBufferType.uniform:
            return GL_UNIFORM_BUFFER;
    }
}

final class Hip_GL3_Buffer : IHipRendererBuffer
{
    size_t size;
    uint handle;
    immutable int usage;
    int glType;
    int glAccess;
    immutable HipRendererBufferType _type;

    HipRendererBufferType type() const { return _type; }

    this(size_t size, HipResourceUsage usage, HipRendererBufferType type, HipResourceAccess access = HipResourceAccess.write)
    {
        this.usage = getGLUsage(usage);
        this._type = type;
        this.glType = getBufferType(type);
        this.glAccess = getGLAccess(access);
        this.size = size;
        glCall(() => glGenBuffers(1, &handle));
        bind();
        glCall(() => glBufferData(glType, size, null, this.usage));
        unbind();
    }
    void bind()
    {
        glCall(()=>glBindBuffer(glType, handle));
    }
    void unbind()
    {
        glCall(()=>glBindBuffer(glType, 0));
    }
    void setData(const(void)[] data)
    {
        this.size = data.length;
        bind();
        glCall(() => glBufferData(glType, data.length, cast(void*)data.ptr, this.usage));
    }

    ubyte[] getBuffer()
    {
        version(HipGL3)
        {
            bind();
            scope(exit) unbind();
            return cast(ubyte[])glCall(() => glMapBuffer(glType, this.glAccess))[0..size];
        }
        else
            return null;
    }
    void unmapBuffer()
    {
        version(HipGL3)
        {
            bind();
            scope(exit) unbind();
            glUnmapBuffer(glType);
        }
    }
    void updateData(int offset, const(void)[] data)
    {
        import hip.error.handler;
        import hip.util.conv;
        if(data.length + offset > this.size)
        {
            ErrorHandler.assertExit(
                false, "Tried to set data with size "~to!string(size)~"and offset "~to!string(offset)~
        "for buffer with size "~to!string(this.size));
        }
        this.bind();
        {
            glCall(() => glBufferSubData(glType, offset, data.length, data.ptr));
        }
    }
    ~this(){glCall(() => glDeleteBuffers(1, &handle));}
}

private int getGLAccess(HipResourceAccess access)
{
    final switch(access) with(HipResourceAccess)
    {
        case write: return GL_WRITE_ONLY;
        case read: return GL_READ_ONLY;
        case readWrite: return GL_READ_WRITE;
    }
}

private int getGLUsage(HipResourceUsage usage)
{
    final switch(usage) with(HipResourceUsage)
    {
        case Immutable:
            return GL_STATIC_DRAW;
        case Default:
        case Dynamic:
            return GL_DYNAMIC_DRAW;
    }
}
