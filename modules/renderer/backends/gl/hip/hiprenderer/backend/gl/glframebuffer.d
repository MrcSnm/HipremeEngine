/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.backend.gl.glframebuffer;

import hip.api.renderer.texture;
version(OpenGL):

import hip.error.handler;
import hip.hiprenderer.renderer;
import hip.api.renderer.shader;
import hip.hiprenderer.backend.gl.glrenderer;
import hip.hiprenderer.backend.gl.gltexture;


private struct HipGL3RenderBuffer
{
    uint rbo;

    void bind()
    {
        if(rbo != 0)
            glCall(() => glBindRenderbuffer(GL_RENDERBUFFER, this.rbo));
    }
    void unbind()
    {
        if(rbo != 0)
            glCall(() => glBindRenderbuffer(GL_RENDERBUFFER, 0));
    }

    void create(uint width, uint height, DepthFormat depth)
    {
        if(depth == DepthFormat.none)
            return;
        glCall(() => glGenRenderbuffers(1, &this.rbo));
        bind();
        //Render buffer initialization
        glCall(() => glRenderbufferStorage(GL_RENDERBUFFER, getDepthFormat(depth), width, height));
    }

    void dispose()
    {
        if(rbo != 0)
        {
            glCall(() => glDeleteRenderbuffers(1, &this.rbo));
            rbo = 0;
        }
    }
}

class Hip_GL3_FrameBuffer : IHipFrameBuffer
{
    ///Texture to be returned. It is filled with the opengl framebuffer contents
    Hip_GL3_Texture retTexture;
    HipGL3RenderBuffer renderBuffer;
    DepthFormat depth;
    uint fbo;
    

    this(uint width, uint height, TextureFormat format = TextureFormat.rgb8, DepthFormat depth = DepthFormat.depth16)
    {
        create(width, height);
    }
    void create(uint width, uint height, TextureFormat format = TextureFormat.rgb8, DepthFormat depth = DepthFormat.depth16)
    {
        if(fbo != 0)
            dispose();
        this.depth = depth;
        //Objects initialization
        glCall(() => glGenFramebuffers(1, &this.fbo));

        //Texture initialization
        glCall(() => glBindFramebuffer(GL_FRAMEBUFFER, this.fbo));
        retTexture = new Hip_GL3_Texture(HipResourceUsage.Dynamic, HipTextureType.Texture2D);
        retTexture.initWithFormat(width, height, format);
        //Attach to the framebuffer
        glCall(() => glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, retTexture.textureID, 0));

        if(depth != DepthFormat.none)
        {
            renderBuffer.create(width,height,depth);
            glCall(() => glFramebufferRenderbuffer(GL_FRAMEBUFFER, getDepthAttachment(depth), GL_RENDERBUFFER, renderBuffer.rbo));
        }


        //Check if creation went successful
        int res = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if(res != GL_FRAMEBUFFER_COMPLETE)
        {
            string msg = getFramebufferStatusMessage(res);
            ErrorHandler.assertErrorMessage(false, "GL Framebuffer Creation: ", msg);
        }

        //Reset to defaults
        glCall(() => glBindFramebuffer(GL_FRAMEBUFFER, 0));
        renderBuffer.unbind();
    }

    private string getFramebufferStatusMessage(int res)
    {
        switch(res)
        {
            case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT: return "any of the framebuffer attachment points are framebuffer incomplete.";
            case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: return "the framebuffer does not have at least one image attached to it.";
            case GL_FRAMEBUFFER_UNSUPPORTED: return "the combination of internal formats of the attached images violates an implementation-dependent set of restrictions.";
            version(GLES20)
            {
                case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
                    return "Framebuffer attachments do not have matching dimensions.";
            }
            else
            {
                case GL_FRAMEBUFFER_UNDEFINED: return "the specified framebuffer is the default read or draw framebuffer, but the default framebuffer does not exist.";
                case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER: return "the value of GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE is GL_NONE for any color attachment point(s) named by GL_DRAW_BUFFERi.";
                case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER: return "GL_READ_BUFFER is not GL_NONE and the value of GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE is GL_NONE for the color attachment point named by GL_READ_BUFFER.";
                case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE: 
                    return "the value of GL_RENDERBUFFER_SAMPLES is not the same for all attached renderbuffers; if the value of GL_TEXTURE_SAMPLES is the not same for all attached textures; or, if the attached images are a mix of renderbuffers and textures, the value of GL_RENDERBUFFER_SAMPLES does not match the value of GL_TEXTURE_SAMPLES.\n"~
                    "Or the value of GL_TEXTURE_FIXED_SAMPLE_LOCATIONS is not the same for all attached textures; or, if the attached images are a mix of renderbuffers and textures, the value of GL_TEXTURE_FIXED_SAMPLE_LOCATIONS is not GL_TRUE for all attached textures.";
                case GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS: return "any framebuffer attachment is layered, and any populated attachment is not layered, or if all populated color attachments are not from textures of the same target.";
            }
            default: return null;
        }
    }

    void resize(uint width, uint height){}

    void bind()
    {
        glCall(() => glBindFramebuffer(GL_FRAMEBUFFER, this.fbo));
    }
    void unbind(){glCall(() => glBindFramebuffer(GL_FRAMEBUFFER, 0));}
    void clear()
    {
        glCall(() => glClearColor(0.0, 0.0, 0.0, 1.0));
        uint flags = GL_COLOR_BUFFER_BIT;
        if(depth != DepthFormat.none)
            flags|= GL_DEPTH_BUFFER_BIT;
        if(depth == DepthFormat.depth24Stencil8)
            flags|= GL_STENCIL_BUFFER_BIT;

        glCall(() => glClear(flags));
    }

    IHipTexture getTexture(){return retTexture;}

    void draw()
    {
        // glBindTexture(GL_TEXTURE_2D, this.texture);
        // glDrawArrays(GL_TRIANGLES, 0, 6);
    }

    void dispose()
    {
        if(fbo != 0)
        {
            glCall(() => glDeleteFramebuffers(1, &this.fbo));
            fbo = 0;            
        }
        renderBuffer.dispose();
        if(retTexture !is null)
        {
            retTexture.dispose();
            retTexture = null;            
        }
    }
}


static if(StaticGLES20)
private int getDepthFormat(DepthFormat format)
{
    switch(format)
    {
        case DepthFormat.depth16:
            return GL_DEPTH_COMPONENT16;
        case DepthFormat.depth24: throw new Error("Depth24 requires GLES2 OES_depth24 support");
        case DepthFormat.depth24Stencil8: throw new Error("GLES20 requires OES_packed_depth_stencil");
        default: throw new Error("Can't get none format in getDepthFormat");
    }
}
else 
private int getDepthFormat(DepthFormat format)
{
    import hip.hiprenderer.backend.gl.glconfig;
    switch(format)
    {
        case DepthFormat.depth16:
            return GL_DEPTH_COMPONENT16;
        case DepthFormat.depth24:
            if(hipGlCapabilities.depth24)
                return GL_DEPTH_COMPONENT24;
            throw new Error("Depth24 requires GLES2 OES_depth24 support");
        case DepthFormat.depth24Stencil8:
            if(hipGlCapabilities.packedDepthStencil)
                return GL_DEPTH24_STENCIL8;
            throw new Error("GLES20 requires OES_packed_depth_stencil");
        default:
            throw new Error("Can't get none format in getDepthFormat");
    }
}

private int getDepthAttachment(DepthFormat format)
{
    switch(format)
    {
        case DepthFormat.depth16, DepthFormat.depth24:
            return GL_DEPTH_ATTACHMENT;
        case DepthFormat.depth24Stencil8:
            version(GLES20)
                throw new Error("No support to GL_DEPTH_STENCIL_ATTACHMENT");
            else 
                return GL_DEPTH_STENCIL_ATTACHMENT;
        default:
            return 0;
    }
}