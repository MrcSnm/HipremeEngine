/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.imgui.imgui_impl_opengl3;
version(CIMGUI):
import bindbc.cimgui;

import core.stdc.stdio;

import core.stdc.string;
import core.stdc.stdint : intptr_t;

enum CIMGUI_USER_DEFINED_GL = true;


// dear imgui: Renderer for modern OpenGL with shaders / programmatic pipeline
// - Desktop GL: 2.x 3.x 4.x
// - Embedded GL: ES 2.0 (WebGL 1.0), ES 3.0 (WebGL 2.0)
// This needs to be used along with a Platform Binding (e.g. GLFW, SDL, Win32, custom..)

// Implemented features:
//  [X] Renderer: User texture binding. Use 'GLuint' OpenGL texture identifier as void*/ImTextureID. Read the FAQ about ImTextureID!
//  [x] Renderer: Desktop GL only: Support for large meshes (64k+ vertices) with 16-bit indices.

// You can copy and use unmodified imgui_impl_* files in your project. See main.cpp for an example of using this.
// If you are new to dear imgui, read examples/README.txt and read the documentation at the top of imgui.cpp.
// https://github.com/ocornut/imgui

// CHANGELOG
// (minor and older changes stripped away, please see git history for details)
//  2020-09-17: OpenGL: Fix to avoid compiling/calling glBindSampler() on ES or pre 3.3 context which have the defines set by a loader.
//  2020-07-10: OpenGL: Added support for glad2 OpenGL loader.
//  2020-05-08: OpenGL: Made default GLSL version 150 (instead of 130) on OSX.
//  2020-04-21: OpenGL: Fixed handling of glClipControl(GL_UPPER_LEFT) by inverting projection matrix.
//  2020-04-12: OpenGL: Fixed context version check mistakenly testing for 4.0+ instead of 3.2+ to enable ImGuiBackendFlags_RendererHasVtxOffset.
//  2020-03-24: OpenGL: Added support for glbinding 2.x OpenGL loader.
//  2020-01-07: OpenGL: Added support for glbinding 3.x OpenGL loader.
//  2019-10-25: OpenGL: Using a combination of GL define and runtime GL version to decide whether to use glDrawElementsBaseVertex(). Fix building with pre-3.2 GL loaders.
//  2019-09-22: OpenGL: Detect default GL loader using __has_include compiler facility.
//  2019-09-16: OpenGL: Tweak initialization code to allow application calling ImGui_ImplOpenGL3_CreateFontsTexture() before the first NewFrame() call.
//  2019-05-29: OpenGL: Desktop GL only: Added support for large mesh (64K+ vertices), enable ImGuiBackendFlags_RendererHasVtxOffset flag.
//  2019-04-30: OpenGL: Added support for special ImDrawCallback_ResetRenderState callback to reset render state.
//  2019-03-29: OpenGL: Not calling glBindBuffer more than necessary in the render loop.
//  2019-03-15: OpenGL: Added a GL call + comments in ImGui_ImplOpenGL3_Init() to detect uninitialized GL function loaders early.
//  2019-03-03: OpenGL: Fix support for ES 2.0 (WebGL 1.0).
//  2019-02-20: OpenGL: Fix for OSX not supporting OpenGL 4.5, we don't try to read GL_CLIP_ORIGIN even if defined by the headers/loader.
//  2019-02-11: OpenGL: Projecting clipping rectangles correctly using draw_data.FramebufferScale to allow multi-viewports for retina display.
//  2019-02-01: OpenGL: Using GLSL 410 shaders for any version over 410 (e.g. 430, 450).
//  2018-11-30: Misc: Setting up io.BackendRendererName so it can be displayed in the About Window.
//  2018-11-13: OpenGL: Support for GL 4.5's glClipControl(GL_UPPER_LEFT) / GL_CLIP_ORIGIN.
//  2018-08-29: OpenGL: Added support for more OpenGL loaders: glew and glad, with comments indicative that any loader can be used.
//  2018-08-09: OpenGL: Default to OpenGL ES 3 on iOS and Android. GLSL version default to "#version 300 ES".
//  2018-07-30: OpenGL: Support for GLSL 300 ES and 410 core. Fixes for Emscripten compilation.
//  2018-07-10: OpenGL: Support for more GLSL versions (based on the GLSL version string). Added error output when shaders fail to compile/link.
//  2018-06-08: Misc: Extracted imgui_impl_opengl3.cpp/.h away from the old combined GLFW/SDL+OpenGL3 examples.
//  2018-06-08: OpenGL: Use draw_data.DisplayPos and draw_data.DisplaySize to setup projection matrix and clipping rectangle.
//  2018-05-25: OpenGL: Removed unnecessary backup/restore of GL_ELEMENT_ARRAY_BUFFER_BINDING since this is part of the VAO state.
//  2018-05-14: OpenGL: Making the call to glBindSampler() optional so 3.2 context won't fail if the function is a null pointer.
//  2018-03-06: OpenGL: Added const char* glsl_version parameter to ImGui_ImplOpenGL3_Init() so user can override the GLSL version e.g. "#version 150".
//  2018-02-23: OpenGL: Create the VAO in the render function so the setup can more easily be used with multiple shared GL context.
//  2018-02-16: Misc: Obsoleted the io.RenderDrawListsFn callback and exposed ImGui_ImplSdlGL3_RenderDrawData() in the .h file so you can call it yourself.
//  2018-01-07: OpenGL: Changed GLSL shader version from 330 to 150.
//  2017-09-01: OpenGL: Save and restore current bound sampler. Save and restore current polygon mode.
//  2017-05-01: OpenGL: Fixed save and restore of current blend func state.
//  2017-05-01: OpenGL: Fixed save and restore of current GL_ACTIVE_TEXTURE.
//  2016-09-05: OpenGL: Fixed save and restore of current scissor rectangle.
//  2016-07-29: OpenGL: Explicitly setting GL_UNPACK_ROW_LENGTH to reduce issues because SDL changes it. (#752)

//----------------------------------------
// OpenGL    GLSL      GLSL
// version   version   string
//----------------------------------------
//  2.0       110       "#version 110"
//  2.1       120       "#version 120"
//  3.0       130       "#version 130"
//  3.1       140       "#version 140"
//  3.2       150       "#version 150"
//  3.3       330       "#version 330 core"
//  4.0       400       "#version 400 core"
//  4.1       410       "#version 410 core"
//  4.2       420       "#version 410 core"
//  4.3       430       "#version 430 core"
//  ES 2.0    100       "#version 100"      = WebGL 1.0
//  ES 3.0    300       "#version 300 es"   = WebGL 2.0
//----------------------------------------

enum _MSC_VER = -1;
enum IMGUI_IMPL_OPENGL_ES2 = false;
enum GL_VERSION_3_2 = false;
enum GL_VERSION_3_3 = false;
enum IMGUI_IMPL_OPENGL_ES3 = false;
enum IMGUI_IMPL_OPENGL_MAY_HAVE_BIND_SAMPLER = false;
enum IMGUI_IMPL_OPENGL_MAY_HAVE_VTX_OFFSET = false;


static if(CIMGUI_USER_DEFINED_GL)
{
    // GL includes
    static if(IMGUI_IMPL_OPENGL_ES2)
    {
        //#include <GLES2/gl2.h>
    }
    else static if(IMGUI_IMPL_OPENGL_ES3)
    {
        //#include <GLES3/gl3.h>          // Use GL ES 3
    }
    else
    {
        import bindbc.opengl;
        // About Desktop OpenGL function loaders:
        //  Modern desktop OpenGL doesn't have a standard portable header file to load OpenGL function pointers.
        //  Helper libraries are often used for this purpose! Here we are supporting a few common ones (gl3w, glew, glad).
        //  You may use another loader/header of your choice (glext, glLoadGen, etc.), or chose to manually implement your own.
    }

    // Desktop GL 3.2+ has glDrawElementsBaseVertex() which GL ES and WebGL don't have.
    static if(!IMGUI_IMPL_OPENGL_ES2 && !IMGUI_IMPL_OPENGL_ES3 && GL_VERSION_3_2)
    {
        enum IMGUI_IMPL_OPENGL_MAY_HAVE_VTX_OFFSET = true;
    }

    // Desktop GL 3.3+ has glBindSampler()
    static if(!IMGUI_IMPL_OPENGL_ES2 && !IMGUI_IMPL_OPENGL_ES3 && GL_VERSION_3_3)
    {
        enum IMGUI_IMPL_OPENGL_MAY_HAVE_BIND_SAMPLER = true;
    }

    // OpenGL Data
    static GLuint       g_GlVersion = 0;                // Extracted at runtime using GL_MAJOR_VERSION, GL_MINOR_VERSION queries (e.g. 320 for GL 3.2)
    static char[32]     g_GlslVersionString;   // Specified by user or detected based on compile time GL settings.
    static GLuint       g_FontTexture = 0;
    static GLuint       g_ShaderHandle = 0, g_VertHandle = 0, g_FragHandle = 0;
    static GLint        g_AttribLocationTex = 0, g_AttribLocationProjMtx = 0;                                // Uniforms location
    static GLuint       g_AttribLocationVtxPos = 0, g_AttribLocationVtxUV = 0, g_AttribLocationVtxColor = 0; // Vertex attributes location
    static uint         g_VboHandle = 0, g_ElementsHandle = 0;

    // Functions
    bool    ImGui_ImplOpenGL3_Init(const (char)* glsl_version)
    {
        // Query for GL version (e.g. 320 for GL 3.2)
        static if(!IMGUI_IMPL_OPENGL_ES2)
        {
            GLint major, minor;
            glGetIntegerv(GL_MAJOR_VERSION, &major);
            glGetIntegerv(GL_MINOR_VERSION, &minor);
            g_GlVersion = cast(GLuint)(major * 100 + minor * 10);
        }
        else
        {
            g_GlVersion = 200; // GLES 2
        }

            // Setup back-end capabilities flags
        ImGuiIO* io = igGetIO();
        io.BackendRendererName = "imgui_impl_opengl3";
        static if(IMGUI_IMPL_OPENGL_MAY_HAVE_VTX_OFFSET)
        {
            if (g_GlVersion >= 320)
                io.BackendFlags |= ImGuiBackendFlags_RendererHasVtxOffset;  // We can honor the ImDrawCmd::VtxOffset field, allowing for large meshes.
        }
        io.BackendFlags |= ImGuiBackendFlags_RendererHasViewports;

        // Store GLSL version string so we can refer to it later in case we recreate shaders.
        // Note: GLSL version is NOT the same as GL version. Leave this to null if unsure.
        version(IMGUI_IMPL_OPENGL_ES2)
        {
            if (glsl_version == "")
                glsl_version = "#version 100";
        }
        version(IMGUI_IMPL_OPENGL_ES3)
        {
            if (glsl_version == "")
                glsl_version = "#version 300 es";
        }
        version(__APPLE__)
        {
            if (glsl_version == "")
                glsl_version = "#version 150";
        }
        else
        {
            if (glsl_version == "")
                glsl_version = "#version 130";
        }
        IM_ASSERT(cast(int)strlen(glsl_version) + 2 < IM_ARRAYSIZE(g_GlslVersionString));
        strcpy(g_GlslVersionString.ptr, glsl_version);
        strcat(g_GlslVersionString.ptr, "\n");

        // Debugging construct to make it easily visible in the IDE and debugger which GL loader has been selected.
        // The code actually never uses the 'gl_loader' variable! It is only here so you can read it!
        // If auto-detection fails or doesn't select the same GL loader file as used by your application,
        // you are likely to get a crash below.
        // You can explicitly select a loader by using '#define IMGUI_IMPL_OPENGL_LOADER_XXX' in imconfig.h or compiler command-line.
        const (char)* gl_loader = "bindbc-opengl";

        // Make an arbitrary GL call (we don't actually need the result)
        // IF YOU GET A CRASH HERE: it probably means that you haven't initialized the OpenGL function loader used by this code.
        // Desktop OpenGL 3/4 need a function loader. See the IMGUI_IMPL_OPENGL_LOADER_xxx explanation above.
        GLint current_texture;
        glGetIntegerv(GL_TEXTURE_BINDING_2D, &current_texture);

        if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable)
            ImGui_ImplOpenGL3_InitPlatformInterface();

        return true;
    }

    void    ImGui_ImplOpenGL3_Shutdown()
    {
        ImGui_ImplOpenGL3_ShutdownPlatformInterface();
        ImGui_ImplOpenGL3_DestroyDeviceObjects();
    }

    void    ImGui_ImplOpenGL3_NewFrame()
    {
        if (!g_ShaderHandle)
            ImGui_ImplOpenGL3_CreateDeviceObjects();
    }

    static void ImGui_ImplOpenGL3_SetupRenderState(ImDrawData* draw_data, int fb_width, int fb_height, GLuint vertex_array_object)
    {
        // Setup render state: alpha-blending enabled, no face culling, no depth testing, scissor enabled, polygon fill
        glEnable(GL_BLEND);
        glBlendEquation(GL_FUNC_ADD);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glDisable(GL_CULL_FACE);
        glDisable(GL_DEPTH_TEST);
        glEnable(GL_SCISSOR_TEST);
        static if(GL_POLYGON_MODE)
        {
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        }

        // Support for GL 4.5 rarely used glClipControl(GL_UPPER_LEFT)
        bool clip_origin_lower_left = true;
        static if (GL_CLIP_ORIGIN)
        {
            GLenum current_clip_origin = 0; glGetIntegerv(GL_CLIP_ORIGIN, cast(GLint*)&current_clip_origin);
            if (current_clip_origin == GL_UPPER_LEFT)
                clip_origin_lower_left = false;
        }

        // Setup viewport, orthographic projection matrix
        // Our visible imgui space lies from draw_data.DisplayPos (top left) to draw_data.DisplayPos+data_data.DisplaySize (bottom right). DisplayPos is (0,0) for single viewport apps.
        glViewport(0, 0, cast(GLsizei)fb_width, cast(GLsizei)fb_height);
        float L = draw_data.DisplayPos.x;
        float R = draw_data.DisplayPos.x + draw_data.DisplaySize.x;
        float T = draw_data.DisplayPos.y;
        float B = draw_data.DisplayPos.y + draw_data.DisplaySize.y;
        if (!clip_origin_lower_left) { float tmp = T; T = B; B = tmp; } // Swap top and bottom if origin is upper left
        const float[4][4] ortho_projection =
        [
            [ 2.0f/(R-L),   0.0f,         0.0f,   0.0f ],
            [ 0.0f,         2.0f/(T-B),   0.0f,   0.0f ],
            [ 0.0f,         0.0f,        -1.0f,   0.0f ],
            [ (R+L)/(L-R),  (T+B)/(B-T),  0.0f,   1.0f ],
        ];
        glUseProgram(g_ShaderHandle);
        glUniform1i(g_AttribLocationTex, 0);
        glUniformMatrix4fv(g_AttribLocationProjMtx, 1, GL_FALSE, &ortho_projection[0][0]);
        
        static if(IMGUI_IMPL_OPENGL_MAY_HAVE_BIND_SAMPLER)
        {
            if (g_GlVersion >= 330)
                glBindSampler(0, 0); // We use combined texture/sampler state. Applications using GL 3.3 may set that otherwise.
        }
        cast(void)vertex_array_object;
        static if(!IMGUI_IMPL_OPENGL_ES2)
        {
            glBindVertexArray(vertex_array_object);
        }

        // Bind vertex/index buffers and setup attributes for ImDrawVert
        glBindBuffer(GL_ARRAY_BUFFER, g_VboHandle);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, g_ElementsHandle);
        glEnableVertexAttribArray(g_AttribLocationVtxPos);
        glEnableVertexAttribArray(g_AttribLocationVtxUV);
        glEnableVertexAttribArray(g_AttribLocationVtxColor);
        glVertexAttribPointer(g_AttribLocationVtxPos,   2, GL_FLOAT,         GL_FALSE, ImDrawVert.sizeof, cast(GLvoid*)IM_OFFSETOF!(ImDrawVert.pos));
        glVertexAttribPointer(g_AttribLocationVtxUV,    2, GL_FLOAT,         GL_FALSE, ImDrawVert.sizeof, cast(GLvoid*)IM_OFFSETOF!(ImDrawVert.uv));
        glVertexAttribPointer(g_AttribLocationVtxColor, 4, GL_UNSIGNED_BYTE, GL_TRUE,  ImDrawVert.sizeof, cast(GLvoid*)IM_OFFSETOF!(ImDrawVert.col));
    }

    // OpenGL3 Render function.
    // (this used to be set in io.RenderDrawListsFn and called by ImGui::Render(), but you can now call this directly from your main loop)
    // Note that this implementation is little overcomplicated because we are saving/setting up/restoring every OpenGL state explicitly, in order to be able to run within any OpenGL engine that doesn't do so.
    void    ImGui_ImplOpenGL3_RenderDrawData(ImDrawData* draw_data)
    {
        // Avoid rendering when minimized, scale coordinates for retina displays (screen coordinates != framebuffer coordinates)
        int fb_width = cast(int)(draw_data.DisplaySize.x * draw_data.FramebufferScale.x);
        int fb_height = cast(int)(draw_data.DisplaySize.y * draw_data.FramebufferScale.y);
        if (fb_width <= 0 || fb_height <= 0)
            return;

        // Backup GL state
        GLenum last_active_texture; glGetIntegerv(GL_ACTIVE_TEXTURE, cast(GLint*)&last_active_texture);
        glActiveTexture(GL_TEXTURE0);
        GLuint last_program; glGetIntegerv(GL_CURRENT_PROGRAM, cast(GLint*)&last_program);
        GLuint last_texture; glGetIntegerv(GL_TEXTURE_BINDING_2D, cast(GLint*)&last_texture);
        static if(IMGUI_IMPL_OPENGL_MAY_HAVE_BIND_SAMPLER)
        {
            GLuint last_sampler; 
            if (g_GlVersion >= 330) 
                glGetIntegerv(GL_SAMPLER_BINDING, cast(GLint*)&last_sampler); 
            else 
                last_sampler = 0;
        }
        GLuint last_array_buffer; glGetIntegerv(GL_ARRAY_BUFFER_BINDING, cast(GLint*)&last_array_buffer);
        static if(!IMGUI_IMPL_OPENGL_ES2)
        {
            GLuint last_vertex_array_object; glGetIntegerv(GL_VERTEX_ARRAY_BINDING, cast(GLint*)&last_vertex_array_object);
        }
        static if(GL_POLYGON_MODE)
        {
            GLint[2] last_polygon_mode;
            glGetIntegerv(GL_POLYGON_MODE, &last_polygon_mode[0]);
        }
        GLint[4] last_viewport; glGetIntegerv(GL_VIEWPORT, &last_viewport[0]);
        GLint[4] last_scissor_box; glGetIntegerv(GL_SCISSOR_BOX, &last_scissor_box[0]);
        GLenum last_blend_src_rgb; glGetIntegerv(GL_BLEND_SRC_RGB, cast(GLint*)&last_blend_src_rgb);
        GLenum last_blend_dst_rgb; glGetIntegerv(GL_BLEND_DST_RGB, cast(GLint*)&last_blend_dst_rgb);
        GLenum last_blend_src_alpha; glGetIntegerv(GL_BLEND_SRC_ALPHA, cast(GLint*)&last_blend_src_alpha);
        GLenum last_blend_dst_alpha; glGetIntegerv(GL_BLEND_DST_ALPHA, cast(GLint*)&last_blend_dst_alpha);
        GLenum last_blend_equation_rgb; glGetIntegerv(GL_BLEND_EQUATION_RGB, cast(GLint*)&last_blend_equation_rgb);
        GLenum last_blend_equation_alpha; glGetIntegerv(GL_BLEND_EQUATION_ALPHA, cast(GLint*)&last_blend_equation_alpha);
        GLboolean last_enable_blend = glIsEnabled(GL_BLEND);
        GLboolean last_enable_cull_face = glIsEnabled(GL_CULL_FACE);
        GLboolean last_enable_depth_test = glIsEnabled(GL_DEPTH_TEST);
        GLboolean last_enable_scissor_test = glIsEnabled(GL_SCISSOR_TEST);

        // Setup desired GL state
        // Recreate the VAO every time (this is to easily allow multiple GL contexts to be rendered to. VAO are not shared among GL contexts)
        // The renderer would actually work without any VAO bound, but then our VertexAttrib calls would overwrite the default one currently bound.
        GLuint vertex_array_object = 0;
        static if(!IMGUI_IMPL_OPENGL_ES2)
        {
            glGenVertexArrays(1, &vertex_array_object);
        }
        ImGui_ImplOpenGL3_SetupRenderState(draw_data, fb_width, fb_height, vertex_array_object);

        // Will project scissor/clipping rectangles into framebuffer space
        ImVec2 clip_off = draw_data.DisplayPos;         // (0,0) unless using multi-viewports
        ImVec2 clip_scale = draw_data.FramebufferScale; // (1,1) unless using retina display which are often (2,2)

        // Render command lists
        for (int n = 0; n < draw_data.CmdListsCount; n++)
        {
            ImDrawList* cmd_list = draw_data.CmdLists[n]; //Const was there

            // Upload vertex/index buffers
            glBufferData(GL_ARRAY_BUFFER, cast(GLsizeiptr)cmd_list.VtxBuffer.Size * cast(int)ImDrawVert.sizeof, cast(const GLvoid*)cmd_list.VtxBuffer.Data, GL_STREAM_DRAW);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, cast(GLsizeiptr)cmd_list.IdxBuffer.Size * cast(int)ImDrawIdx.sizeof, cast(const GLvoid*)cmd_list.IdxBuffer.Data, GL_STREAM_DRAW);

            for (int cmd_i = 0; cmd_i < cmd_list.CmdBuffer.Size; cmd_i++)
            {
                const (ImDrawCmd)* pcmd = &(cmd_list.CmdBuffer.Data[cmd_i]);
                if (pcmd.UserCallback != null)
                {
                    // User callback, registered via ImDrawList::AddCallback()
                    // (ImDrawCallback_ResetRenderState is a special callback value used by the user to request the renderer to reset render state.)
                    if (pcmd.UserCallback == ImDrawCallback_ResetRenderState)
                        ImGui_ImplOpenGL3_SetupRenderState(draw_data, fb_width, fb_height, vertex_array_object);
                    else
                        pcmd.UserCallback(cmd_list, pcmd);
                }
                else
                {
                    // Project scissor/clipping rectangles into framebuffer space
                    ImVec4 clip_rect;
                    clip_rect.x = (pcmd.ClipRect.x - clip_off.x) * clip_scale.x;
                    clip_rect.y = (pcmd.ClipRect.y - clip_off.y) * clip_scale.y;
                    clip_rect.z = (pcmd.ClipRect.z - clip_off.x) * clip_scale.x;
                    clip_rect.w = (pcmd.ClipRect.w - clip_off.y) * clip_scale.y;

                    if (clip_rect.x < fb_width && clip_rect.y < fb_height && clip_rect.z >= 0.0f && clip_rect.w >= 0.0f)
                    {
                        // Apply scissor/clipping rectangle
                        glScissor(cast(int)clip_rect.x, cast(int)(fb_height - clip_rect.w), cast(int)(clip_rect.z - clip_rect.x), cast(int)(clip_rect.w - clip_rect.y));

                        // Bind texture, Draw
                        glBindTexture(GL_TEXTURE_2D, cast(GLuint)cast(intptr_t)pcmd.TextureId);
                        static if(IMGUI_IMPL_OPENGL_MAY_HAVE_VTX_OFFSET)
                        {
                            if (g_GlVersion >= 320)
                                glDrawElementsBaseVertex(GL_TRIANGLES, cast(GLsizei)pcmd.ElemCount, ImDrawIdx.sizeof == 2 ? GL_UNSIGNED_SHORT : GL_UNSIGNED_INT, cast(void*)cast(intptr_t)(pcmd.IdxOffset * ImDrawIdx.sizeof), cast(GLint)pcmd.VtxOffset);
                        }
                        //If not drawelement base vertex
                        glDrawElements(GL_TRIANGLES, cast(GLsizei)pcmd.ElemCount, ImDrawIdx.sizeof == 2 ? GL_UNSIGNED_SHORT : GL_UNSIGNED_INT, cast(void*)cast(intptr_t)(pcmd.IdxOffset * ImDrawIdx.sizeof));
                    }
                }
            }
        }

        // Destroy the temporary VAO
        static if(!IMGUI_IMPL_OPENGL_ES2)
        {
            glDeleteVertexArrays(1, &vertex_array_object);
        }

        // Restore modified GL state
        glUseProgram(last_program);
        glBindTexture(GL_TEXTURE_2D, last_texture);
        static if(IMGUI_IMPL_OPENGL_MAY_HAVE_BIND_SAMPLER)
        {
            if (g_GlVersion >= 330)
                glBindSampler(0, last_sampler);
        }
        glActiveTexture(last_active_texture);
        static if(!IMGUI_IMPL_OPENGL_ES2)
        {
            glBindVertexArray(last_vertex_array_object);
        }
        glBindBuffer(GL_ARRAY_BUFFER, last_array_buffer);
        glBlendEquationSeparate(last_blend_equation_rgb, last_blend_equation_alpha);
        glBlendFuncSeparate(last_blend_src_rgb, last_blend_dst_rgb, last_blend_src_alpha, last_blend_dst_alpha);
        if (last_enable_blend) glEnable(GL_BLEND); else glDisable(GL_BLEND);
        if (last_enable_cull_face) glEnable(GL_CULL_FACE); else glDisable(GL_CULL_FACE);
        if (last_enable_depth_test) glEnable(GL_DEPTH_TEST); else glDisable(GL_DEPTH_TEST);
        if (last_enable_scissor_test) glEnable(GL_SCISSOR_TEST); else glDisable(GL_SCISSOR_TEST);
        static if(GL_POLYGON_MODE)
        {
            glPolygonMode(GL_FRONT_AND_BACK, cast(GLenum)last_polygon_mode[0]);
        }
        glViewport(last_viewport[0], last_viewport[1], cast(GLsizei)last_viewport[2], cast(GLsizei)last_viewport[3]);
        glScissor(last_scissor_box[0], last_scissor_box[1], cast(GLsizei)last_scissor_box[2], cast(GLsizei)last_scissor_box[3]);
    }

    bool ImGui_ImplOpenGL3_CreateFontsTexture()
    {
        // Build texture atlas
        ImGuiIO* io = igGetIO();
        ubyte* pixels = null;
        int width, height;
        static int bytePerPixel = 4;

        ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, &pixels, &width, &height, &bytePerPixel);   // Load as RGBA 32-bit (75% of the memory is wasted, but default font is so small) because it is more likely to be compatible with user's existing shaders. If your ImTextureId represent a higher-level concept than just a GL texture id, consider calling GetTexDataAsAlpha8() instead to save on GPU memory.

        // Upload texture to graphics system
        GLint last_texture;
        glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
        glGenTextures(1, &g_FontTexture);
        glBindTexture(GL_TEXTURE_2D, g_FontTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        static if(GL_UNPACK_ROW_LENGTH)
        {
            glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
        }
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);

        // Store our identifier
        io.Fonts.TexID = cast(ImTextureID)cast(intptr_t)g_FontTexture;

        // Restore state
        glBindTexture(GL_TEXTURE_2D, last_texture);
        
        return true;
    }

    void ImGui_ImplOpenGL3_DestroyFontsTexture()
    {
        if (g_FontTexture)
        {
            ImGuiIO* io = igGetIO();
            glDeleteTextures(1, &g_FontTexture);
            io.Fonts.TexID = null; //Same as 0
            g_FontTexture = 0;
        }
    }

    // If you get an error please report on github. You may try different GL context version or GLSL version. See GL<>GLSL version table at the top of this file.
    static bool CheckShader(GLuint handle, const (char)* desc)
    {
        GLint status = 0, log_length = 0;
        glGetShaderiv(handle, GL_COMPILE_STATUS, &status);
        glGetShaderiv(handle, GL_INFO_LOG_LENGTH, &log_length);

        if (cast(GLboolean)status == GL_FALSE)
            fprintf(stderr, "ERROR: ImGui_ImplOpenGL3_CreateDeviceObjects: failed to compile %s!\n", desc);
        if (log_length > 1)
        {
            
            // ImVector_char buf;
            // buf.resize(cast(int)(log_length + 1));
            // glGetShaderInfoLog(handle, log_length, null, cast(GLchar*)buf.begin());
            // fprintf(stderr, "%s\n", buf.begin());
        }
        return cast(GLboolean)status == GL_TRUE;
    }

    // If you get an error please report on GitHub. You may try different GL context version or GLSL version.
    static bool CheckProgram(GLuint handle, const (char)* desc)
    {
        GLint status = 0, log_length = 0;
        glGetProgramiv(handle, GL_LINK_STATUS, &status);
        glGetProgramiv(handle, GL_INFO_LOG_LENGTH, &log_length);
        if (cast(GLboolean)status == GL_FALSE)
            fprintf(stderr, "ERROR: ImGui_ImplOpenGL3_CreateDeviceObjects: failed to link %s! (with GLSL '%s')\n", desc, &g_GlslVersionString[0]);
        if (log_length > 1)
        {
            // ImVector_char buf;
            // buf.resize(cast(int)(log_length + 1));
            // glGetProgramInfoLog(handle, log_length, null, cast(GLchar*)buf.begin());
            // fprintf(stderr, "%s\n", buf.begin());
        }
        return cast(GLboolean)status == GL_TRUE;
    }

    bool    ImGui_ImplOpenGL3_CreateDeviceObjects()
    {
        // Backup GL state
        GLint last_texture, last_array_buffer;
        glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
        glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &last_array_buffer);
        static if(!IMGUI_IMPL_OPENGL_ES2)
        {
            GLint last_vertex_array;
            glGetIntegerv(GL_VERTEX_ARRAY_BINDING, &last_vertex_array);
        }



        // Parse GLSL version string
        int glsl_version = 130;
        sscanf(&g_GlslVersionString[0], "#version %d", &glsl_version);

        const (GLchar)* vertex_shader_glsl_120 =
            "uniform mat4 ProjMtx;\n"~
            "attribute vec2 Position;\n"~
            "attribute vec2 UV;\n"~
            "attribute vec4 Color;\n"~
            "varying vec2 Frag_UV;\n"~
            "varying vec4 Frag_Color;\n"~
            "void main()\n"~
            "{\n"~
            "    Frag_UV = UV;\n"~
            "    Frag_Color = Color;\n"~
            "    gl_Position = ProjMtx * vec4(Position.xy,0,1);\n"~
            "}\n";

        const (GLchar)* vertex_shader_glsl_130 =
            "uniform mat4 ProjMtx;\n"~
            "in vec2 Position;\n"~
            "in vec2 UV;\n"~
            "in vec4 Color;\n"~
            "out vec2 Frag_UV;\n"~
            "out vec4 Frag_Color;\n"~
            "void main()\n"~
            "{\n"~
            "    Frag_UV = UV;\n"~
            "    Frag_Color = Color;\n"~
            "    gl_Position = ProjMtx * vec4(Position.xy,0,1);\n"~
            "}\n";

        const (GLchar)* vertex_shader_glsl_300_es =
            "precision mediump float;\n"~
            "layout (location = 0) in vec2 Position;\n"~
            "layout (location = 1) in vec2 UV;\n"~
            "layout (location = 2) in vec4 Color;\n"~
            "uniform mat4 ProjMtx;\n"~
            "out vec2 Frag_UV;\n"~
            "out vec4 Frag_Color;\n"~
            "void main()\n"~
            "{\n"~
            "    Frag_UV = UV;\n"~
            "    Frag_Color = Color;\n"~
            "    gl_Position = ProjMtx * vec4(Position.xy,0,1);\n"~
            "}\n";

        const (GLchar)* vertex_shader_glsl_410_core =
            "layout (location = 0) in vec2 Position;\n"~
            "layout (location = 1) in vec2 UV;\n"~
            "layout (location = 2) in vec4 Color;\n"~
            "uniform mat4 ProjMtx;\n"~
            "out vec2 Frag_UV;\n"~
            "out vec4 Frag_Color;\n"~
            "void main()\n"~
            "{\n"~
            "    Frag_UV = UV;\n"~
            "    Frag_Color = Color;\n"~
            "    gl_Position = ProjMtx * vec4(Position.xy,0,1);\n"~
            "}\n";

        const (GLchar)* fragment_shader_glsl_120 =
            "#ifdef GL_ES\n"~
            "    precision mediump float;\n"~
            "#endif\n"~
            "uniform sampler2D Texture;\n"~
            "varying vec2 Frag_UV;\n"~
            "varying vec4 Frag_Color;\n"~
            "void main()\n"~
            "{\n"~
            "    gl_FragColor = Frag_Color * texture2D(Texture, Frag_UV.st);\n"~
            "}\n";

        const (GLchar)* fragment_shader_glsl_130 =
            "uniform sampler2D Texture;\n"~
            "in vec2 Frag_UV;\n"~
            "in vec4 Frag_Color;\n"~
            "out vec4 Out_Color;\n"~
            "void main()\n"~
            "{\n"~
            "    Out_Color = Frag_Color * texture(Texture, Frag_UV.st);\n"~
            "}\n";

        const (GLchar)* fragment_shader_glsl_300_es =
            "precision mediump float;\n"~
            "uniform sampler2D Texture;\n"~
            "in vec2 Frag_UV;\n"~
            "in vec4 Frag_Color;\n"~
            "layout (location = 0) out vec4 Out_Color;\n"~
            "void main()\n"~
            "{\n"~
            "    Out_Color = Frag_Color * texture(Texture, Frag_UV.st);\n"~
            "}\n";

        const (GLchar)* fragment_shader_glsl_410_core =
            "in vec2 Frag_UV;\n"~
            "in vec4 Frag_Color;\n"~
            "uniform sampler2D Texture;\n"~
            "layout (location = 0) out vec4 Out_Color;\n"~
            "void main()\n"~
            "{\n"~
            "    Out_Color = Frag_Color * texture(Texture, Frag_UV.st);\n"~
            "}\n";

        // Select shaders matching our GLSL versions
        const (GLchar)* vertex_shader = null;
        const (GLchar)* fragment_shader = null;
        if (glsl_version < 130)
        {
            vertex_shader = vertex_shader_glsl_120;
            fragment_shader = fragment_shader_glsl_120;
        }
        else if (glsl_version >= 410)
        {
            vertex_shader = vertex_shader_glsl_410_core;
            fragment_shader = fragment_shader_glsl_410_core;
        }
        else if (glsl_version == 300)
        {
            vertex_shader = vertex_shader_glsl_300_es;
            fragment_shader = fragment_shader_glsl_300_es;
        }
        else
        {
            vertex_shader = vertex_shader_glsl_130;
            fragment_shader = fragment_shader_glsl_130;
        }

        // Create shaders
        const (GLchar)*[2] vertex_shader_with_version = [g_GlslVersionString.ptr, vertex_shader ];
        g_VertHandle = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(g_VertHandle, 2, vertex_shader_with_version.ptr, null);
        glCompileShader(g_VertHandle);
        CheckShader(g_VertHandle, "vertex shader");

        const (GLchar)*[2] fragment_shader_with_version =  [g_GlslVersionString.ptr, fragment_shader];
        g_FragHandle = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(g_FragHandle, 2, fragment_shader_with_version.ptr, null);
        glCompileShader(g_FragHandle);
        CheckShader(g_FragHandle, "fragment shader");

        g_ShaderHandle = glCreateProgram();
        glAttachShader(g_ShaderHandle, g_VertHandle);
        glAttachShader(g_ShaderHandle, g_FragHandle);
        glLinkProgram(g_ShaderHandle);
        CheckProgram(g_ShaderHandle, "shader program");

        g_AttribLocationTex = glGetUniformLocation(g_ShaderHandle, "Texture");
        g_AttribLocationProjMtx = glGetUniformLocation(g_ShaderHandle, "ProjMtx");
        g_AttribLocationVtxPos = cast(GLuint)glGetAttribLocation(g_ShaderHandle, "Position");
        g_AttribLocationVtxUV = cast(GLuint)glGetAttribLocation(g_ShaderHandle, "UV");
        g_AttribLocationVtxColor = cast(GLuint)glGetAttribLocation(g_ShaderHandle, "Color");

        // Create buffers
        glGenBuffers(1, &g_VboHandle);
        glGenBuffers(1, &g_ElementsHandle);

        ImGui_ImplOpenGL3_CreateFontsTexture();

        // Restore modified GL state
        glBindTexture(GL_TEXTURE_2D, last_texture);
        glBindBuffer(GL_ARRAY_BUFFER, last_array_buffer);
        static if(!IMGUI_IMPL_OPENGL_ES2)
        {
            glBindVertexArray(last_vertex_array);
        }

        return true;
    }

    void    ImGui_ImplOpenGL3_DestroyDeviceObjects()
    {
        if (g_VboHandle)        { glDeleteBuffers(1, &g_VboHandle); g_VboHandle = 0; }
        if (g_ElementsHandle)   { glDeleteBuffers(1, &g_ElementsHandle); g_ElementsHandle = 0; }
        if (g_ShaderHandle && g_VertHandle) { glDetachShader(g_ShaderHandle, g_VertHandle); }
        if (g_ShaderHandle && g_FragHandle) { glDetachShader(g_ShaderHandle, g_FragHandle); }
        if (g_VertHandle)       { glDeleteShader(g_VertHandle); g_VertHandle = 0; }
        if (g_FragHandle)       { glDeleteShader(g_FragHandle); g_FragHandle = 0; }
        if (g_ShaderHandle)     { glDeleteProgram(g_ShaderHandle); g_ShaderHandle = 0; }

        ImGui_ImplOpenGL3_DestroyFontsTexture();
    }


    //--------------------------------------------------------------------------------------------------------
    // MULTI-VIEWPORT / PLATFORM INTERFACE SUPPORT
    // This is an _advanced_ and _optional_ feature, allowing the back-end to create and handle multiple viewports simultaneously.
    // If you are new to dear imgui or creating a new binding for dear imgui, it is recommended that you completely ignore this section first..
    //--------------------------------------------------------------------------------------------------------

    extern(C) static void ImGui_ImplOpenGL3_RenderWindow(ImGuiViewport* viewport, void*)
    {
        //viewport = cast(ImGuiViewport*)param;
        if (!(viewport.Flags & ImGuiViewportFlags_NoRendererClear))
        {
            ImVec4 clear_color = ImVec4(0.0f, 0.0f, 0.0f, 1.0f);
            glClearColor(clear_color.x, clear_color.y, clear_color.z, clear_color.w);
            glClear(GL_COLOR_BUFFER_BIT);
        }
        ImGui_ImplOpenGL3_RenderDrawData(viewport.DrawData);
    }

    static void ImGui_ImplOpenGL3_InitPlatformInterface()
    {
        ImGuiPlatformIO* platform_io = igGetPlatformIO();
        platform_io.Renderer_RenderWindow = &ImGui_ImplOpenGL3_RenderWindow;
    }

    static void ImGui_ImplOpenGL3_ShutdownPlatformInterface()
    {
        igDestroyPlatformWindows();
    }

}
else
{
    extern(C) @nogc nothrow
    {
        alias pImGui_ImplOpenGL3_Init = bool function(const (char)* glsl_version);
        alias pImGui_ImplOpenGL3_Shutdown = void function();
        alias pImGui_ImplOpenGL3_NewFrame = void function();
        alias pImGui_ImplOpenGL3_RenderDrawData = void function(ImDrawData* draw_data);
        alias pImGui_ImplOpenGL3_CreateFontsTexture = bool function();
        alias pImGui_ImplOpenGL3_DestroyFontsTexture = void function();
        alias pImGui_ImplOpenGL3_CreateDeviceObjects = bool function();
        alias pImGui_ImplOpenGL3_DestroyDeviceObjects = void function();
    }

    __gshared
    {
        pImGui_ImplOpenGL3_Init ImGui_ImplOpenGL3_Init;
        pImGui_ImplOpenGL3_Shutdown ImGui_ImplOpenGL3_Shutdown;
        pImGui_ImplOpenGL3_NewFrame ImGui_ImplOpenGL3_NewFrame;
        pImGui_ImplOpenGL3_RenderDrawData ImGui_ImplOpenGL3_RenderDrawData;
        pImGui_ImplOpenGL3_CreateFontsTexture ImGui_ImplOpenGL3_CreateFontsTexture;
        pImGui_ImplOpenGL3_DestroyFontsTexture ImGui_ImplOpenGL3_DestroyFontsTexture;
        pImGui_ImplOpenGL3_CreateDeviceObjects ImGui_ImplOpenGL3_CreateDeviceObjects;
        pImGui_ImplOpenGL3_DestroyDeviceObjects ImGui_ImplOpenGL3_DestroyDeviceObjects;
    }
    import bindbc.loader:SharedLib, bindSymbol;
    void bindGLImgui(SharedLib lib)
    {
        lib.bindSymbol(cast(void**)&ImGui_ImplOpenGL3_Init, "ImGui_ImplOpenGL3_Init");
        lib.bindSymbol(cast(void**)&ImGui_ImplOpenGL3_Shutdown, "ImGui_ImplOpenGL3_Shutdown");
        lib.bindSymbol(cast(void**)&ImGui_ImplOpenGL3_NewFrame, "ImGui_ImplOpenGL3_NewFrame");
        lib.bindSymbol(cast(void**)&ImGui_ImplOpenGL3_RenderDrawData, "ImGui_ImplOpenGL3_RenderDrawData");
        lib.bindSymbol(cast(void**)&ImGui_ImplOpenGL3_CreateFontsTexture, "ImGui_ImplOpenGL3_CreateFontsTexture");
        lib.bindSymbol(cast(void**)&ImGui_ImplOpenGL3_DestroyFontsTexture, "ImGui_ImplOpenGL3_DestroyFontsTexture");
        lib.bindSymbol(cast(void**)&ImGui_ImplOpenGL3_CreateDeviceObjects, "ImGui_ImplOpenGL3_CreateDeviceObjects");
        lib.bindSymbol(cast(void**)&ImGui_ImplOpenGL3_DestroyDeviceObjects, "ImGui_ImplOpenGL3_DestroyDeviceObjects");
    }
}