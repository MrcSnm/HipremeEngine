/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.backend.gl.glvertex;

version(OpenGL):
public import hip.hiprenderer.backend.gl.glbuffer;
import hip.api.renderer.vertex;
import hip.hiprenderer.backend.gl.glrenderer;
import hip.error.handler;
import hip.util.conv;
import hip.config.opts;
import hip.hiprenderer.renderer;
import hip.hiprenderer.shader;
import hip.hiprenderer.vertex;



private int getGLAttributeType(HipAttributeType _t)
{
    final switch(_t) with(HipAttributeType)
    {
        case Rgba32: return GL_UNSIGNED_BYTE;
        case Float: return GL_FLOAT;
        case Int: return GL_INT;
        case Ushort: return GL_UNSIGNED_SHORT;
        case Short: return GL_SHORT;
        case Uint: return GL_UNSIGNED_INT;
        case Bool: return GL_BOOL;
    }
}

//Used as a wrapper 
final class Hip_GL_VertexArrayObject : IHipVertexArrayImpl
{
    import hip.util.data_structures;
    IHipRendererBuffer ebo;
    HipVertexAttributeInfo[] vaoInfos;
    private __gshared Hip_GL_VertexArrayObject boundVAO;

    void bind()
    {
        static if(!GLShouldDisableVertexAttrib)
        {
            __gshared bool[GLMaxVertexAttributes] enabledAttributes;
        }

        if(boundVAO !is this)
        {
            ebo.bind();
            foreach(info; vaoInfos)
            {
                info.vbo.bind();
                foreach(field; info.fields)
                {
                    static if(!GLShouldDisableVertexAttrib)
                    {
                        if(!enabledAttributes[field.index])
                        {
                            glCall(() => glEnableVertexAttribArray(field.index));
                            enabledAttributes[field.index] = true;
                        }
                    }
                    else
                    {
                        glCall(() => glEnableVertexAttribArray(field.index));
                    }
                    glCall(() => glVertexAttribPointer(
                        field.index,
                        field.count,
                        getGLAttributeType(field.valueType),
                        field.isNormalized,
                        info.vboStride,
                        cast(void*)field.offset
                    ));
                }
            }
            boundVAO = this;
        }
    }
        
    void unbind()
    {
        static if(UseDelayedUnbinding)
        {

        }
        else
        {
            if(boundVAO is this)
            {
                foreach(vao; vaoInfos)
                {
                    glCall(() => glDisableVertexAttribArray(vao.info.index));
                    vao.vbo.unbind();
                }
                ebo.unbind();
                boundVAO = null;
            }
        }
    }
    void createInputLayout(HipVertexAttributeInfo[] attInfos, IHipRendererBuffer ebo, ShaderProgram p)
    {
        import hip.hiprenderer.backend.gl.glshader;
        Hip_GL3_ShaderProgram glProg = cast(Hip_GL3_ShaderProgram)p;
        this.ebo = ebo;
        vaoInfos = attInfos;
        foreach(ref info; attInfos)
        {
            foreach(ref field; info.fields)
            {
                int attloc = glCall(() => glGetAttribLocation(glProg.program, cast(char*)field.name.ptr));
                if(attloc == -1)
                    throw new Exception("Could not find attribute "~field.name~" at shader.");
                field.index = attloc;
            }
            // glCall(() => glBindAttribLocation(glProg.program, i, vao.info.name.ptr)); That strategy does not work since the shader is already linked at that stage...
        }
    }
}

static if (OpenGLHasVAOSupport) final class Hip_GL3_VertexArrayObject : IHipVertexArrayImpl
{
    uint vao;
    private __gshared Hip_GL3_VertexArrayObject boundVao;
    this()
    {
        glCall(() => glGenVertexArrays(1, &this.vao));
    }
    void bind()
    {
        if(boundVao !is this)
        {
            glCall(() => glBindVertexArray(this.vao));
            boundVao = this;
        }
    }
    void unbind()
    {
        if(boundVao is this)
        {
            glCall(() => glBindVertexArray(0));
            boundVao = null;
        }
    }

    void createInputLayout(HipVertexAttributeInfo[] attInfos, IHipRendererBuffer ebo, ShaderProgram p)
    {
        glCall(() => glBindVertexArray(this.vao));
        ebo.bind();
        foreach(i, info; attInfos)
        {
            info.vbo.bind();
            foreach(field; info.fields)
            {
                if(field.isNormalized || !isAttributeTypeIntegral(field.valueType))
                {
                    glCall(() => glVertexAttribPointer(
                        field.index,
                        field.count,
                        getGLAttributeType(field.valueType),
                        field.isNormalized,
                        info.vboStride,
                        cast(void*)field.offset
                    ));
                }
                else
                {
                    glCall(() => glVertexAttribIPointer(
                        field.index,
                        field.count,
                        getGLAttributeType(field.valueType),
                        info.vboStride,
                        cast(void*)field.offset
                    ));
                }
                glCall(() => glEnableVertexAttribArray(field.index));
                if(info.isInstanced)
                    glCall(() => glVertexAttribDivisor(field.index, 1));
            }
        }
        glCall(() => glBindVertexArray(0));
        foreach(i, info; attInfos)
            info.vbo.unbind();
    }
    ~this(){glCall(() => glDeleteVertexArrays(1, &this.vao));}
}