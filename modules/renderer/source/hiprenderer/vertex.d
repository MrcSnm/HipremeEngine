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

module hiprenderer.vertex;
import hiprenderer.renderer;
import error.handler;
import console.log;
public import hiprenderer.backend.gl.vertex;
// version(Android){alias index_t = ushort;}
// else{alias index_t = uint;}
alias index_t = ushort;

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
    FLOAT,
    INT,
    BOOL
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
    void setData(ulong size, const void* data);
    void updateData(int offset, ulong size, const void* data);
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
    *   Creates and binds an index buffer.
    */
    void createIndexBuffer(index_t count, HipBufferUsage usage)
    {
        this.bind();
        this.EBO = HipRenderer.createIndexBuffer(count, usage);
        this.EBO.bind();
    }
    /**
    * Creates and binds a vertex buffer.
    *
    * The vertex buffer size is dependant on the attributes that were appended to this vertex array.
    */
    void createVertexBuffer(uint count, HipBufferUsage usage)
    {
        this.bind();
        this.VBO = HipRenderer.createVertexBuffer(count*this.stride, usage);
        this.VBO.bind();
    }
    /**
    *   This function creates an attribute information,
    * for later sending it(it is necessary as the stride needs to be recalculated)
    */
    HipVertexArrayObject appendAttribute(uint count, HipAttributeType valueType, uint typeSize, string infoName)
    {
        HipVertexAttributeInfo info;
        info.name = infoName;
        info.count = count;
        info.valueType = valueType;
        info.typeSize = typeSize;
        info.index = cast(uint)infos.length;
        //It actually is the `last stride`, which is the same as the offset is the total current stride
        info.offset = stride;
        infos~= info;
        stride+= count*typeSize;
        dataCount+= count;
        return this;
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
        isBonded = true;
        this.VAO.bind(this.VBO, this.EBO);
        HipRenderer.exitOnError();
    }
    void unbind()
    {
        isBonded = false;
        this.VAO.unbind(this.VBO, this.EBO);
        HipRenderer.exitOnError();
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
        HipRenderer.exitOnError();
    }
    /**
    *   Update the VBO. Won't cause memory allocation
    */
    void updateVertices(index_t count, const void* data, int offset = 0)
    {
        if(VBO is null)
            ErrorHandler.showErrorMessage("Null VertexBuffer", "No vertex buffer was created before setting its vertices");
        this.bind();
        this.VBO.updateData(offset, count*this.stride, data);
        HipRenderer.exitOnError();
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
        HipRenderer.exitOnError();
    }
    /**
    *   Updates the index buffer's data. It won't allocate memory
    */
    void updateIndices(index_t count, index_t* data, int offset = 0)
    {
        if(EBO is null)
            ErrorHandler.showErrorMessage("Null IndexBuffer", "No index buffer was created before setting its indices");
        this.bind();
        this.EBO.updateData(offset, count, data);
        HipRenderer.exitOnError();
    }

    /**
    *   Remember calling sendAttributes!
    *   Defines:
    *
    *    vec2 vPosition
    *   
    *    vec2 vTexST
    */
    static HipVertexArrayObject getXY_ST_VAO()
    {
        HipVertexArrayObject obj = new HipVertexArrayObject();
        with(HipAttributeType)
        {
            obj.appendAttribute(2, FLOAT, float.sizeof, "vPosition") //X, Y
               .appendAttribute(2, FLOAT, float.sizeof, "vTexST"); //ST
        }
        return obj;
    }

    /**
    *   Remember calling sendAttributes!
    */
    static HipVertexArrayObject getXYZ_RGBA_VAO()
    {
        HipVertexArrayObject obj = new HipVertexArrayObject();
        with(HipAttributeType)
        {
            obj.appendAttribute(3, FLOAT, float.sizeof, "vPosition") //X, Y, Z
               .appendAttribute(4, FLOAT, float.sizeof, "vColor"); //R, G, B, A
        }
        return obj;
    }
    /**
    *   Remember calling sendAttributes!
    */
    static HipVertexArrayObject getXYZ_RGBA_ST_VAO()
    {
        HipVertexArrayObject obj = new HipVertexArrayObject();
        with(HipAttributeType)
        {
            obj.appendAttribute(3, FLOAT, float.sizeof, "vPosition") //X, Y, Z
               .appendAttribute(4, FLOAT, float.sizeof, "vColor") //R, G, B, A
               .appendAttribute(2, FLOAT, float.sizeof, "vTexST"); //S, T (Texture coordinates)
        }
        return obj;
    }

    /**
    *   Remember calling sendAttributes!
    */
    static HipVertexArrayObject getXYZ_RGBA_ST_TID_VAO()
    {
        HipVertexArrayObject obj = new HipVertexArrayObject();
        with(HipAttributeType)
        {
            obj.appendAttribute(3, FLOAT, float.sizeof, "vPosition") //X, Y, Z
               .appendAttribute(4, FLOAT, float.sizeof, "vColor") //R, G, B, A
               .appendAttribute(2, FLOAT, float.sizeof, "vTexST") //S, T (Texture coordinates)
               .appendAttribute(1, FLOAT, float.sizeof, "vTexID");
        }
        return obj;
    }
    /**
    *   Remember calling sendAttributes!
    */
    static HipVertexArrayObject getXY_RGBA_ST_VAO()
    {
        HipVertexArrayObject obj = new HipVertexArrayObject();
        with(HipAttributeType)
        {
            obj.appendAttribute(2, FLOAT, float.sizeof, "position"); //X, Y, Z
            obj.appendAttribute(4, FLOAT, float.sizeof, "color"); //R, G, B, A
            obj.appendAttribute(2, FLOAT, float.sizeof, "tex_st"); //S, T (Texture coordinates)
        }
        return obj;
    }
}