module gles.gl2ext;
import gles.gl2;
extern (C):

enum __gles2_gl2ext_h_ = 1;

/*
** Copyright (c) 2013-2018 The Khronos Group Inc.
**
** Permission is hereby granted, free of charge, to any person obtaining a
** copy of this software and/or associated documentation files (the
** "Materials"), to deal in the Materials without restriction, including
** without limitation the rights to use, copy, modify, merge, publish,
** distribute, sublicense, and/or sell copies of the Materials, and to
** permit persons to whom the Materials are furnished to do so, subject to
** the following conditions:
**
** The above copyright notice and this permission notice shall be included
** in all copies or substantial portions of the Materials.
**
** THE MATERIALS ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
** EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
** MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
** IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
** CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
** TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
** MATERIALS OR THE USE OR OTHER DEALINGS IN THE MATERIALS.
*/
/*
** This header is generated from the Khronos OpenGL / OpenGL ES XML
** API Registry. The current version of the Registry, generator scripts
** used to make the header, and the header can be found at
**   https://github.com/KhronosGroup/OpenGL-Registry
*/

/* Generated on date 20200806 */

/* Generated C header for:
 * API: gles2
 * Profile: common
 * Versions considered: 2\.[0-9]
 * Versions emitted: _nomatch_^
 * Default extensions included: gles2
 * Additional extensions included: _nomatch_^
 * Extensions removed: _nomatch_^
 */

enum GL_KHR_blend_equation_advanced = 1;
enum GL_MULTIPLY_KHR = 0x9294;
enum GL_SCREEN_KHR = 0x9295;
enum GL_OVERLAY_KHR = 0x9296;
enum GL_DARKEN_KHR = 0x9297;
enum GL_LIGHTEN_KHR = 0x9298;
enum GL_COLORDODGE_KHR = 0x9299;
enum GL_COLORBURN_KHR = 0x929A;
enum GL_HARDLIGHT_KHR = 0x929B;
enum GL_SOFTLIGHT_KHR = 0x929C;
enum GL_DIFFERENCE_KHR = 0x929E;
enum GL_EXCLUSION_KHR = 0x92A0;
enum GL_HSL_HUE_KHR = 0x92AD;
enum GL_HSL_SATURATION_KHR = 0x92AE;
enum GL_HSL_COLOR_KHR = 0x92AF;
enum GL_HSL_LUMINOSITY_KHR = 0x92B0;
alias PFNGLBLENDBARRIERKHRPROC = void function ();

/* GL_KHR_blend_equation_advanced */

enum GL_KHR_blend_equation_advanced_coherent = 1;
enum GL_BLEND_ADVANCED_COHERENT_KHR = 0x9285;
/* GL_KHR_blend_equation_advanced_coherent */

enum GL_KHR_context_flush_control = 1;
enum GL_CONTEXT_RELEASE_BEHAVIOR_KHR = 0x82FB;
enum GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH_KHR = 0x82FC;
/* GL_KHR_context_flush_control */

enum GL_KHR_debug = 1;
alias GLDEBUGPROCKHR = void function (GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, GLchar* message, void* userParam);
enum GL_SAMPLER = 0x82E6;
enum GL_DEBUG_OUTPUT_SYNCHRONOUS_KHR = 0x8242;
enum GL_DEBUG_NEXT_LOGGED_MESSAGE_LENGTH_KHR = 0x8243;
enum GL_DEBUG_CALLBACK_FUNCTION_KHR = 0x8244;
enum GL_DEBUG_CALLBACK_USER_PARAM_KHR = 0x8245;
enum GL_DEBUG_SOURCE_API_KHR = 0x8246;
enum GL_DEBUG_SOURCE_WINDOW_SYSTEM_KHR = 0x8247;
enum GL_DEBUG_SOURCE_SHADER_COMPILER_KHR = 0x8248;
enum GL_DEBUG_SOURCE_THIRD_PARTY_KHR = 0x8249;
enum GL_DEBUG_SOURCE_APPLICATION_KHR = 0x824A;
enum GL_DEBUG_SOURCE_OTHER_KHR = 0x824B;
enum GL_DEBUG_TYPE_ERROR_KHR = 0x824C;
enum GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR_KHR = 0x824D;
enum GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR_KHR = 0x824E;
enum GL_DEBUG_TYPE_PORTABILITY_KHR = 0x824F;
enum GL_DEBUG_TYPE_PERFORMANCE_KHR = 0x8250;
enum GL_DEBUG_TYPE_OTHER_KHR = 0x8251;
enum GL_DEBUG_TYPE_MARKER_KHR = 0x8268;
enum GL_DEBUG_TYPE_PUSH_GROUP_KHR = 0x8269;
enum GL_DEBUG_TYPE_POP_GROUP_KHR = 0x826A;
enum GL_DEBUG_SEVERITY_NOTIFICATION_KHR = 0x826B;
enum GL_MAX_DEBUG_GROUP_STACK_DEPTH_KHR = 0x826C;
enum GL_DEBUG_GROUP_STACK_DEPTH_KHR = 0x826D;
enum GL_BUFFER_KHR = 0x82E0;
enum GL_SHADER_KHR = 0x82E1;
enum GL_PROGRAM_KHR = 0x82E2;
enum GL_VERTEX_ARRAY_KHR = 0x8074;
enum GL_QUERY_KHR = 0x82E3;
enum GL_PROGRAM_PIPELINE_KHR = 0x82E4;
enum GL_SAMPLER_KHR = 0x82E6;
enum GL_MAX_LABEL_LENGTH_KHR = 0x82E8;
enum GL_MAX_DEBUG_MESSAGE_LENGTH_KHR = 0x9143;
enum GL_MAX_DEBUG_LOGGED_MESSAGES_KHR = 0x9144;
enum GL_DEBUG_LOGGED_MESSAGES_KHR = 0x9145;
enum GL_DEBUG_SEVERITY_HIGH_KHR = 0x9146;
enum GL_DEBUG_SEVERITY_MEDIUM_KHR = 0x9147;
enum GL_DEBUG_SEVERITY_LOW_KHR = 0x9148;
enum GL_DEBUG_OUTPUT_KHR = 0x92E0;
enum GL_CONTEXT_FLAG_DEBUG_BIT_KHR = 0x00000002;
enum GL_STACK_OVERFLOW_KHR = 0x0503;
enum GL_STACK_UNDERFLOW_KHR = 0x0504;
alias PFNGLDEBUGMESSAGECONTROLKHRPROC = void function (GLenum source, GLenum type, GLenum severity, GLsizei count, GLuint* ids, GLboolean enabled);
alias PFNGLDEBUGMESSAGEINSERTKHRPROC = void function (GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, GLchar* buf);
alias PFNGLDEBUGMESSAGECALLBACKKHRPROC = void function (GLDEBUGPROCKHR callback, void* userParam);
alias PFNGLGETDEBUGMESSAGELOGKHRPROC = uint function (GLuint count, GLsizei bufSize, GLenum* sources, GLenum* types, GLuint* ids, GLenum* severities, GLsizei* lengths, GLchar* messageLog);
alias PFNGLPUSHDEBUGGROUPKHRPROC = void function (GLenum source, GLuint id, GLsizei length, GLchar* message);
alias PFNGLPOPDEBUGGROUPKHRPROC = void function ();
alias PFNGLOBJECTLABELKHRPROC = void function (GLenum identifier, GLuint name, GLsizei length, GLchar* label);
alias PFNGLGETOBJECTLABELKHRPROC = void function (GLenum identifier, GLuint name, GLsizei bufSize, GLsizei* length, GLchar* label);
alias PFNGLOBJECTPTRLABELKHRPROC = void function (void* ptr, GLsizei length, GLchar* label);
alias PFNGLGETOBJECTPTRLABELKHRPROC = void function (void* ptr, GLsizei bufSize, GLsizei* length, GLchar* label);
alias PFNGLGETPOINTERVKHRPROC = void function (GLenum pname, void** params);

/* GL_KHR_debug */

enum GL_KHR_no_error = 1;
enum GL_CONTEXT_FLAG_NO_ERROR_BIT_KHR = 0x00000008;
/* GL_KHR_no_error */

enum GL_KHR_parallel_shader_compile = 1;
enum GL_MAX_SHADER_COMPILER_THREADS_KHR = 0x91B0;
enum GL_COMPLETION_STATUS_KHR = 0x91B1;
alias PFNGLMAXSHADERCOMPILERTHREADSKHRPROC = void function (GLuint count);

/* GL_KHR_parallel_shader_compile */

enum GL_KHR_robust_buffer_access_behavior = 1;
/* GL_KHR_robust_buffer_access_behavior */

enum GL_KHR_robustness = 1;
enum GL_CONTEXT_ROBUST_ACCESS_KHR = 0x90F3;
enum GL_LOSE_CONTEXT_ON_RESET_KHR = 0x8252;
enum GL_GUILTY_CONTEXT_RESET_KHR = 0x8253;
enum GL_INNOCENT_CONTEXT_RESET_KHR = 0x8254;
enum GL_UNKNOWN_CONTEXT_RESET_KHR = 0x8255;
enum GL_RESET_NOTIFICATION_STRATEGY_KHR = 0x8256;
enum GL_NO_RESET_NOTIFICATION_KHR = 0x8261;
enum GL_CONTEXT_LOST_KHR = 0x0507;
alias PFNGLGETGRAPHICSRESETSTATUSKHRPROC = uint function ();
alias PFNGLREADNPIXELSKHRPROC = void function (GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLsizei bufSize, void* data);
alias PFNGLGETNUNIFORMFVKHRPROC = void function (GLuint program, GLint location, GLsizei bufSize, GLfloat* params);
alias PFNGLGETNUNIFORMIVKHRPROC = void function (GLuint program, GLint location, GLsizei bufSize, GLint* params);
alias PFNGLGETNUNIFORMUIVKHRPROC = void function (GLuint program, GLint location, GLsizei bufSize, GLuint* params);

/* GL_KHR_robustness */

enum GL_KHR_shader_subgroup = 1;
enum GL_SUBGROUP_SIZE_KHR = 0x9532;
enum GL_SUBGROUP_SUPPORTED_STAGES_KHR = 0x9533;
enum GL_SUBGROUP_SUPPORTED_FEATURES_KHR = 0x9534;
enum GL_SUBGROUP_QUAD_ALL_STAGES_KHR = 0x9535;
enum GL_SUBGROUP_FEATURE_BASIC_BIT_KHR = 0x00000001;
enum GL_SUBGROUP_FEATURE_VOTE_BIT_KHR = 0x00000002;
enum GL_SUBGROUP_FEATURE_ARITHMETIC_BIT_KHR = 0x00000004;
enum GL_SUBGROUP_FEATURE_BALLOT_BIT_KHR = 0x00000008;
enum GL_SUBGROUP_FEATURE_SHUFFLE_BIT_KHR = 0x00000010;
enum GL_SUBGROUP_FEATURE_SHUFFLE_RELATIVE_BIT_KHR = 0x00000020;
enum GL_SUBGROUP_FEATURE_CLUSTERED_BIT_KHR = 0x00000040;
enum GL_SUBGROUP_FEATURE_QUAD_BIT_KHR = 0x00000080;
/* GL_KHR_shader_subgroup */

enum GL_KHR_texture_compression_astc_hdr = 1;
enum GL_COMPRESSED_RGBA_ASTC_4x4_KHR = 0x93B0;
enum GL_COMPRESSED_RGBA_ASTC_5x4_KHR = 0x93B1;
enum GL_COMPRESSED_RGBA_ASTC_5x5_KHR = 0x93B2;
enum GL_COMPRESSED_RGBA_ASTC_6x5_KHR = 0x93B3;
enum GL_COMPRESSED_RGBA_ASTC_6x6_KHR = 0x93B4;
enum GL_COMPRESSED_RGBA_ASTC_8x5_KHR = 0x93B5;
enum GL_COMPRESSED_RGBA_ASTC_8x6_KHR = 0x93B6;
enum GL_COMPRESSED_RGBA_ASTC_8x8_KHR = 0x93B7;
enum GL_COMPRESSED_RGBA_ASTC_10x5_KHR = 0x93B8;
enum GL_COMPRESSED_RGBA_ASTC_10x6_KHR = 0x93B9;
enum GL_COMPRESSED_RGBA_ASTC_10x8_KHR = 0x93BA;
enum GL_COMPRESSED_RGBA_ASTC_10x10_KHR = 0x93BB;
enum GL_COMPRESSED_RGBA_ASTC_12x10_KHR = 0x93BC;
enum GL_COMPRESSED_RGBA_ASTC_12x12_KHR = 0x93BD;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_4x4_KHR = 0x93D0;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_5x4_KHR = 0x93D1;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_5x5_KHR = 0x93D2;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_6x5_KHR = 0x93D3;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_6x6_KHR = 0x93D4;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_8x5_KHR = 0x93D5;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_8x6_KHR = 0x93D6;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_8x8_KHR = 0x93D7;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_10x5_KHR = 0x93D8;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_10x6_KHR = 0x93D9;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_10x8_KHR = 0x93DA;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_10x10_KHR = 0x93DB;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_12x10_KHR = 0x93DC;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_12x12_KHR = 0x93DD;
/* GL_KHR_texture_compression_astc_hdr */

enum GL_KHR_texture_compression_astc_ldr = 1;
/* GL_KHR_texture_compression_astc_ldr */

enum GL_KHR_texture_compression_astc_sliced_3d = 1;
/* GL_KHR_texture_compression_astc_sliced_3d */

enum GL_OES_EGL_image = 1;
alias GLeglImageOES = void*;
alias PFNGLEGLIMAGETARGETTEXTURE2DOESPROC = void function (GLenum target, GLeglImageOES image);
alias PFNGLEGLIMAGETARGETRENDERBUFFERSTORAGEOESPROC = void function (GLenum target, GLeglImageOES image);

/* GL_OES_EGL_image */

enum GL_OES_EGL_image_external = 1;
enum GL_TEXTURE_EXTERNAL_OES = 0x8D65;
enum GL_TEXTURE_BINDING_EXTERNAL_OES = 0x8D67;
enum GL_REQUIRED_TEXTURE_IMAGE_UNITS_OES = 0x8D68;
enum GL_SAMPLER_EXTERNAL_OES = 0x8D66;
/* GL_OES_EGL_image_external */

enum GL_OES_EGL_image_external_essl3 = 1;
/* GL_OES_EGL_image_external_essl3 */

enum GL_OES_compressed_ETC1_RGB8_sub_texture = 1;
/* GL_OES_compressed_ETC1_RGB8_sub_texture */

enum GL_OES_compressed_ETC1_RGB8_texture = 1;
enum GL_ETC1_RGB8_OES = 0x8D64;
/* GL_OES_compressed_ETC1_RGB8_texture */

enum GL_OES_compressed_paletted_texture = 1;
enum GL_PALETTE4_RGB8_OES = 0x8B90;
enum GL_PALETTE4_RGBA8_OES = 0x8B91;
enum GL_PALETTE4_R5_G6_B5_OES = 0x8B92;
enum GL_PALETTE4_RGBA4_OES = 0x8B93;
enum GL_PALETTE4_RGB5_A1_OES = 0x8B94;
enum GL_PALETTE8_RGB8_OES = 0x8B95;
enum GL_PALETTE8_RGBA8_OES = 0x8B96;
enum GL_PALETTE8_R5_G6_B5_OES = 0x8B97;
enum GL_PALETTE8_RGBA4_OES = 0x8B98;
enum GL_PALETTE8_RGB5_A1_OES = 0x8B99;
/* GL_OES_compressed_paletted_texture */

enum GL_OES_copy_image = 1;
alias PFNGLCOPYIMAGESUBDATAOESPROC = void function (GLuint srcName, GLenum srcTarget, GLint srcLevel, GLint srcX, GLint srcY, GLint srcZ, GLuint dstName, GLenum dstTarget, GLint dstLevel, GLint dstX, GLint dstY, GLint dstZ, GLsizei srcWidth, GLsizei srcHeight, GLsizei srcDepth);

/* GL_OES_copy_image */

enum GL_OES_depth24 = 1;
enum GL_DEPTH_COMPONENT24_OES = 0x81A6;
/* GL_OES_depth24 */

enum GL_OES_depth32 = 1;
enum GL_DEPTH_COMPONENT32_OES = 0x81A7;
/* GL_OES_depth32 */

enum GL_OES_depth_texture = 1;
/* GL_OES_depth_texture */

enum GL_OES_draw_buffers_indexed = 1;
enum GL_MIN = 0x8007;
enum GL_MAX = 0x8008;
alias PFNGLENABLEIOESPROC = void function (GLenum target, GLuint index);
alias PFNGLDISABLEIOESPROC = void function (GLenum target, GLuint index);
alias PFNGLBLENDEQUATIONIOESPROC = void function (GLuint buf, GLenum mode);
alias PFNGLBLENDEQUATIONSEPARATEIOESPROC = void function (GLuint buf, GLenum modeRGB, GLenum modeAlpha);
alias PFNGLBLENDFUNCIOESPROC = void function (GLuint buf, GLenum src, GLenum dst);
alias PFNGLBLENDFUNCSEPARATEIOESPROC = void function (GLuint buf, GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha);
alias PFNGLCOLORMASKIOESPROC = void function (GLuint index, GLboolean r, GLboolean g, GLboolean b, GLboolean a);
alias PFNGLISENABLEDIOESPROC = ubyte function (GLenum target, GLuint index);

/* GL_OES_draw_buffers_indexed */

enum GL_OES_draw_elements_base_vertex = 1;
alias PFNGLDRAWELEMENTSBASEVERTEXOESPROC = void function (GLenum mode, GLsizei count, GLenum type, void* indices, GLint basevertex);
alias PFNGLDRAWRANGEELEMENTSBASEVERTEXOESPROC = void function (GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, void* indices, GLint basevertex);
alias PFNGLDRAWELEMENTSINSTANCEDBASEVERTEXOESPROC = void function (GLenum mode, GLsizei count, GLenum type, void* indices, GLsizei instancecount, GLint basevertex);
alias PFNGLMULTIDRAWELEMENTSBASEVERTEXEXTPROC = void function (GLenum mode, GLsizei* count, GLenum type, void** indices, GLsizei primcount, GLint* basevertex);

/* GL_OES_draw_elements_base_vertex */

enum GL_OES_element_index_uint = 1;
/* GL_OES_element_index_uint */

enum GL_OES_fbo_render_mipmap = 1;
/* GL_OES_fbo_render_mipmap */

enum GL_OES_fragment_precision_high = 1;
/* GL_OES_fragment_precision_high */

enum GL_OES_geometry_point_size = 1;
/* GL_OES_geometry_point_size */

enum GL_OES_geometry_shader = 1;
enum GL_GEOMETRY_SHADER_OES = 0x8DD9;
enum GL_GEOMETRY_SHADER_BIT_OES = 0x00000004;
enum GL_GEOMETRY_LINKED_VERTICES_OUT_OES = 0x8916;
enum GL_GEOMETRY_LINKED_INPUT_TYPE_OES = 0x8917;
enum GL_GEOMETRY_LINKED_OUTPUT_TYPE_OES = 0x8918;
enum GL_GEOMETRY_SHADER_INVOCATIONS_OES = 0x887F;
enum GL_LAYER_PROVOKING_VERTEX_OES = 0x825E;
enum GL_LINES_ADJACENCY_OES = 0x000A;
enum GL_LINE_STRIP_ADJACENCY_OES = 0x000B;
enum GL_TRIANGLES_ADJACENCY_OES = 0x000C;
enum GL_TRIANGLE_STRIP_ADJACENCY_OES = 0x000D;
enum GL_MAX_GEOMETRY_UNIFORM_COMPONENTS_OES = 0x8DDF;
enum GL_MAX_GEOMETRY_UNIFORM_BLOCKS_OES = 0x8A2C;
enum GL_MAX_COMBINED_GEOMETRY_UNIFORM_COMPONENTS_OES = 0x8A32;
enum GL_MAX_GEOMETRY_INPUT_COMPONENTS_OES = 0x9123;
enum GL_MAX_GEOMETRY_OUTPUT_COMPONENTS_OES = 0x9124;
enum GL_MAX_GEOMETRY_OUTPUT_VERTICES_OES = 0x8DE0;
enum GL_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS_OES = 0x8DE1;
enum GL_MAX_GEOMETRY_SHADER_INVOCATIONS_OES = 0x8E5A;
enum GL_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS_OES = 0x8C29;
enum GL_MAX_GEOMETRY_ATOMIC_COUNTER_BUFFERS_OES = 0x92CF;
enum GL_MAX_GEOMETRY_ATOMIC_COUNTERS_OES = 0x92D5;
enum GL_MAX_GEOMETRY_IMAGE_UNIFORMS_OES = 0x90CD;
enum GL_MAX_GEOMETRY_SHADER_STORAGE_BLOCKS_OES = 0x90D7;
enum GL_FIRST_VERTEX_CONVENTION_OES = 0x8E4D;
enum GL_LAST_VERTEX_CONVENTION_OES = 0x8E4E;
enum GL_UNDEFINED_VERTEX_OES = 0x8260;
enum GL_PRIMITIVES_GENERATED_OES = 0x8C87;
enum GL_FRAMEBUFFER_DEFAULT_LAYERS_OES = 0x9312;
enum GL_MAX_FRAMEBUFFER_LAYERS_OES = 0x9317;
enum GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS_OES = 0x8DA8;
enum GL_FRAMEBUFFER_ATTACHMENT_LAYERED_OES = 0x8DA7;
enum GL_REFERENCED_BY_GEOMETRY_SHADER_OES = 0x9309;
alias PFNGLFRAMEBUFFERTEXTUREOESPROC = void function (GLenum target, GLenum attachment, GLuint texture, GLint level);

/* GL_OES_geometry_shader */

enum GL_OES_get_program_binary = 1;
enum GL_PROGRAM_BINARY_LENGTH_OES = 0x8741;
enum GL_NUM_PROGRAM_BINARY_FORMATS_OES = 0x87FE;
enum GL_PROGRAM_BINARY_FORMATS_OES = 0x87FF;
alias PFNGLGETPROGRAMBINARYOESPROC = void function (GLuint program, GLsizei bufSize, GLsizei* length, GLenum* binaryFormat, void* binary);
alias PFNGLPROGRAMBINARYOESPROC = void function (GLuint program, GLenum binaryFormat, void* binary, GLint length);

/* GL_OES_get_program_binary */

enum GL_OES_gpu_shader5 = 1;
/* GL_OES_gpu_shader5 */

enum GL_OES_mapbuffer = 1;
enum GL_WRITE_ONLY_OES = 0x88B9;
enum GL_BUFFER_ACCESS_OES = 0x88BB;
enum GL_BUFFER_MAPPED_OES = 0x88BC;
enum GL_BUFFER_MAP_POINTER_OES = 0x88BD;
alias PFNGLMAPBUFFEROESPROC = void* function (GLenum target, GLenum access);
alias PFNGLUNMAPBUFFEROESPROC = ubyte function (GLenum target);
alias PFNGLGETBUFFERPOINTERVOESPROC = void function (GLenum target, GLenum pname, void** params);

/* GL_OES_mapbuffer */

enum GL_OES_packed_depth_stencil = 1;
enum GL_DEPTH_STENCIL_OES = 0x84F9;
enum GL_UNSIGNED_INT_24_8_OES = 0x84FA;
enum GL_DEPTH24_STENCIL8_OES = 0x88F0;
/* GL_OES_packed_depth_stencil */

enum GL_OES_primitive_bounding_box = 1;
enum GL_PRIMITIVE_BOUNDING_BOX_OES = 0x92BE;
alias PFNGLPRIMITIVEBOUNDINGBOXOESPROC = void function (GLfloat minX, GLfloat minY, GLfloat minZ, GLfloat minW, GLfloat maxX, GLfloat maxY, GLfloat maxZ, GLfloat maxW);

/* GL_OES_primitive_bounding_box */

enum GL_OES_required_internalformat = 1;
enum GL_ALPHA8_OES = 0x803C;
enum GL_DEPTH_COMPONENT16_OES = 0x81A5;
enum GL_LUMINANCE4_ALPHA4_OES = 0x8043;
enum GL_LUMINANCE8_ALPHA8_OES = 0x8045;
enum GL_LUMINANCE8_OES = 0x8040;
enum GL_RGBA4_OES = 0x8056;
enum GL_RGB5_A1_OES = 0x8057;
enum GL_RGB565_OES = 0x8D62;
enum GL_RGB8_OES = 0x8051;
enum GL_RGBA8_OES = 0x8058;
enum GL_RGB10_EXT = 0x8052;
enum GL_RGB10_A2_EXT = 0x8059;
/* GL_OES_required_internalformat */

enum GL_OES_rgb8_rgba8 = 1;
/* GL_OES_rgb8_rgba8 */

enum GL_OES_sample_shading = 1;
enum GL_SAMPLE_SHADING_OES = 0x8C36;
enum GL_MIN_SAMPLE_SHADING_VALUE_OES = 0x8C37;
alias PFNGLMINSAMPLESHADINGOESPROC = void function (GLfloat value);

/* GL_OES_sample_shading */

enum GL_OES_sample_variables = 1;
/* GL_OES_sample_variables */

enum GL_OES_shader_image_atomic = 1;
/* GL_OES_shader_image_atomic */

enum GL_OES_shader_io_blocks = 1;
/* GL_OES_shader_io_blocks */

enum GL_OES_shader_multisample_interpolation = 1;
enum GL_MIN_FRAGMENT_INTERPOLATION_OFFSET_OES = 0x8E5B;
enum GL_MAX_FRAGMENT_INTERPOLATION_OFFSET_OES = 0x8E5C;
enum GL_FRAGMENT_INTERPOLATION_OFFSET_BITS_OES = 0x8E5D;
/* GL_OES_shader_multisample_interpolation */

enum GL_OES_standard_derivatives = 1;
enum GL_FRAGMENT_SHADER_DERIVATIVE_HINT_OES = 0x8B8B;
/* GL_OES_standard_derivatives */

enum GL_OES_stencil1 = 1;
enum GL_STENCIL_INDEX1_OES = 0x8D46;
/* GL_OES_stencil1 */

enum GL_OES_stencil4 = 1;
enum GL_STENCIL_INDEX4_OES = 0x8D47;
/* GL_OES_stencil4 */

enum GL_OES_surfaceless_context = 1;
enum GL_FRAMEBUFFER_UNDEFINED_OES = 0x8219;
/* GL_OES_surfaceless_context */

enum GL_OES_tessellation_point_size = 1;
/* GL_OES_tessellation_point_size */

enum GL_OES_tessellation_shader = 1;
enum GL_PATCHES_OES = 0x000E;
enum GL_PATCH_VERTICES_OES = 0x8E72;
enum GL_TESS_CONTROL_OUTPUT_VERTICES_OES = 0x8E75;
enum GL_TESS_GEN_MODE_OES = 0x8E76;
enum GL_TESS_GEN_SPACING_OES = 0x8E77;
enum GL_TESS_GEN_VERTEX_ORDER_OES = 0x8E78;
enum GL_TESS_GEN_POINT_MODE_OES = 0x8E79;
enum GL_ISOLINES_OES = 0x8E7A;
enum GL_QUADS_OES = 0x0007;
enum GL_FRACTIONAL_ODD_OES = 0x8E7B;
enum GL_FRACTIONAL_EVEN_OES = 0x8E7C;
enum GL_MAX_PATCH_VERTICES_OES = 0x8E7D;
enum GL_MAX_TESS_GEN_LEVEL_OES = 0x8E7E;
enum GL_MAX_TESS_CONTROL_UNIFORM_COMPONENTS_OES = 0x8E7F;
enum GL_MAX_TESS_EVALUATION_UNIFORM_COMPONENTS_OES = 0x8E80;
enum GL_MAX_TESS_CONTROL_TEXTURE_IMAGE_UNITS_OES = 0x8E81;
enum GL_MAX_TESS_EVALUATION_TEXTURE_IMAGE_UNITS_OES = 0x8E82;
enum GL_MAX_TESS_CONTROL_OUTPUT_COMPONENTS_OES = 0x8E83;
enum GL_MAX_TESS_PATCH_COMPONENTS_OES = 0x8E84;
enum GL_MAX_TESS_CONTROL_TOTAL_OUTPUT_COMPONENTS_OES = 0x8E85;
enum GL_MAX_TESS_EVALUATION_OUTPUT_COMPONENTS_OES = 0x8E86;
enum GL_MAX_TESS_CONTROL_UNIFORM_BLOCKS_OES = 0x8E89;
enum GL_MAX_TESS_EVALUATION_UNIFORM_BLOCKS_OES = 0x8E8A;
enum GL_MAX_TESS_CONTROL_INPUT_COMPONENTS_OES = 0x886C;
enum GL_MAX_TESS_EVALUATION_INPUT_COMPONENTS_OES = 0x886D;
enum GL_MAX_COMBINED_TESS_CONTROL_UNIFORM_COMPONENTS_OES = 0x8E1E;
enum GL_MAX_COMBINED_TESS_EVALUATION_UNIFORM_COMPONENTS_OES = 0x8E1F;
enum GL_MAX_TESS_CONTROL_ATOMIC_COUNTER_BUFFERS_OES = 0x92CD;
enum GL_MAX_TESS_EVALUATION_ATOMIC_COUNTER_BUFFERS_OES = 0x92CE;
enum GL_MAX_TESS_CONTROL_ATOMIC_COUNTERS_OES = 0x92D3;
enum GL_MAX_TESS_EVALUATION_ATOMIC_COUNTERS_OES = 0x92D4;
enum GL_MAX_TESS_CONTROL_IMAGE_UNIFORMS_OES = 0x90CB;
enum GL_MAX_TESS_EVALUATION_IMAGE_UNIFORMS_OES = 0x90CC;
enum GL_MAX_TESS_CONTROL_SHADER_STORAGE_BLOCKS_OES = 0x90D8;
enum GL_MAX_TESS_EVALUATION_SHADER_STORAGE_BLOCKS_OES = 0x90D9;
enum GL_PRIMITIVE_RESTART_FOR_PATCHES_SUPPORTED_OES = 0x8221;
enum GL_IS_PER_PATCH_OES = 0x92E7;
enum GL_REFERENCED_BY_TESS_CONTROL_SHADER_OES = 0x9307;
enum GL_REFERENCED_BY_TESS_EVALUATION_SHADER_OES = 0x9308;
enum GL_TESS_CONTROL_SHADER_OES = 0x8E88;
enum GL_TESS_EVALUATION_SHADER_OES = 0x8E87;
enum GL_TESS_CONTROL_SHADER_BIT_OES = 0x00000008;
enum GL_TESS_EVALUATION_SHADER_BIT_OES = 0x00000010;
alias PFNGLPATCHPARAMETERIOESPROC = void function (GLenum pname, GLint value);

/* GL_OES_tessellation_shader */

enum GL_OES_texture_3D = 1;
enum GL_TEXTURE_WRAP_R_OES = 0x8072;
enum GL_TEXTURE_3D_OES = 0x806F;
enum GL_TEXTURE_BINDING_3D_OES = 0x806A;
enum GL_MAX_3D_TEXTURE_SIZE_OES = 0x8073;
enum GL_SAMPLER_3D_OES = 0x8B5F;
enum GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_3D_ZOFFSET_OES = 0x8CD4;
alias PFNGLTEXIMAGE3DOESPROC = void function (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, void* pixels);
alias PFNGLTEXSUBIMAGE3DOESPROC = void function (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, void* pixels);
alias PFNGLCOPYTEXSUBIMAGE3DOESPROC = void function (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height);
alias PFNGLCOMPRESSEDTEXIMAGE3DOESPROC = void function (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize, void* data);
alias PFNGLCOMPRESSEDTEXSUBIMAGE3DOESPROC = void function (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, void* data);
alias PFNGLFRAMEBUFFERTEXTURE3DOESPROC = void function (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLint zoffset);

/* GL_OES_texture_3D */

enum GL_OES_texture_border_clamp = 1;
enum GL_TEXTURE_BORDER_COLOR_OES = 0x1004;
enum GL_CLAMP_TO_BORDER_OES = 0x812D;
alias PFNGLTEXPARAMETERIIVOESPROC = void function (GLenum target, GLenum pname, GLint* params);
alias PFNGLTEXPARAMETERIUIVOESPROC = void function (GLenum target, GLenum pname, GLuint* params);
alias PFNGLGETTEXPARAMETERIIVOESPROC = void function (GLenum target, GLenum pname, GLint* params);
alias PFNGLGETTEXPARAMETERIUIVOESPROC = void function (GLenum target, GLenum pname, GLuint* params);
alias PFNGLSAMPLERPARAMETERIIVOESPROC = void function (GLuint sampler, GLenum pname, GLint* param);
alias PFNGLSAMPLERPARAMETERIUIVOESPROC = void function (GLuint sampler, GLenum pname, GLuint* param);
alias PFNGLGETSAMPLERPARAMETERIIVOESPROC = void function (GLuint sampler, GLenum pname, GLint* params);
alias PFNGLGETSAMPLERPARAMETERIUIVOESPROC = void function (GLuint sampler, GLenum pname, GLuint* params);

/* GL_OES_texture_border_clamp */

enum GL_OES_texture_buffer = 1;
enum GL_TEXTURE_BUFFER_OES = 0x8C2A;
enum GL_TEXTURE_BUFFER_BINDING_OES = 0x8C2A;
enum GL_MAX_TEXTURE_BUFFER_SIZE_OES = 0x8C2B;
enum GL_TEXTURE_BINDING_BUFFER_OES = 0x8C2C;
enum GL_TEXTURE_BUFFER_DATA_STORE_BINDING_OES = 0x8C2D;
enum GL_TEXTURE_BUFFER_OFFSET_ALIGNMENT_OES = 0x919F;
enum GL_SAMPLER_BUFFER_OES = 0x8DC2;
enum GL_INT_SAMPLER_BUFFER_OES = 0x8DD0;
enum GL_UNSIGNED_INT_SAMPLER_BUFFER_OES = 0x8DD8;
enum GL_IMAGE_BUFFER_OES = 0x9051;
enum GL_INT_IMAGE_BUFFER_OES = 0x905C;
enum GL_UNSIGNED_INT_IMAGE_BUFFER_OES = 0x9067;
enum GL_TEXTURE_BUFFER_OFFSET_OES = 0x919D;
enum GL_TEXTURE_BUFFER_SIZE_OES = 0x919E;
alias PFNGLTEXBUFFEROESPROC = void function (GLenum target, GLenum internalformat, GLuint buffer);
alias PFNGLTEXBUFFERRANGEOESPROC = void function (GLenum target, GLenum internalformat, GLuint buffer, GLintptr offset, GLsizeiptr size);

/* GL_OES_texture_buffer */

enum GL_OES_texture_compression_astc = 1;
enum GL_COMPRESSED_RGBA_ASTC_3x3x3_OES = 0x93C0;
enum GL_COMPRESSED_RGBA_ASTC_4x3x3_OES = 0x93C1;
enum GL_COMPRESSED_RGBA_ASTC_4x4x3_OES = 0x93C2;
enum GL_COMPRESSED_RGBA_ASTC_4x4x4_OES = 0x93C3;
enum GL_COMPRESSED_RGBA_ASTC_5x4x4_OES = 0x93C4;
enum GL_COMPRESSED_RGBA_ASTC_5x5x4_OES = 0x93C5;
enum GL_COMPRESSED_RGBA_ASTC_5x5x5_OES = 0x93C6;
enum GL_COMPRESSED_RGBA_ASTC_6x5x5_OES = 0x93C7;
enum GL_COMPRESSED_RGBA_ASTC_6x6x5_OES = 0x93C8;
enum GL_COMPRESSED_RGBA_ASTC_6x6x6_OES = 0x93C9;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_3x3x3_OES = 0x93E0;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_4x3x3_OES = 0x93E1;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_4x4x3_OES = 0x93E2;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_4x4x4_OES = 0x93E3;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_5x4x4_OES = 0x93E4;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_5x5x4_OES = 0x93E5;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_5x5x5_OES = 0x93E6;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_6x5x5_OES = 0x93E7;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_6x6x5_OES = 0x93E8;
enum GL_COMPRESSED_SRGB8_ALPHA8_ASTC_6x6x6_OES = 0x93E9;
/* GL_OES_texture_compression_astc */

enum GL_OES_texture_cube_map_array = 1;
enum GL_TEXTURE_CUBE_MAP_ARRAY_OES = 0x9009;
enum GL_TEXTURE_BINDING_CUBE_MAP_ARRAY_OES = 0x900A;
enum GL_SAMPLER_CUBE_MAP_ARRAY_OES = 0x900C;
enum GL_SAMPLER_CUBE_MAP_ARRAY_SHADOW_OES = 0x900D;
enum GL_INT_SAMPLER_CUBE_MAP_ARRAY_OES = 0x900E;
enum GL_UNSIGNED_INT_SAMPLER_CUBE_MAP_ARRAY_OES = 0x900F;
enum GL_IMAGE_CUBE_MAP_ARRAY_OES = 0x9054;
enum GL_INT_IMAGE_CUBE_MAP_ARRAY_OES = 0x905F;
enum GL_UNSIGNED_INT_IMAGE_CUBE_MAP_ARRAY_OES = 0x906A;
/* GL_OES_texture_cube_map_array */

enum GL_OES_texture_float = 1;
/* GL_OES_texture_float */

enum GL_OES_texture_float_linear = 1;
/* GL_OES_texture_float_linear */

enum GL_OES_texture_half_float = 1;
enum GL_HALF_FLOAT_OES = 0x8D61;
/* GL_OES_texture_half_float */

enum GL_OES_texture_half_float_linear = 1;
/* GL_OES_texture_half_float_linear */

enum GL_OES_texture_npot = 1;
/* GL_OES_texture_npot */

enum GL_OES_texture_stencil8 = 1;
enum GL_STENCIL_INDEX_OES = 0x1901;
enum GL_STENCIL_INDEX8_OES = 0x8D48;
/* GL_OES_texture_stencil8 */

enum GL_OES_texture_storage_multisample_2d_array = 1;
enum GL_TEXTURE_2D_MULTISAMPLE_ARRAY_OES = 0x9102;
enum GL_TEXTURE_BINDING_2D_MULTISAMPLE_ARRAY_OES = 0x9105;
enum GL_SAMPLER_2D_MULTISAMPLE_ARRAY_OES = 0x910B;
enum GL_INT_SAMPLER_2D_MULTISAMPLE_ARRAY_OES = 0x910C;
enum GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE_ARRAY_OES = 0x910D;
alias PFNGLTEXSTORAGE3DMULTISAMPLEOESPROC = void function (GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations);

/* GL_OES_texture_storage_multisample_2d_array */

enum GL_OES_texture_view = 1;
enum GL_TEXTURE_VIEW_MIN_LEVEL_OES = 0x82DB;
enum GL_TEXTURE_VIEW_NUM_LEVELS_OES = 0x82DC;
enum GL_TEXTURE_VIEW_MIN_LAYER_OES = 0x82DD;
enum GL_TEXTURE_VIEW_NUM_LAYERS_OES = 0x82DE;
enum GL_TEXTURE_IMMUTABLE_LEVELS = 0x82DF;
alias PFNGLTEXTUREVIEWOESPROC = void function (GLuint texture, GLenum target, GLuint origtexture, GLenum internalformat, GLuint minlevel, GLuint numlevels, GLuint minlayer, GLuint numlayers);

/* GL_OES_texture_view */

enum GL_OES_vertex_array_object = 1;
enum GL_VERTEX_ARRAY_BINDING_OES = 0x85B5;
alias PFNGLBINDVERTEXARRAYOESPROC = void function (GLuint array);
alias PFNGLDELETEVERTEXARRAYSOESPROC = void function (GLsizei n, GLuint* arrays);
alias PFNGLGENVERTEXARRAYSOESPROC = void function (GLsizei n, GLuint* arrays);
alias PFNGLISVERTEXARRAYOESPROC = ubyte function (GLuint array);

/* GL_OES_vertex_array_object */

enum GL_OES_vertex_half_float = 1;
/* GL_OES_vertex_half_float */

enum GL_OES_vertex_type_10_10_10_2 = 1;
enum GL_UNSIGNED_INT_10_10_10_2_OES = 0x8DF6;
enum GL_INT_10_10_10_2_OES = 0x8DF7;
/* GL_OES_vertex_type_10_10_10_2 */

enum GL_OES_viewport_array = 1;
enum GL_MAX_VIEWPORTS_OES = 0x825B;
enum GL_VIEWPORT_SUBPIXEL_BITS_OES = 0x825C;
enum GL_VIEWPORT_BOUNDS_RANGE_OES = 0x825D;
enum GL_VIEWPORT_INDEX_PROVOKING_VERTEX_OES = 0x825F;
alias PFNGLVIEWPORTARRAYVOESPROC = void function (GLuint first, GLsizei count, GLfloat* v);
alias PFNGLVIEWPORTINDEXEDFOESPROC = void function (GLuint index, GLfloat x, GLfloat y, GLfloat w, GLfloat h);
alias PFNGLVIEWPORTINDEXEDFVOESPROC = void function (GLuint index, GLfloat* v);
alias PFNGLSCISSORARRAYVOESPROC = void function (GLuint first, GLsizei count, GLint* v);
alias PFNGLSCISSORINDEXEDOESPROC = void function (GLuint index, GLint left, GLint bottom, GLsizei width, GLsizei height);
alias PFNGLSCISSORINDEXEDVOESPROC = void function (GLuint index, GLint* v);
alias PFNGLDEPTHRANGEARRAYFVOESPROC = void function (GLuint first, GLsizei count, GLfloat* v);
alias PFNGLDEPTHRANGEINDEXEDFOESPROC = void function (GLuint index, GLfloat n, GLfloat f);
alias PFNGLGETFLOATI_VOESPROC = void function (GLenum target, GLuint index, GLfloat* data);

/* GL_OES_viewport_array */

enum GL_AMD_compressed_3DC_texture = 1;
enum GL_3DC_X_AMD = 0x87F9;
enum GL_3DC_XY_AMD = 0x87FA;
/* GL_AMD_compressed_3DC_texture */

enum GL_AMD_compressed_ATC_texture = 1;
enum GL_ATC_RGB_AMD = 0x8C92;
enum GL_ATC_RGBA_EXPLICIT_ALPHA_AMD = 0x8C93;
enum GL_ATC_RGBA_INTERPOLATED_ALPHA_AMD = 0x87EE;
/* GL_AMD_compressed_ATC_texture */

enum GL_AMD_framebuffer_multisample_advanced = 1;
enum GL_RENDERBUFFER_STORAGE_SAMPLES_AMD = 0x91B2;
enum GL_MAX_COLOR_FRAMEBUFFER_SAMPLES_AMD = 0x91B3;
enum GL_MAX_COLOR_FRAMEBUFFER_STORAGE_SAMPLES_AMD = 0x91B4;
enum GL_MAX_DEPTH_STENCIL_FRAMEBUFFER_SAMPLES_AMD = 0x91B5;
enum GL_NUM_SUPPORTED_MULTISAMPLE_MODES_AMD = 0x91B6;
enum GL_SUPPORTED_MULTISAMPLE_MODES_AMD = 0x91B7;
alias PFNGLRENDERBUFFERSTORAGEMULTISAMPLEADVANCEDAMDPROC = void function (GLenum target, GLsizei samples, GLsizei storageSamples, GLenum internalformat, GLsizei width, GLsizei height);
alias PFNGLNAMEDRENDERBUFFERSTORAGEMULTISAMPLEADVANCEDAMDPROC = void function (GLuint renderbuffer, GLsizei samples, GLsizei storageSamples, GLenum internalformat, GLsizei width, GLsizei height);

/* GL_AMD_framebuffer_multisample_advanced */

enum GL_AMD_performance_monitor = 1;
enum GL_COUNTER_TYPE_AMD = 0x8BC0;
enum GL_COUNTER_RANGE_AMD = 0x8BC1;
enum GL_UNSIGNED_INT64_AMD = 0x8BC2;
enum GL_PERCENTAGE_AMD = 0x8BC3;
enum GL_PERFMON_RESULT_AVAILABLE_AMD = 0x8BC4;
enum GL_PERFMON_RESULT_SIZE_AMD = 0x8BC5;
enum GL_PERFMON_RESULT_AMD = 0x8BC6;
alias PFNGLGETPERFMONITORGROUPSAMDPROC = void function (GLint* numGroups, GLsizei groupsSize, GLuint* groups);
alias PFNGLGETPERFMONITORCOUNTERSAMDPROC = void function (GLuint group, GLint* numCounters, GLint* maxActiveCounters, GLsizei counterSize, GLuint* counters);
alias PFNGLGETPERFMONITORGROUPSTRINGAMDPROC = void function (GLuint group, GLsizei bufSize, GLsizei* length, GLchar* groupString);
alias PFNGLGETPERFMONITORCOUNTERSTRINGAMDPROC = void function (GLuint group, GLuint counter, GLsizei bufSize, GLsizei* length, GLchar* counterString);
alias PFNGLGETPERFMONITORCOUNTERINFOAMDPROC = void function (GLuint group, GLuint counter, GLenum pname, void* data);
alias PFNGLGENPERFMONITORSAMDPROC = void function (GLsizei n, GLuint* monitors);
alias PFNGLDELETEPERFMONITORSAMDPROC = void function (GLsizei n, GLuint* monitors);
alias PFNGLSELECTPERFMONITORCOUNTERSAMDPROC = void function (GLuint monitor, GLboolean enable, GLuint group, GLint numCounters, GLuint* counterList);
alias PFNGLBEGINPERFMONITORAMDPROC = void function (GLuint monitor);
alias PFNGLENDPERFMONITORAMDPROC = void function (GLuint monitor);
alias PFNGLGETPERFMONITORCOUNTERDATAAMDPROC = void function (GLuint monitor, GLenum pname, GLsizei dataSize, GLuint* data, GLint* bytesWritten);

/* GL_AMD_performance_monitor */

enum GL_AMD_program_binary_Z400 = 1;
enum GL_Z400_BINARY_AMD = 0x8740;
/* GL_AMD_program_binary_Z400 */

enum GL_ANDROID_extension_pack_es31a = 1;
/* GL_ANDROID_extension_pack_es31a */

enum GL_ANGLE_depth_texture = 1;
/* GL_ANGLE_depth_texture */

enum GL_ANGLE_framebuffer_blit = 1;
enum GL_READ_FRAMEBUFFER_ANGLE = 0x8CA8;
enum GL_DRAW_FRAMEBUFFER_ANGLE = 0x8CA9;
enum GL_DRAW_FRAMEBUFFER_BINDING_ANGLE = 0x8CA6;
enum GL_READ_FRAMEBUFFER_BINDING_ANGLE = 0x8CAA;
alias PFNGLBLITFRAMEBUFFERANGLEPROC = void function (GLint srcX0, GLint srcY0, GLint srcX1, GLint srcY1, GLint dstX0, GLint dstY0, GLint dstX1, GLint dstY1, GLbitfield mask, GLenum filter);

/* GL_ANGLE_framebuffer_blit */

enum GL_ANGLE_framebuffer_multisample = 1;
enum GL_RENDERBUFFER_SAMPLES_ANGLE = 0x8CAB;
enum GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE_ANGLE = 0x8D56;
enum GL_MAX_SAMPLES_ANGLE = 0x8D57;
alias PFNGLRENDERBUFFERSTORAGEMULTISAMPLEANGLEPROC = void function (GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height);

/* GL_ANGLE_framebuffer_multisample */

enum GL_ANGLE_instanced_arrays = 1;
enum GL_VERTEX_ATTRIB_ARRAY_DIVISOR_ANGLE = 0x88FE;
alias PFNGLDRAWARRAYSINSTANCEDANGLEPROC = void function (GLenum mode, GLint first, GLsizei count, GLsizei primcount);
alias PFNGLDRAWELEMENTSINSTANCEDANGLEPROC = void function (GLenum mode, GLsizei count, GLenum type, void* indices, GLsizei primcount);
alias PFNGLVERTEXATTRIBDIVISORANGLEPROC = void function (GLuint index, GLuint divisor);

/* GL_ANGLE_instanced_arrays */

enum GL_ANGLE_pack_reverse_row_order = 1;
enum GL_PACK_REVERSE_ROW_ORDER_ANGLE = 0x93A4;
/* GL_ANGLE_pack_reverse_row_order */

enum GL_ANGLE_program_binary = 1;
enum GL_PROGRAM_BINARY_ANGLE = 0x93A6;
/* GL_ANGLE_program_binary */

enum GL_ANGLE_texture_compression_dxt3 = 1;
enum GL_COMPRESSED_RGBA_S3TC_DXT3_ANGLE = 0x83F2;
/* GL_ANGLE_texture_compression_dxt3 */

enum GL_ANGLE_texture_compression_dxt5 = 1;
enum GL_COMPRESSED_RGBA_S3TC_DXT5_ANGLE = 0x83F3;
/* GL_ANGLE_texture_compression_dxt5 */

enum GL_ANGLE_texture_usage = 1;
enum GL_TEXTURE_USAGE_ANGLE = 0x93A2;
enum GL_FRAMEBUFFER_ATTACHMENT_ANGLE = 0x93A3;
/* GL_ANGLE_texture_usage */

enum GL_ANGLE_translated_shader_source = 1;
enum GL_TRANSLATED_SHADER_SOURCE_LENGTH_ANGLE = 0x93A0;
alias PFNGLGETTRANSLATEDSHADERSOURCEANGLEPROC = void function (GLuint shader, GLsizei bufSize, GLsizei* length, GLchar* source);

/* GL_ANGLE_translated_shader_source */

enum GL_APPLE_clip_distance = 1;
enum GL_MAX_CLIP_DISTANCES_APPLE = 0x0D32;
enum GL_CLIP_DISTANCE0_APPLE = 0x3000;
enum GL_CLIP_DISTANCE1_APPLE = 0x3001;
enum GL_CLIP_DISTANCE2_APPLE = 0x3002;
enum GL_CLIP_DISTANCE3_APPLE = 0x3003;
enum GL_CLIP_DISTANCE4_APPLE = 0x3004;
enum GL_CLIP_DISTANCE5_APPLE = 0x3005;
enum GL_CLIP_DISTANCE6_APPLE = 0x3006;
enum GL_CLIP_DISTANCE7_APPLE = 0x3007;
/* GL_APPLE_clip_distance */

enum GL_APPLE_color_buffer_packed_float = 1;
/* GL_APPLE_color_buffer_packed_float */

enum GL_APPLE_copy_texture_levels = 1;
alias PFNGLCOPYTEXTURELEVELSAPPLEPROC = void function (GLuint destinationTexture, GLuint sourceTexture, GLint sourceBaseLevel, GLsizei sourceLevelCount);

/* GL_APPLE_copy_texture_levels */

enum GL_APPLE_framebuffer_multisample = 1;
enum GL_RENDERBUFFER_SAMPLES_APPLE = 0x8CAB;
enum GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE_APPLE = 0x8D56;
enum GL_MAX_SAMPLES_APPLE = 0x8D57;
enum GL_READ_FRAMEBUFFER_APPLE = 0x8CA8;
enum GL_DRAW_FRAMEBUFFER_APPLE = 0x8CA9;
enum GL_DRAW_FRAMEBUFFER_BINDING_APPLE = 0x8CA6;
enum GL_READ_FRAMEBUFFER_BINDING_APPLE = 0x8CAA;
alias PFNGLRENDERBUFFERSTORAGEMULTISAMPLEAPPLEPROC = void function (GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height);
alias PFNGLRESOLVEMULTISAMPLEFRAMEBUFFERAPPLEPROC = void function ();

/* GL_APPLE_framebuffer_multisample */

enum GL_APPLE_rgb_422 = 1;
enum GL_RGB_422_APPLE = 0x8A1F;
enum GL_UNSIGNED_SHORT_8_8_APPLE = 0x85BA;
enum GL_UNSIGNED_SHORT_8_8_REV_APPLE = 0x85BB;
enum GL_RGB_RAW_422_APPLE = 0x8A51;
/* GL_APPLE_rgb_422 */

enum GL_APPLE_sync = 1;
enum GL_SYNC_OBJECT_APPLE = 0x8A53;
enum GL_MAX_SERVER_WAIT_TIMEOUT_APPLE = 0x9111;
enum GL_OBJECT_TYPE_APPLE = 0x9112;
enum GL_SYNC_CONDITION_APPLE = 0x9113;
enum GL_SYNC_STATUS_APPLE = 0x9114;
enum GL_SYNC_FLAGS_APPLE = 0x9115;
enum GL_SYNC_FENCE_APPLE = 0x9116;
enum GL_SYNC_GPU_COMMANDS_COMPLETE_APPLE = 0x9117;
enum GL_UNSIGNALED_APPLE = 0x9118;
enum GL_SIGNALED_APPLE = 0x9119;
enum GL_ALREADY_SIGNALED_APPLE = 0x911A;
enum GL_TIMEOUT_EXPIRED_APPLE = 0x911B;
enum GL_CONDITION_SATISFIED_APPLE = 0x911C;
enum GL_WAIT_FAILED_APPLE = 0x911D;
enum GL_SYNC_FLUSH_COMMANDS_BIT_APPLE = 0x00000001;
enum GL_TIMEOUT_IGNORED_APPLE = 0xFFFFFFFFFFFFFFFFuL;
alias PFNGLFENCESYNCAPPLEPROC = __GLsync* function (GLenum condition, GLbitfield flags);
alias PFNGLISSYNCAPPLEPROC = ubyte function (GLsync sync);
alias PFNGLDELETESYNCAPPLEPROC = void function (GLsync sync);
alias PFNGLCLIENTWAITSYNCAPPLEPROC = uint function (GLsync sync, GLbitfield flags, GLuint64 timeout);
alias PFNGLWAITSYNCAPPLEPROC = void function (GLsync sync, GLbitfield flags, GLuint64 timeout);
alias PFNGLGETINTEGER64VAPPLEPROC = void function (GLenum pname, GLint64* params);
alias PFNGLGETSYNCIVAPPLEPROC = void function (GLsync sync, GLenum pname, GLsizei count, GLsizei* length, GLint* values);

/* GL_APPLE_sync */

enum GL_APPLE_texture_format_BGRA8888 = 1;
enum GL_BGRA_EXT = 0x80E1;
enum GL_BGRA8_EXT = 0x93A1;
/* GL_APPLE_texture_format_BGRA8888 */

enum GL_APPLE_texture_max_level = 1;
enum GL_TEXTURE_MAX_LEVEL_APPLE = 0x813D;
/* GL_APPLE_texture_max_level */

enum GL_APPLE_texture_packed_float = 1;
enum GL_UNSIGNED_INT_10F_11F_11F_REV_APPLE = 0x8C3B;
enum GL_UNSIGNED_INT_5_9_9_9_REV_APPLE = 0x8C3E;
enum GL_R11F_G11F_B10F_APPLE = 0x8C3A;
enum GL_RGB9_E5_APPLE = 0x8C3D;
/* GL_APPLE_texture_packed_float */

enum GL_ARM_mali_program_binary = 1;
enum GL_MALI_PROGRAM_BINARY_ARM = 0x8F61;
/* GL_ARM_mali_program_binary */

enum GL_ARM_mali_shader_binary = 1;
enum GL_MALI_SHADER_BINARY_ARM = 0x8F60;
/* GL_ARM_mali_shader_binary */

enum GL_ARM_rgba8 = 1;
/* GL_ARM_rgba8 */

enum GL_ARM_shader_framebuffer_fetch = 1;
enum GL_FETCH_PER_SAMPLE_ARM = 0x8F65;
enum GL_FRAGMENT_SHADER_FRAMEBUFFER_FETCH_MRT_ARM = 0x8F66;
/* GL_ARM_shader_framebuffer_fetch */

enum GL_ARM_shader_framebuffer_fetch_depth_stencil = 1;
/* GL_ARM_shader_framebuffer_fetch_depth_stencil */

enum GL_ARM_texture_unnormalized_coordinates = 1;
enum GL_TEXTURE_UNNORMALIZED_COORDINATES_ARM = 0x8F6A;
/* GL_ARM_texture_unnormalized_coordinates */

enum GL_DMP_program_binary = 1;
enum GL_SMAPHS30_PROGRAM_BINARY_DMP = 0x9251;
enum GL_SMAPHS_PROGRAM_BINARY_DMP = 0x9252;
enum GL_DMP_PROGRAM_BINARY_DMP = 0x9253;
/* GL_DMP_program_binary */

enum GL_DMP_shader_binary = 1;
enum GL_SHADER_BINARY_DMP = 0x9250;
/* GL_DMP_shader_binary */

enum GL_EXT_EGL_image_array = 1;
/* GL_EXT_EGL_image_array */

enum GL_EXT_EGL_image_storage = 1;
alias PFNGLEGLIMAGETARGETTEXSTORAGEEXTPROC = void function (GLenum target, GLeglImageOES image, GLint* attrib_list);
alias PFNGLEGLIMAGETARGETTEXTURESTORAGEEXTPROC = void function (GLuint texture, GLeglImageOES image, GLint* attrib_list);

/* GL_EXT_EGL_image_storage */

enum GL_EXT_YUV_target = 1;
enum GL_SAMPLER_EXTERNAL_2D_Y2Y_EXT = 0x8BE7;
/* GL_EXT_YUV_target */

enum GL_EXT_base_instance = 1;
alias PFNGLDRAWARRAYSINSTANCEDBASEINSTANCEEXTPROC = void function (GLenum mode, GLint first, GLsizei count, GLsizei instancecount, GLuint baseinstance);
alias PFNGLDRAWELEMENTSINSTANCEDBASEINSTANCEEXTPROC = void function (GLenum mode, GLsizei count, GLenum type, void* indices, GLsizei instancecount, GLuint baseinstance);
alias PFNGLDRAWELEMENTSINSTANCEDBASEVERTEXBASEINSTANCEEXTPROC = void function (GLenum mode, GLsizei count, GLenum type, void* indices, GLsizei instancecount, GLint basevertex, GLuint baseinstance);

/* GL_EXT_base_instance */

enum GL_EXT_blend_func_extended = 1;
enum GL_SRC1_COLOR_EXT = 0x88F9;
enum GL_SRC1_ALPHA_EXT = 0x8589;
enum GL_ONE_MINUS_SRC1_COLOR_EXT = 0x88FA;
enum GL_ONE_MINUS_SRC1_ALPHA_EXT = 0x88FB;
enum GL_SRC_ALPHA_SATURATE_EXT = 0x0308;
enum GL_LOCATION_INDEX_EXT = 0x930F;
enum GL_MAX_DUAL_SOURCE_DRAW_BUFFERS_EXT = 0x88FC;
alias PFNGLBINDFRAGDATALOCATIONINDEXEDEXTPROC = void function (GLuint program, GLuint colorNumber, GLuint index, GLchar* name);
alias PFNGLBINDFRAGDATALOCATIONEXTPROC = void function (GLuint program, GLuint color, GLchar* name);
alias PFNGLGETPROGRAMRESOURCELOCATIONINDEXEXTPROC = int function (GLuint program, GLenum programInterface, GLchar* name);
alias PFNGLGETFRAGDATAINDEXEXTPROC = int function (GLuint program, GLchar* name);

/* GL_EXT_blend_func_extended */

enum GL_EXT_blend_minmax = 1;
enum GL_MIN_EXT = 0x8007;
enum GL_MAX_EXT = 0x8008;
/* GL_EXT_blend_minmax */

enum GL_EXT_buffer_storage = 1;
enum GL_MAP_READ_BIT = 0x0001;
enum GL_MAP_WRITE_BIT = 0x0002;
enum GL_MAP_PERSISTENT_BIT_EXT = 0x0040;
enum GL_MAP_COHERENT_BIT_EXT = 0x0080;
enum GL_DYNAMIC_STORAGE_BIT_EXT = 0x0100;
enum GL_CLIENT_STORAGE_BIT_EXT = 0x0200;
enum GL_CLIENT_MAPPED_BUFFER_BARRIER_BIT_EXT = 0x00004000;
enum GL_BUFFER_IMMUTABLE_STORAGE_EXT = 0x821F;
enum GL_BUFFER_STORAGE_FLAGS_EXT = 0x8220;
alias PFNGLBUFFERSTORAGEEXTPROC = void function (GLenum target, GLsizeiptr size, void* data, GLbitfield flags);

/* GL_EXT_buffer_storage */

enum GL_EXT_clear_texture = 1;
alias PFNGLCLEARTEXIMAGEEXTPROC = void function (GLuint texture, GLint level, GLenum format, GLenum type, void* data);
alias PFNGLCLEARTEXSUBIMAGEEXTPROC = void function (GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, void* data);

/* GL_EXT_clear_texture */

enum GL_EXT_clip_control = 1;
enum GL_LOWER_LEFT_EXT = 0x8CA1;
enum GL_UPPER_LEFT_EXT = 0x8CA2;
enum GL_NEGATIVE_ONE_TO_ONE_EXT = 0x935E;
enum GL_ZERO_TO_ONE_EXT = 0x935F;
enum GL_CLIP_ORIGIN_EXT = 0x935C;
enum GL_CLIP_DEPTH_MODE_EXT = 0x935D;
alias PFNGLCLIPCONTROLEXTPROC = void function (GLenum origin, GLenum depth);

/* GL_EXT_clip_control */

enum GL_EXT_clip_cull_distance = 1;
enum GL_MAX_CLIP_DISTANCES_EXT = 0x0D32;
enum GL_MAX_CULL_DISTANCES_EXT = 0x82F9;
enum GL_MAX_COMBINED_CLIP_AND_CULL_DISTANCES_EXT = 0x82FA;
enum GL_CLIP_DISTANCE0_EXT = 0x3000;
enum GL_CLIP_DISTANCE1_EXT = 0x3001;
enum GL_CLIP_DISTANCE2_EXT = 0x3002;
enum GL_CLIP_DISTANCE3_EXT = 0x3003;
enum GL_CLIP_DISTANCE4_EXT = 0x3004;
enum GL_CLIP_DISTANCE5_EXT = 0x3005;
enum GL_CLIP_DISTANCE6_EXT = 0x3006;
enum GL_CLIP_DISTANCE7_EXT = 0x3007;
/* GL_EXT_clip_cull_distance */

enum GL_EXT_color_buffer_float = 1;
/* GL_EXT_color_buffer_float */

enum GL_EXT_color_buffer_half_float = 1;
enum GL_RGBA16F_EXT = 0x881A;
enum GL_RGB16F_EXT = 0x881B;
enum GL_RG16F_EXT = 0x822F;
enum GL_R16F_EXT = 0x822D;
enum GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE_EXT = 0x8211;
enum GL_UNSIGNED_NORMALIZED_EXT = 0x8C17;
/* GL_EXT_color_buffer_half_float */

enum GL_EXT_conservative_depth = 1;
/* GL_EXT_conservative_depth */

enum GL_EXT_copy_image = 1;
alias PFNGLCOPYIMAGESUBDATAEXTPROC = void function (GLuint srcName, GLenum srcTarget, GLint srcLevel, GLint srcX, GLint srcY, GLint srcZ, GLuint dstName, GLenum dstTarget, GLint dstLevel, GLint dstX, GLint dstY, GLint dstZ, GLsizei srcWidth, GLsizei srcHeight, GLsizei srcDepth);

/* GL_EXT_copy_image */

enum GL_EXT_debug_label = 1;
enum GL_PROGRAM_PIPELINE_OBJECT_EXT = 0x8A4F;
enum GL_PROGRAM_OBJECT_EXT = 0x8B40;
enum GL_SHADER_OBJECT_EXT = 0x8B48;
enum GL_BUFFER_OBJECT_EXT = 0x9151;
enum GL_QUERY_OBJECT_EXT = 0x9153;
enum GL_VERTEX_ARRAY_OBJECT_EXT = 0x9154;
enum GL_TRANSFORM_FEEDBACK = 0x8E22;
alias PFNGLLABELOBJECTEXTPROC = void function (GLenum type, GLuint object, GLsizei length, GLchar* label);
alias PFNGLGETOBJECTLABELEXTPROC = void function (GLenum type, GLuint object, GLsizei bufSize, GLsizei* length, GLchar* label);

/* GL_EXT_debug_label */

enum GL_EXT_debug_marker = 1;
alias PFNGLINSERTEVENTMARKEREXTPROC = void function (GLsizei length, GLchar* marker);
alias PFNGLPUSHGROUPMARKEREXTPROC = void function (GLsizei length, GLchar* marker);
alias PFNGLPOPGROUPMARKEREXTPROC = void function ();

/* GL_EXT_debug_marker */

enum GL_EXT_depth_clamp = 1;
enum GL_DEPTH_CLAMP_EXT = 0x864F;
/* GL_EXT_depth_clamp */

enum GL_EXT_discard_framebuffer = 1;
enum GL_COLOR_EXT = 0x1800;
enum GL_DEPTH_EXT = 0x1801;
enum GL_STENCIL_EXT = 0x1802;
alias PFNGLDISCARDFRAMEBUFFEREXTPROC = void function (GLenum target, GLsizei numAttachments, GLenum* attachments);

/* GL_EXT_discard_framebuffer */

enum GL_EXT_disjoint_timer_query = 1;
enum GL_QUERY_COUNTER_BITS_EXT = 0x8864;
enum GL_CURRENT_QUERY_EXT = 0x8865;
enum GL_QUERY_RESULT_EXT = 0x8866;
enum GL_QUERY_RESULT_AVAILABLE_EXT = 0x8867;
enum GL_TIME_ELAPSED_EXT = 0x88BF;
enum GL_TIMESTAMP_EXT = 0x8E28;
enum GL_GPU_DISJOINT_EXT = 0x8FBB;
alias PFNGLGENQUERIESEXTPROC = void function (GLsizei n, GLuint* ids);
alias PFNGLDELETEQUERIESEXTPROC = void function (GLsizei n, GLuint* ids);
alias PFNGLISQUERYEXTPROC = ubyte function (GLuint id);
alias PFNGLBEGINQUERYEXTPROC = void function (GLenum target, GLuint id);
alias PFNGLENDQUERYEXTPROC = void function (GLenum target);
alias PFNGLQUERYCOUNTEREXTPROC = void function (GLuint id, GLenum target);
alias PFNGLGETQUERYIVEXTPROC = void function (GLenum target, GLenum pname, GLint* params);
alias PFNGLGETQUERYOBJECTIVEXTPROC = void function (GLuint id, GLenum pname, GLint* params);
alias PFNGLGETQUERYOBJECTUIVEXTPROC = void function (GLuint id, GLenum pname, GLuint* params);
alias PFNGLGETQUERYOBJECTI64VEXTPROC = void function (GLuint id, GLenum pname, GLint64* params);
alias PFNGLGETQUERYOBJECTUI64VEXTPROC = void function (GLuint id, GLenum pname, GLuint64* params);
alias PFNGLGETINTEGER64VEXTPROC = void function (GLenum pname, GLint64* data);

/* GL_EXT_disjoint_timer_query */

enum GL_EXT_draw_buffers = 1;
enum GL_MAX_COLOR_ATTACHMENTS_EXT = 0x8CDF;
enum GL_MAX_DRAW_BUFFERS_EXT = 0x8824;
enum GL_DRAW_BUFFER0_EXT = 0x8825;
enum GL_DRAW_BUFFER1_EXT = 0x8826;
enum GL_DRAW_BUFFER2_EXT = 0x8827;
enum GL_DRAW_BUFFER3_EXT = 0x8828;
enum GL_DRAW_BUFFER4_EXT = 0x8829;
enum GL_DRAW_BUFFER5_EXT = 0x882A;
enum GL_DRAW_BUFFER6_EXT = 0x882B;
enum GL_DRAW_BUFFER7_EXT = 0x882C;
enum GL_DRAW_BUFFER8_EXT = 0x882D;
enum GL_DRAW_BUFFER9_EXT = 0x882E;
enum GL_DRAW_BUFFER10_EXT = 0x882F;
enum GL_DRAW_BUFFER11_EXT = 0x8830;
enum GL_DRAW_BUFFER12_EXT = 0x8831;
enum GL_DRAW_BUFFER13_EXT = 0x8832;
enum GL_DRAW_BUFFER14_EXT = 0x8833;
enum GL_DRAW_BUFFER15_EXT = 0x8834;
enum GL_COLOR_ATTACHMENT0_EXT = 0x8CE0;
enum GL_COLOR_ATTACHMENT1_EXT = 0x8CE1;
enum GL_COLOR_ATTACHMENT2_EXT = 0x8CE2;
enum GL_COLOR_ATTACHMENT3_EXT = 0x8CE3;
enum GL_COLOR_ATTACHMENT4_EXT = 0x8CE4;
enum GL_COLOR_ATTACHMENT5_EXT = 0x8CE5;
enum GL_COLOR_ATTACHMENT6_EXT = 0x8CE6;
enum GL_COLOR_ATTACHMENT7_EXT = 0x8CE7;
enum GL_COLOR_ATTACHMENT8_EXT = 0x8CE8;
enum GL_COLOR_ATTACHMENT9_EXT = 0x8CE9;
enum GL_COLOR_ATTACHMENT10_EXT = 0x8CEA;
enum GL_COLOR_ATTACHMENT11_EXT = 0x8CEB;
enum GL_COLOR_ATTACHMENT12_EXT = 0x8CEC;
enum GL_COLOR_ATTACHMENT13_EXT = 0x8CED;
enum GL_COLOR_ATTACHMENT14_EXT = 0x8CEE;
enum GL_COLOR_ATTACHMENT15_EXT = 0x8CEF;
alias PFNGLDRAWBUFFERSEXTPROC = void function (GLsizei n, GLenum* bufs);

/* GL_EXT_draw_buffers */

enum GL_EXT_draw_buffers_indexed = 1;
alias PFNGLENABLEIEXTPROC = void function (GLenum target, GLuint index);
alias PFNGLDISABLEIEXTPROC = void function (GLenum target, GLuint index);
alias PFNGLBLENDEQUATIONIEXTPROC = void function (GLuint buf, GLenum mode);
alias PFNGLBLENDEQUATIONSEPARATEIEXTPROC = void function (GLuint buf, GLenum modeRGB, GLenum modeAlpha);
alias PFNGLBLENDFUNCIEXTPROC = void function (GLuint buf, GLenum src, GLenum dst);
alias PFNGLBLENDFUNCSEPARATEIEXTPROC = void function (GLuint buf, GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha);
alias PFNGLCOLORMASKIEXTPROC = void function (GLuint index, GLboolean r, GLboolean g, GLboolean b, GLboolean a);
alias PFNGLISENABLEDIEXTPROC = ubyte function (GLenum target, GLuint index);

/* GL_EXT_draw_buffers_indexed */

enum GL_EXT_draw_elements_base_vertex = 1;
alias PFNGLDRAWELEMENTSBASEVERTEXEXTPROC = void function (GLenum mode, GLsizei count, GLenum type, void* indices, GLint basevertex);
alias PFNGLDRAWRANGEELEMENTSBASEVERTEXEXTPROC = void function (GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, void* indices, GLint basevertex);
alias PFNGLDRAWELEMENTSINSTANCEDBASEVERTEXEXTPROC = void function (GLenum mode, GLsizei count, GLenum type, void* indices, GLsizei instancecount, GLint basevertex);

/* GL_EXT_draw_elements_base_vertex */

enum GL_EXT_draw_instanced = 1;
alias PFNGLDRAWARRAYSINSTANCEDEXTPROC = void function (GLenum mode, GLint start, GLsizei count, GLsizei primcount);
alias PFNGLDRAWELEMENTSINSTANCEDEXTPROC = void function (GLenum mode, GLsizei count, GLenum type, void* indices, GLsizei primcount);

/* GL_EXT_draw_instanced */

enum GL_EXT_draw_transform_feedback = 1;
alias PFNGLDRAWTRANSFORMFEEDBACKEXTPROC = void function (GLenum mode, GLuint id);
alias PFNGLDRAWTRANSFORMFEEDBACKINSTANCEDEXTPROC = void function (GLenum mode, GLuint id, GLsizei instancecount);

/* GL_EXT_draw_transform_feedback */

enum GL_EXT_external_buffer = 1;
alias GLeglClientBufferEXT = void*;
alias PFNGLBUFFERSTORAGEEXTERNALEXTPROC = void function (GLenum target, GLintptr offset, GLsizeiptr size, GLeglClientBufferEXT clientBuffer, GLbitfield flags);
alias PFNGLNAMEDBUFFERSTORAGEEXTERNALEXTPROC = void function (GLuint buffer, GLintptr offset, GLsizeiptr size, GLeglClientBufferEXT clientBuffer, GLbitfield flags);

/* GL_EXT_external_buffer */

enum GL_EXT_float_blend = 1;
/* GL_EXT_float_blend */

enum GL_EXT_geometry_point_size = 1;
/* GL_EXT_geometry_point_size */

enum GL_EXT_geometry_shader = 1;
enum GL_GEOMETRY_SHADER_EXT = 0x8DD9;
enum GL_GEOMETRY_SHADER_BIT_EXT = 0x00000004;
enum GL_GEOMETRY_LINKED_VERTICES_OUT_EXT = 0x8916;
enum GL_GEOMETRY_LINKED_INPUT_TYPE_EXT = 0x8917;
enum GL_GEOMETRY_LINKED_OUTPUT_TYPE_EXT = 0x8918;
enum GL_GEOMETRY_SHADER_INVOCATIONS_EXT = 0x887F;
enum GL_LAYER_PROVOKING_VERTEX_EXT = 0x825E;
enum GL_LINES_ADJACENCY_EXT = 0x000A;
enum GL_LINE_STRIP_ADJACENCY_EXT = 0x000B;
enum GL_TRIANGLES_ADJACENCY_EXT = 0x000C;
enum GL_TRIANGLE_STRIP_ADJACENCY_EXT = 0x000D;
enum GL_MAX_GEOMETRY_UNIFORM_COMPONENTS_EXT = 0x8DDF;
enum GL_MAX_GEOMETRY_UNIFORM_BLOCKS_EXT = 0x8A2C;
enum GL_MAX_COMBINED_GEOMETRY_UNIFORM_COMPONENTS_EXT = 0x8A32;
enum GL_MAX_GEOMETRY_INPUT_COMPONENTS_EXT = 0x9123;
enum GL_MAX_GEOMETRY_OUTPUT_COMPONENTS_EXT = 0x9124;
enum GL_MAX_GEOMETRY_OUTPUT_VERTICES_EXT = 0x8DE0;
enum GL_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS_EXT = 0x8DE1;
enum GL_MAX_GEOMETRY_SHADER_INVOCATIONS_EXT = 0x8E5A;
enum GL_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS_EXT = 0x8C29;
enum GL_MAX_GEOMETRY_ATOMIC_COUNTER_BUFFERS_EXT = 0x92CF;
enum GL_MAX_GEOMETRY_ATOMIC_COUNTERS_EXT = 0x92D5;
enum GL_MAX_GEOMETRY_IMAGE_UNIFORMS_EXT = 0x90CD;
enum GL_MAX_GEOMETRY_SHADER_STORAGE_BLOCKS_EXT = 0x90D7;
enum GL_FIRST_VERTEX_CONVENTION_EXT = 0x8E4D;
enum GL_LAST_VERTEX_CONVENTION_EXT = 0x8E4E;
enum GL_UNDEFINED_VERTEX_EXT = 0x8260;
enum GL_PRIMITIVES_GENERATED_EXT = 0x8C87;
enum GL_FRAMEBUFFER_DEFAULT_LAYERS_EXT = 0x9312;
enum GL_MAX_FRAMEBUFFER_LAYERS_EXT = 0x9317;
enum GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS_EXT = 0x8DA8;
enum GL_FRAMEBUFFER_ATTACHMENT_LAYERED_EXT = 0x8DA7;
enum GL_REFERENCED_BY_GEOMETRY_SHADER_EXT = 0x9309;
alias PFNGLFRAMEBUFFERTEXTUREEXTPROC = void function (GLenum target, GLenum attachment, GLuint texture, GLint level);

/* GL_EXT_geometry_shader */

enum GL_EXT_gpu_shader5 = 1;
/* GL_EXT_gpu_shader5 */

enum GL_EXT_instanced_arrays = 1;
enum GL_VERTEX_ATTRIB_ARRAY_DIVISOR_EXT = 0x88FE;
alias PFNGLVERTEXATTRIBDIVISOREXTPROC = void function (GLuint index, GLuint divisor);

/* GL_EXT_instanced_arrays */

enum GL_EXT_map_buffer_range = 1;
enum GL_MAP_READ_BIT_EXT = 0x0001;
enum GL_MAP_WRITE_BIT_EXT = 0x0002;
enum GL_MAP_INVALIDATE_RANGE_BIT_EXT = 0x0004;
enum GL_MAP_INVALIDATE_BUFFER_BIT_EXT = 0x0008;
enum GL_MAP_FLUSH_EXPLICIT_BIT_EXT = 0x0010;
enum GL_MAP_UNSYNCHRONIZED_BIT_EXT = 0x0020;
alias PFNGLMAPBUFFERRANGEEXTPROC = void* function (GLenum target, GLintptr offset, GLsizeiptr length, GLbitfield access);
alias PFNGLFLUSHMAPPEDBUFFERRANGEEXTPROC = void function (GLenum target, GLintptr offset, GLsizeiptr length);

/* GL_EXT_map_buffer_range */

enum GL_EXT_memory_object = 1;
enum GL_TEXTURE_TILING_EXT = 0x9580;
enum GL_DEDICATED_MEMORY_OBJECT_EXT = 0x9581;
enum GL_PROTECTED_MEMORY_OBJECT_EXT = 0x959B;
enum GL_NUM_TILING_TYPES_EXT = 0x9582;
enum GL_TILING_TYPES_EXT = 0x9583;
enum GL_OPTIMAL_TILING_EXT = 0x9584;
enum GL_LINEAR_TILING_EXT = 0x9585;
enum GL_NUM_DEVICE_UUIDS_EXT = 0x9596;
enum GL_DEVICE_UUID_EXT = 0x9597;
enum GL_DRIVER_UUID_EXT = 0x9598;
enum GL_UUID_SIZE_EXT = 16;
alias PFNGLGETUNSIGNEDBYTEVEXTPROC = void function (GLenum pname, GLubyte* data);
alias PFNGLGETUNSIGNEDBYTEI_VEXTPROC = void function (GLenum target, GLuint index, GLubyte* data);
alias PFNGLDELETEMEMORYOBJECTSEXTPROC = void function (GLsizei n, GLuint* memoryObjects);
alias PFNGLISMEMORYOBJECTEXTPROC = ubyte function (GLuint memoryObject);
alias PFNGLCREATEMEMORYOBJECTSEXTPROC = void function (GLsizei n, GLuint* memoryObjects);
alias PFNGLMEMORYOBJECTPARAMETERIVEXTPROC = void function (GLuint memoryObject, GLenum pname, GLint* params);
alias PFNGLGETMEMORYOBJECTPARAMETERIVEXTPROC = void function (GLuint memoryObject, GLenum pname, GLint* params);
alias PFNGLTEXSTORAGEMEM2DEXTPROC = void function (GLenum target, GLsizei levels, GLenum internalFormat, GLsizei width, GLsizei height, GLuint memory, GLuint64 offset);
alias PFNGLTEXSTORAGEMEM2DMULTISAMPLEEXTPROC = void function (GLenum target, GLsizei samples, GLenum internalFormat, GLsizei width, GLsizei height, GLboolean fixedSampleLocations, GLuint memory, GLuint64 offset);
alias PFNGLTEXSTORAGEMEM3DEXTPROC = void function (GLenum target, GLsizei levels, GLenum internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLuint memory, GLuint64 offset);
alias PFNGLTEXSTORAGEMEM3DMULTISAMPLEEXTPROC = void function (GLenum target, GLsizei samples, GLenum internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedSampleLocations, GLuint memory, GLuint64 offset);
alias PFNGLBUFFERSTORAGEMEMEXTPROC = void function (GLenum target, GLsizeiptr size, GLuint memory, GLuint64 offset);
alias PFNGLTEXTURESTORAGEMEM2DEXTPROC = void function (GLuint texture, GLsizei levels, GLenum internalFormat, GLsizei width, GLsizei height, GLuint memory, GLuint64 offset);
alias PFNGLTEXTURESTORAGEMEM2DMULTISAMPLEEXTPROC = void function (GLuint texture, GLsizei samples, GLenum internalFormat, GLsizei width, GLsizei height, GLboolean fixedSampleLocations, GLuint memory, GLuint64 offset);
alias PFNGLTEXTURESTORAGEMEM3DEXTPROC = void function (GLuint texture, GLsizei levels, GLenum internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLuint memory, GLuint64 offset);
alias PFNGLTEXTURESTORAGEMEM3DMULTISAMPLEEXTPROC = void function (GLuint texture, GLsizei samples, GLenum internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedSampleLocations, GLuint memory, GLuint64 offset);
alias PFNGLNAMEDBUFFERSTORAGEMEMEXTPROC = void function (GLuint buffer, GLsizeiptr size, GLuint memory, GLuint64 offset);

/* GL_EXT_memory_object */

enum GL_EXT_memory_object_fd = 1;
enum GL_HANDLE_TYPE_OPAQUE_FD_EXT = 0x9586;
alias PFNGLIMPORTMEMORYFDEXTPROC = void function (GLuint memory, GLuint64 size, GLenum handleType, GLint fd);

/* GL_EXT_memory_object_fd */

enum GL_EXT_memory_object_win32 = 1;
enum GL_HANDLE_TYPE_OPAQUE_WIN32_EXT = 0x9587;
enum GL_HANDLE_TYPE_OPAQUE_WIN32_KMT_EXT = 0x9588;
enum GL_DEVICE_LUID_EXT = 0x9599;
enum GL_DEVICE_NODE_MASK_EXT = 0x959A;
enum GL_LUID_SIZE_EXT = 8;
enum GL_HANDLE_TYPE_D3D12_TILEPOOL_EXT = 0x9589;
enum GL_HANDLE_TYPE_D3D12_RESOURCE_EXT = 0x958A;
enum GL_HANDLE_TYPE_D3D11_IMAGE_EXT = 0x958B;
enum GL_HANDLE_TYPE_D3D11_IMAGE_KMT_EXT = 0x958C;
alias PFNGLIMPORTMEMORYWIN32HANDLEEXTPROC = void function (GLuint memory, GLuint64 size, GLenum handleType, void* handle);
alias PFNGLIMPORTMEMORYWIN32NAMEEXTPROC = void function (GLuint memory, GLuint64 size, GLenum handleType, void* name);

/* GL_EXT_memory_object_win32 */

enum GL_EXT_multi_draw_arrays = 1;
alias PFNGLMULTIDRAWARRAYSEXTPROC = void function (GLenum mode, GLint* first, GLsizei* count, GLsizei primcount);
alias PFNGLMULTIDRAWELEMENTSEXTPROC = void function (GLenum mode, GLsizei* count, GLenum type, void** indices, GLsizei primcount);

/* GL_EXT_multi_draw_arrays */

enum GL_EXT_multi_draw_indirect = 1;
alias PFNGLMULTIDRAWARRAYSINDIRECTEXTPROC = void function (GLenum mode, void* indirect, GLsizei drawcount, GLsizei stride);
alias PFNGLMULTIDRAWELEMENTSINDIRECTEXTPROC = void function (GLenum mode, GLenum type, void* indirect, GLsizei drawcount, GLsizei stride);

/* GL_EXT_multi_draw_indirect */

enum GL_EXT_multisampled_compatibility = 1;
enum GL_MULTISAMPLE_EXT = 0x809D;
enum GL_SAMPLE_ALPHA_TO_ONE_EXT = 0x809F;
/* GL_EXT_multisampled_compatibility */

enum GL_EXT_multisampled_render_to_texture = 1;
enum GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_SAMPLES_EXT = 0x8D6C;
enum GL_RENDERBUFFER_SAMPLES_EXT = 0x8CAB;
enum GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE_EXT = 0x8D56;
enum GL_MAX_SAMPLES_EXT = 0x8D57;
alias PFNGLRENDERBUFFERSTORAGEMULTISAMPLEEXTPROC = void function (GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height);
alias PFNGLFRAMEBUFFERTEXTURE2DMULTISAMPLEEXTPROC = void function (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLsizei samples);

/* GL_EXT_multisampled_render_to_texture */

enum GL_EXT_multisampled_render_to_texture2 = 1;
/* GL_EXT_multisampled_render_to_texture2 */

enum GL_EXT_multiview_draw_buffers = 1;
enum GL_COLOR_ATTACHMENT_EXT = 0x90F0;
enum GL_MULTIVIEW_EXT = 0x90F1;
enum GL_DRAW_BUFFER_EXT = 0x0C01;
enum GL_READ_BUFFER_EXT = 0x0C02;
enum GL_MAX_MULTIVIEW_BUFFERS_EXT = 0x90F2;
alias PFNGLREADBUFFERINDEXEDEXTPROC = void function (GLenum src, GLint index);
alias PFNGLDRAWBUFFERSINDEXEDEXTPROC = void function (GLint n, GLenum* location, GLint* indices);
alias PFNGLGETINTEGERI_VEXTPROC = void function (GLenum target, GLuint index, GLint* data);

/* GL_EXT_multiview_draw_buffers */

enum GL_EXT_multiview_tessellation_geometry_shader = 1;
/* GL_EXT_multiview_tessellation_geometry_shader */

enum GL_EXT_multiview_texture_multisample = 1;
/* GL_EXT_multiview_texture_multisample */

enum GL_EXT_multiview_timer_query = 1;
/* GL_EXT_multiview_timer_query */

enum GL_EXT_occlusion_query_boolean = 1;
enum GL_ANY_SAMPLES_PASSED_EXT = 0x8C2F;
enum GL_ANY_SAMPLES_PASSED_CONSERVATIVE_EXT = 0x8D6A;
/* GL_EXT_occlusion_query_boolean */

enum GL_EXT_polygon_offset_clamp = 1;
enum GL_POLYGON_OFFSET_CLAMP_EXT = 0x8E1B;
alias PFNGLPOLYGONOFFSETCLAMPEXTPROC = void function (GLfloat factor, GLfloat units, GLfloat clamp);

/* GL_EXT_polygon_offset_clamp */

enum GL_EXT_post_depth_coverage = 1;
/* GL_EXT_post_depth_coverage */

enum GL_EXT_primitive_bounding_box = 1;
enum GL_PRIMITIVE_BOUNDING_BOX_EXT = 0x92BE;
alias PFNGLPRIMITIVEBOUNDINGBOXEXTPROC = void function (GLfloat minX, GLfloat minY, GLfloat minZ, GLfloat minW, GLfloat maxX, GLfloat maxY, GLfloat maxZ, GLfloat maxW);

/* GL_EXT_primitive_bounding_box */

enum GL_EXT_protected_textures = 1;
enum GL_CONTEXT_FLAG_PROTECTED_CONTENT_BIT_EXT = 0x00000010;
enum GL_TEXTURE_PROTECTED_EXT = 0x8BFA;
/* GL_EXT_protected_textures */

enum GL_EXT_pvrtc_sRGB = 1;
enum GL_COMPRESSED_SRGB_PVRTC_2BPPV1_EXT = 0x8A54;
enum GL_COMPRESSED_SRGB_PVRTC_4BPPV1_EXT = 0x8A55;
enum GL_COMPRESSED_SRGB_ALPHA_PVRTC_2BPPV1_EXT = 0x8A56;
enum GL_COMPRESSED_SRGB_ALPHA_PVRTC_4BPPV1_EXT = 0x8A57;
enum GL_COMPRESSED_SRGB_ALPHA_PVRTC_2BPPV2_IMG = 0x93F0;
enum GL_COMPRESSED_SRGB_ALPHA_PVRTC_4BPPV2_IMG = 0x93F1;
/* GL_EXT_pvrtc_sRGB */

enum GL_EXT_raster_multisample = 1;
enum GL_RASTER_MULTISAMPLE_EXT = 0x9327;
enum GL_RASTER_SAMPLES_EXT = 0x9328;
enum GL_MAX_RASTER_SAMPLES_EXT = 0x9329;
enum GL_RASTER_FIXED_SAMPLE_LOCATIONS_EXT = 0x932A;
enum GL_MULTISAMPLE_RASTERIZATION_ALLOWED_EXT = 0x932B;
enum GL_EFFECTIVE_RASTER_SAMPLES_EXT = 0x932C;
alias PFNGLRASTERSAMPLESEXTPROC = void function (GLuint samples, GLboolean fixedsamplelocations);

/* GL_EXT_raster_multisample */

enum GL_EXT_read_format_bgra = 1;
enum GL_UNSIGNED_SHORT_4_4_4_4_REV_EXT = 0x8365;
enum GL_UNSIGNED_SHORT_1_5_5_5_REV_EXT = 0x8366;
/* GL_EXT_read_format_bgra */

enum GL_EXT_render_snorm = 1;
enum GL_R8_SNORM = 0x8F94;
enum GL_RG8_SNORM = 0x8F95;
enum GL_RGBA8_SNORM = 0x8F97;
enum GL_R16_SNORM_EXT = 0x8F98;
enum GL_RG16_SNORM_EXT = 0x8F99;
enum GL_RGBA16_SNORM_EXT = 0x8F9B;
/* GL_EXT_render_snorm */

enum GL_EXT_robustness = 1;
enum GL_GUILTY_CONTEXT_RESET_EXT = 0x8253;
enum GL_INNOCENT_CONTEXT_RESET_EXT = 0x8254;
enum GL_UNKNOWN_CONTEXT_RESET_EXT = 0x8255;
enum GL_CONTEXT_ROBUST_ACCESS_EXT = 0x90F3;
enum GL_RESET_NOTIFICATION_STRATEGY_EXT = 0x8256;
enum GL_LOSE_CONTEXT_ON_RESET_EXT = 0x8252;
enum GL_NO_RESET_NOTIFICATION_EXT = 0x8261;
alias PFNGLGETGRAPHICSRESETSTATUSEXTPROC = uint function ();
alias PFNGLREADNPIXELSEXTPROC = void function (GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLsizei bufSize, void* data);
alias PFNGLGETNUNIFORMFVEXTPROC = void function (GLuint program, GLint location, GLsizei bufSize, GLfloat* params);
alias PFNGLGETNUNIFORMIVEXTPROC = void function (GLuint program, GLint location, GLsizei bufSize, GLint* params);

/* GL_EXT_robustness */

enum GL_EXT_sRGB = 1;
enum GL_SRGB_EXT = 0x8C40;
enum GL_SRGB_ALPHA_EXT = 0x8C42;
enum GL_SRGB8_ALPHA8_EXT = 0x8C43;
enum GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING_EXT = 0x8210;
/* GL_EXT_sRGB */

enum GL_EXT_sRGB_write_control = 1;
enum GL_FRAMEBUFFER_SRGB_EXT = 0x8DB9;
/* GL_EXT_sRGB_write_control */

enum GL_EXT_semaphore = 1;
enum GL_LAYOUT_GENERAL_EXT = 0x958D;
enum GL_LAYOUT_COLOR_ATTACHMENT_EXT = 0x958E;
enum GL_LAYOUT_DEPTH_STENCIL_ATTACHMENT_EXT = 0x958F;
enum GL_LAYOUT_DEPTH_STENCIL_READ_ONLY_EXT = 0x9590;
enum GL_LAYOUT_SHADER_READ_ONLY_EXT = 0x9591;
enum GL_LAYOUT_TRANSFER_SRC_EXT = 0x9592;
enum GL_LAYOUT_TRANSFER_DST_EXT = 0x9593;
enum GL_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_EXT = 0x9530;
enum GL_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_EXT = 0x9531;
alias PFNGLGENSEMAPHORESEXTPROC = void function (GLsizei n, GLuint* semaphores);
alias PFNGLDELETESEMAPHORESEXTPROC = void function (GLsizei n, GLuint* semaphores);
alias PFNGLISSEMAPHOREEXTPROC = ubyte function (GLuint semaphore);
alias PFNGLSEMAPHOREPARAMETERUI64VEXTPROC = void function (GLuint semaphore, GLenum pname, GLuint64* params);
alias PFNGLGETSEMAPHOREPARAMETERUI64VEXTPROC = void function (GLuint semaphore, GLenum pname, GLuint64* params);
alias PFNGLWAITSEMAPHOREEXTPROC = void function (GLuint semaphore, GLuint numBufferBarriers, GLuint* buffers, GLuint numTextureBarriers, GLuint* textures, GLenum* srcLayouts);
alias PFNGLSIGNALSEMAPHOREEXTPROC = void function (GLuint semaphore, GLuint numBufferBarriers, GLuint* buffers, GLuint numTextureBarriers, GLuint* textures, GLenum* dstLayouts);

/* GL_EXT_semaphore */

enum GL_EXT_semaphore_fd = 1;
alias PFNGLIMPORTSEMAPHOREFDEXTPROC = void function (GLuint semaphore, GLenum handleType, GLint fd);

/* GL_EXT_semaphore_fd */

enum GL_EXT_semaphore_win32 = 1;
enum GL_HANDLE_TYPE_D3D12_FENCE_EXT = 0x9594;
enum GL_D3D12_FENCE_VALUE_EXT = 0x9595;
alias PFNGLIMPORTSEMAPHOREWIN32HANDLEEXTPROC = void function (GLuint semaphore, GLenum handleType, void* handle);
alias PFNGLIMPORTSEMAPHOREWIN32NAMEEXTPROC = void function (GLuint semaphore, GLenum handleType, void* name);

/* GL_EXT_semaphore_win32 */

enum GL_EXT_separate_shader_objects = 1;
enum GL_ACTIVE_PROGRAM_EXT = 0x8259;
enum GL_VERTEX_SHADER_BIT_EXT = 0x00000001;
enum GL_FRAGMENT_SHADER_BIT_EXT = 0x00000002;
enum GL_ALL_SHADER_BITS_EXT = 0xFFFFFFFF;
enum GL_PROGRAM_SEPARABLE_EXT = 0x8258;
enum GL_PROGRAM_PIPELINE_BINDING_EXT = 0x825A;
alias PFNGLACTIVESHADERPROGRAMEXTPROC = void function (GLuint pipeline, GLuint program);
alias PFNGLBINDPROGRAMPIPELINEEXTPROC = void function (GLuint pipeline);
alias PFNGLCREATESHADERPROGRAMVEXTPROC = uint function (GLenum type, GLsizei count, GLchar** strings);
alias PFNGLDELETEPROGRAMPIPELINESEXTPROC = void function (GLsizei n, GLuint* pipelines);
alias PFNGLGENPROGRAMPIPELINESEXTPROC = void function (GLsizei n, GLuint* pipelines);
alias PFNGLGETPROGRAMPIPELINEINFOLOGEXTPROC = void function (GLuint pipeline, GLsizei bufSize, GLsizei* length, GLchar* infoLog);
alias PFNGLGETPROGRAMPIPELINEIVEXTPROC = void function (GLuint pipeline, GLenum pname, GLint* params);
alias PFNGLISPROGRAMPIPELINEEXTPROC = ubyte function (GLuint pipeline);
alias PFNGLPROGRAMPARAMETERIEXTPROC = void function (GLuint program, GLenum pname, GLint value);
alias PFNGLPROGRAMUNIFORM1FEXTPROC = void function (GLuint program, GLint location, GLfloat v0);
alias PFNGLPROGRAMUNIFORM1FVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLfloat* value);
alias PFNGLPROGRAMUNIFORM1IEXTPROC = void function (GLuint program, GLint location, GLint v0);
alias PFNGLPROGRAMUNIFORM1IVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLint* value);
alias PFNGLPROGRAMUNIFORM2FEXTPROC = void function (GLuint program, GLint location, GLfloat v0, GLfloat v1);
alias PFNGLPROGRAMUNIFORM2FVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLfloat* value);
alias PFNGLPROGRAMUNIFORM2IEXTPROC = void function (GLuint program, GLint location, GLint v0, GLint v1);
alias PFNGLPROGRAMUNIFORM2IVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLint* value);
alias PFNGLPROGRAMUNIFORM3FEXTPROC = void function (GLuint program, GLint location, GLfloat v0, GLfloat v1, GLfloat v2);
alias PFNGLPROGRAMUNIFORM3FVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLfloat* value);
alias PFNGLPROGRAMUNIFORM3IEXTPROC = void function (GLuint program, GLint location, GLint v0, GLint v1, GLint v2);
alias PFNGLPROGRAMUNIFORM3IVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLint* value);
alias PFNGLPROGRAMUNIFORM4FEXTPROC = void function (GLuint program, GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3);
alias PFNGLPROGRAMUNIFORM4FVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLfloat* value);
alias PFNGLPROGRAMUNIFORM4IEXTPROC = void function (GLuint program, GLint location, GLint v0, GLint v1, GLint v2, GLint v3);
alias PFNGLPROGRAMUNIFORM4IVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLint* value);
alias PFNGLPROGRAMUNIFORMMATRIX2FVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat* value);
alias PFNGLPROGRAMUNIFORMMATRIX3FVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat* value);
alias PFNGLPROGRAMUNIFORMMATRIX4FVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat* value);
alias PFNGLUSEPROGRAMSTAGESEXTPROC = void function (GLuint pipeline, GLbitfield stages, GLuint program);
alias PFNGLVALIDATEPROGRAMPIPELINEEXTPROC = void function (GLuint pipeline);
alias PFNGLPROGRAMUNIFORM1UIEXTPROC = void function (GLuint program, GLint location, GLuint v0);
alias PFNGLPROGRAMUNIFORM2UIEXTPROC = void function (GLuint program, GLint location, GLuint v0, GLuint v1);
alias PFNGLPROGRAMUNIFORM3UIEXTPROC = void function (GLuint program, GLint location, GLuint v0, GLuint v1, GLuint v2);
alias PFNGLPROGRAMUNIFORM4UIEXTPROC = void function (GLuint program, GLint location, GLuint v0, GLuint v1, GLuint v2, GLuint v3);
alias PFNGLPROGRAMUNIFORM1UIVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLuint* value);
alias PFNGLPROGRAMUNIFORM2UIVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLuint* value);
alias PFNGLPROGRAMUNIFORM3UIVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLuint* value);
alias PFNGLPROGRAMUNIFORM4UIVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLuint* value);
alias PFNGLPROGRAMUNIFORMMATRIX2X3FVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat* value);
alias PFNGLPROGRAMUNIFORMMATRIX3X2FVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat* value);
alias PFNGLPROGRAMUNIFORMMATRIX2X4FVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat* value);
alias PFNGLPROGRAMUNIFORMMATRIX4X2FVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat* value);
alias PFNGLPROGRAMUNIFORMMATRIX3X4FVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat* value);
alias PFNGLPROGRAMUNIFORMMATRIX4X3FVEXTPROC = void function (GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat* value);

/* GL_EXT_separate_shader_objects */

enum GL_EXT_shader_framebuffer_fetch = 1;
enum GL_FRAGMENT_SHADER_DISCARDS_SAMPLES_EXT = 0x8A52;
/* GL_EXT_shader_framebuffer_fetch */

enum GL_EXT_shader_framebuffer_fetch_non_coherent = 1;
alias PFNGLFRAMEBUFFERFETCHBARRIEREXTPROC = void function ();

/* GL_EXT_shader_framebuffer_fetch_non_coherent */

enum GL_EXT_shader_group_vote = 1;
/* GL_EXT_shader_group_vote */

enum GL_EXT_shader_implicit_conversions = 1;
/* GL_EXT_shader_implicit_conversions */

enum GL_EXT_shader_integer_mix = 1;
/* GL_EXT_shader_integer_mix */

enum GL_EXT_shader_io_blocks = 1;
/* GL_EXT_shader_io_blocks */

enum GL_EXT_shader_non_constant_global_initializers = 1;
/* GL_EXT_shader_non_constant_global_initializers */

enum GL_EXT_shader_pixel_local_storage = 1;
enum GL_MAX_SHADER_PIXEL_LOCAL_STORAGE_FAST_SIZE_EXT = 0x8F63;
enum GL_MAX_SHADER_PIXEL_LOCAL_STORAGE_SIZE_EXT = 0x8F67;
enum GL_SHADER_PIXEL_LOCAL_STORAGE_EXT = 0x8F64;
/* GL_EXT_shader_pixel_local_storage */

enum GL_EXT_shader_pixel_local_storage2 = 1;
enum GL_MAX_SHADER_COMBINED_LOCAL_STORAGE_FAST_SIZE_EXT = 0x9650;
enum GL_MAX_SHADER_COMBINED_LOCAL_STORAGE_SIZE_EXT = 0x9651;
enum GL_FRAMEBUFFER_INCOMPLETE_INSUFFICIENT_SHADER_COMBINED_LOCAL_STORAGE_EXT = 0x9652;
alias PFNGLFRAMEBUFFERPIXELLOCALSTORAGESIZEEXTPROC = void function (GLuint target, GLsizei size);
alias PFNGLGETFRAMEBUFFERPIXELLOCALSTORAGESIZEEXTPROC = int function (GLuint target);
alias PFNGLCLEARPIXELLOCALSTORAGEUIEXTPROC = void function (GLsizei offset, GLsizei n, GLuint* values);

/* GL_EXT_shader_pixel_local_storage2 */

enum GL_EXT_shader_texture_lod = 1;
/* GL_EXT_shader_texture_lod */

enum GL_EXT_shadow_samplers = 1;
enum GL_TEXTURE_COMPARE_MODE_EXT = 0x884C;
enum GL_TEXTURE_COMPARE_FUNC_EXT = 0x884D;
enum GL_COMPARE_REF_TO_TEXTURE_EXT = 0x884E;
enum GL_SAMPLER_2D_SHADOW_EXT = 0x8B62;
/* GL_EXT_shadow_samplers */

enum GL_EXT_sparse_texture = 1;
enum GL_TEXTURE_SPARSE_EXT = 0x91A6;
enum GL_VIRTUAL_PAGE_SIZE_INDEX_EXT = 0x91A7;
enum GL_NUM_SPARSE_LEVELS_EXT = 0x91AA;
enum GL_NUM_VIRTUAL_PAGE_SIZES_EXT = 0x91A8;
enum GL_VIRTUAL_PAGE_SIZE_X_EXT = 0x9195;
enum GL_VIRTUAL_PAGE_SIZE_Y_EXT = 0x9196;
enum GL_VIRTUAL_PAGE_SIZE_Z_EXT = 0x9197;
enum GL_TEXTURE_2D_ARRAY = 0x8C1A;
enum GL_TEXTURE_3D = 0x806F;
enum GL_MAX_SPARSE_TEXTURE_SIZE_EXT = 0x9198;
enum GL_MAX_SPARSE_3D_TEXTURE_SIZE_EXT = 0x9199;
enum GL_MAX_SPARSE_ARRAY_TEXTURE_LAYERS_EXT = 0x919A;
enum GL_SPARSE_TEXTURE_FULL_ARRAY_CUBE_MIPMAPS_EXT = 0x91A9;
alias PFNGLTEXPAGECOMMITMENTEXTPROC = void function (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLboolean commit);

/* GL_EXT_sparse_texture */

enum GL_EXT_sparse_texture2 = 1;
/* GL_EXT_sparse_texture2 */

enum GL_EXT_tessellation_point_size = 1;
/* GL_EXT_tessellation_point_size */

enum GL_EXT_tessellation_shader = 1;
enum GL_PATCHES_EXT = 0x000E;
enum GL_PATCH_VERTICES_EXT = 0x8E72;
enum GL_TESS_CONTROL_OUTPUT_VERTICES_EXT = 0x8E75;
enum GL_TESS_GEN_MODE_EXT = 0x8E76;
enum GL_TESS_GEN_SPACING_EXT = 0x8E77;
enum GL_TESS_GEN_VERTEX_ORDER_EXT = 0x8E78;
enum GL_TESS_GEN_POINT_MODE_EXT = 0x8E79;
enum GL_ISOLINES_EXT = 0x8E7A;
enum GL_QUADS_EXT = 0x0007;
enum GL_FRACTIONAL_ODD_EXT = 0x8E7B;
enum GL_FRACTIONAL_EVEN_EXT = 0x8E7C;
enum GL_MAX_PATCH_VERTICES_EXT = 0x8E7D;
enum GL_MAX_TESS_GEN_LEVEL_EXT = 0x8E7E;
enum GL_MAX_TESS_CONTROL_UNIFORM_COMPONENTS_EXT = 0x8E7F;
enum GL_MAX_TESS_EVALUATION_UNIFORM_COMPONENTS_EXT = 0x8E80;
enum GL_MAX_TESS_CONTROL_TEXTURE_IMAGE_UNITS_EXT = 0x8E81;
enum GL_MAX_TESS_EVALUATION_TEXTURE_IMAGE_UNITS_EXT = 0x8E82;
enum GL_MAX_TESS_CONTROL_OUTPUT_COMPONENTS_EXT = 0x8E83;
enum GL_MAX_TESS_PATCH_COMPONENTS_EXT = 0x8E84;
enum GL_MAX_TESS_CONTROL_TOTAL_OUTPUT_COMPONENTS_EXT = 0x8E85;
enum GL_MAX_TESS_EVALUATION_OUTPUT_COMPONENTS_EXT = 0x8E86;
enum GL_MAX_TESS_CONTROL_UNIFORM_BLOCKS_EXT = 0x8E89;
enum GL_MAX_TESS_EVALUATION_UNIFORM_BLOCKS_EXT = 0x8E8A;
enum GL_MAX_TESS_CONTROL_INPUT_COMPONENTS_EXT = 0x886C;
enum GL_MAX_TESS_EVALUATION_INPUT_COMPONENTS_EXT = 0x886D;
enum GL_MAX_COMBINED_TESS_CONTROL_UNIFORM_COMPONENTS_EXT = 0x8E1E;
enum GL_MAX_COMBINED_TESS_EVALUATION_UNIFORM_COMPONENTS_EXT = 0x8E1F;
enum GL_MAX_TESS_CONTROL_ATOMIC_COUNTER_BUFFERS_EXT = 0x92CD;
enum GL_MAX_TESS_EVALUATION_ATOMIC_COUNTER_BUFFERS_EXT = 0x92CE;
enum GL_MAX_TESS_CONTROL_ATOMIC_COUNTERS_EXT = 0x92D3;
enum GL_MAX_TESS_EVALUATION_ATOMIC_COUNTERS_EXT = 0x92D4;
enum GL_MAX_TESS_CONTROL_IMAGE_UNIFORMS_EXT = 0x90CB;
enum GL_MAX_TESS_EVALUATION_IMAGE_UNIFORMS_EXT = 0x90CC;
enum GL_MAX_TESS_CONTROL_SHADER_STORAGE_BLOCKS_EXT = 0x90D8;
enum GL_MAX_TESS_EVALUATION_SHADER_STORAGE_BLOCKS_EXT = 0x90D9;
enum GL_PRIMITIVE_RESTART_FOR_PATCHES_SUPPORTED = 0x8221;
enum GL_IS_PER_PATCH_EXT = 0x92E7;
enum GL_REFERENCED_BY_TESS_CONTROL_SHADER_EXT = 0x9307;
enum GL_REFERENCED_BY_TESS_EVALUATION_SHADER_EXT = 0x9308;
enum GL_TESS_CONTROL_SHADER_EXT = 0x8E88;
enum GL_TESS_EVALUATION_SHADER_EXT = 0x8E87;
enum GL_TESS_CONTROL_SHADER_BIT_EXT = 0x00000008;
enum GL_TESS_EVALUATION_SHADER_BIT_EXT = 0x00000010;
alias PFNGLPATCHPARAMETERIEXTPROC = void function (GLenum pname, GLint value);

/* GL_EXT_tessellation_shader */

enum GL_EXT_texture_border_clamp = 1;
enum GL_TEXTURE_BORDER_COLOR_EXT = 0x1004;
enum GL_CLAMP_TO_BORDER_EXT = 0x812D;
alias PFNGLTEXPARAMETERIIVEXTPROC = void function (GLenum target, GLenum pname, GLint* params);
alias PFNGLTEXPARAMETERIUIVEXTPROC = void function (GLenum target, GLenum pname, GLuint* params);
alias PFNGLGETTEXPARAMETERIIVEXTPROC = void function (GLenum target, GLenum pname, GLint* params);
alias PFNGLGETTEXPARAMETERIUIVEXTPROC = void function (GLenum target, GLenum pname, GLuint* params);
alias PFNGLSAMPLERPARAMETERIIVEXTPROC = void function (GLuint sampler, GLenum pname, GLint* param);
alias PFNGLSAMPLERPARAMETERIUIVEXTPROC = void function (GLuint sampler, GLenum pname, GLuint* param);
alias PFNGLGETSAMPLERPARAMETERIIVEXTPROC = void function (GLuint sampler, GLenum pname, GLint* params);
alias PFNGLGETSAMPLERPARAMETERIUIVEXTPROC = void function (GLuint sampler, GLenum pname, GLuint* params);

/* GL_EXT_texture_border_clamp */

enum GL_EXT_texture_buffer = 1;
enum GL_TEXTURE_BUFFER_EXT = 0x8C2A;
enum GL_TEXTURE_BUFFER_BINDING_EXT = 0x8C2A;
enum GL_MAX_TEXTURE_BUFFER_SIZE_EXT = 0x8C2B;
enum GL_TEXTURE_BINDING_BUFFER_EXT = 0x8C2C;
enum GL_TEXTURE_BUFFER_DATA_STORE_BINDING_EXT = 0x8C2D;
enum GL_TEXTURE_BUFFER_OFFSET_ALIGNMENT_EXT = 0x919F;
enum GL_SAMPLER_BUFFER_EXT = 0x8DC2;
enum GL_INT_SAMPLER_BUFFER_EXT = 0x8DD0;
enum GL_UNSIGNED_INT_SAMPLER_BUFFER_EXT = 0x8DD8;
enum GL_IMAGE_BUFFER_EXT = 0x9051;
enum GL_INT_IMAGE_BUFFER_EXT = 0x905C;
enum GL_UNSIGNED_INT_IMAGE_BUFFER_EXT = 0x9067;
enum GL_TEXTURE_BUFFER_OFFSET_EXT = 0x919D;
enum GL_TEXTURE_BUFFER_SIZE_EXT = 0x919E;
alias PFNGLTEXBUFFEREXTPROC = void function (GLenum target, GLenum internalformat, GLuint buffer);
alias PFNGLTEXBUFFERRANGEEXTPROC = void function (GLenum target, GLenum internalformat, GLuint buffer, GLintptr offset, GLsizeiptr size);

/* GL_EXT_texture_buffer */

enum GL_EXT_texture_compression_astc_decode_mode = 1;
enum GL_TEXTURE_ASTC_DECODE_PRECISION_EXT = 0x8F69;
/* GL_EXT_texture_compression_astc_decode_mode */

enum GL_EXT_texture_compression_bptc = 1;
enum GL_COMPRESSED_RGBA_BPTC_UNORM_EXT = 0x8E8C;
enum GL_COMPRESSED_SRGB_ALPHA_BPTC_UNORM_EXT = 0x8E8D;
enum GL_COMPRESSED_RGB_BPTC_SIGNED_FLOAT_EXT = 0x8E8E;
enum GL_COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT_EXT = 0x8E8F;
/* GL_EXT_texture_compression_bptc */

enum GL_EXT_texture_compression_dxt1 = 1;
enum GL_COMPRESSED_RGB_S3TC_DXT1_EXT = 0x83F0;
enum GL_COMPRESSED_RGBA_S3TC_DXT1_EXT = 0x83F1;
/* GL_EXT_texture_compression_dxt1 */

enum GL_EXT_texture_compression_rgtc = 1;
enum GL_COMPRESSED_RED_RGTC1_EXT = 0x8DBB;
enum GL_COMPRESSED_SIGNED_RED_RGTC1_EXT = 0x8DBC;
enum GL_COMPRESSED_RED_GREEN_RGTC2_EXT = 0x8DBD;
enum GL_COMPRESSED_SIGNED_RED_GREEN_RGTC2_EXT = 0x8DBE;
/* GL_EXT_texture_compression_rgtc */

enum GL_EXT_texture_compression_s3tc = 1;
enum GL_COMPRESSED_RGBA_S3TC_DXT3_EXT = 0x83F2;
enum GL_COMPRESSED_RGBA_S3TC_DXT5_EXT = 0x83F3;
/* GL_EXT_texture_compression_s3tc */

enum GL_EXT_texture_compression_s3tc_srgb = 1;
enum GL_COMPRESSED_SRGB_S3TC_DXT1_EXT = 0x8C4C;
enum GL_COMPRESSED_SRGB_ALPHA_S3TC_DXT1_EXT = 0x8C4D;
enum GL_COMPRESSED_SRGB_ALPHA_S3TC_DXT3_EXT = 0x8C4E;
enum GL_COMPRESSED_SRGB_ALPHA_S3TC_DXT5_EXT = 0x8C4F;
/* GL_EXT_texture_compression_s3tc_srgb */

enum GL_EXT_texture_cube_map_array = 1;
enum GL_TEXTURE_CUBE_MAP_ARRAY_EXT = 0x9009;
enum GL_TEXTURE_BINDING_CUBE_MAP_ARRAY_EXT = 0x900A;
enum GL_SAMPLER_CUBE_MAP_ARRAY_EXT = 0x900C;
enum GL_SAMPLER_CUBE_MAP_ARRAY_SHADOW_EXT = 0x900D;
enum GL_INT_SAMPLER_CUBE_MAP_ARRAY_EXT = 0x900E;
enum GL_UNSIGNED_INT_SAMPLER_CUBE_MAP_ARRAY_EXT = 0x900F;
enum GL_IMAGE_CUBE_MAP_ARRAY_EXT = 0x9054;
enum GL_INT_IMAGE_CUBE_MAP_ARRAY_EXT = 0x905F;
enum GL_UNSIGNED_INT_IMAGE_CUBE_MAP_ARRAY_EXT = 0x906A;
/* GL_EXT_texture_cube_map_array */

enum GL_EXT_texture_filter_anisotropic = 1;
enum GL_TEXTURE_MAX_ANISOTROPY_EXT = 0x84FE;
enum GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT = 0x84FF;
/* GL_EXT_texture_filter_anisotropic */

enum GL_EXT_texture_filter_minmax = 1;
enum GL_TEXTURE_REDUCTION_MODE_EXT = 0x9366;
enum GL_WEIGHTED_AVERAGE_EXT = 0x9367;
/* GL_EXT_texture_filter_minmax */

enum GL_EXT_texture_format_BGRA8888 = 1;
/* GL_EXT_texture_format_BGRA8888 */

enum GL_EXT_texture_format_sRGB_override = 1;
enum GL_TEXTURE_FORMAT_SRGB_OVERRIDE_EXT = 0x8FBF;
/* GL_EXT_texture_format_sRGB_override */

enum GL_EXT_texture_mirror_clamp_to_edge = 1;
enum GL_MIRROR_CLAMP_TO_EDGE_EXT = 0x8743;
/* GL_EXT_texture_mirror_clamp_to_edge */

enum GL_EXT_texture_norm16 = 1;
enum GL_R16_EXT = 0x822A;
enum GL_RG16_EXT = 0x822C;
enum GL_RGBA16_EXT = 0x805B;
enum GL_RGB16_EXT = 0x8054;
enum GL_RGB16_SNORM_EXT = 0x8F9A;
/* GL_EXT_texture_norm16 */

enum GL_EXT_texture_query_lod = 1;
/* GL_EXT_texture_query_lod */

enum GL_EXT_texture_rg = 1;
enum GL_RED_EXT = 0x1903;
enum GL_RG_EXT = 0x8227;
enum GL_R8_EXT = 0x8229;
enum GL_RG8_EXT = 0x822B;
/* GL_EXT_texture_rg */

enum GL_EXT_texture_sRGB_R8 = 1;
enum GL_SR8_EXT = 0x8FBD;
/* GL_EXT_texture_sRGB_R8 */

enum GL_EXT_texture_sRGB_RG8 = 1;
enum GL_SRG8_EXT = 0x8FBE;
/* GL_EXT_texture_sRGB_RG8 */

enum GL_EXT_texture_sRGB_decode = 1;
enum GL_TEXTURE_SRGB_DECODE_EXT = 0x8A48;
enum GL_DECODE_EXT = 0x8A49;
enum GL_SKIP_DECODE_EXT = 0x8A4A;
/* GL_EXT_texture_sRGB_decode */

enum GL_EXT_texture_shadow_lod = 1;
/* GL_EXT_texture_shadow_lod */

enum GL_EXT_texture_storage = 1;
enum GL_TEXTURE_IMMUTABLE_FORMAT_EXT = 0x912F;
enum GL_ALPHA8_EXT = 0x803C;
enum GL_LUMINANCE8_EXT = 0x8040;
enum GL_LUMINANCE8_ALPHA8_EXT = 0x8045;
enum GL_RGBA32F_EXT = 0x8814;
enum GL_RGB32F_EXT = 0x8815;
enum GL_ALPHA32F_EXT = 0x8816;
enum GL_LUMINANCE32F_EXT = 0x8818;
enum GL_LUMINANCE_ALPHA32F_EXT = 0x8819;
enum GL_ALPHA16F_EXT = 0x881C;
enum GL_LUMINANCE16F_EXT = 0x881E;
enum GL_LUMINANCE_ALPHA16F_EXT = 0x881F;
enum GL_R32F_EXT = 0x822E;
enum GL_RG32F_EXT = 0x8230;
alias PFNGLTEXSTORAGE1DEXTPROC = void function (GLenum target, GLsizei levels, GLenum internalformat, GLsizei width);
alias PFNGLTEXSTORAGE2DEXTPROC = void function (GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height);
alias PFNGLTEXSTORAGE3DEXTPROC = void function (GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth);
alias PFNGLTEXTURESTORAGE1DEXTPROC = void function (GLuint texture, GLenum target, GLsizei levels, GLenum internalformat, GLsizei width);
alias PFNGLTEXTURESTORAGE2DEXTPROC = void function (GLuint texture, GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height);
alias PFNGLTEXTURESTORAGE3DEXTPROC = void function (GLuint texture, GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth);

/* GL_EXT_texture_storage */

enum GL_EXT_texture_type_2_10_10_10_REV = 1;
enum GL_UNSIGNED_INT_2_10_10_10_REV_EXT = 0x8368;
/* GL_EXT_texture_type_2_10_10_10_REV */

enum GL_EXT_texture_view = 1;
enum GL_TEXTURE_VIEW_MIN_LEVEL_EXT = 0x82DB;
enum GL_TEXTURE_VIEW_NUM_LEVELS_EXT = 0x82DC;
enum GL_TEXTURE_VIEW_MIN_LAYER_EXT = 0x82DD;
enum GL_TEXTURE_VIEW_NUM_LAYERS_EXT = 0x82DE;
alias PFNGLTEXTUREVIEWEXTPROC = void function (GLuint texture, GLenum target, GLuint origtexture, GLenum internalformat, GLuint minlevel, GLuint numlevels, GLuint minlayer, GLuint numlayers);

/* GL_EXT_texture_view */

enum GL_EXT_unpack_subimage = 1;
enum GL_UNPACK_ROW_LENGTH_EXT = 0x0CF2;
enum GL_UNPACK_SKIP_ROWS_EXT = 0x0CF3;
enum GL_UNPACK_SKIP_PIXELS_EXT = 0x0CF4;
/* GL_EXT_unpack_subimage */

enum GL_EXT_win32_keyed_mutex = 1;
alias PFNGLACQUIREKEYEDMUTEXWIN32EXTPROC = ubyte function (GLuint memory, GLuint64 key, GLuint timeout);
alias PFNGLRELEASEKEYEDMUTEXWIN32EXTPROC = ubyte function (GLuint memory, GLuint64 key);

/* GL_EXT_win32_keyed_mutex */

enum GL_EXT_window_rectangles = 1;
enum GL_INCLUSIVE_EXT = 0x8F10;
enum GL_EXCLUSIVE_EXT = 0x8F11;
enum GL_WINDOW_RECTANGLE_EXT = 0x8F12;
enum GL_WINDOW_RECTANGLE_MODE_EXT = 0x8F13;
enum GL_MAX_WINDOW_RECTANGLES_EXT = 0x8F14;
enum GL_NUM_WINDOW_RECTANGLES_EXT = 0x8F15;
alias PFNGLWINDOWRECTANGLESEXTPROC = void function (GLenum mode, GLsizei count, GLint* box);

/* GL_EXT_window_rectangles */

enum GL_FJ_shader_binary_GCCSO = 1;
enum GL_GCCSO_SHADER_BINARY_FJ = 0x9260;
/* GL_FJ_shader_binary_GCCSO */

enum GL_IMG_bindless_texture = 1;
alias PFNGLGETTEXTUREHANDLEIMGPROC = ulong function (GLuint texture);
alias PFNGLGETTEXTURESAMPLERHANDLEIMGPROC = ulong function (GLuint texture, GLuint sampler);
alias PFNGLUNIFORMHANDLEUI64IMGPROC = void function (GLint location, GLuint64 value);
alias PFNGLUNIFORMHANDLEUI64VIMGPROC = void function (GLint location, GLsizei count, GLuint64* value);
alias PFNGLPROGRAMUNIFORMHANDLEUI64IMGPROC = void function (GLuint program, GLint location, GLuint64 value);
alias PFNGLPROGRAMUNIFORMHANDLEUI64VIMGPROC = void function (GLuint program, GLint location, GLsizei count, GLuint64* values);

/* GL_IMG_bindless_texture */

enum GL_IMG_framebuffer_downsample = 1;
enum GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE_AND_DOWNSAMPLE_IMG = 0x913C;
enum GL_NUM_DOWNSAMPLE_SCALES_IMG = 0x913D;
enum GL_DOWNSAMPLE_SCALES_IMG = 0x913E;
enum GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_SCALE_IMG = 0x913F;
alias PFNGLFRAMEBUFFERTEXTURE2DDOWNSAMPLEIMGPROC = void function (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLint xscale, GLint yscale);
alias PFNGLFRAMEBUFFERTEXTURELAYERDOWNSAMPLEIMGPROC = void function (GLenum target, GLenum attachment, GLuint texture, GLint level, GLint layer, GLint xscale, GLint yscale);

/* GL_IMG_framebuffer_downsample */

enum GL_IMG_multisampled_render_to_texture = 1;
enum GL_RENDERBUFFER_SAMPLES_IMG = 0x9133;
enum GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE_IMG = 0x9134;
enum GL_MAX_SAMPLES_IMG = 0x9135;
enum GL_TEXTURE_SAMPLES_IMG = 0x9136;
alias PFNGLRENDERBUFFERSTORAGEMULTISAMPLEIMGPROC = void function (GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height);
alias PFNGLFRAMEBUFFERTEXTURE2DMULTISAMPLEIMGPROC = void function (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLsizei samples);

/* GL_IMG_multisampled_render_to_texture */

enum GL_IMG_program_binary = 1;
enum GL_SGX_PROGRAM_BINARY_IMG = 0x9130;
/* GL_IMG_program_binary */

enum GL_IMG_read_format = 1;
enum GL_BGRA_IMG = 0x80E1;
enum GL_UNSIGNED_SHORT_4_4_4_4_REV_IMG = 0x8365;
/* GL_IMG_read_format */

enum GL_IMG_shader_binary = 1;
enum GL_SGX_BINARY_IMG = 0x8C0A;
/* GL_IMG_shader_binary */

enum GL_IMG_texture_compression_pvrtc = 1;
enum GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG = 0x8C00;
enum GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG = 0x8C01;
enum GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG = 0x8C02;
enum GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG = 0x8C03;
/* GL_IMG_texture_compression_pvrtc */

enum GL_IMG_texture_compression_pvrtc2 = 1;
enum GL_COMPRESSED_RGBA_PVRTC_2BPPV2_IMG = 0x9137;
enum GL_COMPRESSED_RGBA_PVRTC_4BPPV2_IMG = 0x9138;
/* GL_IMG_texture_compression_pvrtc2 */

enum GL_IMG_texture_filter_cubic = 1;
enum GL_CUBIC_IMG = 0x9139;
enum GL_CUBIC_MIPMAP_NEAREST_IMG = 0x913A;
enum GL_CUBIC_MIPMAP_LINEAR_IMG = 0x913B;
/* GL_IMG_texture_filter_cubic */

enum GL_INTEL_blackhole_render = 1;
enum GL_BLACKHOLE_RENDER_INTEL = 0x83FC;
/* GL_INTEL_blackhole_render */

enum GL_INTEL_conservative_rasterization = 1;
enum GL_CONSERVATIVE_RASTERIZATION_INTEL = 0x83FE;
/* GL_INTEL_conservative_rasterization */

enum GL_INTEL_framebuffer_CMAA = 1;
alias PFNGLAPPLYFRAMEBUFFERATTACHMENTCMAAINTELPROC = void function ();

/* GL_INTEL_framebuffer_CMAA */

enum GL_INTEL_performance_query = 1;
enum GL_PERFQUERY_SINGLE_CONTEXT_INTEL = 0x00000000;
enum GL_PERFQUERY_GLOBAL_CONTEXT_INTEL = 0x00000001;
enum GL_PERFQUERY_WAIT_INTEL = 0x83FB;
enum GL_PERFQUERY_FLUSH_INTEL = 0x83FA;
enum GL_PERFQUERY_DONOT_FLUSH_INTEL = 0x83F9;
enum GL_PERFQUERY_COUNTER_EVENT_INTEL = 0x94F0;
enum GL_PERFQUERY_COUNTER_DURATION_NORM_INTEL = 0x94F1;
enum GL_PERFQUERY_COUNTER_DURATION_RAW_INTEL = 0x94F2;
enum GL_PERFQUERY_COUNTER_THROUGHPUT_INTEL = 0x94F3;
enum GL_PERFQUERY_COUNTER_RAW_INTEL = 0x94F4;
enum GL_PERFQUERY_COUNTER_TIMESTAMP_INTEL = 0x94F5;
enum GL_PERFQUERY_COUNTER_DATA_UINT32_INTEL = 0x94F8;
enum GL_PERFQUERY_COUNTER_DATA_UINT64_INTEL = 0x94F9;
enum GL_PERFQUERY_COUNTER_DATA_FLOAT_INTEL = 0x94FA;
enum GL_PERFQUERY_COUNTER_DATA_DOUBLE_INTEL = 0x94FB;
enum GL_PERFQUERY_COUNTER_DATA_BOOL32_INTEL = 0x94FC;
enum GL_PERFQUERY_QUERY_NAME_LENGTH_MAX_INTEL = 0x94FD;
enum GL_PERFQUERY_COUNTER_NAME_LENGTH_MAX_INTEL = 0x94FE;
enum GL_PERFQUERY_COUNTER_DESC_LENGTH_MAX_INTEL = 0x94FF;
enum GL_PERFQUERY_GPA_EXTENDED_COUNTERS_INTEL = 0x9500;
alias PFNGLBEGINPERFQUERYINTELPROC = void function (GLuint queryHandle);
alias PFNGLCREATEPERFQUERYINTELPROC = void function (GLuint queryId, GLuint* queryHandle);
alias PFNGLDELETEPERFQUERYINTELPROC = void function (GLuint queryHandle);
alias PFNGLENDPERFQUERYINTELPROC = void function (GLuint queryHandle);
alias PFNGLGETFIRSTPERFQUERYIDINTELPROC = void function (GLuint* queryId);
alias PFNGLGETNEXTPERFQUERYIDINTELPROC = void function (GLuint queryId, GLuint* nextQueryId);
alias PFNGLGETPERFCOUNTERINFOINTELPROC = void function (GLuint queryId, GLuint counterId, GLuint counterNameLength, GLchar* counterName, GLuint counterDescLength, GLchar* counterDesc, GLuint* counterOffset, GLuint* counterDataSize, GLuint* counterTypeEnum, GLuint* counterDataTypeEnum, GLuint64* rawCounterMaxValue);
alias PFNGLGETPERFQUERYDATAINTELPROC = void function (GLuint queryHandle, GLuint flags, GLsizei dataSize, void* data, GLuint* bytesWritten);
alias PFNGLGETPERFQUERYIDBYNAMEINTELPROC = void function (GLchar* queryName, GLuint* queryId);
alias PFNGLGETPERFQUERYINFOINTELPROC = void function (GLuint queryId, GLuint queryNameLength, GLchar* queryName, GLuint* dataSize, GLuint* noCounters, GLuint* noInstances, GLuint* capsMask);

/* GL_INTEL_performance_query */

enum GL_MESA_framebuffer_flip_x = 1;
enum GL_FRAMEBUFFER_FLIP_X_MESA = 0x8BBC;
/* GL_MESA_framebuffer_flip_x */

enum GL_MESA_framebuffer_flip_y = 1;
enum GL_FRAMEBUFFER_FLIP_Y_MESA = 0x8BBB;
alias PFNGLFRAMEBUFFERPARAMETERIMESAPROC = void function (GLenum target, GLenum pname, GLint param);
alias PFNGLGETFRAMEBUFFERPARAMETERIVMESAPROC = void function (GLenum target, GLenum pname, GLint* params);

/* GL_MESA_framebuffer_flip_y */

enum GL_MESA_framebuffer_swap_xy = 1;
enum GL_FRAMEBUFFER_SWAP_XY_MESA = 0x8BBD;
/* GL_MESA_framebuffer_swap_xy */

enum GL_MESA_program_binary_formats = 1;
enum GL_PROGRAM_BINARY_FORMAT_MESA = 0x875F;
/* GL_MESA_program_binary_formats */

enum GL_MESA_shader_integer_functions = 1;
/* GL_MESA_shader_integer_functions */

enum GL_NVX_blend_equation_advanced_multi_draw_buffers = 1;
/* GL_NVX_blend_equation_advanced_multi_draw_buffers */

enum GL_NV_bindless_texture = 1;
alias PFNGLGETTEXTUREHANDLENVPROC = ulong function (GLuint texture);
alias PFNGLGETTEXTURESAMPLERHANDLENVPROC = ulong function (GLuint texture, GLuint sampler);
alias PFNGLMAKETEXTUREHANDLERESIDENTNVPROC = void function (GLuint64 handle);
alias PFNGLMAKETEXTUREHANDLENONRESIDENTNVPROC = void function (GLuint64 handle);
alias PFNGLGETIMAGEHANDLENVPROC = ulong function (GLuint texture, GLint level, GLboolean layered, GLint layer, GLenum format);
alias PFNGLMAKEIMAGEHANDLERESIDENTNVPROC = void function (GLuint64 handle, GLenum access);
alias PFNGLMAKEIMAGEHANDLENONRESIDENTNVPROC = void function (GLuint64 handle);
alias PFNGLUNIFORMHANDLEUI64NVPROC = void function (GLint location, GLuint64 value);
alias PFNGLUNIFORMHANDLEUI64VNVPROC = void function (GLint location, GLsizei count, GLuint64* value);
alias PFNGLPROGRAMUNIFORMHANDLEUI64NVPROC = void function (GLuint program, GLint location, GLuint64 value);
alias PFNGLPROGRAMUNIFORMHANDLEUI64VNVPROC = void function (GLuint program, GLint location, GLsizei count, GLuint64* values);
alias PFNGLISTEXTUREHANDLERESIDENTNVPROC = ubyte function (GLuint64 handle);
alias PFNGLISIMAGEHANDLERESIDENTNVPROC = ubyte function (GLuint64 handle);

/* GL_NV_bindless_texture */

enum GL_NV_blend_equation_advanced = 1;
enum GL_BLEND_OVERLAP_NV = 0x9281;
enum GL_BLEND_PREMULTIPLIED_SRC_NV = 0x9280;
enum GL_BLUE_NV = 0x1905;
enum GL_COLORBURN_NV = 0x929A;
enum GL_COLORDODGE_NV = 0x9299;
enum GL_CONJOINT_NV = 0x9284;
enum GL_CONTRAST_NV = 0x92A1;
enum GL_DARKEN_NV = 0x9297;
enum GL_DIFFERENCE_NV = 0x929E;
enum GL_DISJOINT_NV = 0x9283;
enum GL_DST_ATOP_NV = 0x928F;
enum GL_DST_IN_NV = 0x928B;
enum GL_DST_NV = 0x9287;
enum GL_DST_OUT_NV = 0x928D;
enum GL_DST_OVER_NV = 0x9289;
enum GL_EXCLUSION_NV = 0x92A0;
enum GL_GREEN_NV = 0x1904;
enum GL_HARDLIGHT_NV = 0x929B;
enum GL_HARDMIX_NV = 0x92A9;
enum GL_HSL_COLOR_NV = 0x92AF;
enum GL_HSL_HUE_NV = 0x92AD;
enum GL_HSL_LUMINOSITY_NV = 0x92B0;
enum GL_HSL_SATURATION_NV = 0x92AE;
enum GL_INVERT_OVG_NV = 0x92B4;
enum GL_INVERT_RGB_NV = 0x92A3;
enum GL_LIGHTEN_NV = 0x9298;
enum GL_LINEARBURN_NV = 0x92A5;
enum GL_LINEARDODGE_NV = 0x92A4;
enum GL_LINEARLIGHT_NV = 0x92A7;
enum GL_MINUS_CLAMPED_NV = 0x92B3;
enum GL_MINUS_NV = 0x929F;
enum GL_MULTIPLY_NV = 0x9294;
enum GL_OVERLAY_NV = 0x9296;
enum GL_PINLIGHT_NV = 0x92A8;
enum GL_PLUS_CLAMPED_ALPHA_NV = 0x92B2;
enum GL_PLUS_CLAMPED_NV = 0x92B1;
enum GL_PLUS_DARKER_NV = 0x9292;
enum GL_PLUS_NV = 0x9291;
enum GL_RED_NV = 0x1903;
enum GL_SCREEN_NV = 0x9295;
enum GL_SOFTLIGHT_NV = 0x929C;
enum GL_SRC_ATOP_NV = 0x928E;
enum GL_SRC_IN_NV = 0x928A;
enum GL_SRC_NV = 0x9286;
enum GL_SRC_OUT_NV = 0x928C;
enum GL_SRC_OVER_NV = 0x9288;
enum GL_UNCORRELATED_NV = 0x9282;
enum GL_VIVIDLIGHT_NV = 0x92A6;
enum GL_XOR_NV = 0x1506;
alias PFNGLBLENDPARAMETERINVPROC = void function (GLenum pname, GLint value);
alias PFNGLBLENDBARRIERNVPROC = void function ();

/* GL_NV_blend_equation_advanced */

enum GL_NV_blend_equation_advanced_coherent = 1;
enum GL_BLEND_ADVANCED_COHERENT_NV = 0x9285;
/* GL_NV_blend_equation_advanced_coherent */

enum GL_NV_blend_minmax_factor = 1;
enum GL_FACTOR_MIN_AMD = 0x901C;
enum GL_FACTOR_MAX_AMD = 0x901D;
/* GL_NV_blend_minmax_factor */

enum GL_NV_clip_space_w_scaling = 1;
enum GL_VIEWPORT_POSITION_W_SCALE_NV = 0x937C;
enum GL_VIEWPORT_POSITION_W_SCALE_X_COEFF_NV = 0x937D;
enum GL_VIEWPORT_POSITION_W_SCALE_Y_COEFF_NV = 0x937E;
alias PFNGLVIEWPORTPOSITIONWSCALENVPROC = void function (GLuint index, GLfloat xcoeff, GLfloat ycoeff);

/* GL_NV_clip_space_w_scaling */

enum GL_NV_compute_shader_derivatives = 1;
/* GL_NV_compute_shader_derivatives */

enum GL_NV_conditional_render = 1;
enum GL_QUERY_WAIT_NV = 0x8E13;
enum GL_QUERY_NO_WAIT_NV = 0x8E14;
enum GL_QUERY_BY_REGION_WAIT_NV = 0x8E15;
enum GL_QUERY_BY_REGION_NO_WAIT_NV = 0x8E16;
alias PFNGLBEGINCONDITIONALRENDERNVPROC = void function (GLuint id, GLenum mode);
alias PFNGLENDCONDITIONALRENDERNVPROC = void function ();

/* GL_NV_conditional_render */

enum GL_NV_conservative_raster = 1;
enum GL_CONSERVATIVE_RASTERIZATION_NV = 0x9346;
enum GL_SUBPIXEL_PRECISION_BIAS_X_BITS_NV = 0x9347;
enum GL_SUBPIXEL_PRECISION_BIAS_Y_BITS_NV = 0x9348;
enum GL_MAX_SUBPIXEL_PRECISION_BIAS_BITS_NV = 0x9349;
alias PFNGLSUBPIXELPRECISIONBIASNVPROC = void function (GLuint xbits, GLuint ybits);

/* GL_NV_conservative_raster */

enum GL_NV_conservative_raster_pre_snap = 1;
enum GL_CONSERVATIVE_RASTER_MODE_PRE_SNAP_NV = 0x9550;
/* GL_NV_conservative_raster_pre_snap */

enum GL_NV_conservative_raster_pre_snap_triangles = 1;
enum GL_CONSERVATIVE_RASTER_MODE_NV = 0x954D;
enum GL_CONSERVATIVE_RASTER_MODE_POST_SNAP_NV = 0x954E;
enum GL_CONSERVATIVE_RASTER_MODE_PRE_SNAP_TRIANGLES_NV = 0x954F;
alias PFNGLCONSERVATIVERASTERPARAMETERINVPROC = void function (GLenum pname, GLint param);

/* GL_NV_conservative_raster_pre_snap_triangles */

enum GL_NV_copy_buffer = 1;
enum GL_COPY_READ_BUFFER_NV = 0x8F36;
enum GL_COPY_WRITE_BUFFER_NV = 0x8F37;
alias PFNGLCOPYBUFFERSUBDATANVPROC = void function (GLenum readTarget, GLenum writeTarget, GLintptr readOffset, GLintptr writeOffset, GLsizeiptr size);

/* GL_NV_copy_buffer */

enum GL_NV_coverage_sample = 1;
enum GL_COVERAGE_COMPONENT_NV = 0x8ED0;
enum GL_COVERAGE_COMPONENT4_NV = 0x8ED1;
enum GL_COVERAGE_ATTACHMENT_NV = 0x8ED2;
enum GL_COVERAGE_BUFFERS_NV = 0x8ED3;
enum GL_COVERAGE_SAMPLES_NV = 0x8ED4;
enum GL_COVERAGE_ALL_FRAGMENTS_NV = 0x8ED5;
enum GL_COVERAGE_EDGE_FRAGMENTS_NV = 0x8ED6;
enum GL_COVERAGE_AUTOMATIC_NV = 0x8ED7;
enum GL_COVERAGE_BUFFER_BIT_NV = 0x00008000;
alias PFNGLCOVERAGEMASKNVPROC = void function (GLboolean mask);
alias PFNGLCOVERAGEOPERATIONNVPROC = void function (GLenum operation);

/* GL_NV_coverage_sample */

enum GL_NV_depth_nonlinear = 1;
enum GL_DEPTH_COMPONENT16_NONLINEAR_NV = 0x8E2C;
/* GL_NV_depth_nonlinear */

enum GL_NV_draw_buffers = 1;
enum GL_MAX_DRAW_BUFFERS_NV = 0x8824;
enum GL_DRAW_BUFFER0_NV = 0x8825;
enum GL_DRAW_BUFFER1_NV = 0x8826;
enum GL_DRAW_BUFFER2_NV = 0x8827;
enum GL_DRAW_BUFFER3_NV = 0x8828;
enum GL_DRAW_BUFFER4_NV = 0x8829;
enum GL_DRAW_BUFFER5_NV = 0x882A;
enum GL_DRAW_BUFFER6_NV = 0x882B;
enum GL_DRAW_BUFFER7_NV = 0x882C;
enum GL_DRAW_BUFFER8_NV = 0x882D;
enum GL_DRAW_BUFFER9_NV = 0x882E;
enum GL_DRAW_BUFFER10_NV = 0x882F;
enum GL_DRAW_BUFFER11_NV = 0x8830;
enum GL_DRAW_BUFFER12_NV = 0x8831;
enum GL_DRAW_BUFFER13_NV = 0x8832;
enum GL_DRAW_BUFFER14_NV = 0x8833;
enum GL_DRAW_BUFFER15_NV = 0x8834;
enum GL_COLOR_ATTACHMENT0_NV = 0x8CE0;
enum GL_COLOR_ATTACHMENT1_NV = 0x8CE1;
enum GL_COLOR_ATTACHMENT2_NV = 0x8CE2;
enum GL_COLOR_ATTACHMENT3_NV = 0x8CE3;
enum GL_COLOR_ATTACHMENT4_NV = 0x8CE4;
enum GL_COLOR_ATTACHMENT5_NV = 0x8CE5;
enum GL_COLOR_ATTACHMENT6_NV = 0x8CE6;
enum GL_COLOR_ATTACHMENT7_NV = 0x8CE7;
enum GL_COLOR_ATTACHMENT8_NV = 0x8CE8;
enum GL_COLOR_ATTACHMENT9_NV = 0x8CE9;
enum GL_COLOR_ATTACHMENT10_NV = 0x8CEA;
enum GL_COLOR_ATTACHMENT11_NV = 0x8CEB;
enum GL_COLOR_ATTACHMENT12_NV = 0x8CEC;
enum GL_COLOR_ATTACHMENT13_NV = 0x8CED;
enum GL_COLOR_ATTACHMENT14_NV = 0x8CEE;
enum GL_COLOR_ATTACHMENT15_NV = 0x8CEF;
alias PFNGLDRAWBUFFERSNVPROC = void function (GLsizei n, GLenum* bufs);

/* GL_NV_draw_buffers */

enum GL_NV_draw_instanced = 1;
alias PFNGLDRAWARRAYSINSTANCEDNVPROC = void function (GLenum mode, GLint first, GLsizei count, GLsizei primcount);
alias PFNGLDRAWELEMENTSINSTANCEDNVPROC = void function (GLenum mode, GLsizei count, GLenum type, void* indices, GLsizei primcount);

/* GL_NV_draw_instanced */

enum GL_NV_draw_vulkan_image = 1;
alias GLVULKANPROCNV = void function ();
alias PFNGLDRAWVKIMAGENVPROC = void function (GLuint64 vkImage, GLuint sampler, GLfloat x0, GLfloat y0, GLfloat x1, GLfloat y1, GLfloat z, GLfloat s0, GLfloat t0, GLfloat s1, GLfloat t1);
alias PFNGLGETVKPROCADDRNVPROC = void function (GLchar* name) function (GLchar* name);
alias PFNGLWAITVKSEMAPHORENVPROC = void function (GLuint64 vkSemaphore);
alias PFNGLSIGNALVKSEMAPHORENVPROC = void function (GLuint64 vkSemaphore);
alias PFNGLSIGNALVKFENCENVPROC = void function (GLuint64 vkFence);

/* GL_NV_draw_vulkan_image */

enum GL_NV_explicit_attrib_location = 1;
/* GL_NV_explicit_attrib_location */

enum GL_NV_fbo_color_attachments = 1;
enum GL_MAX_COLOR_ATTACHMENTS_NV = 0x8CDF;
/* GL_NV_fbo_color_attachments */

enum GL_NV_fence = 1;
enum GL_ALL_COMPLETED_NV = 0x84F2;
enum GL_FENCE_STATUS_NV = 0x84F3;
enum GL_FENCE_CONDITION_NV = 0x84F4;
alias PFNGLDELETEFENCESNVPROC = void function (GLsizei n, GLuint* fences);
alias PFNGLGENFENCESNVPROC = void function (GLsizei n, GLuint* fences);
alias PFNGLISFENCENVPROC = ubyte function (GLuint fence);
alias PFNGLTESTFENCENVPROC = ubyte function (GLuint fence);
alias PFNGLGETFENCEIVNVPROC = void function (GLuint fence, GLenum pname, GLint* params);
alias PFNGLFINISHFENCENVPROC = void function (GLuint fence);
alias PFNGLSETFENCENVPROC = void function (GLuint fence, GLenum condition);

/* GL_NV_fence */

enum GL_NV_fill_rectangle = 1;
enum GL_FILL_RECTANGLE_NV = 0x933C;
/* GL_NV_fill_rectangle */

enum GL_NV_fragment_coverage_to_color = 1;
enum GL_FRAGMENT_COVERAGE_TO_COLOR_NV = 0x92DD;
enum GL_FRAGMENT_COVERAGE_COLOR_NV = 0x92DE;
alias PFNGLFRAGMENTCOVERAGECOLORNVPROC = void function (GLuint color);

/* GL_NV_fragment_coverage_to_color */

enum GL_NV_fragment_shader_barycentric = 1;
/* GL_NV_fragment_shader_barycentric */

enum GL_NV_fragment_shader_interlock = 1;
/* GL_NV_fragment_shader_interlock */

enum GL_NV_framebuffer_blit = 1;
enum GL_READ_FRAMEBUFFER_NV = 0x8CA8;
enum GL_DRAW_FRAMEBUFFER_NV = 0x8CA9;
enum GL_DRAW_FRAMEBUFFER_BINDING_NV = 0x8CA6;
enum GL_READ_FRAMEBUFFER_BINDING_NV = 0x8CAA;
alias PFNGLBLITFRAMEBUFFERNVPROC = void function (GLint srcX0, GLint srcY0, GLint srcX1, GLint srcY1, GLint dstX0, GLint dstY0, GLint dstX1, GLint dstY1, GLbitfield mask, GLenum filter);

/* GL_NV_framebuffer_blit */

enum GL_NV_framebuffer_mixed_samples = 1;
enum GL_COVERAGE_MODULATION_TABLE_NV = 0x9331;
enum GL_COLOR_SAMPLES_NV = 0x8E20;
enum GL_DEPTH_SAMPLES_NV = 0x932D;
enum GL_STENCIL_SAMPLES_NV = 0x932E;
enum GL_MIXED_DEPTH_SAMPLES_SUPPORTED_NV = 0x932F;
enum GL_MIXED_STENCIL_SAMPLES_SUPPORTED_NV = 0x9330;
enum GL_COVERAGE_MODULATION_NV = 0x9332;
enum GL_COVERAGE_MODULATION_TABLE_SIZE_NV = 0x9333;
alias PFNGLCOVERAGEMODULATIONTABLENVPROC = void function (GLsizei n, GLfloat* v);
alias PFNGLGETCOVERAGEMODULATIONTABLENVPROC = void function (GLsizei bufSize, GLfloat* v);
alias PFNGLCOVERAGEMODULATIONNVPROC = void function (GLenum components);

/* GL_NV_framebuffer_mixed_samples */

enum GL_NV_framebuffer_multisample = 1;
enum GL_RENDERBUFFER_SAMPLES_NV = 0x8CAB;
enum GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE_NV = 0x8D56;
enum GL_MAX_SAMPLES_NV = 0x8D57;
alias PFNGLRENDERBUFFERSTORAGEMULTISAMPLENVPROC = void function (GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height);

/* GL_NV_framebuffer_multisample */

enum GL_NV_generate_mipmap_sRGB = 1;
/* GL_NV_generate_mipmap_sRGB */

enum GL_NV_geometry_shader_passthrough = 1;
/* GL_NV_geometry_shader_passthrough */

enum GL_NV_gpu_shader5 = 1;
alias GLint64EXT = long;
alias GLuint64EXT = ulong;
enum GL_INT64_NV = 0x140E;
enum GL_UNSIGNED_INT64_NV = 0x140F;
enum GL_INT8_NV = 0x8FE0;
enum GL_INT8_VEC2_NV = 0x8FE1;
enum GL_INT8_VEC3_NV = 0x8FE2;
enum GL_INT8_VEC4_NV = 0x8FE3;
enum GL_INT16_NV = 0x8FE4;
enum GL_INT16_VEC2_NV = 0x8FE5;
enum GL_INT16_VEC3_NV = 0x8FE6;
enum GL_INT16_VEC4_NV = 0x8FE7;
enum GL_INT64_VEC2_NV = 0x8FE9;
enum GL_INT64_VEC3_NV = 0x8FEA;
enum GL_INT64_VEC4_NV = 0x8FEB;
enum GL_UNSIGNED_INT8_NV = 0x8FEC;
enum GL_UNSIGNED_INT8_VEC2_NV = 0x8FED;
enum GL_UNSIGNED_INT8_VEC3_NV = 0x8FEE;
enum GL_UNSIGNED_INT8_VEC4_NV = 0x8FEF;
enum GL_UNSIGNED_INT16_NV = 0x8FF0;
enum GL_UNSIGNED_INT16_VEC2_NV = 0x8FF1;
enum GL_UNSIGNED_INT16_VEC3_NV = 0x8FF2;
enum GL_UNSIGNED_INT16_VEC4_NV = 0x8FF3;
enum GL_UNSIGNED_INT64_VEC2_NV = 0x8FF5;
enum GL_UNSIGNED_INT64_VEC3_NV = 0x8FF6;
enum GL_UNSIGNED_INT64_VEC4_NV = 0x8FF7;
enum GL_FLOAT16_NV = 0x8FF8;
enum GL_FLOAT16_VEC2_NV = 0x8FF9;
enum GL_FLOAT16_VEC3_NV = 0x8FFA;
enum GL_FLOAT16_VEC4_NV = 0x8FFB;
enum GL_PATCHES = 0x000E;
alias PFNGLUNIFORM1I64NVPROC = void function (GLint location, GLint64EXT x);
alias PFNGLUNIFORM2I64NVPROC = void function (GLint location, GLint64EXT x, GLint64EXT y);
alias PFNGLUNIFORM3I64NVPROC = void function (GLint location, GLint64EXT x, GLint64EXT y, GLint64EXT z);
alias PFNGLUNIFORM4I64NVPROC = void function (GLint location, GLint64EXT x, GLint64EXT y, GLint64EXT z, GLint64EXT w);
alias PFNGLUNIFORM1I64VNVPROC = void function (GLint location, GLsizei count, GLint64EXT* value);
alias PFNGLUNIFORM2I64VNVPROC = void function (GLint location, GLsizei count, GLint64EXT* value);
alias PFNGLUNIFORM3I64VNVPROC = void function (GLint location, GLsizei count, GLint64EXT* value);
alias PFNGLUNIFORM4I64VNVPROC = void function (GLint location, GLsizei count, GLint64EXT* value);
alias PFNGLUNIFORM1UI64NVPROC = void function (GLint location, GLuint64EXT x);
alias PFNGLUNIFORM2UI64NVPROC = void function (GLint location, GLuint64EXT x, GLuint64EXT y);
alias PFNGLUNIFORM3UI64NVPROC = void function (GLint location, GLuint64EXT x, GLuint64EXT y, GLuint64EXT z);
alias PFNGLUNIFORM4UI64NVPROC = void function (GLint location, GLuint64EXT x, GLuint64EXT y, GLuint64EXT z, GLuint64EXT w);
alias PFNGLUNIFORM1UI64VNVPROC = void function (GLint location, GLsizei count, GLuint64EXT* value);
alias PFNGLUNIFORM2UI64VNVPROC = void function (GLint location, GLsizei count, GLuint64EXT* value);
alias PFNGLUNIFORM3UI64VNVPROC = void function (GLint location, GLsizei count, GLuint64EXT* value);
alias PFNGLUNIFORM4UI64VNVPROC = void function (GLint location, GLsizei count, GLuint64EXT* value);
alias PFNGLGETUNIFORMI64VNVPROC = void function (GLuint program, GLint location, GLint64EXT* params);
alias PFNGLPROGRAMUNIFORM1I64NVPROC = void function (GLuint program, GLint location, GLint64EXT x);
alias PFNGLPROGRAMUNIFORM2I64NVPROC = void function (GLuint program, GLint location, GLint64EXT x, GLint64EXT y);
alias PFNGLPROGRAMUNIFORM3I64NVPROC = void function (GLuint program, GLint location, GLint64EXT x, GLint64EXT y, GLint64EXT z);
alias PFNGLPROGRAMUNIFORM4I64NVPROC = void function (GLuint program, GLint location, GLint64EXT x, GLint64EXT y, GLint64EXT z, GLint64EXT w);
alias PFNGLPROGRAMUNIFORM1I64VNVPROC = void function (GLuint program, GLint location, GLsizei count, GLint64EXT* value);
alias PFNGLPROGRAMUNIFORM2I64VNVPROC = void function (GLuint program, GLint location, GLsizei count, GLint64EXT* value);
alias PFNGLPROGRAMUNIFORM3I64VNVPROC = void function (GLuint program, GLint location, GLsizei count, GLint64EXT* value);
alias PFNGLPROGRAMUNIFORM4I64VNVPROC = void function (GLuint program, GLint location, GLsizei count, GLint64EXT* value);
alias PFNGLPROGRAMUNIFORM1UI64NVPROC = void function (GLuint program, GLint location, GLuint64EXT x);
alias PFNGLPROGRAMUNIFORM2UI64NVPROC = void function (GLuint program, GLint location, GLuint64EXT x, GLuint64EXT y);
alias PFNGLPROGRAMUNIFORM3UI64NVPROC = void function (GLuint program, GLint location, GLuint64EXT x, GLuint64EXT y, GLuint64EXT z);
alias PFNGLPROGRAMUNIFORM4UI64NVPROC = void function (GLuint program, GLint location, GLuint64EXT x, GLuint64EXT y, GLuint64EXT z, GLuint64EXT w);
alias PFNGLPROGRAMUNIFORM1UI64VNVPROC = void function (GLuint program, GLint location, GLsizei count, GLuint64EXT* value);
alias PFNGLPROGRAMUNIFORM2UI64VNVPROC = void function (GLuint program, GLint location, GLsizei count, GLuint64EXT* value);
alias PFNGLPROGRAMUNIFORM3UI64VNVPROC = void function (GLuint program, GLint location, GLsizei count, GLuint64EXT* value);
alias PFNGLPROGRAMUNIFORM4UI64VNVPROC = void function (GLuint program, GLint location, GLsizei count, GLuint64EXT* value);

/* GL_NV_gpu_shader5 */

enum GL_NV_image_formats = 1;
/* GL_NV_image_formats */

enum GL_NV_instanced_arrays = 1;
enum GL_VERTEX_ATTRIB_ARRAY_DIVISOR_NV = 0x88FE;
alias PFNGLVERTEXATTRIBDIVISORNVPROC = void function (GLuint index, GLuint divisor);

/* GL_NV_instanced_arrays */

enum GL_NV_internalformat_sample_query = 1;
enum GL_TEXTURE_2D_MULTISAMPLE = 0x9100;
enum GL_TEXTURE_2D_MULTISAMPLE_ARRAY = 0x9102;
enum GL_MULTISAMPLES_NV = 0x9371;
enum GL_SUPERSAMPLE_SCALE_X_NV = 0x9372;
enum GL_SUPERSAMPLE_SCALE_Y_NV = 0x9373;
enum GL_CONFORMANT_NV = 0x9374;
alias PFNGLGETINTERNALFORMATSAMPLEIVNVPROC = void function (GLenum target, GLenum internalformat, GLsizei samples, GLenum pname, GLsizei count, GLint* params);

/* GL_NV_internalformat_sample_query */

enum GL_NV_memory_attachment = 1;
enum GL_ATTACHED_MEMORY_OBJECT_NV = 0x95A4;
enum GL_ATTACHED_MEMORY_OFFSET_NV = 0x95A5;
enum GL_MEMORY_ATTACHABLE_ALIGNMENT_NV = 0x95A6;
enum GL_MEMORY_ATTACHABLE_SIZE_NV = 0x95A7;
enum GL_MEMORY_ATTACHABLE_NV = 0x95A8;
enum GL_DETACHED_MEMORY_INCARNATION_NV = 0x95A9;
enum GL_DETACHED_TEXTURES_NV = 0x95AA;
enum GL_DETACHED_BUFFERS_NV = 0x95AB;
enum GL_MAX_DETACHED_TEXTURES_NV = 0x95AC;
enum GL_MAX_DETACHED_BUFFERS_NV = 0x95AD;
alias PFNGLGETMEMORYOBJECTDETACHEDRESOURCESUIVNVPROC = void function (GLuint memory, GLenum pname, GLint first, GLsizei count, GLuint* params);
alias PFNGLRESETMEMORYOBJECTPARAMETERNVPROC = void function (GLuint memory, GLenum pname);
alias PFNGLTEXATTACHMEMORYNVPROC = void function (GLenum target, GLuint memory, GLuint64 offset);
alias PFNGLBUFFERATTACHMEMORYNVPROC = void function (GLenum target, GLuint memory, GLuint64 offset);
alias PFNGLTEXTUREATTACHMEMORYNVPROC = void function (GLuint texture, GLuint memory, GLuint64 offset);
alias PFNGLNAMEDBUFFERATTACHMEMORYNVPROC = void function (GLuint buffer, GLuint memory, GLuint64 offset);

/* GL_NV_memory_attachment */

enum GL_NV_mesh_shader = 1;
enum GL_MESH_SHADER_NV = 0x9559;
enum GL_TASK_SHADER_NV = 0x955A;
enum GL_MAX_MESH_UNIFORM_BLOCKS_NV = 0x8E60;
enum GL_MAX_MESH_TEXTURE_IMAGE_UNITS_NV = 0x8E61;
enum GL_MAX_MESH_IMAGE_UNIFORMS_NV = 0x8E62;
enum GL_MAX_MESH_UNIFORM_COMPONENTS_NV = 0x8E63;
enum GL_MAX_MESH_ATOMIC_COUNTER_BUFFERS_NV = 0x8E64;
enum GL_MAX_MESH_ATOMIC_COUNTERS_NV = 0x8E65;
enum GL_MAX_MESH_SHADER_STORAGE_BLOCKS_NV = 0x8E66;
enum GL_MAX_COMBINED_MESH_UNIFORM_COMPONENTS_NV = 0x8E67;
enum GL_MAX_TASK_UNIFORM_BLOCKS_NV = 0x8E68;
enum GL_MAX_TASK_TEXTURE_IMAGE_UNITS_NV = 0x8E69;
enum GL_MAX_TASK_IMAGE_UNIFORMS_NV = 0x8E6A;
enum GL_MAX_TASK_UNIFORM_COMPONENTS_NV = 0x8E6B;
enum GL_MAX_TASK_ATOMIC_COUNTER_BUFFERS_NV = 0x8E6C;
enum GL_MAX_TASK_ATOMIC_COUNTERS_NV = 0x8E6D;
enum GL_MAX_TASK_SHADER_STORAGE_BLOCKS_NV = 0x8E6E;
enum GL_MAX_COMBINED_TASK_UNIFORM_COMPONENTS_NV = 0x8E6F;
enum GL_MAX_MESH_WORK_GROUP_INVOCATIONS_NV = 0x95A2;
enum GL_MAX_TASK_WORK_GROUP_INVOCATIONS_NV = 0x95A3;
enum GL_MAX_MESH_TOTAL_MEMORY_SIZE_NV = 0x9536;
enum GL_MAX_TASK_TOTAL_MEMORY_SIZE_NV = 0x9537;
enum GL_MAX_MESH_OUTPUT_VERTICES_NV = 0x9538;
enum GL_MAX_MESH_OUTPUT_PRIMITIVES_NV = 0x9539;
enum GL_MAX_TASK_OUTPUT_COUNT_NV = 0x953A;
enum GL_MAX_DRAW_MESH_TASKS_COUNT_NV = 0x953D;
enum GL_MAX_MESH_VIEWS_NV = 0x9557;
enum GL_MESH_OUTPUT_PER_VERTEX_GRANULARITY_NV = 0x92DF;
enum GL_MESH_OUTPUT_PER_PRIMITIVE_GRANULARITY_NV = 0x9543;
enum GL_MAX_MESH_WORK_GROUP_SIZE_NV = 0x953B;
enum GL_MAX_TASK_WORK_GROUP_SIZE_NV = 0x953C;
enum GL_MESH_WORK_GROUP_SIZE_NV = 0x953E;
enum GL_TASK_WORK_GROUP_SIZE_NV = 0x953F;
enum GL_MESH_VERTICES_OUT_NV = 0x9579;
enum GL_MESH_PRIMITIVES_OUT_NV = 0x957A;
enum GL_MESH_OUTPUT_TYPE_NV = 0x957B;
enum GL_UNIFORM_BLOCK_REFERENCED_BY_MESH_SHADER_NV = 0x959C;
enum GL_UNIFORM_BLOCK_REFERENCED_BY_TASK_SHADER_NV = 0x959D;
enum GL_REFERENCED_BY_MESH_SHADER_NV = 0x95A0;
enum GL_REFERENCED_BY_TASK_SHADER_NV = 0x95A1;
enum GL_MESH_SHADER_BIT_NV = 0x00000040;
enum GL_TASK_SHADER_BIT_NV = 0x00000080;
enum GL_MESH_SUBROUTINE_NV = 0x957C;
enum GL_TASK_SUBROUTINE_NV = 0x957D;
enum GL_MESH_SUBROUTINE_UNIFORM_NV = 0x957E;
enum GL_TASK_SUBROUTINE_UNIFORM_NV = 0x957F;
enum GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_MESH_SHADER_NV = 0x959E;
enum GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_TASK_SHADER_NV = 0x959F;
alias PFNGLDRAWMESHTASKSNVPROC = void function (GLuint first, GLuint count);
alias PFNGLDRAWMESHTASKSINDIRECTNVPROC = void function (GLintptr indirect);
alias PFNGLMULTIDRAWMESHTASKSINDIRECTNVPROC = void function (GLintptr indirect, GLsizei drawcount, GLsizei stride);
alias PFNGLMULTIDRAWMESHTASKSINDIRECTCOUNTNVPROC = void function (GLintptr indirect, GLintptr drawcount, GLsizei maxdrawcount, GLsizei stride);

/* GL_NV_mesh_shader */

enum GL_NV_non_square_matrices = 1;
enum GL_FLOAT_MAT2x3_NV = 0x8B65;
enum GL_FLOAT_MAT2x4_NV = 0x8B66;
enum GL_FLOAT_MAT3x2_NV = 0x8B67;
enum GL_FLOAT_MAT3x4_NV = 0x8B68;
enum GL_FLOAT_MAT4x2_NV = 0x8B69;
enum GL_FLOAT_MAT4x3_NV = 0x8B6A;
alias PFNGLUNIFORMMATRIX2X3FVNVPROC = void function (GLint location, GLsizei count, GLboolean transpose, GLfloat* value);
alias PFNGLUNIFORMMATRIX3X2FVNVPROC = void function (GLint location, GLsizei count, GLboolean transpose, GLfloat* value);
alias PFNGLUNIFORMMATRIX2X4FVNVPROC = void function (GLint location, GLsizei count, GLboolean transpose, GLfloat* value);
alias PFNGLUNIFORMMATRIX4X2FVNVPROC = void function (GLint location, GLsizei count, GLboolean transpose, GLfloat* value);
alias PFNGLUNIFORMMATRIX3X4FVNVPROC = void function (GLint location, GLsizei count, GLboolean transpose, GLfloat* value);
alias PFNGLUNIFORMMATRIX4X3FVNVPROC = void function (GLint location, GLsizei count, GLboolean transpose, GLfloat* value);

/* GL_NV_non_square_matrices */

enum GL_NV_path_rendering = 1;
alias GLdouble = double;
enum GL_PATH_FORMAT_SVG_NV = 0x9070;
enum GL_PATH_FORMAT_PS_NV = 0x9071;
enum GL_STANDARD_FONT_NAME_NV = 0x9072;
enum GL_SYSTEM_FONT_NAME_NV = 0x9073;
enum GL_FILE_NAME_NV = 0x9074;
enum GL_PATH_STROKE_WIDTH_NV = 0x9075;
enum GL_PATH_END_CAPS_NV = 0x9076;
enum GL_PATH_INITIAL_END_CAP_NV = 0x9077;
enum GL_PATH_TERMINAL_END_CAP_NV = 0x9078;
enum GL_PATH_JOIN_STYLE_NV = 0x9079;
enum GL_PATH_MITER_LIMIT_NV = 0x907A;
enum GL_PATH_DASH_CAPS_NV = 0x907B;
enum GL_PATH_INITIAL_DASH_CAP_NV = 0x907C;
enum GL_PATH_TERMINAL_DASH_CAP_NV = 0x907D;
enum GL_PATH_DASH_OFFSET_NV = 0x907E;
enum GL_PATH_CLIENT_LENGTH_NV = 0x907F;
enum GL_PATH_FILL_MODE_NV = 0x9080;
enum GL_PATH_FILL_MASK_NV = 0x9081;
enum GL_PATH_FILL_COVER_MODE_NV = 0x9082;
enum GL_PATH_STROKE_COVER_MODE_NV = 0x9083;
enum GL_PATH_STROKE_MASK_NV = 0x9084;
enum GL_COUNT_UP_NV = 0x9088;
enum GL_COUNT_DOWN_NV = 0x9089;
enum GL_PATH_OBJECT_BOUNDING_BOX_NV = 0x908A;
enum GL_CONVEX_HULL_NV = 0x908B;
enum GL_BOUNDING_BOX_NV = 0x908D;
enum GL_TRANSLATE_X_NV = 0x908E;
enum GL_TRANSLATE_Y_NV = 0x908F;
enum GL_TRANSLATE_2D_NV = 0x9090;
enum GL_TRANSLATE_3D_NV = 0x9091;
enum GL_AFFINE_2D_NV = 0x9092;
enum GL_AFFINE_3D_NV = 0x9094;
enum GL_TRANSPOSE_AFFINE_2D_NV = 0x9096;
enum GL_TRANSPOSE_AFFINE_3D_NV = 0x9098;
enum GL_UTF8_NV = 0x909A;
enum GL_UTF16_NV = 0x909B;
enum GL_BOUNDING_BOX_OF_BOUNDING_BOXES_NV = 0x909C;
enum GL_PATH_COMMAND_COUNT_NV = 0x909D;
enum GL_PATH_COORD_COUNT_NV = 0x909E;
enum GL_PATH_DASH_ARRAY_COUNT_NV = 0x909F;
enum GL_PATH_COMPUTED_LENGTH_NV = 0x90A0;
enum GL_PATH_FILL_BOUNDING_BOX_NV = 0x90A1;
enum GL_PATH_STROKE_BOUNDING_BOX_NV = 0x90A2;
enum GL_SQUARE_NV = 0x90A3;
enum GL_ROUND_NV = 0x90A4;
enum GL_TRIANGULAR_NV = 0x90A5;
enum GL_BEVEL_NV = 0x90A6;
enum GL_MITER_REVERT_NV = 0x90A7;
enum GL_MITER_TRUNCATE_NV = 0x90A8;
enum GL_SKIP_MISSING_GLYPH_NV = 0x90A9;
enum GL_USE_MISSING_GLYPH_NV = 0x90AA;
enum GL_PATH_ERROR_POSITION_NV = 0x90AB;
enum GL_ACCUM_ADJACENT_PAIRS_NV = 0x90AD;
enum GL_ADJACENT_PAIRS_NV = 0x90AE;
enum GL_FIRST_TO_REST_NV = 0x90AF;
enum GL_PATH_GEN_MODE_NV = 0x90B0;
enum GL_PATH_GEN_COEFF_NV = 0x90B1;
enum GL_PATH_GEN_COMPONENTS_NV = 0x90B3;
enum GL_PATH_STENCIL_FUNC_NV = 0x90B7;
enum GL_PATH_STENCIL_REF_NV = 0x90B8;
enum GL_PATH_STENCIL_VALUE_MASK_NV = 0x90B9;
enum GL_PATH_STENCIL_DEPTH_OFFSET_FACTOR_NV = 0x90BD;
enum GL_PATH_STENCIL_DEPTH_OFFSET_UNITS_NV = 0x90BE;
enum GL_PATH_COVER_DEPTH_FUNC_NV = 0x90BF;
enum GL_PATH_DASH_OFFSET_RESET_NV = 0x90B4;
enum GL_MOVE_TO_RESETS_NV = 0x90B5;
enum GL_MOVE_TO_CONTINUES_NV = 0x90B6;
enum GL_CLOSE_PATH_NV = 0x00;
enum GL_MOVE_TO_NV = 0x02;
enum GL_RELATIVE_MOVE_TO_NV = 0x03;
enum GL_LINE_TO_NV = 0x04;
enum GL_RELATIVE_LINE_TO_NV = 0x05;
enum GL_HORIZONTAL_LINE_TO_NV = 0x06;
enum GL_RELATIVE_HORIZONTAL_LINE_TO_NV = 0x07;
enum GL_VERTICAL_LINE_TO_NV = 0x08;
enum GL_RELATIVE_VERTICAL_LINE_TO_NV = 0x09;
enum GL_QUADRATIC_CURVE_TO_NV = 0x0A;
enum GL_RELATIVE_QUADRATIC_CURVE_TO_NV = 0x0B;
enum GL_CUBIC_CURVE_TO_NV = 0x0C;
enum GL_RELATIVE_CUBIC_CURVE_TO_NV = 0x0D;
enum GL_SMOOTH_QUADRATIC_CURVE_TO_NV = 0x0E;
enum GL_RELATIVE_SMOOTH_QUADRATIC_CURVE_TO_NV = 0x0F;
enum GL_SMOOTH_CUBIC_CURVE_TO_NV = 0x10;
enum GL_RELATIVE_SMOOTH_CUBIC_CURVE_TO_NV = 0x11;
enum GL_SMALL_CCW_ARC_TO_NV = 0x12;
enum GL_RELATIVE_SMALL_CCW_ARC_TO_NV = 0x13;
enum GL_SMALL_CW_ARC_TO_NV = 0x14;
enum GL_RELATIVE_SMALL_CW_ARC_TO_NV = 0x15;
enum GL_LARGE_CCW_ARC_TO_NV = 0x16;
enum GL_RELATIVE_LARGE_CCW_ARC_TO_NV = 0x17;
enum GL_LARGE_CW_ARC_TO_NV = 0x18;
enum GL_RELATIVE_LARGE_CW_ARC_TO_NV = 0x19;
enum GL_RESTART_PATH_NV = 0xF0;
enum GL_DUP_FIRST_CUBIC_CURVE_TO_NV = 0xF2;
enum GL_DUP_LAST_CUBIC_CURVE_TO_NV = 0xF4;
enum GL_RECT_NV = 0xF6;
enum GL_CIRCULAR_CCW_ARC_TO_NV = 0xF8;
enum GL_CIRCULAR_CW_ARC_TO_NV = 0xFA;
enum GL_CIRCULAR_TANGENT_ARC_TO_NV = 0xFC;
enum GL_ARC_TO_NV = 0xFE;
enum GL_RELATIVE_ARC_TO_NV = 0xFF;
enum GL_BOLD_BIT_NV = 0x01;
enum GL_ITALIC_BIT_NV = 0x02;
enum GL_GLYPH_WIDTH_BIT_NV = 0x01;
enum GL_GLYPH_HEIGHT_BIT_NV = 0x02;
enum GL_GLYPH_HORIZONTAL_BEARING_X_BIT_NV = 0x04;
enum GL_GLYPH_HORIZONTAL_BEARING_Y_BIT_NV = 0x08;
enum GL_GLYPH_HORIZONTAL_BEARING_ADVANCE_BIT_NV = 0x10;
enum GL_GLYPH_VERTICAL_BEARING_X_BIT_NV = 0x20;
enum GL_GLYPH_VERTICAL_BEARING_Y_BIT_NV = 0x40;
enum GL_GLYPH_VERTICAL_BEARING_ADVANCE_BIT_NV = 0x80;
enum GL_GLYPH_HAS_KERNING_BIT_NV = 0x100;
enum GL_FONT_X_MIN_BOUNDS_BIT_NV = 0x00010000;
enum GL_FONT_Y_MIN_BOUNDS_BIT_NV = 0x00020000;
enum GL_FONT_X_MAX_BOUNDS_BIT_NV = 0x00040000;
enum GL_FONT_Y_MAX_BOUNDS_BIT_NV = 0x00080000;
enum GL_FONT_UNITS_PER_EM_BIT_NV = 0x00100000;
enum GL_FONT_ASCENDER_BIT_NV = 0x00200000;
enum GL_FONT_DESCENDER_BIT_NV = 0x00400000;
enum GL_FONT_HEIGHT_BIT_NV = 0x00800000;
enum GL_FONT_MAX_ADVANCE_WIDTH_BIT_NV = 0x01000000;
enum GL_FONT_MAX_ADVANCE_HEIGHT_BIT_NV = 0x02000000;
enum GL_FONT_UNDERLINE_POSITION_BIT_NV = 0x04000000;
enum GL_FONT_UNDERLINE_THICKNESS_BIT_NV = 0x08000000;
enum GL_FONT_HAS_KERNING_BIT_NV = 0x10000000;
enum GL_ROUNDED_RECT_NV = 0xE8;
enum GL_RELATIVE_ROUNDED_RECT_NV = 0xE9;
enum GL_ROUNDED_RECT2_NV = 0xEA;
enum GL_RELATIVE_ROUNDED_RECT2_NV = 0xEB;
enum GL_ROUNDED_RECT4_NV = 0xEC;
enum GL_RELATIVE_ROUNDED_RECT4_NV = 0xED;
enum GL_ROUNDED_RECT8_NV = 0xEE;
enum GL_RELATIVE_ROUNDED_RECT8_NV = 0xEF;
enum GL_RELATIVE_RECT_NV = 0xF7;
enum GL_FONT_GLYPHS_AVAILABLE_NV = 0x9368;
enum GL_FONT_TARGET_UNAVAILABLE_NV = 0x9369;
enum GL_FONT_UNAVAILABLE_NV = 0x936A;
enum GL_FONT_UNINTELLIGIBLE_NV = 0x936B;
enum GL_CONIC_CURVE_TO_NV = 0x1A;
enum GL_RELATIVE_CONIC_CURVE_TO_NV = 0x1B;
enum GL_FONT_NUM_GLYPH_INDICES_BIT_NV = 0x20000000;
enum GL_STANDARD_FONT_FORMAT_NV = 0x936C;
enum GL_PATH_PROJECTION_NV = 0x1701;
enum GL_PATH_MODELVIEW_NV = 0x1700;
enum GL_PATH_MODELVIEW_STACK_DEPTH_NV = 0x0BA3;
enum GL_PATH_MODELVIEW_MATRIX_NV = 0x0BA6;
enum GL_PATH_MAX_MODELVIEW_STACK_DEPTH_NV = 0x0D36;
enum GL_PATH_TRANSPOSE_MODELVIEW_MATRIX_NV = 0x84E3;
enum GL_PATH_PROJECTION_STACK_DEPTH_NV = 0x0BA4;
enum GL_PATH_PROJECTION_MATRIX_NV = 0x0BA7;
enum GL_PATH_MAX_PROJECTION_STACK_DEPTH_NV = 0x0D38;
enum GL_PATH_TRANSPOSE_PROJECTION_MATRIX_NV = 0x84E4;
enum GL_FRAGMENT_INPUT_NV = 0x936D;
alias PFNGLGENPATHSNVPROC = uint function (GLsizei range);
alias PFNGLDELETEPATHSNVPROC = void function (GLuint path, GLsizei range);
alias PFNGLISPATHNVPROC = ubyte function (GLuint path);
alias PFNGLPATHCOMMANDSNVPROC = void function (GLuint path, GLsizei numCommands, GLubyte* commands, GLsizei numCoords, GLenum coordType, void* coords);
alias PFNGLPATHCOORDSNVPROC = void function (GLuint path, GLsizei numCoords, GLenum coordType, void* coords);
alias PFNGLPATHSUBCOMMANDSNVPROC = void function (GLuint path, GLsizei commandStart, GLsizei commandsToDelete, GLsizei numCommands, GLubyte* commands, GLsizei numCoords, GLenum coordType, void* coords);
alias PFNGLPATHSUBCOORDSNVPROC = void function (GLuint path, GLsizei coordStart, GLsizei numCoords, GLenum coordType, void* coords);
alias PFNGLPATHSTRINGNVPROC = void function (GLuint path, GLenum format, GLsizei length, void* pathString);
alias PFNGLPATHGLYPHSNVPROC = void function (GLuint firstPathName, GLenum fontTarget, void* fontName, GLbitfield fontStyle, GLsizei numGlyphs, GLenum type, void* charcodes, GLenum handleMissingGlyphs, GLuint pathParameterTemplate, GLfloat emScale);
alias PFNGLPATHGLYPHRANGENVPROC = void function (GLuint firstPathName, GLenum fontTarget, void* fontName, GLbitfield fontStyle, GLuint firstGlyph, GLsizei numGlyphs, GLenum handleMissingGlyphs, GLuint pathParameterTemplate, GLfloat emScale);
alias PFNGLWEIGHTPATHSNVPROC = void function (GLuint resultPath, GLsizei numPaths, GLuint* paths, GLfloat* weights);
alias PFNGLCOPYPATHNVPROC = void function (GLuint resultPath, GLuint srcPath);
alias PFNGLINTERPOLATEPATHSNVPROC = void function (GLuint resultPath, GLuint pathA, GLuint pathB, GLfloat weight);
alias PFNGLTRANSFORMPATHNVPROC = void function (GLuint resultPath, GLuint srcPath, GLenum transformType, GLfloat* transformValues);
alias PFNGLPATHPARAMETERIVNVPROC = void function (GLuint path, GLenum pname, GLint* value);
alias PFNGLPATHPARAMETERINVPROC = void function (GLuint path, GLenum pname, GLint value);
alias PFNGLPATHPARAMETERFVNVPROC = void function (GLuint path, GLenum pname, GLfloat* value);
alias PFNGLPATHPARAMETERFNVPROC = void function (GLuint path, GLenum pname, GLfloat value);
alias PFNGLPATHDASHARRAYNVPROC = void function (GLuint path, GLsizei dashCount, GLfloat* dashArray);
alias PFNGLPATHSTENCILFUNCNVPROC = void function (GLenum func, GLint ref_, GLuint mask);
alias PFNGLPATHSTENCILDEPTHOFFSETNVPROC = void function (GLfloat factor, GLfloat units);
alias PFNGLSTENCILFILLPATHNVPROC = void function (GLuint path, GLenum fillMode, GLuint mask);
alias PFNGLSTENCILSTROKEPATHNVPROC = void function (GLuint path, GLint reference, GLuint mask);
alias PFNGLSTENCILFILLPATHINSTANCEDNVPROC = void function (GLsizei numPaths, GLenum pathNameType, void* paths, GLuint pathBase, GLenum fillMode, GLuint mask, GLenum transformType, GLfloat* transformValues);
alias PFNGLSTENCILSTROKEPATHINSTANCEDNVPROC = void function (GLsizei numPaths, GLenum pathNameType, void* paths, GLuint pathBase, GLint reference, GLuint mask, GLenum transformType, GLfloat* transformValues);
alias PFNGLPATHCOVERDEPTHFUNCNVPROC = void function (GLenum func);
alias PFNGLCOVERFILLPATHNVPROC = void function (GLuint path, GLenum coverMode);
alias PFNGLCOVERSTROKEPATHNVPROC = void function (GLuint path, GLenum coverMode);
alias PFNGLCOVERFILLPATHINSTANCEDNVPROC = void function (GLsizei numPaths, GLenum pathNameType, void* paths, GLuint pathBase, GLenum coverMode, GLenum transformType, GLfloat* transformValues);
alias PFNGLCOVERSTROKEPATHINSTANCEDNVPROC = void function (GLsizei numPaths, GLenum pathNameType, void* paths, GLuint pathBase, GLenum coverMode, GLenum transformType, GLfloat* transformValues);
alias PFNGLGETPATHPARAMETERIVNVPROC = void function (GLuint path, GLenum pname, GLint* value);
alias PFNGLGETPATHPARAMETERFVNVPROC = void function (GLuint path, GLenum pname, GLfloat* value);
alias PFNGLGETPATHCOMMANDSNVPROC = void function (GLuint path, GLubyte* commands);
alias PFNGLGETPATHCOORDSNVPROC = void function (GLuint path, GLfloat* coords);
alias PFNGLGETPATHDASHARRAYNVPROC = void function (GLuint path, GLfloat* dashArray);
alias PFNGLGETPATHMETRICSNVPROC = void function (GLbitfield metricQueryMask, GLsizei numPaths, GLenum pathNameType, void* paths, GLuint pathBase, GLsizei stride, GLfloat* metrics);
alias PFNGLGETPATHMETRICRANGENVPROC = void function (GLbitfield metricQueryMask, GLuint firstPathName, GLsizei numPaths, GLsizei stride, GLfloat* metrics);
alias PFNGLGETPATHSPACINGNVPROC = void function (GLenum pathListMode, GLsizei numPaths, GLenum pathNameType, void* paths, GLuint pathBase, GLfloat advanceScale, GLfloat kerningScale, GLenum transformType, GLfloat* returnedSpacing);
alias PFNGLISPOINTINFILLPATHNVPROC = ubyte function (GLuint path, GLuint mask, GLfloat x, GLfloat y);
alias PFNGLISPOINTINSTROKEPATHNVPROC = ubyte function (GLuint path, GLfloat x, GLfloat y);
alias PFNGLGETPATHLENGTHNVPROC = float function (GLuint path, GLsizei startSegment, GLsizei numSegments);
alias PFNGLPOINTALONGPATHNVPROC = ubyte function (GLuint path, GLsizei startSegment, GLsizei numSegments, GLfloat distance, GLfloat* x, GLfloat* y, GLfloat* tangentX, GLfloat* tangentY);
alias PFNGLMATRIXLOAD3X2FNVPROC = void function (GLenum matrixMode, GLfloat* m);
alias PFNGLMATRIXLOAD3X3FNVPROC = void function (GLenum matrixMode, GLfloat* m);
alias PFNGLMATRIXLOADTRANSPOSE3X3FNVPROC = void function (GLenum matrixMode, GLfloat* m);
alias PFNGLMATRIXMULT3X2FNVPROC = void function (GLenum matrixMode, GLfloat* m);
alias PFNGLMATRIXMULT3X3FNVPROC = void function (GLenum matrixMode, GLfloat* m);
alias PFNGLMATRIXMULTTRANSPOSE3X3FNVPROC = void function (GLenum matrixMode, GLfloat* m);
alias PFNGLSTENCILTHENCOVERFILLPATHNVPROC = void function (GLuint path, GLenum fillMode, GLuint mask, GLenum coverMode);
alias PFNGLSTENCILTHENCOVERSTROKEPATHNVPROC = void function (GLuint path, GLint reference, GLuint mask, GLenum coverMode);
alias PFNGLSTENCILTHENCOVERFILLPATHINSTANCEDNVPROC = void function (GLsizei numPaths, GLenum pathNameType, void* paths, GLuint pathBase, GLenum fillMode, GLuint mask, GLenum coverMode, GLenum transformType, GLfloat* transformValues);
alias PFNGLSTENCILTHENCOVERSTROKEPATHINSTANCEDNVPROC = void function (GLsizei numPaths, GLenum pathNameType, void* paths, GLuint pathBase, GLint reference, GLuint mask, GLenum coverMode, GLenum transformType, GLfloat* transformValues);
alias PFNGLPATHGLYPHINDEXRANGENVPROC = uint function (GLenum fontTarget, void* fontName, GLbitfield fontStyle, GLuint pathParameterTemplate, GLfloat emScale, GLuint[2] baseAndCount);
alias PFNGLPATHGLYPHINDEXARRAYNVPROC = uint function (GLuint firstPathName, GLenum fontTarget, void* fontName, GLbitfield fontStyle, GLuint firstGlyphIndex, GLsizei numGlyphs, GLuint pathParameterTemplate, GLfloat emScale);
alias PFNGLPATHMEMORYGLYPHINDEXARRAYNVPROC = uint function (GLuint firstPathName, GLenum fontTarget, GLsizeiptr fontSize, void* fontData, GLsizei faceIndex, GLuint firstGlyphIndex, GLsizei numGlyphs, GLuint pathParameterTemplate, GLfloat emScale);
alias PFNGLPROGRAMPATHFRAGMENTINPUTGENNVPROC = void function (GLuint program, GLint location, GLenum genMode, GLint components, GLfloat* coeffs);
alias PFNGLGETPROGRAMRESOURCEFVNVPROC = void function (GLuint program, GLenum programInterface, GLuint index, GLsizei propCount, GLenum* props, GLsizei count, GLsizei* length, GLfloat* params);
alias PFNGLMATRIXFRUSTUMEXTPROC = void function (GLenum mode, GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar);
alias PFNGLMATRIXLOADIDENTITYEXTPROC = void function (GLenum mode);
alias PFNGLMATRIXLOADTRANSPOSEFEXTPROC = void function (GLenum mode, GLfloat* m);
alias PFNGLMATRIXLOADTRANSPOSEDEXTPROC = void function (GLenum mode, GLdouble* m);
alias PFNGLMATRIXLOADFEXTPROC = void function (GLenum mode, GLfloat* m);
alias PFNGLMATRIXLOADDEXTPROC = void function (GLenum mode, GLdouble* m);
alias PFNGLMATRIXMULTTRANSPOSEFEXTPROC = void function (GLenum mode, GLfloat* m);
alias PFNGLMATRIXMULTTRANSPOSEDEXTPROC = void function (GLenum mode, GLdouble* m);
alias PFNGLMATRIXMULTFEXTPROC = void function (GLenum mode, GLfloat* m);
alias PFNGLMATRIXMULTDEXTPROC = void function (GLenum mode, GLdouble* m);
alias PFNGLMATRIXORTHOEXTPROC = void function (GLenum mode, GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar);
alias PFNGLMATRIXPOPEXTPROC = void function (GLenum mode);
alias PFNGLMATRIXPUSHEXTPROC = void function (GLenum mode);
alias PFNGLMATRIXROTATEFEXTPROC = void function (GLenum mode, GLfloat angle, GLfloat x, GLfloat y, GLfloat z);
alias PFNGLMATRIXROTATEDEXTPROC = void function (GLenum mode, GLdouble angle, GLdouble x, GLdouble y, GLdouble z);
alias PFNGLMATRIXSCALEFEXTPROC = void function (GLenum mode, GLfloat x, GLfloat y, GLfloat z);
alias PFNGLMATRIXSCALEDEXTPROC = void function (GLenum mode, GLdouble x, GLdouble y, GLdouble z);
alias PFNGLMATRIXTRANSLATEFEXTPROC = void function (GLenum mode, GLfloat x, GLfloat y, GLfloat z);
alias PFNGLMATRIXTRANSLATEDEXTPROC = void function (GLenum mode, GLdouble x, GLdouble y, GLdouble z);

/* GL_NV_path_rendering */

enum GL_NV_path_rendering_shared_edge = 1;
enum GL_SHARED_EDGE_NV = 0xC0;
/* GL_NV_path_rendering_shared_edge */

enum GL_NV_pixel_buffer_object = 1;
enum GL_PIXEL_PACK_BUFFER_NV = 0x88EB;
enum GL_PIXEL_UNPACK_BUFFER_NV = 0x88EC;
enum GL_PIXEL_PACK_BUFFER_BINDING_NV = 0x88ED;
enum GL_PIXEL_UNPACK_BUFFER_BINDING_NV = 0x88EF;
/* GL_NV_pixel_buffer_object */

enum GL_NV_polygon_mode = 1;
enum GL_POLYGON_MODE_NV = 0x0B40;
enum GL_POLYGON_OFFSET_POINT_NV = 0x2A01;
enum GL_POLYGON_OFFSET_LINE_NV = 0x2A02;
enum GL_POINT_NV = 0x1B00;
enum GL_LINE_NV = 0x1B01;
enum GL_FILL_NV = 0x1B02;
alias PFNGLPOLYGONMODENVPROC = void function (GLenum face, GLenum mode);

/* GL_NV_polygon_mode */

enum GL_NV_read_buffer = 1;
enum GL_READ_BUFFER_NV = 0x0C02;
alias PFNGLREADBUFFERNVPROC = void function (GLenum mode);

/* GL_NV_read_buffer */

enum GL_NV_read_buffer_front = 1;
/* GL_NV_read_buffer_front */

enum GL_NV_read_depth = 1;
/* GL_NV_read_depth */

enum GL_NV_read_depth_stencil = 1;
/* GL_NV_read_depth_stencil */

enum GL_NV_read_stencil = 1;
/* GL_NV_read_stencil */

enum GL_NV_representative_fragment_test = 1;
enum GL_REPRESENTATIVE_FRAGMENT_TEST_NV = 0x937F;
/* GL_NV_representative_fragment_test */

enum GL_NV_sRGB_formats = 1;
enum GL_SLUMINANCE_NV = 0x8C46;
enum GL_SLUMINANCE_ALPHA_NV = 0x8C44;
enum GL_SRGB8_NV = 0x8C41;
enum GL_SLUMINANCE8_NV = 0x8C47;
enum GL_SLUMINANCE8_ALPHA8_NV = 0x8C45;
enum GL_COMPRESSED_SRGB_S3TC_DXT1_NV = 0x8C4C;
enum GL_COMPRESSED_SRGB_ALPHA_S3TC_DXT1_NV = 0x8C4D;
enum GL_COMPRESSED_SRGB_ALPHA_S3TC_DXT3_NV = 0x8C4E;
enum GL_COMPRESSED_SRGB_ALPHA_S3TC_DXT5_NV = 0x8C4F;
enum GL_ETC1_SRGB8_NV = 0x88EE;
/* GL_NV_sRGB_formats */

enum GL_NV_sample_locations = 1;
enum GL_SAMPLE_LOCATION_SUBPIXEL_BITS_NV = 0x933D;
enum GL_SAMPLE_LOCATION_PIXEL_GRID_WIDTH_NV = 0x933E;
enum GL_SAMPLE_LOCATION_PIXEL_GRID_HEIGHT_NV = 0x933F;
enum GL_PROGRAMMABLE_SAMPLE_LOCATION_TABLE_SIZE_NV = 0x9340;
enum GL_SAMPLE_LOCATION_NV = 0x8E50;
enum GL_PROGRAMMABLE_SAMPLE_LOCATION_NV = 0x9341;
enum GL_FRAMEBUFFER_PROGRAMMABLE_SAMPLE_LOCATIONS_NV = 0x9342;
enum GL_FRAMEBUFFER_SAMPLE_LOCATION_PIXEL_GRID_NV = 0x9343;
alias PFNGLFRAMEBUFFERSAMPLELOCATIONSFVNVPROC = void function (GLenum target, GLuint start, GLsizei count, GLfloat* v);
alias PFNGLNAMEDFRAMEBUFFERSAMPLELOCATIONSFVNVPROC = void function (GLuint framebuffer, GLuint start, GLsizei count, GLfloat* v);
alias PFNGLRESOLVEDEPTHVALUESNVPROC = void function ();

/* GL_NV_sample_locations */

enum GL_NV_sample_mask_override_coverage = 1;
/* GL_NV_sample_mask_override_coverage */

enum GL_NV_scissor_exclusive = 1;
enum GL_SCISSOR_TEST_EXCLUSIVE_NV = 0x9555;
enum GL_SCISSOR_BOX_EXCLUSIVE_NV = 0x9556;
alias PFNGLSCISSOREXCLUSIVENVPROC = void function (GLint x, GLint y, GLsizei width, GLsizei height);
alias PFNGLSCISSOREXCLUSIVEARRAYVNVPROC = void function (GLuint first, GLsizei count, GLint* v);

/* GL_NV_scissor_exclusive */

enum GL_NV_shader_atomic_fp16_vector = 1;
/* GL_NV_shader_atomic_fp16_vector */

enum GL_NV_shader_noperspective_interpolation = 1;
/* GL_NV_shader_noperspective_interpolation */

enum GL_NV_shader_subgroup_partitioned = 1;
enum GL_SUBGROUP_FEATURE_PARTITIONED_BIT_NV = 0x00000100;
/* GL_NV_shader_subgroup_partitioned */

enum GL_NV_shader_texture_footprint = 1;
/* GL_NV_shader_texture_footprint */

enum GL_NV_shading_rate_image = 1;
enum GL_SHADING_RATE_IMAGE_NV = 0x9563;
enum GL_SHADING_RATE_NO_INVOCATIONS_NV = 0x9564;
enum GL_SHADING_RATE_1_INVOCATION_PER_PIXEL_NV = 0x9565;
enum GL_SHADING_RATE_1_INVOCATION_PER_1X2_PIXELS_NV = 0x9566;
enum GL_SHADING_RATE_1_INVOCATION_PER_2X1_PIXELS_NV = 0x9567;
enum GL_SHADING_RATE_1_INVOCATION_PER_2X2_PIXELS_NV = 0x9568;
enum GL_SHADING_RATE_1_INVOCATION_PER_2X4_PIXELS_NV = 0x9569;
enum GL_SHADING_RATE_1_INVOCATION_PER_4X2_PIXELS_NV = 0x956A;
enum GL_SHADING_RATE_1_INVOCATION_PER_4X4_PIXELS_NV = 0x956B;
enum GL_SHADING_RATE_2_INVOCATIONS_PER_PIXEL_NV = 0x956C;
enum GL_SHADING_RATE_4_INVOCATIONS_PER_PIXEL_NV = 0x956D;
enum GL_SHADING_RATE_8_INVOCATIONS_PER_PIXEL_NV = 0x956E;
enum GL_SHADING_RATE_16_INVOCATIONS_PER_PIXEL_NV = 0x956F;
enum GL_SHADING_RATE_IMAGE_BINDING_NV = 0x955B;
enum GL_SHADING_RATE_IMAGE_TEXEL_WIDTH_NV = 0x955C;
enum GL_SHADING_RATE_IMAGE_TEXEL_HEIGHT_NV = 0x955D;
enum GL_SHADING_RATE_IMAGE_PALETTE_SIZE_NV = 0x955E;
enum GL_MAX_COARSE_FRAGMENT_SAMPLES_NV = 0x955F;
enum GL_SHADING_RATE_SAMPLE_ORDER_DEFAULT_NV = 0x95AE;
enum GL_SHADING_RATE_SAMPLE_ORDER_PIXEL_MAJOR_NV = 0x95AF;
enum GL_SHADING_RATE_SAMPLE_ORDER_SAMPLE_MAJOR_NV = 0x95B0;
alias PFNGLBINDSHADINGRATEIMAGENVPROC = void function (GLuint texture);
alias PFNGLGETSHADINGRATEIMAGEPALETTENVPROC = void function (GLuint viewport, GLuint entry, GLenum* rate);
alias PFNGLGETSHADINGRATESAMPLELOCATIONIVNVPROC = void function (GLenum rate, GLuint samples, GLuint index, GLint* location);
alias PFNGLSHADINGRATEIMAGEBARRIERNVPROC = void function (GLboolean synchronize);
alias PFNGLSHADINGRATEIMAGEPALETTENVPROC = void function (GLuint viewport, GLuint first, GLsizei count, GLenum* rates);
alias PFNGLSHADINGRATESAMPLEORDERNVPROC = void function (GLenum order);
alias PFNGLSHADINGRATESAMPLEORDERCUSTOMNVPROC = void function (GLenum rate, GLuint samples, GLint* locations);

/* GL_NV_shading_rate_image */

enum GL_NV_shadow_samplers_array = 1;
enum GL_SAMPLER_2D_ARRAY_SHADOW_NV = 0x8DC4;
/* GL_NV_shadow_samplers_array */

enum GL_NV_shadow_samplers_cube = 1;
enum GL_SAMPLER_CUBE_SHADOW_NV = 0x8DC5;
/* GL_NV_shadow_samplers_cube */

enum GL_NV_stereo_view_rendering = 1;
/* GL_NV_stereo_view_rendering */

enum GL_NV_texture_border_clamp = 1;
enum GL_TEXTURE_BORDER_COLOR_NV = 0x1004;
enum GL_CLAMP_TO_BORDER_NV = 0x812D;
/* GL_NV_texture_border_clamp */

enum GL_NV_texture_compression_s3tc_update = 1;
/* GL_NV_texture_compression_s3tc_update */

enum GL_NV_texture_npot_2D_mipmap = 1;
/* GL_NV_texture_npot_2D_mipmap */

enum GL_NV_viewport_array = 1;
enum GL_MAX_VIEWPORTS_NV = 0x825B;
enum GL_VIEWPORT_SUBPIXEL_BITS_NV = 0x825C;
enum GL_VIEWPORT_BOUNDS_RANGE_NV = 0x825D;
enum GL_VIEWPORT_INDEX_PROVOKING_VERTEX_NV = 0x825F;
alias PFNGLVIEWPORTARRAYVNVPROC = void function (GLuint first, GLsizei count, GLfloat* v);
alias PFNGLVIEWPORTINDEXEDFNVPROC = void function (GLuint index, GLfloat x, GLfloat y, GLfloat w, GLfloat h);
alias PFNGLVIEWPORTINDEXEDFVNVPROC = void function (GLuint index, GLfloat* v);
alias PFNGLSCISSORARRAYVNVPROC = void function (GLuint first, GLsizei count, GLint* v);
alias PFNGLSCISSORINDEXEDNVPROC = void function (GLuint index, GLint left, GLint bottom, GLsizei width, GLsizei height);
alias PFNGLSCISSORINDEXEDVNVPROC = void function (GLuint index, GLint* v);
alias PFNGLDEPTHRANGEARRAYFVNVPROC = void function (GLuint first, GLsizei count, GLfloat* v);
alias PFNGLDEPTHRANGEINDEXEDFNVPROC = void function (GLuint index, GLfloat n, GLfloat f);
alias PFNGLGETFLOATI_VNVPROC = void function (GLenum target, GLuint index, GLfloat* data);
alias PFNGLENABLEINVPROC = void function (GLenum target, GLuint index);
alias PFNGLDISABLEINVPROC = void function (GLenum target, GLuint index);
alias PFNGLISENABLEDINVPROC = ubyte function (GLenum target, GLuint index);

/* GL_NV_viewport_array */

enum GL_NV_viewport_array2 = 1;
/* GL_NV_viewport_array2 */

enum GL_NV_viewport_swizzle = 1;
enum GL_VIEWPORT_SWIZZLE_POSITIVE_X_NV = 0x9350;
enum GL_VIEWPORT_SWIZZLE_NEGATIVE_X_NV = 0x9351;
enum GL_VIEWPORT_SWIZZLE_POSITIVE_Y_NV = 0x9352;
enum GL_VIEWPORT_SWIZZLE_NEGATIVE_Y_NV = 0x9353;
enum GL_VIEWPORT_SWIZZLE_POSITIVE_Z_NV = 0x9354;
enum GL_VIEWPORT_SWIZZLE_NEGATIVE_Z_NV = 0x9355;
enum GL_VIEWPORT_SWIZZLE_POSITIVE_W_NV = 0x9356;
enum GL_VIEWPORT_SWIZZLE_NEGATIVE_W_NV = 0x9357;
enum GL_VIEWPORT_SWIZZLE_X_NV = 0x9358;
enum GL_VIEWPORT_SWIZZLE_Y_NV = 0x9359;
enum GL_VIEWPORT_SWIZZLE_Z_NV = 0x935A;
enum GL_VIEWPORT_SWIZZLE_W_NV = 0x935B;
alias PFNGLVIEWPORTSWIZZLENVPROC = void function (GLuint index, GLenum swizzlex, GLenum swizzley, GLenum swizzlez, GLenum swizzlew);

/* GL_NV_viewport_swizzle */

enum GL_OVR_multiview = 1;
enum GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_NUM_VIEWS_OVR = 0x9630;
enum GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_BASE_VIEW_INDEX_OVR = 0x9632;
enum GL_MAX_VIEWS_OVR = 0x9631;
enum GL_FRAMEBUFFER_INCOMPLETE_VIEW_TARGETS_OVR = 0x9633;
alias PFNGLFRAMEBUFFERTEXTUREMULTIVIEWOVRPROC = void function (GLenum target, GLenum attachment, GLuint texture, GLint level, GLint baseViewIndex, GLsizei numViews);

/* GL_OVR_multiview */

enum GL_OVR_multiview2 = 1;
/* GL_OVR_multiview2 */

enum GL_OVR_multiview_multisampled_render_to_texture = 1;
alias PFNGLFRAMEBUFFERTEXTUREMULTISAMPLEMULTIVIEWOVRPROC = void function (GLenum target, GLenum attachment, GLuint texture, GLint level, GLsizei samples, GLint baseViewIndex, GLsizei numViews);

/* GL_OVR_multiview_multisampled_render_to_texture */

enum GL_QCOM_YUV_texture_gather = 1;
/* GL_QCOM_YUV_texture_gather */

enum GL_QCOM_alpha_test = 1;
enum GL_ALPHA_TEST_QCOM = 0x0BC0;
enum GL_ALPHA_TEST_FUNC_QCOM = 0x0BC1;
enum GL_ALPHA_TEST_REF_QCOM = 0x0BC2;
alias PFNGLALPHAFUNCQCOMPROC = void function (GLenum func, GLclampf ref_);

/* GL_QCOM_alpha_test */

enum GL_QCOM_binning_control = 1;
enum GL_BINNING_CONTROL_HINT_QCOM = 0x8FB0;
enum GL_CPU_OPTIMIZED_QCOM = 0x8FB1;
enum GL_GPU_OPTIMIZED_QCOM = 0x8FB2;
enum GL_RENDER_DIRECT_TO_FRAMEBUFFER_QCOM = 0x8FB3;
/* GL_QCOM_binning_control */

enum GL_QCOM_driver_control = 1;
alias PFNGLGETDRIVERCONTROLSQCOMPROC = void function (GLint* num, GLsizei size, GLuint* driverControls);
alias PFNGLGETDRIVERCONTROLSTRINGQCOMPROC = void function (GLuint driverControl, GLsizei bufSize, GLsizei* length, GLchar* driverControlString);
alias PFNGLENABLEDRIVERCONTROLQCOMPROC = void function (GLuint driverControl);
alias PFNGLDISABLEDRIVERCONTROLQCOMPROC = void function (GLuint driverControl);

/* GL_QCOM_driver_control */

enum GL_QCOM_extended_get = 1;
enum GL_TEXTURE_WIDTH_QCOM = 0x8BD2;
enum GL_TEXTURE_HEIGHT_QCOM = 0x8BD3;
enum GL_TEXTURE_DEPTH_QCOM = 0x8BD4;
enum GL_TEXTURE_INTERNAL_FORMAT_QCOM = 0x8BD5;
enum GL_TEXTURE_FORMAT_QCOM = 0x8BD6;
enum GL_TEXTURE_TYPE_QCOM = 0x8BD7;
enum GL_TEXTURE_IMAGE_VALID_QCOM = 0x8BD8;
enum GL_TEXTURE_NUM_LEVELS_QCOM = 0x8BD9;
enum GL_TEXTURE_TARGET_QCOM = 0x8BDA;
enum GL_TEXTURE_OBJECT_VALID_QCOM = 0x8BDB;
enum GL_STATE_RESTORE = 0x8BDC;
alias PFNGLEXTGETTEXTURESQCOMPROC = void function (GLuint* textures, GLint maxTextures, GLint* numTextures);
alias PFNGLEXTGETBUFFERSQCOMPROC = void function (GLuint* buffers, GLint maxBuffers, GLint* numBuffers);
alias PFNGLEXTGETRENDERBUFFERSQCOMPROC = void function (GLuint* renderbuffers, GLint maxRenderbuffers, GLint* numRenderbuffers);
alias PFNGLEXTGETFRAMEBUFFERSQCOMPROC = void function (GLuint* framebuffers, GLint maxFramebuffers, GLint* numFramebuffers);
alias PFNGLEXTGETTEXLEVELPARAMETERIVQCOMPROC = void function (GLuint texture, GLenum face, GLint level, GLenum pname, GLint* params);
alias PFNGLEXTTEXOBJECTSTATEOVERRIDEIQCOMPROC = void function (GLenum target, GLenum pname, GLint param);
alias PFNGLEXTGETTEXSUBIMAGEQCOMPROC = void function (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, void* texels);
alias PFNGLEXTGETBUFFERPOINTERVQCOMPROC = void function (GLenum target, void** params);

/* GL_QCOM_extended_get */

enum GL_QCOM_extended_get2 = 1;
alias PFNGLEXTGETSHADERSQCOMPROC = void function (GLuint* shaders, GLint maxShaders, GLint* numShaders);
alias PFNGLEXTGETPROGRAMSQCOMPROC = void function (GLuint* programs, GLint maxPrograms, GLint* numPrograms);
alias PFNGLEXTISPROGRAMBINARYQCOMPROC = ubyte function (GLuint program);
alias PFNGLEXTGETPROGRAMBINARYSOURCEQCOMPROC = void function (GLuint program, GLenum shadertype, GLchar* source, GLint* length);

/* GL_QCOM_extended_get2 */

enum GL_QCOM_framebuffer_foveated = 1;
enum GL_FOVEATION_ENABLE_BIT_QCOM = 0x00000001;
enum GL_FOVEATION_SCALED_BIN_METHOD_BIT_QCOM = 0x00000002;
alias PFNGLFRAMEBUFFERFOVEATIONCONFIGQCOMPROC = void function (GLuint framebuffer, GLuint numLayers, GLuint focalPointsPerLayer, GLuint requestedFeatures, GLuint* providedFeatures);
alias PFNGLFRAMEBUFFERFOVEATIONPARAMETERSQCOMPROC = void function (GLuint framebuffer, GLuint layer, GLuint focalPoint, GLfloat focalX, GLfloat focalY, GLfloat gainX, GLfloat gainY, GLfloat foveaArea);

/* GL_QCOM_framebuffer_foveated */

enum GL_QCOM_motion_estimation = 1;
enum GL_MOTION_ESTIMATION_SEARCH_BLOCK_X_QCOM = 0x8C90;
enum GL_MOTION_ESTIMATION_SEARCH_BLOCK_Y_QCOM = 0x8C91;
alias PFNGLTEXESTIMATEMOTIONQCOMPROC = void function (GLuint ref_, GLuint target, GLuint output);
alias PFNGLTEXESTIMATEMOTIONREGIONSQCOMPROC = void function (GLuint ref_, GLuint target, GLuint output, GLuint mask);

/* GL_QCOM_motion_estimation */

enum GL_QCOM_perfmon_global_mode = 1;
enum GL_PERFMON_GLOBAL_MODE_QCOM = 0x8FA0;
/* GL_QCOM_perfmon_global_mode */

enum GL_QCOM_shader_framebuffer_fetch_noncoherent = 1;
enum GL_FRAMEBUFFER_FETCH_NONCOHERENT_QCOM = 0x96A2;
alias PFNGLFRAMEBUFFERFETCHBARRIERQCOMPROC = void function ();

/* GL_QCOM_shader_framebuffer_fetch_noncoherent */

enum GL_QCOM_shader_framebuffer_fetch_rate = 1;
/* GL_QCOM_shader_framebuffer_fetch_rate */

enum GL_QCOM_shading_rate = 1;
enum GL_SHADING_RATE_QCOM = 0x96A4;
enum GL_SHADING_RATE_PRESERVE_ASPECT_RATIO_QCOM = 0x96A5;
enum GL_SHADING_RATE_1X1_PIXELS_QCOM = 0x96A6;
enum GL_SHADING_RATE_1X2_PIXELS_QCOM = 0x96A7;
enum GL_SHADING_RATE_2X1_PIXELS_QCOM = 0x96A8;
enum GL_SHADING_RATE_2X2_PIXELS_QCOM = 0x96A9;
enum GL_SHADING_RATE_4X2_PIXELS_QCOM = 0x96AC;
enum GL_SHADING_RATE_4X4_PIXELS_QCOM = 0x96AE;
alias PFNGLSHADINGRATEQCOMPROC = void function (GLenum rate);

/* GL_QCOM_shading_rate */

enum GL_QCOM_texture_foveated = 1;
enum GL_TEXTURE_FOVEATED_FEATURE_BITS_QCOM = 0x8BFB;
enum GL_TEXTURE_FOVEATED_MIN_PIXEL_DENSITY_QCOM = 0x8BFC;
enum GL_TEXTURE_FOVEATED_FEATURE_QUERY_QCOM = 0x8BFD;
enum GL_TEXTURE_FOVEATED_NUM_FOCAL_POINTS_QUERY_QCOM = 0x8BFE;
enum GL_FRAMEBUFFER_INCOMPLETE_FOVEATION_QCOM = 0x8BFF;
alias PFNGLTEXTUREFOVEATIONPARAMETERSQCOMPROC = void function (GLuint texture, GLuint layer, GLuint focalPoint, GLfloat focalX, GLfloat focalY, GLfloat gainX, GLfloat gainY, GLfloat foveaArea);

/* GL_QCOM_texture_foveated */

enum GL_QCOM_texture_foveated_subsampled_layout = 1;
enum GL_FOVEATION_SUBSAMPLED_LAYOUT_METHOD_BIT_QCOM = 0x00000004;
enum GL_MAX_SHADER_SUBSAMPLED_IMAGE_UNITS_QCOM = 0x8FA1;
/* GL_QCOM_texture_foveated_subsampled_layout */

enum GL_QCOM_tiled_rendering = 1;
enum GL_COLOR_BUFFER_BIT0_QCOM = 0x00000001;
enum GL_COLOR_BUFFER_BIT1_QCOM = 0x00000002;
enum GL_COLOR_BUFFER_BIT2_QCOM = 0x00000004;
enum GL_COLOR_BUFFER_BIT3_QCOM = 0x00000008;
enum GL_COLOR_BUFFER_BIT4_QCOM = 0x00000010;
enum GL_COLOR_BUFFER_BIT5_QCOM = 0x00000020;
enum GL_COLOR_BUFFER_BIT6_QCOM = 0x00000040;
enum GL_COLOR_BUFFER_BIT7_QCOM = 0x00000080;
enum GL_DEPTH_BUFFER_BIT0_QCOM = 0x00000100;
enum GL_DEPTH_BUFFER_BIT1_QCOM = 0x00000200;
enum GL_DEPTH_BUFFER_BIT2_QCOM = 0x00000400;
enum GL_DEPTH_BUFFER_BIT3_QCOM = 0x00000800;
enum GL_DEPTH_BUFFER_BIT4_QCOM = 0x00001000;
enum GL_DEPTH_BUFFER_BIT5_QCOM = 0x00002000;
enum GL_DEPTH_BUFFER_BIT6_QCOM = 0x00004000;
enum GL_DEPTH_BUFFER_BIT7_QCOM = 0x00008000;
enum GL_STENCIL_BUFFER_BIT0_QCOM = 0x00010000;
enum GL_STENCIL_BUFFER_BIT1_QCOM = 0x00020000;
enum GL_STENCIL_BUFFER_BIT2_QCOM = 0x00040000;
enum GL_STENCIL_BUFFER_BIT3_QCOM = 0x00080000;
enum GL_STENCIL_BUFFER_BIT4_QCOM = 0x00100000;
enum GL_STENCIL_BUFFER_BIT5_QCOM = 0x00200000;
enum GL_STENCIL_BUFFER_BIT6_QCOM = 0x00400000;
enum GL_STENCIL_BUFFER_BIT7_QCOM = 0x00800000;
enum GL_MULTISAMPLE_BUFFER_BIT0_QCOM = 0x01000000;
enum GL_MULTISAMPLE_BUFFER_BIT1_QCOM = 0x02000000;
enum GL_MULTISAMPLE_BUFFER_BIT2_QCOM = 0x04000000;
enum GL_MULTISAMPLE_BUFFER_BIT3_QCOM = 0x08000000;
enum GL_MULTISAMPLE_BUFFER_BIT4_QCOM = 0x10000000;
enum GL_MULTISAMPLE_BUFFER_BIT5_QCOM = 0x20000000;
enum GL_MULTISAMPLE_BUFFER_BIT6_QCOM = 0x40000000;
enum GL_MULTISAMPLE_BUFFER_BIT7_QCOM = 0x80000000;
alias PFNGLSTARTTILINGQCOMPROC = void function (GLuint x, GLuint y, GLuint width, GLuint height, GLbitfield preserveMask);
alias PFNGLENDTILINGQCOMPROC = void function (GLbitfield preserveMask);

/* GL_QCOM_tiled_rendering */

enum GL_QCOM_writeonly_rendering = 1;
enum GL_WRITEONLY_RENDERING_QCOM = 0x8823;
/* GL_QCOM_writeonly_rendering */

enum GL_SCE_piglet_shader_binary = 1;
enum GL_PIGLET_SHADER_BINARY_SCE = 0x9270;
alias PFNGLPIGLETGETSHADERBINARYSCEPROC = void function (GLuint shader, GLsizei bufSize, GLsizei* length, GLenum* binaryFormat, void* binary);

/* GL_SCE_piglet_shader_binary */

enum GL_SCE_texture_resource = 1;
alias PFNGLTEXIMAGERESOURCESCEPROC = void function (GLenum target, GLvoid* texture_resource_descriptor, GLsizei descriptor_size);
alias PFNGLMAPTEXTURERESOURCESCEPROC = void function (GLenum target, GLvoid* texture_resource_descriptor, GLsizei* descriptor_size);
alias PFNGLUNMAPTEXTURERESOURCESCEPROC = void function (GLenum target);

/* GL_SCE_texture_resource */

enum GL_VIV_shader_binary = 1;
enum GL_SHADER_BINARY_VIV = 0x8FC4;
/* GL_VIV_shader_binary */

