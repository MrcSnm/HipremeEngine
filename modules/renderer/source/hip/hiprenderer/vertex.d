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
public import hip.hiprenderer.backend.gl.glvertex;
// version(Android){alias index_t = ushort;}
// else{alias index_t = uint;}
alias index_t = ushort;


enum index_t_maxQuads()
{
    return cast(index_t)(ushort.max / 6);
}
enum index_t_maxQuadIndices()
{
    return cast(index_t)(index_t_maxQuads * 6);
}



enum InternalVertexAttribute
{
    POSITION = 0,
    TEXTURE_COORDS,
    COLOR
}

enum InternalVertexAttributeFlags
{
    POSITION = 1 << InternalVertexAttribute.POSITION,
    TEXTURE_COORDS = 1 << InternalVertexAttribute.TEXTURE_COORDS,
    COLOR = 1 << InternalVertexAttribute.COLOR,
}
enum HipBufferUsage
{
    DYNAMIC,
    STATIC,
    DEFAULT
}

enum HipAttributeType
{
    Float,
    Uint,
    Int,
    Bool
}


struct HipVertexAttributeInfo
{
    uint index;
    uint count;
    uint offset;
    uint typeSize;
    HipAttributeType valueType;
    string name;
}


interface IHipVertexBufferImpl
{
    void bind();
    void unbind();
    void setData(size_t size, const void* data);
    void updateData(int offset, size_t size, const void* data);
}
interface IHipIndexBufferImpl
{
    void bind();
    void unbind();
    void setData(index_t count, const index_t* data);
    void updateData(int offset, index_t count, const index_t* data);
}
interface IHipVertexArrayImpl
{
    void bind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo);
    void unbind(IHipVertexBufferImpl vbo, IHipIndexBufferImpl ebo);
    void setAttributeInfo(ref HipVertexAttributeInfo info, uint stride);
    ///Was created because Direct3D 11 needs shader to create its VAO
    void createInputLayout(Shader s);
}


/**
*   For using this class, you must first define the vertex layout for after that, create the vertex
*   buffer and/or the index buffer.
*/
class HipVertexArrayObject
{
    IHipVertexArrayImpl  VAO;
    IHipVertexBufferImpl VBO;
    IHipIndexBufferImpl  EBO;
    ///Accumulated size of the vertex data
    uint stride;
    ///How many data slots it uses, for instance, vec3 will count +3
    uint dataCount;
    HipVertexAttributeInfo[] infos;

    protected bool isBonded;
    
    /**
    *   Remember calling sendAttributes
    */
    this()
    {
        isBonded = false;
        this.VAO = HipRenderer.createVertexArray();
    }

    /**
    *   Populates a buffer with indices forming quads
    *   Returns if the output can contain the size
    */
    static bool putQuadBatchIndices(ref index_t[] output, size_t countQuads)
    {
        assert(output.length >= countQuads*6, "Out of bounds");
        if(output.length < countQuads*6)
            return false;
        index_t index = 0;
        for(index_t i = 0; i < countQuads; i++)
        {
            output[index+0] = cast(index_t)(i*4+0);
            output[index+1] = cast(index_t)(i*4+1);
            output[index+2] = cast(index_t)(i*4+2);

            output[index+3] = cast(index_t)(i*4+2);
            output[index+4] = cast(index_t)(i*4+3);
            output[index+5] = cast(index_t)(i*4+0);
            index+=6;
        }
        return true;
    }

    /**
    *   Creates and binds an index buffer.
    */
    void createIndexBuffer(index_t count, HipBufferUsage usage)
    {
        this.EBO = HipRenderer.createIndexBuffer(count, usage);
        this.bind();
        this.EBO.bind();
    }
    /**
    * Creates and binds a vertex buffer.
    *
    * The vertex buffer size is dependant on the attributes that were appended to this vertex array.
    */
    void createVertexBuffer(uint count, HipBufferUsage usage)
    {
        this.VBO = HipRenderer.createVertexBuffer(count*this.stride, usage);
        this.bind();
        this.VBO.bind();
    }
    /**
    *   This function creates an attribute information,
    * for later sending it(it is necessary as the stride needs to be recalculated)
    */
    HipVertexArrayObject appendAttribute(
        uint count, 
        HipAttributeType valueType, 
        uint typeSize, 
        string infoName, 
        bool isPadding = false,
    )
    {
        HipVertexAttributeInfo info;
        info.name = infoName;
        info.count = count;
        info.valueType = valueType;
        info.typeSize = typeSize;
        info.index = cast(uint)infos.length;
        //It actually is the `last stride`, which is the same as the offset is the total current stride
        info.offset = stride;
        // if(!isPadding)
        {
            infos~= info;
            dataCount+= count;
        }
        stride+= count*typeSize;
        return this;
    }

    HipVertexArrayObject appendAttribute(T)(string infoName, bool isPadding = false)
    {
        uint count = 1;
        HipAttributeType type = HipAttributeType.Float;
        uint typeSize = float.sizeof;
        import hip.math.vector;

        static if(is(T == Vector2)) count = 2;
        else static if(is(T == Vector3)) count = 3;
        else static if(is(T == Vector4) || is(T == HipColorf)) count = 4;
        else
        {
            static if(is(T == int)) type = HipAttributeType.Int;
            else static if(is(T == uint) || is(T == HipColor)) type = HipAttributeType.Uint;
            else static if(is(T == bool)) type = HipAttributeType.Bool;
            else
                static assert(is(T == float), "Unrecognized type for attribute: "~T.stringof);

            typeSize = T.sizeof;
        }
        return appendAttribute(count, type, typeSize ,infoName, isPadding);
    }

    /**
    *   Sets the attribute infos that were appended to this object. This function must only be called
    *   after binding/creating a VBO, or it will fail
    */
    void sendAttributes(Shader s)
    {
        if(!isBonded)
        {
            ErrorHandler.showErrorMessage("VertexArrayObject error", "VAO wasn't bound when trying to send its attributes");
            return;
        }
        foreach(info; infos)
            this.VAO.setAttributeInfo(info, stride);
        this.VAO.createInputLayout(s);
    }

    void bind()
    {
        // if(!this.isBonded)
        // {
            isBonded = true;
            this.VAO.bind(this.VBO, this.EBO);
        // }
    }
    void unbind()
    {
        // if(this.isBonded)
        // {
            isBonded = false;
            this.VAO.unbind(this.VBO, this.EBO);
        // }
    }

    /**
    *   Sets the VBO data. Use this function only for initialization as it allocates memory.
    *
    *   If you wish to only update its data, call updateVertices instead.
    */
    void setVertices(uint count, const void* data)
    {
        if(VBO is null)
            ErrorHandler.showErrorMessage("Null VertexBuffer", "No vertex buffer was created before setting its vertices");
            
        this.bind(); 
        this.VBO.setData(count*this.stride, data);
    }
    /**
    *   Update the VBO. Won't cause memory allocation
    */
    void updateVertices(index_t count, const void* data, int offset = 0)
    {
        if(VBO is null)
            ErrorHandler.showErrorMessage("Null VertexBuffer", "No vertex buffer was created before setting its vertices");
        this.bind();
        this.VBO.updateData(offset*this.stride, count*this.stride, data);
    }
    /**
    *   Will set the indices data. Beware that this function may allocate memory.
    *   
    *   If you need to only change its data value instead of allocating memory for a greater index buffer
    *   call updateIndices
    */
    void setIndices(index_t count, const index_t* data)
    {
        if(EBO is null)
            ErrorHandler.showErrorMessage("Null IndexBuffer", "No index buffer was created before setting its indices");
        this.bind();
        this.EBO.setData(count, data);
    }
    /**
    *   Updates the index buffer's data. It won't allocate memory
    */
    void updateIndices(index_t count, index_t* data, int offset = 0)
    {
        if(EBO is null)
            ErrorHandler.showErrorMessage("Null IndexBuffer", "No index buffer was created before setting its indices");
        this.bind();
        this.EBO.updateData(cast(int)(offset*index_t.sizeof), count, data);
    }

    /**
    * Receives a struct and creates a VAO based on its member types and names.
    */
    static HipVertexArrayObject getVAO(T)() if(is(T == struct))
    {
        import std.traits:isFunction;
        import hip.util.reflection:hasUDA;

        HipVertexArrayObject obj = new HipVertexArrayObject();
        static foreach(member; __traits(allMembers, T))
        {{
            alias mem = __traits(getMember, T, member);
            static if(!isFunction!(mem) && __traits(compiles, mem.offsetof))
            {
                obj.appendAttribute!((typeof(mem)))
                (
                    member,
                    hasUDA!(mem, HipShaderInputPadding)
                );
            }
        }}
        return obj;
    }

}