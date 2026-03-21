/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
/**
*    This file provides the essential information for specifying vertices
*   for the target 3D API. Its Attributes/Layout, some preset layouts.
*    The workflow for vertices are entirely based on OpenGL, using VAOs and VBOs
*
*/

module hip.hiprenderer.vertex;
import hip.hiprenderer.renderer;
import hip.error.handler;
import hip.console.log;
public import hip.api.renderer.vertex;




private __gshared HipVertexArrayObject lastBoundVertex;

/**
*   For using this class, you must first define the vertex layout for after that, create the vertex
*   buffer and/or the index buffer.
*/
class HipVertexArrayObject
{
    IHipVertexArrayImpl VAO;
    IHipRendererBuffer  EBO;
    HipVertexAttributeInfo[] infos;

    bool isBonded;
    protected bool hasVertexInitialized;
    protected bool hasIndexInitialized;

    /**
    *   Remember calling sendAttributes
    */
    this()
    {
        isBonded = false;
        this.VAO = HipRenderer.createVertexArray();
    }

    /**
    *   Creates and binds an index buffer.
    */
    void createIndexBuffer(index_t count, HipResourceUsage usage)
    {
        assert(EBO is null, "Can't create buffer if it is already assigned.");
        this.EBO = HipRenderer.createBuffer(count*index_t.sizeof, usage, HipRendererBufferType.index);
    }
    /**
    *   Sets the index buffer. Mainly useful for sharing multiple index buffer (quads and etc)
    */
    void setIndexBuffer(IHipRendererBuffer buffer)
    {
        this.EBO = buffer;
    }

    /**
    *   Sets the attribute infos that were appended to this object. This function must only be called
    *   after binding/creating a VBO, or it will fail
    */
    void sendAttributes(Shader s)
    {
        // if(!isBonded)
        // {
        //     ErrorHandler.showErrorMessage("VertexArrayObject error", "VAO wasn't bound when trying to send its attributes");
        //     return;
        // }
        assert(infos.length && EBO !is null, "Create the VBO and EBO before sending attributes.");
        this.VAO.createInputLayout(infos, EBO, s.shaderProgram);
    }

    void bind()
    {
        static if(UseDelayedUnbinding)
        {
            if(lastBoundVertex is this)
                return;
            if(lastBoundVertex !is null)
            {
                lastBoundVertex.isBonded = false;
                lastBoundVertex.VAO.unbind();
            }
            lastBoundVertex = this;
        }
        if(!this.isBonded)
        {
            isBonded = true;
            this.VAO.bind();
        }
        else assert(false, "Erroneous bind.");
    }
    void unbind()
    {
        static if(UseDelayedUnbinding)
            return;
        if(this.isBonded)
        {
            isBonded = false;
            this.VAO.unbind();
        }
        else assert(false, "Erroneous unbind.");
    }

    /**
    *   Sets the VBO data. Use this function only for initialization as it allocates memory.
    *   If you wish to only update its data, call updateVertices instead.
    *   Params:
    *       data = The data to set the vertices.
    *       vbo = Target vbo to set the data
    */
    void setVertices(const void[] data, ubyte vbo = 0)
    {
        if(infos.length == 0)
            ErrorHandler.showErrorMessage("Null VertexBuffer", "No vertex buffer was created before setting its vertices");
        else
        {
            hasVertexInitialized = true;
            this.infos[vbo].vbo.setData(data);
        }
    }
    /**
     * Update the VBO. Won't cause memory allocation.
     * Params:
     *   data = The data containing a type which is conforming to the VAO.
     *   offset = The offset is always multiplied by this vertex array object stride.
     *   vbo = The target vbo to update.
     */
    void updateVertices(const void[] data, int offset = 0, ubyte vbo = 0)
    {
        if(infos.length == 0)
            ErrorHandler.showErrorMessage("Null VertexBuffer", "No vertex buffer was created before setting its vertices");
        ErrorHandler.assertExit(hasVertexInitialized, "Vertex must setData before updating its contents.");
        this.infos[vbo].vbo.updateData(offset*this.infos[vbo].vboStride, data);
    }
    /**
    *   Will set the indices data. Beware that this function may allocate memory.
    *
    *   If you need to only change its data value instead of allocating memory for a greater index buffer
    *   call updateIndices
    */
    void setIndices(const index_t[] data)
    {
        if(EBO is null)
            ErrorHandler.showErrorMessage("Null IndexBuffer", "No index buffer was created before setting its indices");
        else
        {
            hasIndexInitialized = true;
            this.EBO.setData(data);
        }
    }
    /**
    *   Updates the index buffer's data. It won't allocate memory
    */
    void updateIndices(const index_t[] data, int offset = 0)
    {
        if(EBO is null)
            ErrorHandler.showErrorMessage("Null IndexBuffer", "No index buffer was created before setting its indices");
        else
        {
            ErrorHandler.assertExit(hasIndexInitialized, "Index must setData before updating its contents.");
            this.EBO.updateData(cast(int)(offset*index_t.sizeof), data);
        }
    }

    /**
    * Receives a struct and creates a VAO based on its member types and names.
    */
    static HipVertexArrayObject getVAO(BufferTypes...)(HipVertexAttributeCreateInfo[BufferTypes.length] creationInfo)
    {
        HipVertexArrayObject obj = new HipVertexArrayObject();
        static foreach(i, T; BufferTypes)
        {
            static assert(is(T == struct), T.stringof~" must be a struct to create a HipVertexAttributeInfo based on it.");
            obj.infos~= getAttributeInfo!(T)();
            obj.infos[i].vbo = HipRenderer.createBuffer(creationInfo[i].count * obj.infos[i].vboStride, creationInfo[i].usage, HipRendererBufferType.vertex);
        }
        return obj;
    }
}

/**
*   This function creates an attribute information,
* for later sending it(it is necessary as the stride needs to be recalculated)
*/
private ref HipVertexAttributeInfo appendAttributeField(return ref HipVertexAttributeInfo info, 
    uint count,
    HipAttributeType valueType,
    uint typeSize,
    string fieldName,
    bool isPadding = false
)
{
     
    HipVertexAttributeFieldInfo field = HipVertexAttributeFieldInfo(
        name: fieldName,
        count: count,
        valueType: valueType,
        typeSize: typeSize,
        index: cast(uint)info.fields.length,
        //It actually is the `last stride`, which is the same as the offset is the total current stride
        offset: info.vboStride
    );

    // if(!isPadding)
    {
        info.fields~= field;
        info.dataCount+= count;
    }
    info.vboStride += count*typeSize;
    return info;
}

private ref HipVertexAttributeInfo appendAttributeField(T)(return ref HipVertexAttributeInfo info, string infoName, bool isPadding = false)
{
    uint count = 1;
    HipAttributeType type = HipAttributeType.Float;
    uint typeSize = float.sizeof;
    import hip.math.vector;

    static if(is(T == Vector2)) count = 2;
    else static if(is(T == Vector3)) count = 3;
    else static if(is(T == Vector4) || is(T == HipColorf)) count = 4;
    else static if(is(T == HipColor))
    {
        type = HipAttributeType.Rgba32;
        count = 4;
        typeSize = ubyte.sizeof;
    }
    else
    {
        static if(is(T == int)) type = HipAttributeType.Int;
        else static if(is(T == uint)) type = HipAttributeType.Uint;
        else static if(is(T == bool)) type = HipAttributeType.Bool;
        else
            static assert(is(T == float), "Unrecognized type for attribute: "~T.stringof);

        typeSize = T.sizeof;
    }
    return appendAttributeField(info, count, type, typeSize ,infoName, isPadding);
}


private HipVertexAttributeInfo getAttributeInfo(T)() if(is(T == struct))
{
    import std.traits:isFunction;
    import hip.util.reflection:hasUDA;

    HipVertexAttributeInfo info;

    static foreach(member; __traits(allMembers, T))
    {{
        alias mem = __traits(getMember, T, member);
        static if(!isFunction!(mem) && __traits(compiles, mem.offsetof))
        {
            appendAttributeField!((typeof(mem)))
            (
                info,
                member,
                hasUDA!(mem, HipShaderInputPadding)
            );
        }
    }}
    return info;
}