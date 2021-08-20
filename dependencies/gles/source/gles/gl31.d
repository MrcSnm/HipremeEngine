module gles.gl31;


import core.stdc.config;
import core.stdc.stdarg: va_list;
static import core.simd;
static import std.conv;

struct Int128 { long lower; long upper; }
struct UInt128 { ulong lower; ulong upper; }

struct __locale_data { int dummy; }



alias _Bool = bool;
struct dpp {
    static struct Opaque(int N) {
        void[N] bytes;
    }

    static bool isEmpty(T)() {
        return T.tupleof.length == 0;
    }
    static struct Move(T) {
        T* ptr;
    }


    static auto move(T)(ref T value) {
        return Move!T(&value);
    }
    mixin template EnumD(string name, T, string prefix) if(is(T == enum)) {
        private static string _memberMixinStr(string member) {
            import std.conv: text;
            import std.array: replace;
            return text(` `, member.replace(prefix, ""), ` = `, T.stringof, `.`, member, `,`);
        }
        private static string _enumMixinStr() {
            import std.array: join;
            string[] ret;
            ret ~= "enum " ~ name ~ "{";
            static foreach(member; __traits(allMembers, T)) {
                ret ~= _memberMixinStr(member);
            }
            ret ~= "}";
            return ret.join("\n");
        }
        mixin(_enumMixinStr());
    }
}

extern(C)
{
    alias size_t = ulong;
    void __va_start(char**, ...) @nogc nothrow;
    alias uintptr_t = ulong;
    alias uintmax_t = ulong;
    alias intmax_t = long;
    alias uint_fast64_t = ulong;
    alias uint_fast32_t = uint;
    alias uint_fast16_t = uint;
    alias uint_fast8_t = ubyte;
    alias int_fast64_t = long;
    alias int_fast32_t = int;
    alias int_fast16_t = int;
    alias int_fast8_t = byte;
    alias uint_least64_t = ulong;
    alias uint_least32_t = uint;
    alias uint_least16_t = ushort;
    alias uint_least8_t = ubyte;
    alias int_least64_t = long;
    alias int_least32_t = int;
    alias int_least16_t = short;
    alias int_least8_t = byte;
    alias uint64_t = ulong;
    alias uint32_t = uint;
    alias uint16_t = ushort;
    alias uint8_t = ubyte;
    alias int64_t = long;
    alias int32_t = int;
    alias int16_t = short;
    alias int8_t = byte;
    alias threadlocinfo = threadlocaleinfostruct;
    struct localerefcount
    {
        char* locale;
        ushort* wlocale;
        int* refcount;
        int* wrefcount;
    }
    alias locrefcount = localerefcount;
    struct localeinfo_struct
    {
        threadlocaleinfostruct* locinfo;
        threadmbcinfostruct* mbcinfo;
    }
    alias _locale_tstruct = localeinfo_struct;
    alias _locale_t = localeinfo_struct*;
    struct __lc_time_data;
    alias pthreadmbcinfo = threadmbcinfostruct*;
    alias pthreadlocinfo = threadlocaleinfostruct*;
    struct threadmbcinfostruct;
    struct threadlocaleinfostruct
    {
        int refcount;
        uint lc_codepage;
        uint lc_collate_cp;
        uint lc_time_cp;
        localerefcount[6] lc_category;
        int lc_clike;
        int mb_cur_max;
        int* lconv_intl_refcount;
        int* lconv_num_refcount;
        int* lconv_mon_refcount;
        lconv* lconv_;
        int* ctype1_refcount;
        ushort* ctype1;
        const(ushort)* pctype;
        const(ubyte)* pclmap;
        const(ubyte)* pcumap;
        __lc_time_data* lc_time_curr;
        ushort*[6] locale_name;
    }
    void _invoke_watson(const(ushort)*, const(ushort)*, const(ushort)*, uint, ulong) @nogc nothrow;
    void _invalid_parameter_noinfo_noreturn() @nogc nothrow;
    void _invalid_parameter_noinfo() @nogc nothrow;
    alias time_t = long;
    alias __time64_t = long;
    alias __time32_t = c_long;
    alias errno_t = int;
    alias wctype_t = ushort;
    alias wint_t = ushort;
    alias wchar_t = ushort;
    alias ptrdiff_t = long;
    alias intptr_t = long;
    alias rsize_t = ulong;
    enum _Anonymous_0
    {
        KHRONOS_FALSE = 0,
        KHRONOS_TRUE = 1,
        KHRONOS_BOOLEAN_ENUM_FORCE_SIZE = 2147483647,
    }
    enum KHRONOS_FALSE = _Anonymous_0.KHRONOS_FALSE;
    enum KHRONOS_TRUE = _Anonymous_0.KHRONOS_TRUE;
    enum KHRONOS_BOOLEAN_ENUM_FORCE_SIZE = _Anonymous_0.KHRONOS_BOOLEAN_ENUM_FORCE_SIZE;
    alias khronos_boolean_enum_t = _Anonymous_0;
    alias khronos_stime_nanoseconds_t = long;
    alias khronos_utime_nanoseconds_t = ulong;
    alias khronos_float_t = float;
    alias khronos_usize_t = c_ulong;
    alias khronos_ssize_t = c_long;
    alias khronos_uintptr_t = c_ulong;
    alias khronos_intptr_t = c_long;
    alias khronos_uint16_t = ushort;
    alias khronos_int16_t = short;
    alias khronos_uint8_t = ubyte;
    alias khronos_int8_t = byte;
    alias khronos_uint64_t = ulong;
    alias khronos_int64_t = long;
    alias khronos_uint32_t = uint;
    alias khronos_int32_t = int;
    void glVertexBindingDivisor(uint, uint) @nogc nothrow;
    void glVertexAttribBinding(uint, uint) @nogc nothrow;
    void glVertexAttribIFormat(uint, int, uint, uint) @nogc nothrow;
    void glVertexAttribFormat(uint, int, uint, ubyte, uint) @nogc nothrow;
    void glBindVertexBuffer(uint, uint, c_long, int) @nogc nothrow;
    void glGetTexLevelParameterfv(uint, int, uint, float*) @nogc nothrow;
    void glGetTexLevelParameteriv(uint, int, uint, int*) @nogc nothrow;
    void glSampleMaski(uint, uint) @nogc nothrow;
    void glGetMultisamplefv(uint, uint, float*) @nogc nothrow;
    void glTexStorage2DMultisample(uint, int, uint, int, int, ubyte) @nogc nothrow;
    void glMemoryBarrierByRegion(uint) @nogc nothrow;
    void glMemoryBarrier(uint) @nogc nothrow;
    void glGetBooleani_v(uint, uint, ubyte*) @nogc nothrow;
    void glBindImageTexture(uint, uint, int, ubyte, int, uint, uint) @nogc nothrow;
    void glGetProgramPipelineInfoLog(uint, int, int*, char*) @nogc nothrow;
    void glValidateProgramPipeline(uint) @nogc nothrow;
    void glProgramUniformMatrix4x3fv(uint, int, int, ubyte, const(float)*) @nogc nothrow;
    void glProgramUniformMatrix3x4fv(uint, int, int, ubyte, const(float)*) @nogc nothrow;
    void glProgramUniformMatrix4x2fv(uint, int, int, ubyte, const(float)*) @nogc nothrow;
    void glProgramUniformMatrix2x4fv(uint, int, int, ubyte, const(float)*) @nogc nothrow;
    void glProgramUniformMatrix3x2fv(uint, int, int, ubyte, const(float)*) @nogc nothrow;
    void glProgramUniformMatrix2x3fv(uint, int, int, ubyte, const(float)*) @nogc nothrow;
    void glProgramUniformMatrix4fv(uint, int, int, ubyte, const(float)*) @nogc nothrow;
    void glProgramUniformMatrix3fv(uint, int, int, ubyte, const(float)*) @nogc nothrow;
    void glProgramUniformMatrix2fv(uint, int, int, ubyte, const(float)*) @nogc nothrow;
    void glProgramUniform4fv(uint, int, int, const(float)*) @nogc nothrow;
    void glProgramUniform3fv(uint, int, int, const(float)*) @nogc nothrow;
    void glProgramUniform2fv(uint, int, int, const(float)*) @nogc nothrow;
    void glProgramUniform1fv(uint, int, int, const(float)*) @nogc nothrow;
    void glProgramUniform4uiv(uint, int, int, const(uint)*) @nogc nothrow;
    void glProgramUniform3uiv(uint, int, int, const(uint)*) @nogc nothrow;
    void glProgramUniform2uiv(uint, int, int, const(uint)*) @nogc nothrow;
    void glProgramUniform1uiv(uint, int, int, const(uint)*) @nogc nothrow;
    void glProgramUniform4iv(uint, int, int, const(int)*) @nogc nothrow;
    void glProgramUniform3iv(uint, int, int, const(int)*) @nogc nothrow;
    void glProgramUniform2iv(uint, int, int, const(int)*) @nogc nothrow;
    void glProgramUniform1iv(uint, int, int, const(int)*) @nogc nothrow;
    void glProgramUniform4f(uint, int, float, float, float, float) @nogc nothrow;
    void glProgramUniform3f(uint, int, float, float, float) @nogc nothrow;
    void glProgramUniform2f(uint, int, float, float) @nogc nothrow;
    void glProgramUniform1f(uint, int, float) @nogc nothrow;
    void glProgramUniform4ui(uint, int, uint, uint, uint, uint) @nogc nothrow;
    void glProgramUniform3ui(uint, int, uint, uint, uint) @nogc nothrow;
    void glProgramUniform2ui(uint, int, uint, uint) @nogc nothrow;
    void glProgramUniform1ui(uint, int, uint) @nogc nothrow;
    void glProgramUniform4i(uint, int, int, int, int, int) @nogc nothrow;
    void glProgramUniform3i(uint, int, int, int, int) @nogc nothrow;
    void glProgramUniform2i(uint, int, int, int) @nogc nothrow;
    void glProgramUniform1i(uint, int, int) @nogc nothrow;
    void glGetProgramPipelineiv(uint, uint, int*) @nogc nothrow;
    ubyte glIsProgramPipeline(uint) @nogc nothrow;
    void glGenProgramPipelines(int, uint*) @nogc nothrow;
    void glDeleteProgramPipelines(int, const(uint)*) @nogc nothrow;
    void glBindProgramPipeline(uint) @nogc nothrow;
    uint glCreateShaderProgramv(uint, int, const(const(char)*)*) @nogc nothrow;
    void glActiveShaderProgram(uint, uint) @nogc nothrow;
    void glUseProgramStages(uint, uint, uint) @nogc nothrow;
    int glGetProgramResourceLocation(uint, uint, const(char)*) @nogc nothrow;
    void glGetProgramResourceiv(uint, uint, uint, int, const(uint)*, int, int*, int*) @nogc nothrow;
    void glGetProgramResourceName(uint, uint, uint, int, int*, char*) @nogc nothrow;
    uint glGetProgramResourceIndex(uint, uint, const(char)*) @nogc nothrow;
    void glGetProgramInterfaceiv(uint, uint, uint, int*) @nogc nothrow;
    void glGetFramebufferParameteriv(uint, uint, int*) @nogc nothrow;
    alias GLbyte = byte;
    alias GLclampf = float;
    alias GLfixed = int;
    alias GLshort = short;
    alias GLushort = ushort;
    alias GLvoid = void;
    alias GLsync = __GLsync*;
    struct __GLsync;
    alias GLint64 = long;
    alias GLuint64 = ulong;
    alias GLenum = uint;
    alias GLuint = uint;
    alias GLchar = char;
    alias GLfloat = float;
    alias GLsizeiptr = c_long;
    alias GLintptr = c_long;
    alias GLbitfield = uint;
    alias GLint = int;
    alias GLboolean = ubyte;
    alias GLsizei = int;
    alias GLubyte = ubyte;
    void glFramebufferParameteri(uint, uint, int) @nogc nothrow;
    void glDrawElementsIndirect(uint, uint, const(void)*) @nogc nothrow;
    void glDrawArraysIndirect(uint, const(void)*) @nogc nothrow;
    void glDispatchComputeIndirect(c_long) @nogc nothrow;
    void glDispatchCompute(uint, uint, uint) @nogc nothrow;
    alias PFNGLVERTEXBINDINGDIVISORPROC = void function(uint, uint);
    alias PFNGLVERTEXATTRIBBINDINGPROC = void function(uint, uint);
    alias PFNGLVERTEXATTRIBIFORMATPROC = void function(uint, int, uint, uint);
    alias PFNGLVERTEXATTRIBFORMATPROC = void function(uint, int, uint, ubyte, uint);
    alias PFNGLBINDVERTEXBUFFERPROC = void function(uint, uint, c_long, int);
    alias PFNGLGETTEXLEVELPARAMETERFVPROC = void function(uint, int, uint, float*);
    alias PFNGLGETTEXLEVELPARAMETERIVPROC = void function(uint, int, uint, int*);
    alias PFNGLSAMPLEMASKIPROC = void function(uint, uint);
    alias PFNGLGETMULTISAMPLEFVPROC = void function(uint, uint, float*);
    alias PFNGLTEXSTORAGE2DMULTISAMPLEPROC = void function(uint, int, uint, int, int, ubyte);
    alias PFNGLMEMORYBARRIERBYREGIONPROC = void function(uint);
    alias PFNGLMEMORYBARRIERPROC = void function(uint);
    alias PFNGLGETBOOLEANI_VPROC = void function(uint, uint, ubyte*);
    alias PFNGLBINDIMAGETEXTUREPROC = void function(uint, uint, int, ubyte, int, uint, uint);
    alias PFNGLGETPROGRAMPIPELINEINFOLOGPROC = void function(uint, int, int*, char*);
    alias PFNGLVALIDATEPROGRAMPIPELINEPROC = void function(uint);
    alias PFNGLPROGRAMUNIFORMMATRIX4X3FVPROC = void function(uint, int, int, ubyte, const(float)*);
    alias PFNGLPROGRAMUNIFORMMATRIX3X4FVPROC = void function(uint, int, int, ubyte, const(float)*);
    alias PFNGLPROGRAMUNIFORMMATRIX4X2FVPROC = void function(uint, int, int, ubyte, const(float)*);
    alias PFNGLPROGRAMUNIFORMMATRIX2X4FVPROC = void function(uint, int, int, ubyte, const(float)*);
    alias PFNGLPROGRAMUNIFORMMATRIX3X2FVPROC = void function(uint, int, int, ubyte, const(float)*);
    alias PFNGLPROGRAMUNIFORMMATRIX2X3FVPROC = void function(uint, int, int, ubyte, const(float)*);
    alias PFNGLPROGRAMUNIFORMMATRIX4FVPROC = void function(uint, int, int, ubyte, const(float)*);
    alias PFNGLPROGRAMUNIFORMMATRIX3FVPROC = void function(uint, int, int, ubyte, const(float)*);
    alias PFNGLPROGRAMUNIFORMMATRIX2FVPROC = void function(uint, int, int, ubyte, const(float)*);
    alias PFNGLPROGRAMUNIFORM4FVPROC = void function(uint, int, int, const(float)*);
    alias PFNGLPROGRAMUNIFORM3FVPROC = void function(uint, int, int, const(float)*);
    alias PFNGLPROGRAMUNIFORM2FVPROC = void function(uint, int, int, const(float)*);
    alias PFNGLPROGRAMUNIFORM1FVPROC = void function(uint, int, int, const(float)*);
    alias PFNGLPROGRAMUNIFORM4UIVPROC = void function(uint, int, int, const(uint)*);
    alias PFNGLPROGRAMUNIFORM3UIVPROC = void function(uint, int, int, const(uint)*);
    alias PFNGLPROGRAMUNIFORM2UIVPROC = void function(uint, int, int, const(uint)*);
    alias PFNGLPROGRAMUNIFORM1UIVPROC = void function(uint, int, int, const(uint)*);
    alias PFNGLPROGRAMUNIFORM4IVPROC = void function(uint, int, int, const(int)*);
    alias PFNGLPROGRAMUNIFORM3IVPROC = void function(uint, int, int, const(int)*);
    alias PFNGLPROGRAMUNIFORM2IVPROC = void function(uint, int, int, const(int)*);
    alias PFNGLPROGRAMUNIFORM1IVPROC = void function(uint, int, int, const(int)*);
    alias PFNGLPROGRAMUNIFORM4FPROC = void function(uint, int, float, float, float, float);
    alias PFNGLPROGRAMUNIFORM3FPROC = void function(uint, int, float, float, float);
    alias PFNGLPROGRAMUNIFORM2FPROC = void function(uint, int, float, float);
    alias PFNGLPROGRAMUNIFORM1FPROC = void function(uint, int, float);
    alias PFNGLPROGRAMUNIFORM4UIPROC = void function(uint, int, uint, uint, uint, uint);
    alias PFNGLPROGRAMUNIFORM3UIPROC = void function(uint, int, uint, uint, uint);
    alias PFNGLPROGRAMUNIFORM2UIPROC = void function(uint, int, uint, uint);
    alias PFNGLPROGRAMUNIFORM1UIPROC = void function(uint, int, uint);
    alias PFNGLPROGRAMUNIFORM4IPROC = void function(uint, int, int, int, int, int);
    alias PFNGLPROGRAMUNIFORM3IPROC = void function(uint, int, int, int, int);
    alias PFNGLPROGRAMUNIFORM2IPROC = void function(uint, int, int, int);
    alias PFNGLPROGRAMUNIFORM1IPROC = void function(uint, int, int);
    alias PFNGLGETPROGRAMPIPELINEIVPROC = void function(uint, uint, int*);
    alias PFNGLISPROGRAMPIPELINEPROC = ubyte function(uint);
    alias PFNGLGENPROGRAMPIPELINESPROC = void function(int, uint*);
    alias PFNGLDELETEPROGRAMPIPELINESPROC = void function(int, const(uint)*);
    alias PFNGLBINDPROGRAMPIPELINEPROC = void function(uint);
    alias PFNGLCREATESHADERPROGRAMVPROC = uint function(uint, int, const(const(char)*)*);
    alias PFNGLACTIVESHADERPROGRAMPROC = void function(uint, uint);
    alias PFNGLUSEPROGRAMSTAGESPROC = void function(uint, uint, uint);
    alias PFNGLGETPROGRAMRESOURCELOCATIONPROC = int function(uint, uint, const(char)*);
    alias PFNGLGETPROGRAMRESOURCEIVPROC = void function(uint, uint, uint, int, const(uint)*, int, int*, int*);
    alias PFNGLGETPROGRAMRESOURCENAMEPROC = void function(uint, uint, uint, int, int*, char*);
    alias PFNGLGETPROGRAMRESOURCEINDEXPROC = uint function(uint, uint, const(char)*);
    alias PFNGLGETPROGRAMINTERFACEIVPROC = void function(uint, uint, uint, int*);
    alias PFNGLGETFRAMEBUFFERPARAMETERIVPROC = void function(uint, uint, int*);
    alias PFNGLFRAMEBUFFERPARAMETERIPROC = void function(uint, uint, int);
    alias PFNGLDRAWELEMENTSINDIRECTPROC = void function(uint, uint, const(void)*);
    alias PFNGLDRAWARRAYSINDIRECTPROC = void function(uint, const(void)*);
    alias PFNGLDISPATCHCOMPUTEINDIRECTPROC = void function(c_long);
    alias PFNGLDISPATCHCOMPUTEPROC = void function(uint, uint, uint);
    void glGetInternalformativ(uint, uint, uint, int, int*) @nogc nothrow;
    void glTexStorage3D(uint, int, uint, int, int, int) @nogc nothrow;
    void glTexStorage2D(uint, int, uint, int, int) @nogc nothrow;
    void glInvalidateSubFramebuffer(uint, int, const(uint)*, int, int, int, int) @nogc nothrow;
    void glInvalidateFramebuffer(uint, int, const(uint)*) @nogc nothrow;
    void glProgramParameteri(uint, uint, int) @nogc nothrow;
    void glProgramBinary(uint, uint, const(void)*, int) @nogc nothrow;
    void glGetProgramBinary(uint, int, int*, uint*, void*) @nogc nothrow;
    void glResumeTransformFeedback() @nogc nothrow;
    void glPauseTransformFeedback() @nogc nothrow;
    ubyte glIsTransformFeedback(uint) @nogc nothrow;
    void glGenTransformFeedbacks(int, uint*) @nogc nothrow;
    void glDeleteTransformFeedbacks(int, const(uint)*) @nogc nothrow;
    void glBindTransformFeedback(uint, uint) @nogc nothrow;
    void glVertexAttribDivisor(uint, uint) @nogc nothrow;
    void glGetSamplerParameterfv(uint, uint, float*) @nogc nothrow;
    void glGetSamplerParameteriv(uint, uint, int*) @nogc nothrow;
    void glSamplerParameterfv(uint, uint, const(float)*) @nogc nothrow;
    void glSamplerParameterf(uint, uint, float) @nogc nothrow;
    void glSamplerParameteriv(uint, uint, const(int)*) @nogc nothrow;
    void glSamplerParameteri(uint, uint, int) @nogc nothrow;
    void glBindSampler(uint, uint) @nogc nothrow;
    ubyte glIsSampler(uint) @nogc nothrow;
    void glDeleteSamplers(int, const(uint)*) @nogc nothrow;
    void glGenSamplers(int, uint*) @nogc nothrow;
    void glGetBufferParameteri64v(uint, uint, long*) @nogc nothrow;
    void glGetInteger64i_v(uint, uint, long*) @nogc nothrow;
    void glGetSynciv(__GLsync*, uint, int, int*, int*) @nogc nothrow;
    void glGetInteger64v(uint, long*) @nogc nothrow;
    void glWaitSync(__GLsync*, uint, ulong) @nogc nothrow;
    uint glClientWaitSync(__GLsync*, uint, ulong) @nogc nothrow;
    void glDeleteSync(__GLsync*) @nogc nothrow;
    ubyte glIsSync(__GLsync*) @nogc nothrow;
    __GLsync* glFenceSync(uint, uint) @nogc nothrow;
    void glDrawElementsInstanced(uint, int, uint, const(void)*, int) @nogc nothrow;
    void glDrawArraysInstanced(uint, int, int, int) @nogc nothrow;
    void glUniformBlockBinding(uint, uint, uint) @nogc nothrow;
    void glGetActiveUniformBlockName(uint, uint, int, int*, char*) @nogc nothrow;
    void glGetActiveUniformBlockiv(uint, uint, uint, int*) @nogc nothrow;
    uint glGetUniformBlockIndex(uint, const(char)*) @nogc nothrow;
    void glGetActiveUniformsiv(uint, int, const(uint)*, uint, int*) @nogc nothrow;
    void glGetUniformIndices(uint, int, const(const(char)*)*, uint*) @nogc nothrow;
    void glCopyBufferSubData(uint, uint, c_long, c_long, c_long) @nogc nothrow;
    const(ubyte)* glGetStringi(uint, uint) @nogc nothrow;
    void glClearBufferfi(uint, int, float, int) @nogc nothrow;
    void glClearBufferfv(uint, int, const(float)*) @nogc nothrow;
    void glClearBufferuiv(uint, int, const(uint)*) @nogc nothrow;
    void glClearBufferiv(uint, int, const(int)*) @nogc nothrow;
    void glUniform4uiv(int, int, const(uint)*) @nogc nothrow;
    void glUniform3uiv(int, int, const(uint)*) @nogc nothrow;
    alias PFNGLACTIVETEXTUREPROC = void function(uint);
    alias PFNGLATTACHSHADERPROC = void function(uint, uint);
    alias PFNGLBINDATTRIBLOCATIONPROC = void function(uint, uint, const(char)*);
    alias PFNGLBINDBUFFERPROC = void function(uint, uint);
    alias PFNGLBINDFRAMEBUFFERPROC = void function(uint, uint);
    alias PFNGLBINDRENDERBUFFERPROC = void function(uint, uint);
    alias PFNGLBINDTEXTUREPROC = void function(uint, uint);
    alias PFNGLBLENDCOLORPROC = void function(float, float, float, float);
    alias PFNGLBLENDEQUATIONPROC = void function(uint);
    alias PFNGLBLENDEQUATIONSEPARATEPROC = void function(uint, uint);
    alias PFNGLBLENDFUNCPROC = void function(uint, uint);
    alias PFNGLBLENDFUNCSEPARATEPROC = void function(uint, uint, uint, uint);
    alias PFNGLBUFFERDATAPROC = void function(uint, c_long, const(void)*, uint);
    alias PFNGLBUFFERSUBDATAPROC = void function(uint, c_long, c_long, const(void)*);
    alias PFNGLCHECKFRAMEBUFFERSTATUSPROC = uint function(uint);
    alias PFNGLCLEARPROC = void function(uint);
    alias PFNGLCLEARCOLORPROC = void function(float, float, float, float);
    alias PFNGLCLEARDEPTHFPROC = void function(float);
    alias PFNGLCLEARSTENCILPROC = void function(int);
    alias PFNGLCOLORMASKPROC = void function(ubyte, ubyte, ubyte, ubyte);
    alias PFNGLCOMPILESHADERPROC = void function(uint);
    alias PFNGLCOMPRESSEDTEXIMAGE2DPROC = void function(uint, int, uint, int, int, int, int, const(void)*);
    alias PFNGLCOMPRESSEDTEXSUBIMAGE2DPROC = void function(uint, int, int, int, int, int, uint, int, const(void)*);
    alias PFNGLCOPYTEXIMAGE2DPROC = void function(uint, int, uint, int, int, int, int, int);
    alias PFNGLCOPYTEXSUBIMAGE2DPROC = void function(uint, int, int, int, int, int, int, int);
    alias PFNGLCREATEPROGRAMPROC = uint function();
    alias PFNGLCREATESHADERPROC = uint function(uint);
    alias PFNGLCULLFACEPROC = void function(uint);
    alias PFNGLDELETEBUFFERSPROC = void function(int, const(uint)*);
    alias PFNGLDELETEFRAMEBUFFERSPROC = void function(int, const(uint)*);
    alias PFNGLDELETEPROGRAMPROC = void function(uint);
    alias PFNGLDELETERENDERBUFFERSPROC = void function(int, const(uint)*);
    alias PFNGLDELETESHADERPROC = void function(uint);
    alias PFNGLDELETETEXTURESPROC = void function(int, const(uint)*);
    alias PFNGLDEPTHFUNCPROC = void function(uint);
    alias PFNGLDEPTHMASKPROC = void function(ubyte);
    alias PFNGLDEPTHRANGEFPROC = void function(float, float);
    alias PFNGLDETACHSHADERPROC = void function(uint, uint);
    alias PFNGLDISABLEPROC = void function(uint);
    alias PFNGLDISABLEVERTEXATTRIBARRAYPROC = void function(uint);
    alias PFNGLDRAWARRAYSPROC = void function(uint, int, int);
    alias PFNGLDRAWELEMENTSPROC = void function(uint, int, uint, const(void)*);
    alias PFNGLENABLEPROC = void function(uint);
    alias PFNGLENABLEVERTEXATTRIBARRAYPROC = void function(uint);
    alias PFNGLFINISHPROC = void function();
    alias PFNGLFLUSHPROC = void function();
    alias PFNGLFRAMEBUFFERRENDERBUFFERPROC = void function(uint, uint, uint, uint);
    alias PFNGLFRAMEBUFFERTEXTURE2DPROC = void function(uint, uint, uint, uint, int);
    alias PFNGLFRONTFACEPROC = void function(uint);
    alias PFNGLGENBUFFERSPROC = void function(int, uint*);
    alias PFNGLGENERATEMIPMAPPROC = void function(uint);
    alias PFNGLGENFRAMEBUFFERSPROC = void function(int, uint*);
    alias PFNGLGENRENDERBUFFERSPROC = void function(int, uint*);
    alias PFNGLGENTEXTURESPROC = void function(int, uint*);
    alias PFNGLGETACTIVEATTRIBPROC = void function(uint, uint, int, int*, int*, uint*, char*);
    alias PFNGLGETACTIVEUNIFORMPROC = void function(uint, uint, int, int*, int*, uint*, char*);
    alias PFNGLGETATTACHEDSHADERSPROC = void function(uint, int, int*, uint*);
    alias PFNGLGETATTRIBLOCATIONPROC = int function(uint, const(char)*);
    alias PFNGLGETBOOLEANVPROC = void function(uint, ubyte*);
    alias PFNGLGETBUFFERPARAMETERIVPROC = void function(uint, uint, int*);
    alias PFNGLGETERRORPROC = uint function();
    alias PFNGLGETFLOATVPROC = void function(uint, float*);
    alias PFNGLGETFRAMEBUFFERATTACHMENTPARAMETERIVPROC = void function(uint, uint, uint, int*);
    alias PFNGLGETINTEGERVPROC = void function(uint, int*);
    alias PFNGLGETPROGRAMIVPROC = void function(uint, uint, int*);
    alias PFNGLGETPROGRAMINFOLOGPROC = void function(uint, int, int*, char*);
    alias PFNGLGETRENDERBUFFERPARAMETERIVPROC = void function(uint, uint, int*);
    alias PFNGLGETSHADERIVPROC = void function(uint, uint, int*);
    alias PFNGLGETSHADERINFOLOGPROC = void function(uint, int, int*, char*);
    alias PFNGLGETSHADERPRECISIONFORMATPROC = void function(uint, uint, int*, int*);
    alias PFNGLGETSHADERSOURCEPROC = void function(uint, int, int*, char*);
    alias PFNGLGETSTRINGPROC = const(ubyte)* function(uint);
    alias PFNGLGETTEXPARAMETERFVPROC = void function(uint, uint, float*);
    alias PFNGLGETTEXPARAMETERIVPROC = void function(uint, uint, int*);
    alias PFNGLGETUNIFORMFVPROC = void function(uint, int, float*);
    alias PFNGLGETUNIFORMIVPROC = void function(uint, int, int*);
    alias PFNGLGETUNIFORMLOCATIONPROC = int function(uint, const(char)*);
    alias PFNGLGETVERTEXATTRIBFVPROC = void function(uint, uint, float*);
    alias PFNGLGETVERTEXATTRIBIVPROC = void function(uint, uint, int*);
    alias PFNGLGETVERTEXATTRIBPOINTERVPROC = void function(uint, uint, void**);
    alias PFNGLHINTPROC = void function(uint, uint);
    alias PFNGLISBUFFERPROC = ubyte function(uint);
    alias PFNGLISENABLEDPROC = ubyte function(uint);
    alias PFNGLISFRAMEBUFFERPROC = ubyte function(uint);
    alias PFNGLISPROGRAMPROC = ubyte function(uint);
    alias PFNGLISRENDERBUFFERPROC = ubyte function(uint);
    alias PFNGLISSHADERPROC = ubyte function(uint);
    alias PFNGLISTEXTUREPROC = ubyte function(uint);
    alias PFNGLLINEWIDTHPROC = void function(float);
    alias PFNGLLINKPROGRAMPROC = void function(uint);
    alias PFNGLPIXELSTOREIPROC = void function(uint, int);
    alias PFNGLPOLYGONOFFSETPROC = void function(float, float);
    alias PFNGLREADPIXELSPROC = void function(int, int, int, int, uint, uint, void*);
    alias PFNGLRELEASESHADERCOMPILERPROC = void function();
    alias PFNGLRENDERBUFFERSTORAGEPROC = void function(uint, uint, int, int);
    alias PFNGLSAMPLECOVERAGEPROC = void function(float, ubyte);
    alias PFNGLSCISSORPROC = void function(int, int, int, int);
    alias PFNGLSHADERBINARYPROC = void function(int, const(uint)*, uint, const(void)*, int);
    alias PFNGLSHADERSOURCEPROC = void function(uint, int, const(const(char)*)*, const(int)*);
    alias PFNGLSTENCILFUNCPROC = void function(uint, int, uint);
    alias PFNGLSTENCILFUNCSEPARATEPROC = void function(uint, uint, int, uint);
    alias PFNGLSTENCILMASKPROC = void function(uint);
    alias PFNGLSTENCILMASKSEPARATEPROC = void function(uint, uint);
    alias PFNGLSTENCILOPPROC = void function(uint, uint, uint);
    alias PFNGLSTENCILOPSEPARATEPROC = void function(uint, uint, uint, uint);
    alias PFNGLTEXIMAGE2DPROC = void function(uint, int, int, int, int, int, uint, uint, const(void)*);
    alias PFNGLTEXPARAMETERFPROC = void function(uint, uint, float);
    alias PFNGLTEXPARAMETERFVPROC = void function(uint, uint, const(float)*);
    alias PFNGLTEXPARAMETERIPROC = void function(uint, uint, int);
    alias PFNGLTEXPARAMETERIVPROC = void function(uint, uint, const(int)*);
    alias PFNGLTEXSUBIMAGE2DPROC = void function(uint, int, int, int, int, int, uint, uint, const(void)*);
    alias PFNGLUNIFORM1FPROC = void function(int, float);
    alias PFNGLUNIFORM1FVPROC = void function(int, int, const(float)*);
    alias PFNGLUNIFORM1IPROC = void function(int, int);
    alias PFNGLUNIFORM1IVPROC = void function(int, int, const(int)*);
    alias PFNGLUNIFORM2FPROC = void function(int, float, float);
    alias PFNGLUNIFORM2FVPROC = void function(int, int, const(float)*);
    alias PFNGLUNIFORM2IPROC = void function(int, int, int);
    alias PFNGLUNIFORM2IVPROC = void function(int, int, const(int)*);
    alias PFNGLUNIFORM3FPROC = void function(int, float, float, float);
    alias PFNGLUNIFORM3FVPROC = void function(int, int, const(float)*);
    alias PFNGLUNIFORM3IPROC = void function(int, int, int, int);
    alias PFNGLUNIFORM3IVPROC = void function(int, int, const(int)*);
    alias PFNGLUNIFORM4FPROC = void function(int, float, float, float, float);
    alias PFNGLUNIFORM4FVPROC = void function(int, int, const(float)*);
    alias PFNGLUNIFORM4IPROC = void function(int, int, int, int, int);
    alias PFNGLUNIFORM4IVPROC = void function(int, int, const(int)*);
    alias PFNGLUNIFORMMATRIX2FVPROC = void function(int, int, ubyte, const(float)*);
    alias PFNGLUNIFORMMATRIX3FVPROC = void function(int, int, ubyte, const(float)*);
    alias PFNGLUNIFORMMATRIX4FVPROC = void function(int, int, ubyte, const(float)*);
    alias PFNGLUSEPROGRAMPROC = void function(uint);
    alias PFNGLVALIDATEPROGRAMPROC = void function(uint);
    alias PFNGLVERTEXATTRIB1FPROC = void function(uint, float);
    alias PFNGLVERTEXATTRIB1FVPROC = void function(uint, const(float)*);
    alias PFNGLVERTEXATTRIB2FPROC = void function(uint, float, float);
    alias PFNGLVERTEXATTRIB2FVPROC = void function(uint, const(float)*);
    alias PFNGLVERTEXATTRIB3FPROC = void function(uint, float, float, float);
    alias PFNGLVERTEXATTRIB3FVPROC = void function(uint, const(float)*);
    alias PFNGLVERTEXATTRIB4FPROC = void function(uint, float, float, float, float);
    alias PFNGLVERTEXATTRIB4FVPROC = void function(uint, const(float)*);
    alias PFNGLVERTEXATTRIBPOINTERPROC = void function(uint, int, uint, ubyte, int, const(void)*);
    alias PFNGLVIEWPORTPROC = void function(int, int, int, int);
    void glActiveTexture(uint) @nogc nothrow;
    void glAttachShader(uint, uint) @nogc nothrow;
    void glBindAttribLocation(uint, uint, const(char)*) @nogc nothrow;
    void glBindBuffer(uint, uint) @nogc nothrow;
    void glBindFramebuffer(uint, uint) @nogc nothrow;
    void glBindRenderbuffer(uint, uint) @nogc nothrow;
    void glBindTexture(uint, uint) @nogc nothrow;
    void glBlendColor(float, float, float, float) @nogc nothrow;
    void glBlendEquation(uint) @nogc nothrow;
    void glBlendEquationSeparate(uint, uint) @nogc nothrow;
    void glBlendFunc(uint, uint) @nogc nothrow;
    void glBlendFuncSeparate(uint, uint, uint, uint) @nogc nothrow;
    void glBufferData(uint, c_long, const(void)*, uint) @nogc nothrow;
    void glBufferSubData(uint, c_long, c_long, const(void)*) @nogc nothrow;
    uint glCheckFramebufferStatus(uint) @nogc nothrow;
    void glClear(uint) @nogc nothrow;
    void glClearColor(float, float, float, float) @nogc nothrow;
    void glClearDepthf(float) @nogc nothrow;
    void glClearStencil(int) @nogc nothrow;
    void glColorMask(ubyte, ubyte, ubyte, ubyte) @nogc nothrow;
    void glCompileShader(uint) @nogc nothrow;
    void glCompressedTexImage2D(uint, int, uint, int, int, int, int, const(void)*) @nogc nothrow;
    void glCompressedTexSubImage2D(uint, int, int, int, int, int, uint, int, const(void)*) @nogc nothrow;
    void glCopyTexImage2D(uint, int, uint, int, int, int, int, int) @nogc nothrow;
    void glCopyTexSubImage2D(uint, int, int, int, int, int, int, int) @nogc nothrow;
    uint glCreateProgram() @nogc nothrow;
    uint glCreateShader(uint) @nogc nothrow;
    void glCullFace(uint) @nogc nothrow;
    void glDeleteBuffers(int, const(uint)*) @nogc nothrow;
    void glDeleteFramebuffers(int, const(uint)*) @nogc nothrow;
    void glDeleteProgram(uint) @nogc nothrow;
    void glDeleteRenderbuffers(int, const(uint)*) @nogc nothrow;
    void glDeleteShader(uint) @nogc nothrow;
    void glDeleteTextures(int, const(uint)*) @nogc nothrow;
    void glDepthFunc(uint) @nogc nothrow;
    void glDepthMask(ubyte) @nogc nothrow;
    void glDepthRangef(float, float) @nogc nothrow;
    void glDetachShader(uint, uint) @nogc nothrow;
    void glDisable(uint) @nogc nothrow;
    void glDisableVertexAttribArray(uint) @nogc nothrow;
    void glDrawArrays(uint, int, int) @nogc nothrow;
    void glDrawElements(uint, int, uint, const(void)*) @nogc nothrow;
    void glEnable(uint) @nogc nothrow;
    void glEnableVertexAttribArray(uint) @nogc nothrow;
    void glFinish() @nogc nothrow;
    void glFlush() @nogc nothrow;
    void glFramebufferRenderbuffer(uint, uint, uint, uint) @nogc nothrow;
    void glFramebufferTexture2D(uint, uint, uint, uint, int) @nogc nothrow;
    void glFrontFace(uint) @nogc nothrow;
    void glGenBuffers(int, uint*) @nogc nothrow;
    void glGenerateMipmap(uint) @nogc nothrow;
    void glGenFramebuffers(int, uint*) @nogc nothrow;
    void glGenRenderbuffers(int, uint*) @nogc nothrow;
    void glGenTextures(int, uint*) @nogc nothrow;
    void glGetActiveAttrib(uint, uint, int, int*, int*, uint*, char*) @nogc nothrow;
    void glGetActiveUniform(uint, uint, int, int*, int*, uint*, char*) @nogc nothrow;
    void glGetAttachedShaders(uint, int, int*, uint*) @nogc nothrow;
    int glGetAttribLocation(uint, const(char)*) @nogc nothrow;
    void glGetBooleanv(uint, ubyte*) @nogc nothrow;
    void glGetBufferParameteriv(uint, uint, int*) @nogc nothrow;
    uint glGetError() @nogc nothrow;
    void glGetFloatv(uint, float*) @nogc nothrow;
    void glGetFramebufferAttachmentParameteriv(uint, uint, uint, int*) @nogc nothrow;
    void glGetIntegerv(uint, int*) @nogc nothrow;
    void glGetProgramiv(uint, uint, int*) @nogc nothrow;
    void glGetProgramInfoLog(uint, int, int*, char*) @nogc nothrow;
    void glGetRenderbufferParameteriv(uint, uint, int*) @nogc nothrow;
    void glGetShaderiv(uint, uint, int*) @nogc nothrow;
    void glGetShaderInfoLog(uint, int, int*, char*) @nogc nothrow;
    void glGetShaderPrecisionFormat(uint, uint, int*, int*) @nogc nothrow;
    void glGetShaderSource(uint, int, int*, char*) @nogc nothrow;
    const(ubyte)* glGetString(uint) @nogc nothrow;
    void glGetTexParameterfv(uint, uint, float*) @nogc nothrow;
    void glGetTexParameteriv(uint, uint, int*) @nogc nothrow;
    void glGetUniformfv(uint, int, float*) @nogc nothrow;
    void glGetUniformiv(uint, int, int*) @nogc nothrow;
    int glGetUniformLocation(uint, const(char)*) @nogc nothrow;
    void glGetVertexAttribfv(uint, uint, float*) @nogc nothrow;
    void glGetVertexAttribiv(uint, uint, int*) @nogc nothrow;
    void glGetVertexAttribPointerv(uint, uint, void**) @nogc nothrow;
    void glHint(uint, uint) @nogc nothrow;
    ubyte glIsBuffer(uint) @nogc nothrow;
    ubyte glIsEnabled(uint) @nogc nothrow;
    ubyte glIsFramebuffer(uint) @nogc nothrow;
    ubyte glIsProgram(uint) @nogc nothrow;
    ubyte glIsRenderbuffer(uint) @nogc nothrow;
    ubyte glIsShader(uint) @nogc nothrow;
    ubyte glIsTexture(uint) @nogc nothrow;
    void glLineWidth(float) @nogc nothrow;
    void glLinkProgram(uint) @nogc nothrow;
    void glPixelStorei(uint, int) @nogc nothrow;
    void glPolygonOffset(float, float) @nogc nothrow;
    void glReadPixels(int, int, int, int, uint, uint, void*) @nogc nothrow;
    void glReleaseShaderCompiler() @nogc nothrow;
    void glRenderbufferStorage(uint, uint, int, int) @nogc nothrow;
    void glSampleCoverage(float, ubyte) @nogc nothrow;
    void glScissor(int, int, int, int) @nogc nothrow;
    void glShaderBinary(int, const(uint)*, uint, const(void)*, int) @nogc nothrow;
    void glShaderSource(uint, int, const(const(char)*)*, const(int)*) @nogc nothrow;
    void glStencilFunc(uint, int, uint) @nogc nothrow;
    void glStencilFuncSeparate(uint, uint, int, uint) @nogc nothrow;
    void glStencilMask(uint) @nogc nothrow;
    void glStencilMaskSeparate(uint, uint) @nogc nothrow;
    void glStencilOp(uint, uint, uint) @nogc nothrow;
    void glStencilOpSeparate(uint, uint, uint, uint) @nogc nothrow;
    void glTexImage2D(uint, int, int, int, int, int, uint, uint, const(void)*) @nogc nothrow;
    void glTexParameterf(uint, uint, float) @nogc nothrow;
    void glTexParameterfv(uint, uint, const(float)*) @nogc nothrow;
    void glTexParameteri(uint, uint, int) @nogc nothrow;
    void glTexParameteriv(uint, uint, const(int)*) @nogc nothrow;
    void glTexSubImage2D(uint, int, int, int, int, int, uint, uint, const(void)*) @nogc nothrow;
    void glUniform1f(int, float) @nogc nothrow;
    void glUniform1fv(int, int, const(float)*) @nogc nothrow;
    void glUniform1i(int, int) @nogc nothrow;
    void glUniform1iv(int, int, const(int)*) @nogc nothrow;
    void glUniform2f(int, float, float) @nogc nothrow;
    void glUniform2fv(int, int, const(float)*) @nogc nothrow;
    void glUniform2i(int, int, int) @nogc nothrow;
    void glUniform2iv(int, int, const(int)*) @nogc nothrow;
    void glUniform3f(int, float, float, float) @nogc nothrow;
    void glUniform3fv(int, int, const(float)*) @nogc nothrow;
    void glUniform3i(int, int, int, int) @nogc nothrow;
    void glUniform3iv(int, int, const(int)*) @nogc nothrow;
    void glUniform4f(int, float, float, float, float) @nogc nothrow;
    void glUniform4fv(int, int, const(float)*) @nogc nothrow;
    void glUniform4i(int, int, int, int, int) @nogc nothrow;
    void glUniform4iv(int, int, const(int)*) @nogc nothrow;
    void glUniformMatrix2fv(int, int, ubyte, const(float)*) @nogc nothrow;
    void glUniformMatrix3fv(int, int, ubyte, const(float)*) @nogc nothrow;
    void glUniformMatrix4fv(int, int, ubyte, const(float)*) @nogc nothrow;
    void glUseProgram(uint) @nogc nothrow;
    void glValidateProgram(uint) @nogc nothrow;
    void glVertexAttrib1f(uint, float) @nogc nothrow;
    void glVertexAttrib1fv(uint, const(float)*) @nogc nothrow;
    void glVertexAttrib2f(uint, float, float) @nogc nothrow;
    void glVertexAttrib2fv(uint, const(float)*) @nogc nothrow;
    void glVertexAttrib3f(uint, float, float, float) @nogc nothrow;
    void glVertexAttrib3fv(uint, const(float)*) @nogc nothrow;
    void glVertexAttrib4f(uint, float, float, float, float) @nogc nothrow;
    void glVertexAttrib4fv(uint, const(float)*) @nogc nothrow;
    void glVertexAttribPointer(uint, int, uint, ubyte, int, const(void)*) @nogc nothrow;
    void glViewport(int, int, int, int) @nogc nothrow;
    alias GLhalf = ushort;
    void glUniform2uiv(int, int, const(uint)*) @nogc nothrow;
    void glUniform1uiv(int, int, const(uint)*) @nogc nothrow;
    void glUniform4ui(int, uint, uint, uint, uint) @nogc nothrow;
    void glUniform3ui(int, uint, uint, uint) @nogc nothrow;
    void glUniform2ui(int, uint, uint) @nogc nothrow;
    void glUniform1ui(int, uint) @nogc nothrow;
    int glGetFragDataLocation(uint, const(char)*) @nogc nothrow;
    void glGetUniformuiv(uint, int, uint*) @nogc nothrow;
    void glVertexAttribI4uiv(uint, const(uint)*) @nogc nothrow;
    void glVertexAttribI4iv(uint, const(int)*) @nogc nothrow;
    void glVertexAttribI4ui(uint, uint, uint, uint, uint) @nogc nothrow;
    void glVertexAttribI4i(uint, int, int, int, int) @nogc nothrow;
    void glGetVertexAttribIuiv(uint, uint, uint*) @nogc nothrow;
    void glGetVertexAttribIiv(uint, uint, int*) @nogc nothrow;
    void glVertexAttribIPointer(uint, int, uint, int, const(void)*) @nogc nothrow;
    void glGetTransformFeedbackVarying(uint, uint, int, int*, int*, uint*, char*) @nogc nothrow;
    void glTransformFeedbackVaryings(uint, int, const(const(char)*)*, uint) @nogc nothrow;
    void glBindBufferBase(uint, uint, uint) @nogc nothrow;
    void glBindBufferRange(uint, uint, uint, c_long, c_long) @nogc nothrow;
    void glEndTransformFeedback() @nogc nothrow;
    void glBeginTransformFeedback(uint) @nogc nothrow;
    void glGetIntegeri_v(uint, uint, int*) @nogc nothrow;
    ubyte glIsVertexArray(uint) @nogc nothrow;
    void glGenVertexArrays(int, uint*) @nogc nothrow;
    void glDeleteVertexArrays(int, const(uint)*) @nogc nothrow;
    void glBindVertexArray(uint) @nogc nothrow;
    void glFlushMappedBufferRange(uint, c_long, c_long) @nogc nothrow;
    void* glMapBufferRange(uint, c_long, c_long, uint) @nogc nothrow;
    void glFramebufferTextureLayer(uint, uint, uint, int, int) @nogc nothrow;
    void glRenderbufferStorageMultisample(uint, int, uint, int, int) @nogc nothrow;
    void glBlitFramebuffer(int, int, int, int, int, int, int, int, uint, uint) @nogc nothrow;
    void glUniformMatrix4x3fv(int, int, ubyte, const(float)*) @nogc nothrow;
    void glUniformMatrix3x4fv(int, int, ubyte, const(float)*) @nogc nothrow;
    void glUniformMatrix4x2fv(int, int, ubyte, const(float)*) @nogc nothrow;
    void glUniformMatrix2x4fv(int, int, ubyte, const(float)*) @nogc nothrow;
    void glUniformMatrix3x2fv(int, int, ubyte, const(float)*) @nogc nothrow;
    void glUniformMatrix2x3fv(int, int, ubyte, const(float)*) @nogc nothrow;
    void glDrawBuffers(int, const(uint)*) @nogc nothrow;
    void glGetBufferPointerv(uint, uint, void**) @nogc nothrow;
    ubyte glUnmapBuffer(uint) @nogc nothrow;
    void glGetQueryObjectuiv(uint, uint, uint*) @nogc nothrow;
    void glGetQueryiv(uint, uint, int*) @nogc nothrow;
    void glEndQuery(uint) @nogc nothrow;
    void glBeginQuery(uint, uint) @nogc nothrow;
    ubyte glIsQuery(uint) @nogc nothrow;
    void glDeleteQueries(int, const(uint)*) @nogc nothrow;
    void glGenQueries(int, uint*) @nogc nothrow;
    void glCompressedTexSubImage3D(uint, int, int, int, int, int, int, int, uint, int, const(void)*) @nogc nothrow;
    void glCompressedTexImage3D(uint, int, uint, int, int, int, int, int, const(void)*) @nogc nothrow;
    void glCopyTexSubImage3D(uint, int, int, int, int, int, int, int, int) @nogc nothrow;
    void glTexSubImage3D(uint, int, int, int, int, int, int, int, uint, uint, const(void)*) @nogc nothrow;
    void glTexImage3D(uint, int, int, int, int, int, int, uint, uint, const(void)*) @nogc nothrow;
    void glDrawRangeElements(uint, uint, uint, int, uint, const(void)*) @nogc nothrow;
    void glReadBuffer(uint) @nogc nothrow;
    alias PFNGLGETINTERNALFORMATIVPROC = void function(uint, uint, uint, int, int*);
    alias PFNGLTEXSTORAGE3DPROC = void function(uint, int, uint, int, int, int);
    alias PFNGLTEXSTORAGE2DPROC = void function(uint, int, uint, int, int);
    alias PFNGLINVALIDATESUBFRAMEBUFFERPROC = void function(uint, int, const(uint)*, int, int, int, int);
    alias PFNGLINVALIDATEFRAMEBUFFERPROC = void function(uint, int, const(uint)*);
    alias PFNGLPROGRAMPARAMETERIPROC = void function(uint, uint, int);
    alias PFNGLPROGRAMBINARYPROC = void function(uint, uint, const(void)*, int);
    alias PFNGLGETPROGRAMBINARYPROC = void function(uint, int, int*, uint*, void*);
    alias PFNGLRESUMETRANSFORMFEEDBACKPROC = void function();
    alias PFNGLPAUSETRANSFORMFEEDBACKPROC = void function();
    alias PFNGLISTRANSFORMFEEDBACKPROC = ubyte function(uint);
    alias PFNGLGENTRANSFORMFEEDBACKSPROC = void function(int, uint*);
    alias PFNGLDELETETRANSFORMFEEDBACKSPROC = void function(int, const(uint)*);
    alias PFNGLBINDTRANSFORMFEEDBACKPROC = void function(uint, uint);
    alias PFNGLVERTEXATTRIBDIVISORPROC = void function(uint, uint);
    alias PFNGLGETSAMPLERPARAMETERFVPROC = void function(uint, uint, float*);
    alias PFNGLGETSAMPLERPARAMETERIVPROC = void function(uint, uint, int*);
    alias PFNGLSAMPLERPARAMETERFVPROC = void function(uint, uint, const(float)*);
    alias PFNGLSAMPLERPARAMETERFPROC = void function(uint, uint, float);
    alias PFNGLSAMPLERPARAMETERIVPROC = void function(uint, uint, const(int)*);
    alias PFNGLSAMPLERPARAMETERIPROC = void function(uint, uint, int);
    alias PFNGLBINDSAMPLERPROC = void function(uint, uint);
    alias PFNGLISSAMPLERPROC = ubyte function(uint);
    alias PFNGLDELETESAMPLERSPROC = void function(int, const(uint)*);
    alias PFNGLGENSAMPLERSPROC = void function(int, uint*);
    alias PFNGLGETBUFFERPARAMETERI64VPROC = void function(uint, uint, long*);
    alias PFNGLGETINTEGER64I_VPROC = void function(uint, uint, long*);
    alias PFNGLGETSYNCIVPROC = void function(__GLsync*, uint, int, int*, int*);
    alias PFNGLGETINTEGER64VPROC = void function(uint, long*);
    alias PFNGLWAITSYNCPROC = void function(__GLsync*, uint, ulong);
    alias PFNGLCLIENTWAITSYNCPROC = uint function(__GLsync*, uint, ulong);
    alias PFNGLDELETESYNCPROC = void function(__GLsync*);
    alias PFNGLISSYNCPROC = ubyte function(__GLsync*);
    alias PFNGLFENCESYNCPROC = __GLsync* function(uint, uint);
    alias PFNGLDRAWELEMENTSINSTANCEDPROC = void function(uint, int, uint, const(void)*, int);
    alias PFNGLDRAWARRAYSINSTANCEDPROC = void function(uint, int, int, int);
    alias PFNGLUNIFORMBLOCKBINDINGPROC = void function(uint, uint, uint);
    alias PFNGLGETACTIVEUNIFORMBLOCKNAMEPROC = void function(uint, uint, int, int*, char*);
    alias PFNGLGETACTIVEUNIFORMBLOCKIVPROC = void function(uint, uint, uint, int*);
    alias PFNGLGETUNIFORMBLOCKINDEXPROC = uint function(uint, const(char)*);
    alias PFNGLGETACTIVEUNIFORMSIVPROC = void function(uint, int, const(uint)*, uint, int*);
    alias PFNGLGETUNIFORMINDICESPROC = void function(uint, int, const(const(char)*)*, uint*);
    alias PFNGLCOPYBUFFERSUBDATAPROC = void function(uint, uint, c_long, c_long, c_long);
    alias PFNGLGETSTRINGIPROC = const(ubyte)* function(uint, uint);
    alias PFNGLCLEARBUFFERFIPROC = void function(uint, int, float, int);
    alias PFNGLCLEARBUFFERFVPROC = void function(uint, int, const(float)*);
    alias PFNGLCLEARBUFFERUIVPROC = void function(uint, int, const(uint)*);
    alias PFNGLCLEARBUFFERIVPROC = void function(uint, int, const(int)*);
    alias PFNGLUNIFORM4UIVPROC = void function(int, int, const(uint)*);
    alias PFNGLUNIFORM3UIVPROC = void function(int, int, const(uint)*);
    alias PFNGLUNIFORM2UIVPROC = void function(int, int, const(uint)*);
    alias PFNGLUNIFORM1UIVPROC = void function(int, int, const(uint)*);
    alias PFNGLUNIFORM4UIPROC = void function(int, uint, uint, uint, uint);
    alias PFNGLUNIFORM3UIPROC = void function(int, uint, uint, uint);
    alias PFNGLUNIFORM2UIPROC = void function(int, uint, uint);
    alias PFNGLUNIFORM1UIPROC = void function(int, uint);
    alias PFNGLGETFRAGDATALOCATIONPROC = int function(uint, const(char)*);
    alias PFNGLGETUNIFORMUIVPROC = void function(uint, int, uint*);
    alias PFNGLVERTEXATTRIBI4UIVPROC = void function(uint, const(uint)*);
    alias PFNGLVERTEXATTRIBI4IVPROC = void function(uint, const(int)*);
    alias PFNGLVERTEXATTRIBI4UIPROC = void function(uint, uint, uint, uint, uint);
    alias PFNGLVERTEXATTRIBI4IPROC = void function(uint, int, int, int, int);
    alias PFNGLGETVERTEXATTRIBIUIVPROC = void function(uint, uint, uint*);
    alias PFNGLGETVERTEXATTRIBIIVPROC = void function(uint, uint, int*);
    alias PFNGLVERTEXATTRIBIPOINTERPROC = void function(uint, int, uint, int, const(void)*);
    alias PFNGLGETTRANSFORMFEEDBACKVARYINGPROC = void function(uint, uint, int, int*, int*, uint*, char*);
    alias PFNGLTRANSFORMFEEDBACKVARYINGSPROC = void function(uint, int, const(const(char)*)*, uint);
    alias PFNGLBINDBUFFERBASEPROC = void function(uint, uint, uint);
    alias PFNGLBINDBUFFERRANGEPROC = void function(uint, uint, uint, c_long, c_long);
    alias PFNGLENDTRANSFORMFEEDBACKPROC = void function();
    alias PFNGLBEGINTRANSFORMFEEDBACKPROC = void function(uint);
    alias PFNGLGETINTEGERI_VPROC = void function(uint, uint, int*);
    alias PFNGLISVERTEXARRAYPROC = ubyte function(uint);
    alias PFNGLGENVERTEXARRAYSPROC = void function(int, uint*);
    alias PFNGLDELETEVERTEXARRAYSPROC = void function(int, const(uint)*);
    alias PFNGLBINDVERTEXARRAYPROC = void function(uint);
    alias PFNGLFLUSHMAPPEDBUFFERRANGEPROC = void function(uint, c_long, c_long);
    alias PFNGLMAPBUFFERRANGEPROC = void* function(uint, c_long, c_long, uint);
    alias PFNGLFRAMEBUFFERTEXTURELAYERPROC = void function(uint, uint, uint, int, int);
    alias PFNGLRENDERBUFFERSTORAGEMULTISAMPLEPROC = void function(uint, int, uint, int, int);
    alias PFNGLREADBUFFERPROC = void function(uint);
    alias PFNGLDRAWRANGEELEMENTSPROC = void function(uint, uint, uint, int, uint, const(void)*);
    alias PFNGLTEXIMAGE3DPROC = void function(uint, int, int, int, int, int, int, uint, uint, const(void)*);
    alias PFNGLTEXSUBIMAGE3DPROC = void function(uint, int, int, int, int, int, int, int, uint, uint, const(void)*);
    alias PFNGLCOPYTEXSUBIMAGE3DPROC = void function(uint, int, int, int, int, int, int, int, int);
    alias PFNGLCOMPRESSEDTEXIMAGE3DPROC = void function(uint, int, uint, int, int, int, int, int, const(void)*);
    alias PFNGLCOMPRESSEDTEXSUBIMAGE3DPROC = void function(uint, int, int, int, int, int, int, int, uint, int, const(void)*);
    alias PFNGLGENQUERIESPROC = void function(int, uint*);
    alias PFNGLDELETEQUERIESPROC = void function(int, const(uint)*);
    alias PFNGLISQUERYPROC = ubyte function(uint);
    alias PFNGLBEGINQUERYPROC = void function(uint, uint);
    alias PFNGLENDQUERYPROC = void function(uint);
    alias PFNGLGETQUERYIVPROC = void function(uint, uint, int*);
    alias PFNGLGETQUERYOBJECTUIVPROC = void function(uint, uint, uint*);
    alias PFNGLUNMAPBUFFERPROC = ubyte function(uint);
    alias PFNGLGETBUFFERPOINTERVPROC = void function(uint, uint, void**);
    alias PFNGLDRAWBUFFERSPROC = void function(int, const(uint)*);
    alias PFNGLUNIFORMMATRIX2X3FVPROC = void function(int, int, ubyte, const(float)*);
    alias PFNGLUNIFORMMATRIX3X2FVPROC = void function(int, int, ubyte, const(float)*);
    alias PFNGLUNIFORMMATRIX2X4FVPROC = void function(int, int, ubyte, const(float)*);
    alias PFNGLUNIFORMMATRIX4X2FVPROC = void function(int, int, ubyte, const(float)*);
    alias PFNGLUNIFORMMATRIX3X4FVPROC = void function(int, int, ubyte, const(float)*);
    alias PFNGLUNIFORMMATRIX4X3FVPROC = void function(int, int, ubyte, const(float)*);
    alias PFNGLBLITFRAMEBUFFERPROC = void function(int, int, int, int, int, int, int, int, uint, uint);



    static if(!is(typeof(GL_TEXTURE_IMMUTABLE_LEVELS))) {
        private enum enumMixinStr_GL_TEXTURE_IMMUTABLE_LEVELS = `enum GL_TEXTURE_IMMUTABLE_LEVELS = 0x82DF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_IMMUTABLE_LEVELS); }))) {
            mixin(enumMixinStr_GL_TEXTURE_IMMUTABLE_LEVELS);
        }
    }




    static if(!is(typeof(GL_NUM_SAMPLE_COUNTS))) {
        private enum enumMixinStr_GL_NUM_SAMPLE_COUNTS = `enum GL_NUM_SAMPLE_COUNTS = 0x9380;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NUM_SAMPLE_COUNTS); }))) {
            mixin(enumMixinStr_GL_NUM_SAMPLE_COUNTS);
        }
    }




    static if(!is(typeof(GL_MAX_ELEMENT_INDEX))) {
        private enum enumMixinStr_GL_MAX_ELEMENT_INDEX = `enum GL_MAX_ELEMENT_INDEX = 0x8D6B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_ELEMENT_INDEX); }))) {
            mixin(enumMixinStr_GL_MAX_ELEMENT_INDEX);
        }
    }




    static if(!is(typeof(GL_TEXTURE_IMMUTABLE_FORMAT))) {
        private enum enumMixinStr_GL_TEXTURE_IMMUTABLE_FORMAT = `enum GL_TEXTURE_IMMUTABLE_FORMAT = 0x912F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_IMMUTABLE_FORMAT); }))) {
            mixin(enumMixinStr_GL_TEXTURE_IMMUTABLE_FORMAT);
        }
    }




    static if(!is(typeof(GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC))) {
        private enum enumMixinStr_GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC = `enum GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC = 0x9279;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC); }))) {
            mixin(enumMixinStr_GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC);
        }
    }




    static if(!is(typeof(GL_COMPRESSED_RGBA8_ETC2_EAC))) {
        private enum enumMixinStr_GL_COMPRESSED_RGBA8_ETC2_EAC = `enum GL_COMPRESSED_RGBA8_ETC2_EAC = 0x9278;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPRESSED_RGBA8_ETC2_EAC); }))) {
            mixin(enumMixinStr_GL_COMPRESSED_RGBA8_ETC2_EAC);
        }
    }




    static if(!is(typeof(GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2))) {
        private enum enumMixinStr_GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2 = `enum GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2 = 0x9277;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2); }))) {
            mixin(enumMixinStr_GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2);
        }
    }




    static if(!is(typeof(GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2))) {
        private enum enumMixinStr_GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2 = `enum GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2 = 0x9276;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2); }))) {
            mixin(enumMixinStr_GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2);
        }
    }




    static if(!is(typeof(GL_COMPRESSED_SRGB8_ETC2))) {
        private enum enumMixinStr_GL_COMPRESSED_SRGB8_ETC2 = `enum GL_COMPRESSED_SRGB8_ETC2 = 0x9275;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPRESSED_SRGB8_ETC2); }))) {
            mixin(enumMixinStr_GL_COMPRESSED_SRGB8_ETC2);
        }
    }




    static if(!is(typeof(GL_COMPRESSED_RGB8_ETC2))) {
        private enum enumMixinStr_GL_COMPRESSED_RGB8_ETC2 = `enum GL_COMPRESSED_RGB8_ETC2 = 0x9274;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPRESSED_RGB8_ETC2); }))) {
            mixin(enumMixinStr_GL_COMPRESSED_RGB8_ETC2);
        }
    }




    static if(!is(typeof(GL_COMPRESSED_SIGNED_RG11_EAC))) {
        private enum enumMixinStr_GL_COMPRESSED_SIGNED_RG11_EAC = `enum GL_COMPRESSED_SIGNED_RG11_EAC = 0x9273;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPRESSED_SIGNED_RG11_EAC); }))) {
            mixin(enumMixinStr_GL_COMPRESSED_SIGNED_RG11_EAC);
        }
    }




    static if(!is(typeof(GL_COMPRESSED_RG11_EAC))) {
        private enum enumMixinStr_GL_COMPRESSED_RG11_EAC = `enum GL_COMPRESSED_RG11_EAC = 0x9272;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPRESSED_RG11_EAC); }))) {
            mixin(enumMixinStr_GL_COMPRESSED_RG11_EAC);
        }
    }




    static if(!is(typeof(GL_COMPRESSED_SIGNED_R11_EAC))) {
        private enum enumMixinStr_GL_COMPRESSED_SIGNED_R11_EAC = `enum GL_COMPRESSED_SIGNED_R11_EAC = 0x9271;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPRESSED_SIGNED_R11_EAC); }))) {
            mixin(enumMixinStr_GL_COMPRESSED_SIGNED_R11_EAC);
        }
    }




    static if(!is(typeof(GL_COMPRESSED_R11_EAC))) {
        private enum enumMixinStr_GL_COMPRESSED_R11_EAC = `enum GL_COMPRESSED_R11_EAC = 0x9270;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPRESSED_R11_EAC); }))) {
            mixin(enumMixinStr_GL_COMPRESSED_R11_EAC);
        }
    }




    static if(!is(typeof(GL_PROGRAM_BINARY_FORMATS))) {
        private enum enumMixinStr_GL_PROGRAM_BINARY_FORMATS = `enum GL_PROGRAM_BINARY_FORMATS = 0x87FF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PROGRAM_BINARY_FORMATS); }))) {
            mixin(enumMixinStr_GL_PROGRAM_BINARY_FORMATS);
        }
    }




    static if(!is(typeof(GL_NUM_PROGRAM_BINARY_FORMATS))) {
        private enum enumMixinStr_GL_NUM_PROGRAM_BINARY_FORMATS = `enum GL_NUM_PROGRAM_BINARY_FORMATS = 0x87FE;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NUM_PROGRAM_BINARY_FORMATS); }))) {
            mixin(enumMixinStr_GL_NUM_PROGRAM_BINARY_FORMATS);
        }
    }




    static if(!is(typeof(GL_PROGRAM_BINARY_LENGTH))) {
        private enum enumMixinStr_GL_PROGRAM_BINARY_LENGTH = `enum GL_PROGRAM_BINARY_LENGTH = 0x8741;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PROGRAM_BINARY_LENGTH); }))) {
            mixin(enumMixinStr_GL_PROGRAM_BINARY_LENGTH);
        }
    }




    static if(!is(typeof(GL_PROGRAM_BINARY_RETRIEVABLE_HINT))) {
        private enum enumMixinStr_GL_PROGRAM_BINARY_RETRIEVABLE_HINT = `enum GL_PROGRAM_BINARY_RETRIEVABLE_HINT = 0x8257;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PROGRAM_BINARY_RETRIEVABLE_HINT); }))) {
            mixin(enumMixinStr_GL_PROGRAM_BINARY_RETRIEVABLE_HINT);
        }
    }




    static if(!is(typeof(GL_TRANSFORM_FEEDBACK_BINDING))) {
        private enum enumMixinStr_GL_TRANSFORM_FEEDBACK_BINDING = `enum GL_TRANSFORM_FEEDBACK_BINDING = 0x8E25;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_BINDING); }))) {
            mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_BINDING);
        }
    }




    static if(!is(typeof(GL_TRANSFORM_FEEDBACK_ACTIVE))) {
        private enum enumMixinStr_GL_TRANSFORM_FEEDBACK_ACTIVE = `enum GL_TRANSFORM_FEEDBACK_ACTIVE = 0x8E24;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_ACTIVE); }))) {
            mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_ACTIVE);
        }
    }




    static if(!is(typeof(GL_TRANSFORM_FEEDBACK_PAUSED))) {
        private enum enumMixinStr_GL_TRANSFORM_FEEDBACK_PAUSED = `enum GL_TRANSFORM_FEEDBACK_PAUSED = 0x8E23;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_PAUSED); }))) {
            mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_PAUSED);
        }
    }




    static if(!is(typeof(GL_TRANSFORM_FEEDBACK))) {
        private enum enumMixinStr_GL_TRANSFORM_FEEDBACK = `enum GL_TRANSFORM_FEEDBACK = 0x8E22;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK); }))) {
            mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK);
        }
    }




    static if(!is(typeof(GL_INT_2_10_10_10_REV))) {
        private enum enumMixinStr_GL_INT_2_10_10_10_REV = `enum GL_INT_2_10_10_10_REV = 0x8D9F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INT_2_10_10_10_REV); }))) {
            mixin(enumMixinStr_GL_INT_2_10_10_10_REV);
        }
    }




    static if(!is(typeof(GL_BLUE))) {
        private enum enumMixinStr_GL_BLUE = `enum GL_BLUE = 0x1905;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BLUE); }))) {
            mixin(enumMixinStr_GL_BLUE);
        }
    }




    static if(!is(typeof(GL_GREEN))) {
        private enum enumMixinStr_GL_GREEN = `enum GL_GREEN = 0x1904;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_GREEN); }))) {
            mixin(enumMixinStr_GL_GREEN);
        }
    }




    static if(!is(typeof(GL_TEXTURE_SWIZZLE_A))) {
        private enum enumMixinStr_GL_TEXTURE_SWIZZLE_A = `enum GL_TEXTURE_SWIZZLE_A = 0x8E45;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_SWIZZLE_A); }))) {
            mixin(enumMixinStr_GL_TEXTURE_SWIZZLE_A);
        }
    }




    static if(!is(typeof(GL_TEXTURE_SWIZZLE_B))) {
        private enum enumMixinStr_GL_TEXTURE_SWIZZLE_B = `enum GL_TEXTURE_SWIZZLE_B = 0x8E44;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_SWIZZLE_B); }))) {
            mixin(enumMixinStr_GL_TEXTURE_SWIZZLE_B);
        }
    }




    static if(!is(typeof(GL_TEXTURE_SWIZZLE_G))) {
        private enum enumMixinStr_GL_TEXTURE_SWIZZLE_G = `enum GL_TEXTURE_SWIZZLE_G = 0x8E43;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_SWIZZLE_G); }))) {
            mixin(enumMixinStr_GL_TEXTURE_SWIZZLE_G);
        }
    }




    static if(!is(typeof(GL_TEXTURE_SWIZZLE_R))) {
        private enum enumMixinStr_GL_TEXTURE_SWIZZLE_R = `enum GL_TEXTURE_SWIZZLE_R = 0x8E42;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_SWIZZLE_R); }))) {
            mixin(enumMixinStr_GL_TEXTURE_SWIZZLE_R);
        }
    }




    static if(!is(typeof(GL_RGB10_A2UI))) {
        private enum enumMixinStr_GL_RGB10_A2UI = `enum GL_RGB10_A2UI = 0x906F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB10_A2UI); }))) {
            mixin(enumMixinStr_GL_RGB10_A2UI);
        }
    }




    static if(!is(typeof(GL_SAMPLER_BINDING))) {
        private enum enumMixinStr_GL_SAMPLER_BINDING = `enum GL_SAMPLER_BINDING = 0x8919;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLER_BINDING); }))) {
            mixin(enumMixinStr_GL_SAMPLER_BINDING);
        }
    }




    static if(!is(typeof(GL_ANY_SAMPLES_PASSED_CONSERVATIVE))) {
        private enum enumMixinStr_GL_ANY_SAMPLES_PASSED_CONSERVATIVE = `enum GL_ANY_SAMPLES_PASSED_CONSERVATIVE = 0x8D6A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ANY_SAMPLES_PASSED_CONSERVATIVE); }))) {
            mixin(enumMixinStr_GL_ANY_SAMPLES_PASSED_CONSERVATIVE);
        }
    }




    static if(!is(typeof(GL_ANY_SAMPLES_PASSED))) {
        private enum enumMixinStr_GL_ANY_SAMPLES_PASSED = `enum GL_ANY_SAMPLES_PASSED = 0x8C2F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ANY_SAMPLES_PASSED); }))) {
            mixin(enumMixinStr_GL_ANY_SAMPLES_PASSED);
        }
    }




    static if(!is(typeof(GL_VERTEX_ATTRIB_ARRAY_DIVISOR))) {
        private enum enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_DIVISOR = `enum GL_VERTEX_ATTRIB_ARRAY_DIVISOR = 0x88FE;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_DIVISOR); }))) {
            mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_DIVISOR);
        }
    }




    static if(!is(typeof(GL_TIMEOUT_IGNORED))) {
        private enum enumMixinStr_GL_TIMEOUT_IGNORED = `enum GL_TIMEOUT_IGNORED = 0xFFFFFFFFFFFFFFFFLU;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TIMEOUT_IGNORED); }))) {
            mixin(enumMixinStr_GL_TIMEOUT_IGNORED);
        }
    }




    static if(!is(typeof(GL_SYNC_FLUSH_COMMANDS_BIT))) {
        private enum enumMixinStr_GL_SYNC_FLUSH_COMMANDS_BIT = `enum GL_SYNC_FLUSH_COMMANDS_BIT = 0x00000001;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SYNC_FLUSH_COMMANDS_BIT); }))) {
            mixin(enumMixinStr_GL_SYNC_FLUSH_COMMANDS_BIT);
        }
    }




    static if(!is(typeof(GL_WAIT_FAILED))) {
        private enum enumMixinStr_GL_WAIT_FAILED = `enum GL_WAIT_FAILED = 0x911D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_WAIT_FAILED); }))) {
            mixin(enumMixinStr_GL_WAIT_FAILED);
        }
    }




    static if(!is(typeof(GL_CONDITION_SATISFIED))) {
        private enum enumMixinStr_GL_CONDITION_SATISFIED = `enum GL_CONDITION_SATISFIED = 0x911C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_CONDITION_SATISFIED); }))) {
            mixin(enumMixinStr_GL_CONDITION_SATISFIED);
        }
    }




    static if(!is(typeof(GL_TIMEOUT_EXPIRED))) {
        private enum enumMixinStr_GL_TIMEOUT_EXPIRED = `enum GL_TIMEOUT_EXPIRED = 0x911B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TIMEOUT_EXPIRED); }))) {
            mixin(enumMixinStr_GL_TIMEOUT_EXPIRED);
        }
    }




    static if(!is(typeof(GL_ALREADY_SIGNALED))) {
        private enum enumMixinStr_GL_ALREADY_SIGNALED = `enum GL_ALREADY_SIGNALED = 0x911A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ALREADY_SIGNALED); }))) {
            mixin(enumMixinStr_GL_ALREADY_SIGNALED);
        }
    }




    static if(!is(typeof(GL_SIGNALED))) {
        private enum enumMixinStr_GL_SIGNALED = `enum GL_SIGNALED = 0x9119;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SIGNALED); }))) {
            mixin(enumMixinStr_GL_SIGNALED);
        }
    }




    static if(!is(typeof(GL_UNSIGNALED))) {
        private enum enumMixinStr_GL_UNSIGNALED = `enum GL_UNSIGNALED = 0x9118;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNALED); }))) {
            mixin(enumMixinStr_GL_UNSIGNALED);
        }
    }




    static if(!is(typeof(GL_SYNC_GPU_COMMANDS_COMPLETE))) {
        private enum enumMixinStr_GL_SYNC_GPU_COMMANDS_COMPLETE = `enum GL_SYNC_GPU_COMMANDS_COMPLETE = 0x9117;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SYNC_GPU_COMMANDS_COMPLETE); }))) {
            mixin(enumMixinStr_GL_SYNC_GPU_COMMANDS_COMPLETE);
        }
    }




    static if(!is(typeof(GL_SYNC_FENCE))) {
        private enum enumMixinStr_GL_SYNC_FENCE = `enum GL_SYNC_FENCE = 0x9116;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SYNC_FENCE); }))) {
            mixin(enumMixinStr_GL_SYNC_FENCE);
        }
    }




    static if(!is(typeof(GL_SYNC_FLAGS))) {
        private enum enumMixinStr_GL_SYNC_FLAGS = `enum GL_SYNC_FLAGS = 0x9115;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SYNC_FLAGS); }))) {
            mixin(enumMixinStr_GL_SYNC_FLAGS);
        }
    }




    static if(!is(typeof(GL_SYNC_STATUS))) {
        private enum enumMixinStr_GL_SYNC_STATUS = `enum GL_SYNC_STATUS = 0x9114;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SYNC_STATUS); }))) {
            mixin(enumMixinStr_GL_SYNC_STATUS);
        }
    }




    static if(!is(typeof(GL_SYNC_CONDITION))) {
        private enum enumMixinStr_GL_SYNC_CONDITION = `enum GL_SYNC_CONDITION = 0x9113;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SYNC_CONDITION); }))) {
            mixin(enumMixinStr_GL_SYNC_CONDITION);
        }
    }




    static if(!is(typeof(GL_OBJECT_TYPE))) {
        private enum enumMixinStr_GL_OBJECT_TYPE = `enum GL_OBJECT_TYPE = 0x9112;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_OBJECT_TYPE); }))) {
            mixin(enumMixinStr_GL_OBJECT_TYPE);
        }
    }




    static if(!is(typeof(GL_MAX_SERVER_WAIT_TIMEOUT))) {
        private enum enumMixinStr_GL_MAX_SERVER_WAIT_TIMEOUT = `enum GL_MAX_SERVER_WAIT_TIMEOUT = 0x9111;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_SERVER_WAIT_TIMEOUT); }))) {
            mixin(enumMixinStr_GL_MAX_SERVER_WAIT_TIMEOUT);
        }
    }




    static if(!is(typeof(GL_MAX_FRAGMENT_INPUT_COMPONENTS))) {
        private enum enumMixinStr_GL_MAX_FRAGMENT_INPUT_COMPONENTS = `enum GL_MAX_FRAGMENT_INPUT_COMPONENTS = 0x9125;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_FRAGMENT_INPUT_COMPONENTS); }))) {
            mixin(enumMixinStr_GL_MAX_FRAGMENT_INPUT_COMPONENTS);
        }
    }




    static if(!is(typeof(GL_MAX_VERTEX_OUTPUT_COMPONENTS))) {
        private enum enumMixinStr_GL_MAX_VERTEX_OUTPUT_COMPONENTS = `enum GL_MAX_VERTEX_OUTPUT_COMPONENTS = 0x9122;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VERTEX_OUTPUT_COMPONENTS); }))) {
            mixin(enumMixinStr_GL_MAX_VERTEX_OUTPUT_COMPONENTS);
        }
    }




    static if(!is(typeof(GL_INVALID_INDEX))) {
        private enum enumMixinStr_GL_INVALID_INDEX = `enum GL_INVALID_INDEX = 0xFFFFFFFFu;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INVALID_INDEX); }))) {
            mixin(enumMixinStr_GL_INVALID_INDEX);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER))) {
        private enum enumMixinStr_GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER = `enum GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER = 0x8A46;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER))) {
        private enum enumMixinStr_GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER = `enum GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER = 0x8A44;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES))) {
        private enum enumMixinStr_GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES = `enum GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES = 0x8A43;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS))) {
        private enum enumMixinStr_GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS = `enum GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS = 0x8A42;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BLOCK_NAME_LENGTH))) {
        private enum enumMixinStr_GL_UNIFORM_BLOCK_NAME_LENGTH = `enum GL_UNIFORM_BLOCK_NAME_LENGTH = 0x8A41;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BLOCK_NAME_LENGTH); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BLOCK_NAME_LENGTH);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BLOCK_DATA_SIZE))) {
        private enum enumMixinStr_GL_UNIFORM_BLOCK_DATA_SIZE = `enum GL_UNIFORM_BLOCK_DATA_SIZE = 0x8A40;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BLOCK_DATA_SIZE); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BLOCK_DATA_SIZE);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BLOCK_BINDING))) {
        private enum enumMixinStr_GL_UNIFORM_BLOCK_BINDING = `enum GL_UNIFORM_BLOCK_BINDING = 0x8A3F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BLOCK_BINDING); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BLOCK_BINDING);
        }
    }




    static if(!is(typeof(GL_UNIFORM_IS_ROW_MAJOR))) {
        private enum enumMixinStr_GL_UNIFORM_IS_ROW_MAJOR = `enum GL_UNIFORM_IS_ROW_MAJOR = 0x8A3E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_IS_ROW_MAJOR); }))) {
            mixin(enumMixinStr_GL_UNIFORM_IS_ROW_MAJOR);
        }
    }




    static if(!is(typeof(GL_UNIFORM_MATRIX_STRIDE))) {
        private enum enumMixinStr_GL_UNIFORM_MATRIX_STRIDE = `enum GL_UNIFORM_MATRIX_STRIDE = 0x8A3D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_MATRIX_STRIDE); }))) {
            mixin(enumMixinStr_GL_UNIFORM_MATRIX_STRIDE);
        }
    }




    static if(!is(typeof(GL_UNIFORM_ARRAY_STRIDE))) {
        private enum enumMixinStr_GL_UNIFORM_ARRAY_STRIDE = `enum GL_UNIFORM_ARRAY_STRIDE = 0x8A3C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_ARRAY_STRIDE); }))) {
            mixin(enumMixinStr_GL_UNIFORM_ARRAY_STRIDE);
        }
    }




    static if(!is(typeof(GL_UNIFORM_OFFSET))) {
        private enum enumMixinStr_GL_UNIFORM_OFFSET = `enum GL_UNIFORM_OFFSET = 0x8A3B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_OFFSET); }))) {
            mixin(enumMixinStr_GL_UNIFORM_OFFSET);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BLOCK_INDEX))) {
        private enum enumMixinStr_GL_UNIFORM_BLOCK_INDEX = `enum GL_UNIFORM_BLOCK_INDEX = 0x8A3A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BLOCK_INDEX); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BLOCK_INDEX);
        }
    }




    static if(!is(typeof(GL_UNIFORM_NAME_LENGTH))) {
        private enum enumMixinStr_GL_UNIFORM_NAME_LENGTH = `enum GL_UNIFORM_NAME_LENGTH = 0x8A39;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_NAME_LENGTH); }))) {
            mixin(enumMixinStr_GL_UNIFORM_NAME_LENGTH);
        }
    }




    static if(!is(typeof(GL_UNIFORM_SIZE))) {
        private enum enumMixinStr_GL_UNIFORM_SIZE = `enum GL_UNIFORM_SIZE = 0x8A38;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_SIZE); }))) {
            mixin(enumMixinStr_GL_UNIFORM_SIZE);
        }
    }




    static if(!is(typeof(GL_UNIFORM_TYPE))) {
        private enum enumMixinStr_GL_UNIFORM_TYPE = `enum GL_UNIFORM_TYPE = 0x8A37;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_TYPE); }))) {
            mixin(enumMixinStr_GL_UNIFORM_TYPE);
        }
    }




    static if(!is(typeof(GL_ACTIVE_UNIFORM_BLOCKS))) {
        private enum enumMixinStr_GL_ACTIVE_UNIFORM_BLOCKS = `enum GL_ACTIVE_UNIFORM_BLOCKS = 0x8A36;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ACTIVE_UNIFORM_BLOCKS); }))) {
            mixin(enumMixinStr_GL_ACTIVE_UNIFORM_BLOCKS);
        }
    }




    static if(!is(typeof(GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH))) {
        private enum enumMixinStr_GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH = `enum GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH = 0x8A35;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH); }))) {
            mixin(enumMixinStr_GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT))) {
        private enum enumMixinStr_GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT = `enum GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT = 0x8A34;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT);
        }
    }




    static if(!is(typeof(GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS))) {
        private enum enumMixinStr_GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS = `enum GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS = 0x8A33;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS); }))) {
            mixin(enumMixinStr_GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS);
        }
    }




    static if(!is(typeof(GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS))) {
        private enum enumMixinStr_GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS = `enum GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS = 0x8A31;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS); }))) {
            mixin(enumMixinStr_GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS);
        }
    }




    static if(!is(typeof(GL_MAX_UNIFORM_BLOCK_SIZE))) {
        private enum enumMixinStr_GL_MAX_UNIFORM_BLOCK_SIZE = `enum GL_MAX_UNIFORM_BLOCK_SIZE = 0x8A30;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_UNIFORM_BLOCK_SIZE); }))) {
            mixin(enumMixinStr_GL_MAX_UNIFORM_BLOCK_SIZE);
        }
    }




    static if(!is(typeof(GL_MAX_UNIFORM_BUFFER_BINDINGS))) {
        private enum enumMixinStr_GL_MAX_UNIFORM_BUFFER_BINDINGS = `enum GL_MAX_UNIFORM_BUFFER_BINDINGS = 0x8A2F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_UNIFORM_BUFFER_BINDINGS); }))) {
            mixin(enumMixinStr_GL_MAX_UNIFORM_BUFFER_BINDINGS);
        }
    }




    static if(!is(typeof(GL_MAX_COMBINED_UNIFORM_BLOCKS))) {
        private enum enumMixinStr_GL_MAX_COMBINED_UNIFORM_BLOCKS = `enum GL_MAX_COMBINED_UNIFORM_BLOCKS = 0x8A2E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMBINED_UNIFORM_BLOCKS); }))) {
            mixin(enumMixinStr_GL_MAX_COMBINED_UNIFORM_BLOCKS);
        }
    }




    static if(!is(typeof(GL_MAX_FRAGMENT_UNIFORM_BLOCKS))) {
        private enum enumMixinStr_GL_MAX_FRAGMENT_UNIFORM_BLOCKS = `enum GL_MAX_FRAGMENT_UNIFORM_BLOCKS = 0x8A2D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_FRAGMENT_UNIFORM_BLOCKS); }))) {
            mixin(enumMixinStr_GL_MAX_FRAGMENT_UNIFORM_BLOCKS);
        }
    }




    static if(!is(typeof(GL_MAX_VERTEX_UNIFORM_BLOCKS))) {
        private enum enumMixinStr_GL_MAX_VERTEX_UNIFORM_BLOCKS = `enum GL_MAX_VERTEX_UNIFORM_BLOCKS = 0x8A2B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VERTEX_UNIFORM_BLOCKS); }))) {
            mixin(enumMixinStr_GL_MAX_VERTEX_UNIFORM_BLOCKS);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BUFFER_SIZE))) {
        private enum enumMixinStr_GL_UNIFORM_BUFFER_SIZE = `enum GL_UNIFORM_BUFFER_SIZE = 0x8A2A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BUFFER_SIZE); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BUFFER_SIZE);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BUFFER_START))) {
        private enum enumMixinStr_GL_UNIFORM_BUFFER_START = `enum GL_UNIFORM_BUFFER_START = 0x8A29;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BUFFER_START); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BUFFER_START);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BUFFER_BINDING))) {
        private enum enumMixinStr_GL_UNIFORM_BUFFER_BINDING = `enum GL_UNIFORM_BUFFER_BINDING = 0x8A28;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BUFFER))) {
        private enum enumMixinStr_GL_UNIFORM_BUFFER = `enum GL_UNIFORM_BUFFER = 0x8A11;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BUFFER); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BUFFER);
        }
    }




    static if(!is(typeof(GL_COPY_WRITE_BUFFER_BINDING))) {
        private enum enumMixinStr_GL_COPY_WRITE_BUFFER_BINDING = `enum GL_COPY_WRITE_BUFFER_BINDING = 0x8F37;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COPY_WRITE_BUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_COPY_WRITE_BUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_COPY_READ_BUFFER_BINDING))) {
        private enum enumMixinStr_GL_COPY_READ_BUFFER_BINDING = `enum GL_COPY_READ_BUFFER_BINDING = 0x8F36;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COPY_READ_BUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_COPY_READ_BUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_COPY_WRITE_BUFFER))) {
        private enum enumMixinStr_GL_COPY_WRITE_BUFFER = `enum GL_COPY_WRITE_BUFFER = 0x8F37;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COPY_WRITE_BUFFER); }))) {
            mixin(enumMixinStr_GL_COPY_WRITE_BUFFER);
        }
    }




    static if(!is(typeof(GL_COPY_READ_BUFFER))) {
        private enum enumMixinStr_GL_COPY_READ_BUFFER = `enum GL_COPY_READ_BUFFER = 0x8F36;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COPY_READ_BUFFER); }))) {
            mixin(enumMixinStr_GL_COPY_READ_BUFFER);
        }
    }




    static if(!is(typeof(GL_PRIMITIVE_RESTART_FIXED_INDEX))) {
        private enum enumMixinStr_GL_PRIMITIVE_RESTART_FIXED_INDEX = `enum GL_PRIMITIVE_RESTART_FIXED_INDEX = 0x8D69;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PRIMITIVE_RESTART_FIXED_INDEX); }))) {
            mixin(enumMixinStr_GL_PRIMITIVE_RESTART_FIXED_INDEX);
        }
    }




    static if(!is(typeof(GL_SIGNED_NORMALIZED))) {
        private enum enumMixinStr_GL_SIGNED_NORMALIZED = `enum GL_SIGNED_NORMALIZED = 0x8F9C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SIGNED_NORMALIZED); }))) {
            mixin(enumMixinStr_GL_SIGNED_NORMALIZED);
        }
    }




    static if(!is(typeof(GL_RGBA8_SNORM))) {
        private enum enumMixinStr_GL_RGBA8_SNORM = `enum GL_RGBA8_SNORM = 0x8F97;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGBA8_SNORM); }))) {
            mixin(enumMixinStr_GL_RGBA8_SNORM);
        }
    }




    static if(!is(typeof(GL_RGB8_SNORM))) {
        private enum enumMixinStr_GL_RGB8_SNORM = `enum GL_RGB8_SNORM = 0x8F96;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB8_SNORM); }))) {
            mixin(enumMixinStr_GL_RGB8_SNORM);
        }
    }




    static if(!is(typeof(GL_RG8_SNORM))) {
        private enum enumMixinStr_GL_RG8_SNORM = `enum GL_RG8_SNORM = 0x8F95;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RG8_SNORM); }))) {
            mixin(enumMixinStr_GL_RG8_SNORM);
        }
    }




    static if(!is(typeof(GL_R8_SNORM))) {
        private enum enumMixinStr_GL_R8_SNORM = `enum GL_R8_SNORM = 0x8F94;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_R8_SNORM); }))) {
            mixin(enumMixinStr_GL_R8_SNORM);
        }
    }




    static if(!is(typeof(GL_VERTEX_ARRAY_BINDING))) {
        private enum enumMixinStr_GL_VERTEX_ARRAY_BINDING = `enum GL_VERTEX_ARRAY_BINDING = 0x85B5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_ARRAY_BINDING); }))) {
            mixin(enumMixinStr_GL_VERTEX_ARRAY_BINDING);
        }
    }




    static if(!is(typeof(GL_RG32UI))) {
        private enum enumMixinStr_GL_RG32UI = `enum GL_RG32UI = 0x823C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RG32UI); }))) {
            mixin(enumMixinStr_GL_RG32UI);
        }
    }




    static if(!is(typeof(GL_RG32I))) {
        private enum enumMixinStr_GL_RG32I = `enum GL_RG32I = 0x823B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RG32I); }))) {
            mixin(enumMixinStr_GL_RG32I);
        }
    }




    static if(!is(typeof(GL_RG16UI))) {
        private enum enumMixinStr_GL_RG16UI = `enum GL_RG16UI = 0x823A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RG16UI); }))) {
            mixin(enumMixinStr_GL_RG16UI);
        }
    }




    static if(!is(typeof(GL_RG16I))) {
        private enum enumMixinStr_GL_RG16I = `enum GL_RG16I = 0x8239;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RG16I); }))) {
            mixin(enumMixinStr_GL_RG16I);
        }
    }




    static if(!is(typeof(GL_RG8UI))) {
        private enum enumMixinStr_GL_RG8UI = `enum GL_RG8UI = 0x8238;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RG8UI); }))) {
            mixin(enumMixinStr_GL_RG8UI);
        }
    }




    static if(!is(typeof(GL_RG8I))) {
        private enum enumMixinStr_GL_RG8I = `enum GL_RG8I = 0x8237;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RG8I); }))) {
            mixin(enumMixinStr_GL_RG8I);
        }
    }




    static if(!is(typeof(GL_R32UI))) {
        private enum enumMixinStr_GL_R32UI = `enum GL_R32UI = 0x8236;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_R32UI); }))) {
            mixin(enumMixinStr_GL_R32UI);
        }
    }




    static if(!is(typeof(GL_R32I))) {
        private enum enumMixinStr_GL_R32I = `enum GL_R32I = 0x8235;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_R32I); }))) {
            mixin(enumMixinStr_GL_R32I);
        }
    }




    static if(!is(typeof(GL_R16UI))) {
        private enum enumMixinStr_GL_R16UI = `enum GL_R16UI = 0x8234;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_R16UI); }))) {
            mixin(enumMixinStr_GL_R16UI);
        }
    }




    static if(!is(typeof(GL_R16I))) {
        private enum enumMixinStr_GL_R16I = `enum GL_R16I = 0x8233;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_R16I); }))) {
            mixin(enumMixinStr_GL_R16I);
        }
    }




    static if(!is(typeof(GL_R8UI))) {
        private enum enumMixinStr_GL_R8UI = `enum GL_R8UI = 0x8232;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_R8UI); }))) {
            mixin(enumMixinStr_GL_R8UI);
        }
    }




    static if(!is(typeof(GL_R8I))) {
        private enum enumMixinStr_GL_R8I = `enum GL_R8I = 0x8231;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_R8I); }))) {
            mixin(enumMixinStr_GL_R8I);
        }
    }




    static if(!is(typeof(GL_RG32F))) {
        private enum enumMixinStr_GL_RG32F = `enum GL_RG32F = 0x8230;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RG32F); }))) {
            mixin(enumMixinStr_GL_RG32F);
        }
    }




    static if(!is(typeof(GL_RG16F))) {
        private enum enumMixinStr_GL_RG16F = `enum GL_RG16F = 0x822F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RG16F); }))) {
            mixin(enumMixinStr_GL_RG16F);
        }
    }




    static if(!is(typeof(GL_R32F))) {
        private enum enumMixinStr_GL_R32F = `enum GL_R32F = 0x822E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_R32F); }))) {
            mixin(enumMixinStr_GL_R32F);
        }
    }




    static if(!is(typeof(GL_R16F))) {
        private enum enumMixinStr_GL_R16F = `enum GL_R16F = 0x822D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_R16F); }))) {
            mixin(enumMixinStr_GL_R16F);
        }
    }




    static if(!is(typeof(GL_RG8))) {
        private enum enumMixinStr_GL_RG8 = `enum GL_RG8 = 0x822B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RG8); }))) {
            mixin(enumMixinStr_GL_RG8);
        }
    }




    static if(!is(typeof(GL_R8))) {
        private enum enumMixinStr_GL_R8 = `enum GL_R8 = 0x8229;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_R8); }))) {
            mixin(enumMixinStr_GL_R8);
        }
    }




    static if(!is(typeof(GL_RG_INTEGER))) {
        private enum enumMixinStr_GL_RG_INTEGER = `enum GL_RG_INTEGER = 0x8228;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RG_INTEGER); }))) {
            mixin(enumMixinStr_GL_RG_INTEGER);
        }
    }




    static if(!is(typeof(GL_RG))) {
        private enum enumMixinStr_GL_RG = `enum GL_RG = 0x8227;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RG); }))) {
            mixin(enumMixinStr_GL_RG);
        }
    }




    static if(!is(typeof(GL_MAP_UNSYNCHRONIZED_BIT))) {
        private enum enumMixinStr_GL_MAP_UNSYNCHRONIZED_BIT = `enum GL_MAP_UNSYNCHRONIZED_BIT = 0x0020;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAP_UNSYNCHRONIZED_BIT); }))) {
            mixin(enumMixinStr_GL_MAP_UNSYNCHRONIZED_BIT);
        }
    }




    static if(!is(typeof(GL_MAP_FLUSH_EXPLICIT_BIT))) {
        private enum enumMixinStr_GL_MAP_FLUSH_EXPLICIT_BIT = `enum GL_MAP_FLUSH_EXPLICIT_BIT = 0x0010;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAP_FLUSH_EXPLICIT_BIT); }))) {
            mixin(enumMixinStr_GL_MAP_FLUSH_EXPLICIT_BIT);
        }
    }




    static if(!is(typeof(GL_MAP_INVALIDATE_BUFFER_BIT))) {
        private enum enumMixinStr_GL_MAP_INVALIDATE_BUFFER_BIT = `enum GL_MAP_INVALIDATE_BUFFER_BIT = 0x0008;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAP_INVALIDATE_BUFFER_BIT); }))) {
            mixin(enumMixinStr_GL_MAP_INVALIDATE_BUFFER_BIT);
        }
    }




    static if(!is(typeof(GL_MAP_INVALIDATE_RANGE_BIT))) {
        private enum enumMixinStr_GL_MAP_INVALIDATE_RANGE_BIT = `enum GL_MAP_INVALIDATE_RANGE_BIT = 0x0004;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAP_INVALIDATE_RANGE_BIT); }))) {
            mixin(enumMixinStr_GL_MAP_INVALIDATE_RANGE_BIT);
        }
    }




    static if(!is(typeof(GL_MAP_WRITE_BIT))) {
        private enum enumMixinStr_GL_MAP_WRITE_BIT = `enum GL_MAP_WRITE_BIT = 0x0002;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAP_WRITE_BIT); }))) {
            mixin(enumMixinStr_GL_MAP_WRITE_BIT);
        }
    }




    static if(!is(typeof(GL_MAP_READ_BIT))) {
        private enum enumMixinStr_GL_MAP_READ_BIT = `enum GL_MAP_READ_BIT = 0x0001;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAP_READ_BIT); }))) {
            mixin(enumMixinStr_GL_MAP_READ_BIT);
        }
    }




    static if(!is(typeof(GL_HALF_FLOAT))) {
        private enum enumMixinStr_GL_HALF_FLOAT = `enum GL_HALF_FLOAT = 0x140B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_HALF_FLOAT); }))) {
            mixin(enumMixinStr_GL_HALF_FLOAT);
        }
    }




    static if(!is(typeof(GL_MAX_SAMPLES))) {
        private enum enumMixinStr_GL_MAX_SAMPLES = `enum GL_MAX_SAMPLES = 0x8D57;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_SAMPLES); }))) {
            mixin(enumMixinStr_GL_MAX_SAMPLES);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE = `enum GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE = 0x8D56;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT31))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT31 = `enum GL_COLOR_ATTACHMENT31 = 0x8CFF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT31); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT31);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT30))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT30 = `enum GL_COLOR_ATTACHMENT30 = 0x8CFE;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT30); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT30);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT29))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT29 = `enum GL_COLOR_ATTACHMENT29 = 0x8CFD;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT29); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT29);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT28))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT28 = `enum GL_COLOR_ATTACHMENT28 = 0x8CFC;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT28); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT28);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT27))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT27 = `enum GL_COLOR_ATTACHMENT27 = 0x8CFB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT27); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT27);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT26))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT26 = `enum GL_COLOR_ATTACHMENT26 = 0x8CFA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT26); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT26);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT25))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT25 = `enum GL_COLOR_ATTACHMENT25 = 0x8CF9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT25); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT25);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT24))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT24 = `enum GL_COLOR_ATTACHMENT24 = 0x8CF8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT24); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT24);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT23))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT23 = `enum GL_COLOR_ATTACHMENT23 = 0x8CF7;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT23); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT23);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT22))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT22 = `enum GL_COLOR_ATTACHMENT22 = 0x8CF6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT22); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT22);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT21))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT21 = `enum GL_COLOR_ATTACHMENT21 = 0x8CF5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT21); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT21);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT20))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT20 = `enum GL_COLOR_ATTACHMENT20 = 0x8CF4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT20); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT20);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT19))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT19 = `enum GL_COLOR_ATTACHMENT19 = 0x8CF3;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT19); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT19);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT18))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT18 = `enum GL_COLOR_ATTACHMENT18 = 0x8CF2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT18); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT18);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT17))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT17 = `enum GL_COLOR_ATTACHMENT17 = 0x8CF1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT17); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT17);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT16))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT16 = `enum GL_COLOR_ATTACHMENT16 = 0x8CF0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT16); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT16);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT15))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT15 = `enum GL_COLOR_ATTACHMENT15 = 0x8CEF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT15); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT15);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT14))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT14 = `enum GL_COLOR_ATTACHMENT14 = 0x8CEE;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT14); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT14);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT13))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT13 = `enum GL_COLOR_ATTACHMENT13 = 0x8CED;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT13); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT13);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT12))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT12 = `enum GL_COLOR_ATTACHMENT12 = 0x8CEC;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT12); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT12);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT11))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT11 = `enum GL_COLOR_ATTACHMENT11 = 0x8CEB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT11); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT11);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT10))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT10 = `enum GL_COLOR_ATTACHMENT10 = 0x8CEA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT10); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT10);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT9))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT9 = `enum GL_COLOR_ATTACHMENT9 = 0x8CE9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT9); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT9);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT8))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT8 = `enum GL_COLOR_ATTACHMENT8 = 0x8CE8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT8); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT8);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT7))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT7 = `enum GL_COLOR_ATTACHMENT7 = 0x8CE7;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT7); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT7);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT6))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT6 = `enum GL_COLOR_ATTACHMENT6 = 0x8CE6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT6); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT6);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT5))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT5 = `enum GL_COLOR_ATTACHMENT5 = 0x8CE5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT5); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT5);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT4))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT4 = `enum GL_COLOR_ATTACHMENT4 = 0x8CE4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT4); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT4);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT3))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT3 = `enum GL_COLOR_ATTACHMENT3 = 0x8CE3;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT3); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT3);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT2))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT2 = `enum GL_COLOR_ATTACHMENT2 = 0x8CE2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT2); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT2);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT1))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT1 = `enum GL_COLOR_ATTACHMENT1 = 0x8CE1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT1); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT1);
        }
    }




    static if(!is(typeof(GL_MAX_COLOR_ATTACHMENTS))) {
        private enum enumMixinStr_GL_MAX_COLOR_ATTACHMENTS = `enum GL_MAX_COLOR_ATTACHMENTS = 0x8CDF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COLOR_ATTACHMENTS); }))) {
            mixin(enumMixinStr_GL_MAX_COLOR_ATTACHMENTS);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER = `enum GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER = 0x8CD4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER);
        }
    }




    static if(!is(typeof(GL_RENDERBUFFER_SAMPLES))) {
        private enum enumMixinStr_GL_RENDERBUFFER_SAMPLES = `enum GL_RENDERBUFFER_SAMPLES = 0x8CAB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RENDERBUFFER_SAMPLES); }))) {
            mixin(enumMixinStr_GL_RENDERBUFFER_SAMPLES);
        }
    }




    static if(!is(typeof(GL_READ_FRAMEBUFFER_BINDING))) {
        private enum enumMixinStr_GL_READ_FRAMEBUFFER_BINDING = `enum GL_READ_FRAMEBUFFER_BINDING = 0x8CAA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_READ_FRAMEBUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_READ_FRAMEBUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_DRAW_FRAMEBUFFER))) {
        private enum enumMixinStr_GL_DRAW_FRAMEBUFFER = `enum GL_DRAW_FRAMEBUFFER = 0x8CA9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_FRAMEBUFFER); }))) {
            mixin(enumMixinStr_GL_DRAW_FRAMEBUFFER);
        }
    }




    static if(!is(typeof(GL_READ_FRAMEBUFFER))) {
        private enum enumMixinStr_GL_READ_FRAMEBUFFER = `enum GL_READ_FRAMEBUFFER = 0x8CA8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_READ_FRAMEBUFFER); }))) {
            mixin(enumMixinStr_GL_READ_FRAMEBUFFER);
        }
    }




    static if(!is(typeof(GL_DRAW_FRAMEBUFFER_BINDING))) {
        private enum enumMixinStr_GL_DRAW_FRAMEBUFFER_BINDING = `enum GL_DRAW_FRAMEBUFFER_BINDING = 0x8CA6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_FRAMEBUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_DRAW_FRAMEBUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_NORMALIZED))) {
        private enum enumMixinStr_GL_UNSIGNED_NORMALIZED = `enum GL_UNSIGNED_NORMALIZED = 0x8C17;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_NORMALIZED); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_NORMALIZED);
        }
    }




    static if(!is(typeof(GL_DEPTH24_STENCIL8))) {
        private enum enumMixinStr_GL_DEPTH24_STENCIL8 = `enum GL_DEPTH24_STENCIL8 = 0x88F0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH24_STENCIL8); }))) {
            mixin(enumMixinStr_GL_DEPTH24_STENCIL8);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_24_8))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_24_8 = `enum GL_UNSIGNED_INT_24_8 = 0x84FA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_24_8); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_24_8);
        }
    }




    static if(!is(typeof(GL_DEPTH_STENCIL))) {
        private enum enumMixinStr_GL_DEPTH_STENCIL = `enum GL_DEPTH_STENCIL = 0x84F9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_STENCIL); }))) {
            mixin(enumMixinStr_GL_DEPTH_STENCIL);
        }
    }




    static if(!is(typeof(GL_DEPTH_STENCIL_ATTACHMENT))) {
        private enum enumMixinStr_GL_DEPTH_STENCIL_ATTACHMENT = `enum GL_DEPTH_STENCIL_ATTACHMENT = 0x821A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_STENCIL_ATTACHMENT); }))) {
            mixin(enumMixinStr_GL_DEPTH_STENCIL_ATTACHMENT);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_UNDEFINED))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_UNDEFINED = `enum GL_FRAMEBUFFER_UNDEFINED = 0x8219;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_UNDEFINED); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_UNDEFINED);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_DEFAULT))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_DEFAULT = `enum GL_FRAMEBUFFER_DEFAULT = 0x8218;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_DEFAULT); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_DEFAULT);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE = `enum GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE = 0x8217;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE = `enum GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE = 0x8216;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE = `enum GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE = 0x8215;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE = `enum GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE = 0x8214;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE = `enum GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE = 0x8213;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE = `enum GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE = 0x8212;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE = `enum GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE = 0x8211;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING = `enum GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING = 0x8210;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING);
        }
    }




    static if(!is(typeof(GL_FLOAT_32_UNSIGNED_INT_24_8_REV))) {
        private enum enumMixinStr_GL_FLOAT_32_UNSIGNED_INT_24_8_REV = `enum GL_FLOAT_32_UNSIGNED_INT_24_8_REV = 0x8DAD;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FLOAT_32_UNSIGNED_INT_24_8_REV); }))) {
            mixin(enumMixinStr_GL_FLOAT_32_UNSIGNED_INT_24_8_REV);
        }
    }




    static if(!is(typeof(GL_DEPTH32F_STENCIL8))) {
        private enum enumMixinStr_GL_DEPTH32F_STENCIL8 = `enum GL_DEPTH32F_STENCIL8 = 0x8CAD;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH32F_STENCIL8); }))) {
            mixin(enumMixinStr_GL_DEPTH32F_STENCIL8);
        }
    }




    static if(!is(typeof(GL_DEPTH_COMPONENT32F))) {
        private enum enumMixinStr_GL_DEPTH_COMPONENT32F = `enum GL_DEPTH_COMPONENT32F = 0x8CAC;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_COMPONENT32F); }))) {
            mixin(enumMixinStr_GL_DEPTH_COMPONENT32F);
        }
    }




    static if(!is(typeof(GL_BUFFER_MAP_OFFSET))) {
        private enum enumMixinStr_GL_BUFFER_MAP_OFFSET = `enum GL_BUFFER_MAP_OFFSET = 0x9121;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BUFFER_MAP_OFFSET); }))) {
            mixin(enumMixinStr_GL_BUFFER_MAP_OFFSET);
        }
    }




    static if(!is(typeof(GL_BUFFER_MAP_LENGTH))) {
        private enum enumMixinStr_GL_BUFFER_MAP_LENGTH = `enum GL_BUFFER_MAP_LENGTH = 0x9120;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BUFFER_MAP_LENGTH); }))) {
            mixin(enumMixinStr_GL_BUFFER_MAP_LENGTH);
        }
    }




    static if(!is(typeof(GL_BUFFER_ACCESS_FLAGS))) {
        private enum enumMixinStr_GL_BUFFER_ACCESS_FLAGS = `enum GL_BUFFER_ACCESS_FLAGS = 0x911F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BUFFER_ACCESS_FLAGS); }))) {
            mixin(enumMixinStr_GL_BUFFER_ACCESS_FLAGS);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_SAMPLER_2D_ARRAY))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_SAMPLER_2D_ARRAY = `enum GL_UNSIGNED_INT_SAMPLER_2D_ARRAY = 0x8DD7;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_SAMPLER_2D_ARRAY); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_SAMPLER_2D_ARRAY);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_SAMPLER_CUBE))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_SAMPLER_CUBE = `enum GL_UNSIGNED_INT_SAMPLER_CUBE = 0x8DD4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_SAMPLER_CUBE); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_SAMPLER_CUBE);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_SAMPLER_3D))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_SAMPLER_3D = `enum GL_UNSIGNED_INT_SAMPLER_3D = 0x8DD3;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_SAMPLER_3D); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_SAMPLER_3D);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_SAMPLER_2D))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_SAMPLER_2D = `enum GL_UNSIGNED_INT_SAMPLER_2D = 0x8DD2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_SAMPLER_2D); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_SAMPLER_2D);
        }
    }




    static if(!is(typeof(GL_INT_SAMPLER_2D_ARRAY))) {
        private enum enumMixinStr_GL_INT_SAMPLER_2D_ARRAY = `enum GL_INT_SAMPLER_2D_ARRAY = 0x8DCF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INT_SAMPLER_2D_ARRAY); }))) {
            mixin(enumMixinStr_GL_INT_SAMPLER_2D_ARRAY);
        }
    }




    static if(!is(typeof(GL_INT_SAMPLER_CUBE))) {
        private enum enumMixinStr_GL_INT_SAMPLER_CUBE = `enum GL_INT_SAMPLER_CUBE = 0x8DCC;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INT_SAMPLER_CUBE); }))) {
            mixin(enumMixinStr_GL_INT_SAMPLER_CUBE);
        }
    }




    static if(!is(typeof(GL_INT_SAMPLER_3D))) {
        private enum enumMixinStr_GL_INT_SAMPLER_3D = `enum GL_INT_SAMPLER_3D = 0x8DCB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INT_SAMPLER_3D); }))) {
            mixin(enumMixinStr_GL_INT_SAMPLER_3D);
        }
    }




    static if(!is(typeof(GL_INT_SAMPLER_2D))) {
        private enum enumMixinStr_GL_INT_SAMPLER_2D = `enum GL_INT_SAMPLER_2D = 0x8DCA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INT_SAMPLER_2D); }))) {
            mixin(enumMixinStr_GL_INT_SAMPLER_2D);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_VEC4))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_VEC4 = `enum GL_UNSIGNED_INT_VEC4 = 0x8DC8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_VEC4); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_VEC4);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_VEC3))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_VEC3 = `enum GL_UNSIGNED_INT_VEC3 = 0x8DC7;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_VEC3); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_VEC3);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_VEC2))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_VEC2 = `enum GL_UNSIGNED_INT_VEC2 = 0x8DC6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_VEC2); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_VEC2);
        }
    }




    static if(!is(typeof(GL_SAMPLER_CUBE_SHADOW))) {
        private enum enumMixinStr_GL_SAMPLER_CUBE_SHADOW = `enum GL_SAMPLER_CUBE_SHADOW = 0x8DC5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLER_CUBE_SHADOW); }))) {
            mixin(enumMixinStr_GL_SAMPLER_CUBE_SHADOW);
        }
    }




    static if(!is(typeof(GL_SAMPLER_2D_ARRAY_SHADOW))) {
        private enum enumMixinStr_GL_SAMPLER_2D_ARRAY_SHADOW = `enum GL_SAMPLER_2D_ARRAY_SHADOW = 0x8DC4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLER_2D_ARRAY_SHADOW); }))) {
            mixin(enumMixinStr_GL_SAMPLER_2D_ARRAY_SHADOW);
        }
    }




    static if(!is(typeof(GL_SAMPLER_2D_ARRAY))) {
        private enum enumMixinStr_GL_SAMPLER_2D_ARRAY = `enum GL_SAMPLER_2D_ARRAY = 0x8DC1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLER_2D_ARRAY); }))) {
            mixin(enumMixinStr_GL_SAMPLER_2D_ARRAY);
        }
    }




    static if(!is(typeof(GL_RGBA_INTEGER))) {
        private enum enumMixinStr_GL_RGBA_INTEGER = `enum GL_RGBA_INTEGER = 0x8D99;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGBA_INTEGER); }))) {
            mixin(enumMixinStr_GL_RGBA_INTEGER);
        }
    }




    static if(!is(typeof(GL_RGB_INTEGER))) {
        private enum enumMixinStr_GL_RGB_INTEGER = `enum GL_RGB_INTEGER = 0x8D98;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB_INTEGER); }))) {
            mixin(enumMixinStr_GL_RGB_INTEGER);
        }
    }




    static if(!is(typeof(GL_RED_INTEGER))) {
        private enum enumMixinStr_GL_RED_INTEGER = `enum GL_RED_INTEGER = 0x8D94;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RED_INTEGER); }))) {
            mixin(enumMixinStr_GL_RED_INTEGER);
        }
    }




    static if(!is(typeof(GL_RGB8I))) {
        private enum enumMixinStr_GL_RGB8I = `enum GL_RGB8I = 0x8D8F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB8I); }))) {
            mixin(enumMixinStr_GL_RGB8I);
        }
    }




    static if(!is(typeof(GL_RGBA8I))) {
        private enum enumMixinStr_GL_RGBA8I = `enum GL_RGBA8I = 0x8D8E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGBA8I); }))) {
            mixin(enumMixinStr_GL_RGBA8I);
        }
    }




    static if(!is(typeof(GL_RGB16I))) {
        private enum enumMixinStr_GL_RGB16I = `enum GL_RGB16I = 0x8D89;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB16I); }))) {
            mixin(enumMixinStr_GL_RGB16I);
        }
    }




    static if(!is(typeof(GL_RGBA16I))) {
        private enum enumMixinStr_GL_RGBA16I = `enum GL_RGBA16I = 0x8D88;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGBA16I); }))) {
            mixin(enumMixinStr_GL_RGBA16I);
        }
    }




    static if(!is(typeof(GL_RGB32I))) {
        private enum enumMixinStr_GL_RGB32I = `enum GL_RGB32I = 0x8D83;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB32I); }))) {
            mixin(enumMixinStr_GL_RGB32I);
        }
    }




    static if(!is(typeof(GL_RGBA32I))) {
        private enum enumMixinStr_GL_RGBA32I = `enum GL_RGBA32I = 0x8D82;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGBA32I); }))) {
            mixin(enumMixinStr_GL_RGBA32I);
        }
    }




    static if(!is(typeof(GL_RGB8UI))) {
        private enum enumMixinStr_GL_RGB8UI = `enum GL_RGB8UI = 0x8D7D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB8UI); }))) {
            mixin(enumMixinStr_GL_RGB8UI);
        }
    }




    static if(!is(typeof(GL_RGBA8UI))) {
        private enum enumMixinStr_GL_RGBA8UI = `enum GL_RGBA8UI = 0x8D7C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGBA8UI); }))) {
            mixin(enumMixinStr_GL_RGBA8UI);
        }
    }




    static if(!is(typeof(GL_RGB16UI))) {
        private enum enumMixinStr_GL_RGB16UI = `enum GL_RGB16UI = 0x8D77;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB16UI); }))) {
            mixin(enumMixinStr_GL_RGB16UI);
        }
    }




    static if(!is(typeof(GL_RGBA16UI))) {
        private enum enumMixinStr_GL_RGBA16UI = `enum GL_RGBA16UI = 0x8D76;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGBA16UI); }))) {
            mixin(enumMixinStr_GL_RGBA16UI);
        }
    }




    static if(!is(typeof(GL_RGB32UI))) {
        private enum enumMixinStr_GL_RGB32UI = `enum GL_RGB32UI = 0x8D71;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB32UI); }))) {
            mixin(enumMixinStr_GL_RGB32UI);
        }
    }




    static if(!is(typeof(GL_RGBA32UI))) {
        private enum enumMixinStr_GL_RGBA32UI = `enum GL_RGBA32UI = 0x8D70;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGBA32UI); }))) {
            mixin(enumMixinStr_GL_RGBA32UI);
        }
    }




    static if(!is(typeof(GL_TRANSFORM_FEEDBACK_BUFFER_BINDING))) {
        private enum enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER_BINDING = `enum GL_TRANSFORM_FEEDBACK_BUFFER_BINDING = 0x8C8F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_TRANSFORM_FEEDBACK_BUFFER))) {
        private enum enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER = `enum GL_TRANSFORM_FEEDBACK_BUFFER = 0x8C8E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER); }))) {
            mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER);
        }
    }




    static if(!is(typeof(GL_SEPARATE_ATTRIBS))) {
        private enum enumMixinStr_GL_SEPARATE_ATTRIBS = `enum GL_SEPARATE_ATTRIBS = 0x8C8D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SEPARATE_ATTRIBS); }))) {
            mixin(enumMixinStr_GL_SEPARATE_ATTRIBS);
        }
    }




    static if(!is(typeof(GL_INTERLEAVED_ATTRIBS))) {
        private enum enumMixinStr_GL_INTERLEAVED_ATTRIBS = `enum GL_INTERLEAVED_ATTRIBS = 0x8C8C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INTERLEAVED_ATTRIBS); }))) {
            mixin(enumMixinStr_GL_INTERLEAVED_ATTRIBS);
        }
    }




    static if(!is(typeof(GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS))) {
        private enum enumMixinStr_GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS = `enum GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS = 0x8C8B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS); }))) {
            mixin(enumMixinStr_GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS);
        }
    }




    static if(!is(typeof(GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS))) {
        private enum enumMixinStr_GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS = `enum GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS = 0x8C8A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS); }))) {
            mixin(enumMixinStr_GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS);
        }
    }




    static if(!is(typeof(GL_RASTERIZER_DISCARD))) {
        private enum enumMixinStr_GL_RASTERIZER_DISCARD = `enum GL_RASTERIZER_DISCARD = 0x8C89;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RASTERIZER_DISCARD); }))) {
            mixin(enumMixinStr_GL_RASTERIZER_DISCARD);
        }
    }




    static if(!is(typeof(GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN))) {
        private enum enumMixinStr_GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN = `enum GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN = 0x8C88;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN); }))) {
            mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN);
        }
    }




    static if(!is(typeof(GL_TRANSFORM_FEEDBACK_BUFFER_SIZE))) {
        private enum enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER_SIZE = `enum GL_TRANSFORM_FEEDBACK_BUFFER_SIZE = 0x8C85;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER_SIZE); }))) {
            mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER_SIZE);
        }
    }




    static if(!is(typeof(GL_TRANSFORM_FEEDBACK_BUFFER_START))) {
        private enum enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER_START = `enum GL_TRANSFORM_FEEDBACK_BUFFER_START = 0x8C84;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER_START); }))) {
            mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER_START);
        }
    }




    static if(!is(typeof(GL_TRANSFORM_FEEDBACK_VARYINGS))) {
        private enum enumMixinStr_GL_TRANSFORM_FEEDBACK_VARYINGS = `enum GL_TRANSFORM_FEEDBACK_VARYINGS = 0x8C83;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_VARYINGS); }))) {
            mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_VARYINGS);
        }
    }




    static if(!is(typeof(GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS))) {
        private enum enumMixinStr_GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS = `enum GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS = 0x8C80;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS); }))) {
            mixin(enumMixinStr_GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS);
        }
    }




    static if(!is(typeof(GL_TRANSFORM_FEEDBACK_BUFFER_MODE))) {
        private enum enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER_MODE = `enum GL_TRANSFORM_FEEDBACK_BUFFER_MODE = 0x8C7F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER_MODE); }))) {
            mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_BUFFER_MODE);
        }
    }




    static if(!is(typeof(GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH))) {
        private enum enumMixinStr_GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH = `enum GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH = 0x8C76;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH); }))) {
            mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_5_9_9_9_REV))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_5_9_9_9_REV = `enum GL_UNSIGNED_INT_5_9_9_9_REV = 0x8C3E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_5_9_9_9_REV); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_5_9_9_9_REV);
        }
    }




    static if(!is(typeof(GL_RGB9_E5))) {
        private enum enumMixinStr_GL_RGB9_E5 = `enum GL_RGB9_E5 = 0x8C3D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB9_E5); }))) {
            mixin(enumMixinStr_GL_RGB9_E5);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_10F_11F_11F_REV))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_10F_11F_11F_REV = `enum GL_UNSIGNED_INT_10F_11F_11F_REV = 0x8C3B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_10F_11F_11F_REV); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_10F_11F_11F_REV);
        }
    }




    static if(!is(typeof(GL_R11F_G11F_B10F))) {
        private enum enumMixinStr_GL_R11F_G11F_B10F = `enum GL_R11F_G11F_B10F = 0x8C3A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_R11F_G11F_B10F); }))) {
            mixin(enumMixinStr_GL_R11F_G11F_B10F);
        }
    }




    static if(!is(typeof(GL_TEXTURE_BINDING_2D_ARRAY))) {
        private enum enumMixinStr_GL_TEXTURE_BINDING_2D_ARRAY = `enum GL_TEXTURE_BINDING_2D_ARRAY = 0x8C1D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_BINDING_2D_ARRAY); }))) {
            mixin(enumMixinStr_GL_TEXTURE_BINDING_2D_ARRAY);
        }
    }




    static if(!is(typeof(GL_TEXTURE_2D_ARRAY))) {
        private enum enumMixinStr_GL_TEXTURE_2D_ARRAY = `enum GL_TEXTURE_2D_ARRAY = 0x8C1A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_2D_ARRAY); }))) {
            mixin(enumMixinStr_GL_TEXTURE_2D_ARRAY);
        }
    }




    static if(!is(typeof(GL_MAX_VARYING_COMPONENTS))) {
        private enum enumMixinStr_GL_MAX_VARYING_COMPONENTS = `enum GL_MAX_VARYING_COMPONENTS = 0x8B4B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VARYING_COMPONENTS); }))) {
            mixin(enumMixinStr_GL_MAX_VARYING_COMPONENTS);
        }
    }




    static if(!is(typeof(GL_MAX_PROGRAM_TEXEL_OFFSET))) {
        private enum enumMixinStr_GL_MAX_PROGRAM_TEXEL_OFFSET = `enum GL_MAX_PROGRAM_TEXEL_OFFSET = 0x8905;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_PROGRAM_TEXEL_OFFSET); }))) {
            mixin(enumMixinStr_GL_MAX_PROGRAM_TEXEL_OFFSET);
        }
    }




    static if(!is(typeof(GL_MIN_PROGRAM_TEXEL_OFFSET))) {
        private enum enumMixinStr_GL_MIN_PROGRAM_TEXEL_OFFSET = `enum GL_MIN_PROGRAM_TEXEL_OFFSET = 0x8904;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MIN_PROGRAM_TEXEL_OFFSET); }))) {
            mixin(enumMixinStr_GL_MIN_PROGRAM_TEXEL_OFFSET);
        }
    }




    static if(!is(typeof(GL_MAX_ARRAY_TEXTURE_LAYERS))) {
        private enum enumMixinStr_GL_MAX_ARRAY_TEXTURE_LAYERS = `enum GL_MAX_ARRAY_TEXTURE_LAYERS = 0x88FF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_ARRAY_TEXTURE_LAYERS); }))) {
            mixin(enumMixinStr_GL_MAX_ARRAY_TEXTURE_LAYERS);
        }
    }




    static if(!is(typeof(GL_VERTEX_ATTRIB_ARRAY_INTEGER))) {
        private enum enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_INTEGER = `enum GL_VERTEX_ATTRIB_ARRAY_INTEGER = 0x88FD;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_INTEGER); }))) {
            mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_INTEGER);
        }
    }




    static if(!is(typeof(GL_RGB16F))) {
        private enum enumMixinStr_GL_RGB16F = `enum GL_RGB16F = 0x881B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB16F); }))) {
            mixin(enumMixinStr_GL_RGB16F);
        }
    }




    static if(!is(typeof(GL_RGBA16F))) {
        private enum enumMixinStr_GL_RGBA16F = `enum GL_RGBA16F = 0x881A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGBA16F); }))) {
            mixin(enumMixinStr_GL_RGBA16F);
        }
    }




    static if(!is(typeof(GL_RGB32F))) {
        private enum enumMixinStr_GL_RGB32F = `enum GL_RGB32F = 0x8815;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB32F); }))) {
            mixin(enumMixinStr_GL_RGB32F);
        }
    }




    static if(!is(typeof(GL_RGBA32F))) {
        private enum enumMixinStr_GL_RGBA32F = `enum GL_RGBA32F = 0x8814;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGBA32F); }))) {
            mixin(enumMixinStr_GL_RGBA32F);
        }
    }




    static if(!is(typeof(GL_NUM_EXTENSIONS))) {
        private enum enumMixinStr_GL_NUM_EXTENSIONS = `enum GL_NUM_EXTENSIONS = 0x821D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NUM_EXTENSIONS); }))) {
            mixin(enumMixinStr_GL_NUM_EXTENSIONS);
        }
    }




    static if(!is(typeof(GL_MINOR_VERSION))) {
        private enum enumMixinStr_GL_MINOR_VERSION = `enum GL_MINOR_VERSION = 0x821C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MINOR_VERSION); }))) {
            mixin(enumMixinStr_GL_MINOR_VERSION);
        }
    }




    static if(!is(typeof(GL_MAJOR_VERSION))) {
        private enum enumMixinStr_GL_MAJOR_VERSION = `enum GL_MAJOR_VERSION = 0x821B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAJOR_VERSION); }))) {
            mixin(enumMixinStr_GL_MAJOR_VERSION);
        }
    }




    static if(!is(typeof(GL_COMPARE_REF_TO_TEXTURE))) {
        private enum enumMixinStr_GL_COMPARE_REF_TO_TEXTURE = `enum GL_COMPARE_REF_TO_TEXTURE = 0x884E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPARE_REF_TO_TEXTURE); }))) {
            mixin(enumMixinStr_GL_COMPARE_REF_TO_TEXTURE);
        }
    }




    static if(!is(typeof(GL_SRGB8_ALPHA8))) {
        private enum enumMixinStr_GL_SRGB8_ALPHA8 = `enum GL_SRGB8_ALPHA8 = 0x8C43;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SRGB8_ALPHA8); }))) {
            mixin(enumMixinStr_GL_SRGB8_ALPHA8);
        }
    }




    static if(!is(typeof(GL_SRGB8))) {
        private enum enumMixinStr_GL_SRGB8 = `enum GL_SRGB8 = 0x8C41;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SRGB8); }))) {
            mixin(enumMixinStr_GL_SRGB8);
        }
    }




    static if(!is(typeof(GL_SRGB))) {
        private enum enumMixinStr_GL_SRGB = `enum GL_SRGB = 0x8C40;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SRGB); }))) {
            mixin(enumMixinStr_GL_SRGB);
        }
    }




    static if(!is(typeof(GL_FLOAT_MAT4x3))) {
        private enum enumMixinStr_GL_FLOAT_MAT4x3 = `enum GL_FLOAT_MAT4x3 = 0x8B6A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FLOAT_MAT4x3); }))) {
            mixin(enumMixinStr_GL_FLOAT_MAT4x3);
        }
    }




    static if(!is(typeof(GL_FLOAT_MAT4x2))) {
        private enum enumMixinStr_GL_FLOAT_MAT4x2 = `enum GL_FLOAT_MAT4x2 = 0x8B69;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FLOAT_MAT4x2); }))) {
            mixin(enumMixinStr_GL_FLOAT_MAT4x2);
        }
    }




    static if(!is(typeof(GL_FLOAT_MAT3x4))) {
        private enum enumMixinStr_GL_FLOAT_MAT3x4 = `enum GL_FLOAT_MAT3x4 = 0x8B68;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FLOAT_MAT3x4); }))) {
            mixin(enumMixinStr_GL_FLOAT_MAT3x4);
        }
    }




    static if(!is(typeof(GL_FLOAT_MAT3x2))) {
        private enum enumMixinStr_GL_FLOAT_MAT3x2 = `enum GL_FLOAT_MAT3x2 = 0x8B67;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FLOAT_MAT3x2); }))) {
            mixin(enumMixinStr_GL_FLOAT_MAT3x2);
        }
    }




    static if(!is(typeof(GL_FLOAT_MAT2x4))) {
        private enum enumMixinStr_GL_FLOAT_MAT2x4 = `enum GL_FLOAT_MAT2x4 = 0x8B66;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FLOAT_MAT2x4); }))) {
            mixin(enumMixinStr_GL_FLOAT_MAT2x4);
        }
    }




    static if(!is(typeof(GL_FLOAT_MAT2x3))) {
        private enum enumMixinStr_GL_FLOAT_MAT2x3 = `enum GL_FLOAT_MAT2x3 = 0x8B65;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FLOAT_MAT2x3); }))) {
            mixin(enumMixinStr_GL_FLOAT_MAT2x3);
        }
    }




    static if(!is(typeof(GL_PIXEL_UNPACK_BUFFER_BINDING))) {
        private enum enumMixinStr_GL_PIXEL_UNPACK_BUFFER_BINDING = `enum GL_PIXEL_UNPACK_BUFFER_BINDING = 0x88EF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PIXEL_UNPACK_BUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_PIXEL_UNPACK_BUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_PIXEL_PACK_BUFFER_BINDING))) {
        private enum enumMixinStr_GL_PIXEL_PACK_BUFFER_BINDING = `enum GL_PIXEL_PACK_BUFFER_BINDING = 0x88ED;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PIXEL_PACK_BUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_PIXEL_PACK_BUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_PIXEL_UNPACK_BUFFER))) {
        private enum enumMixinStr_GL_PIXEL_UNPACK_BUFFER = `enum GL_PIXEL_UNPACK_BUFFER = 0x88EC;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PIXEL_UNPACK_BUFFER); }))) {
            mixin(enumMixinStr_GL_PIXEL_UNPACK_BUFFER);
        }
    }




    static if(!is(typeof(GL_PIXEL_PACK_BUFFER))) {
        private enum enumMixinStr_GL_PIXEL_PACK_BUFFER = `enum GL_PIXEL_PACK_BUFFER = 0x88EB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PIXEL_PACK_BUFFER); }))) {
            mixin(enumMixinStr_GL_PIXEL_PACK_BUFFER);
        }
    }




    static if(!is(typeof(GL_FRAGMENT_SHADER_DERIVATIVE_HINT))) {
        private enum enumMixinStr_GL_FRAGMENT_SHADER_DERIVATIVE_HINT = `enum GL_FRAGMENT_SHADER_DERIVATIVE_HINT = 0x8B8B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAGMENT_SHADER_DERIVATIVE_HINT); }))) {
            mixin(enumMixinStr_GL_FRAGMENT_SHADER_DERIVATIVE_HINT);
        }
    }




    static if(!is(typeof(GL_SAMPLER_2D_SHADOW))) {
        private enum enumMixinStr_GL_SAMPLER_2D_SHADOW = `enum GL_SAMPLER_2D_SHADOW = 0x8B62;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLER_2D_SHADOW); }))) {
            mixin(enumMixinStr_GL_SAMPLER_2D_SHADOW);
        }
    }




    static if(!is(typeof(GL_SAMPLER_3D))) {
        private enum enumMixinStr_GL_SAMPLER_3D = `enum GL_SAMPLER_3D = 0x8B5F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLER_3D); }))) {
            mixin(enumMixinStr_GL_SAMPLER_3D);
        }
    }




    static if(!is(typeof(GL_MAX_VERTEX_UNIFORM_COMPONENTS))) {
        private enum enumMixinStr_GL_MAX_VERTEX_UNIFORM_COMPONENTS = `enum GL_MAX_VERTEX_UNIFORM_COMPONENTS = 0x8B4A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VERTEX_UNIFORM_COMPONENTS); }))) {
            mixin(enumMixinStr_GL_MAX_VERTEX_UNIFORM_COMPONENTS);
        }
    }




    static if(!is(typeof(GL_MAX_FRAGMENT_UNIFORM_COMPONENTS))) {
        private enum enumMixinStr_GL_MAX_FRAGMENT_UNIFORM_COMPONENTS = `enum GL_MAX_FRAGMENT_UNIFORM_COMPONENTS = 0x8B49;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_FRAGMENT_UNIFORM_COMPONENTS); }))) {
            mixin(enumMixinStr_GL_MAX_FRAGMENT_UNIFORM_COMPONENTS);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER15))) {
        private enum enumMixinStr_GL_DRAW_BUFFER15 = `enum GL_DRAW_BUFFER15 = 0x8834;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER15); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER15);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER14))) {
        private enum enumMixinStr_GL_DRAW_BUFFER14 = `enum GL_DRAW_BUFFER14 = 0x8833;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER14); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER14);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER13))) {
        private enum enumMixinStr_GL_DRAW_BUFFER13 = `enum GL_DRAW_BUFFER13 = 0x8832;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER13); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER13);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER12))) {
        private enum enumMixinStr_GL_DRAW_BUFFER12 = `enum GL_DRAW_BUFFER12 = 0x8831;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER12); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER12);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER11))) {
        private enum enumMixinStr_GL_DRAW_BUFFER11 = `enum GL_DRAW_BUFFER11 = 0x8830;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER11); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER11);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER10))) {
        private enum enumMixinStr_GL_DRAW_BUFFER10 = `enum GL_DRAW_BUFFER10 = 0x882F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER10); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER10);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER9))) {
        private enum enumMixinStr_GL_DRAW_BUFFER9 = `enum GL_DRAW_BUFFER9 = 0x882E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER9); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER9);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER8))) {
        private enum enumMixinStr_GL_DRAW_BUFFER8 = `enum GL_DRAW_BUFFER8 = 0x882D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER8); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER8);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER7))) {
        private enum enumMixinStr_GL_DRAW_BUFFER7 = `enum GL_DRAW_BUFFER7 = 0x882C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER7); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER7);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER6))) {
        private enum enumMixinStr_GL_DRAW_BUFFER6 = `enum GL_DRAW_BUFFER6 = 0x882B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER6); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER6);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER5))) {
        private enum enumMixinStr_GL_DRAW_BUFFER5 = `enum GL_DRAW_BUFFER5 = 0x882A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER5); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER5);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER4))) {
        private enum enumMixinStr_GL_DRAW_BUFFER4 = `enum GL_DRAW_BUFFER4 = 0x8829;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER4); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER4);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER3))) {
        private enum enumMixinStr_GL_DRAW_BUFFER3 = `enum GL_DRAW_BUFFER3 = 0x8828;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER3); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER3);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER2))) {
        private enum enumMixinStr_GL_DRAW_BUFFER2 = `enum GL_DRAW_BUFFER2 = 0x8827;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER2); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER2);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER1))) {
        private enum enumMixinStr_GL_DRAW_BUFFER1 = `enum GL_DRAW_BUFFER1 = 0x8826;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER1); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER1);
        }
    }




    static if(!is(typeof(GL_DRAW_BUFFER0))) {
        private enum enumMixinStr_GL_DRAW_BUFFER0 = `enum GL_DRAW_BUFFER0 = 0x8825;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_BUFFER0); }))) {
            mixin(enumMixinStr_GL_DRAW_BUFFER0);
        }
    }




    static if(!is(typeof(GL_MAX_DRAW_BUFFERS))) {
        private enum enumMixinStr_GL_MAX_DRAW_BUFFERS = `enum GL_MAX_DRAW_BUFFERS = 0x8824;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_DRAW_BUFFERS); }))) {
            mixin(enumMixinStr_GL_MAX_DRAW_BUFFERS);
        }
    }




    static if(!is(typeof(GL_DYNAMIC_COPY))) {
        private enum enumMixinStr_GL_DYNAMIC_COPY = `enum GL_DYNAMIC_COPY = 0x88EA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DYNAMIC_COPY); }))) {
            mixin(enumMixinStr_GL_DYNAMIC_COPY);
        }
    }




    static if(!is(typeof(GL_DYNAMIC_READ))) {
        private enum enumMixinStr_GL_DYNAMIC_READ = `enum GL_DYNAMIC_READ = 0x88E9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DYNAMIC_READ); }))) {
            mixin(enumMixinStr_GL_DYNAMIC_READ);
        }
    }




    static if(!is(typeof(GL_STATIC_COPY))) {
        private enum enumMixinStr_GL_STATIC_COPY = `enum GL_STATIC_COPY = 0x88E6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STATIC_COPY); }))) {
            mixin(enumMixinStr_GL_STATIC_COPY);
        }
    }




    static if(!is(typeof(GL_STATIC_READ))) {
        private enum enumMixinStr_GL_STATIC_READ = `enum GL_STATIC_READ = 0x88E5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STATIC_READ); }))) {
            mixin(enumMixinStr_GL_STATIC_READ);
        }
    }




    static if(!is(typeof(GL_STREAM_COPY))) {
        private enum enumMixinStr_GL_STREAM_COPY = `enum GL_STREAM_COPY = 0x88E2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STREAM_COPY); }))) {
            mixin(enumMixinStr_GL_STREAM_COPY);
        }
    }




    static if(!is(typeof(GL_STREAM_READ))) {
        private enum enumMixinStr_GL_STREAM_READ = `enum GL_STREAM_READ = 0x88E1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STREAM_READ); }))) {
            mixin(enumMixinStr_GL_STREAM_READ);
        }
    }




    static if(!is(typeof(GL_BUFFER_MAP_POINTER))) {
        private enum enumMixinStr_GL_BUFFER_MAP_POINTER = `enum GL_BUFFER_MAP_POINTER = 0x88BD;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BUFFER_MAP_POINTER); }))) {
            mixin(enumMixinStr_GL_BUFFER_MAP_POINTER);
        }
    }




    static if(!is(typeof(GL_BUFFER_MAPPED))) {
        private enum enumMixinStr_GL_BUFFER_MAPPED = `enum GL_BUFFER_MAPPED = 0x88BC;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BUFFER_MAPPED); }))) {
            mixin(enumMixinStr_GL_BUFFER_MAPPED);
        }
    }




    static if(!is(typeof(GL_QUERY_RESULT_AVAILABLE))) {
        private enum enumMixinStr_GL_QUERY_RESULT_AVAILABLE = `enum GL_QUERY_RESULT_AVAILABLE = 0x8867;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_QUERY_RESULT_AVAILABLE); }))) {
            mixin(enumMixinStr_GL_QUERY_RESULT_AVAILABLE);
        }
    }




    static if(!is(typeof(GL_QUERY_RESULT))) {
        private enum enumMixinStr_GL_QUERY_RESULT = `enum GL_QUERY_RESULT = 0x8866;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_QUERY_RESULT); }))) {
            mixin(enumMixinStr_GL_QUERY_RESULT);
        }
    }




    static if(!is(typeof(GL_CURRENT_QUERY))) {
        private enum enumMixinStr_GL_CURRENT_QUERY = `enum GL_CURRENT_QUERY = 0x8865;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_CURRENT_QUERY); }))) {
            mixin(enumMixinStr_GL_CURRENT_QUERY);
        }
    }




    static if(!is(typeof(GL_TEXTURE_COMPARE_FUNC))) {
        private enum enumMixinStr_GL_TEXTURE_COMPARE_FUNC = `enum GL_TEXTURE_COMPARE_FUNC = 0x884D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_COMPARE_FUNC); }))) {
            mixin(enumMixinStr_GL_TEXTURE_COMPARE_FUNC);
        }
    }




    static if(!is(typeof(GL_TEXTURE_COMPARE_MODE))) {
        private enum enumMixinStr_GL_TEXTURE_COMPARE_MODE = `enum GL_TEXTURE_COMPARE_MODE = 0x884C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_COMPARE_MODE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_COMPARE_MODE);
        }
    }




    static if(!is(typeof(GL_MAX_TEXTURE_LOD_BIAS))) {
        private enum enumMixinStr_GL_MAX_TEXTURE_LOD_BIAS = `enum GL_MAX_TEXTURE_LOD_BIAS = 0x84FD;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_TEXTURE_LOD_BIAS); }))) {
            mixin(enumMixinStr_GL_MAX_TEXTURE_LOD_BIAS);
        }
    }




    static if(!is(typeof(GL_DEPTH_COMPONENT24))) {
        private enum enumMixinStr_GL_DEPTH_COMPONENT24 = `enum GL_DEPTH_COMPONENT24 = 0x81A6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_COMPONENT24); }))) {
            mixin(enumMixinStr_GL_DEPTH_COMPONENT24);
        }
    }




    static if(!is(typeof(GL_MAX))) {
        private enum enumMixinStr_GL_MAX = `enum GL_MAX = 0x8008;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX); }))) {
            mixin(enumMixinStr_GL_MAX);
        }
    }




    static if(!is(typeof(GL_MIN))) {
        private enum enumMixinStr_GL_MIN = `enum GL_MIN = 0x8007;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MIN); }))) {
            mixin(enumMixinStr_GL_MIN);
        }
    }




    static if(!is(typeof(GL_TEXTURE_MAX_LEVEL))) {
        private enum enumMixinStr_GL_TEXTURE_MAX_LEVEL = `enum GL_TEXTURE_MAX_LEVEL = 0x813D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_MAX_LEVEL); }))) {
            mixin(enumMixinStr_GL_TEXTURE_MAX_LEVEL);
        }
    }




    static if(!is(typeof(GL_TEXTURE_BASE_LEVEL))) {
        private enum enumMixinStr_GL_TEXTURE_BASE_LEVEL = `enum GL_TEXTURE_BASE_LEVEL = 0x813C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_BASE_LEVEL); }))) {
            mixin(enumMixinStr_GL_TEXTURE_BASE_LEVEL);
        }
    }




    static if(!is(typeof(GL_TEXTURE_MAX_LOD))) {
        private enum enumMixinStr_GL_TEXTURE_MAX_LOD = `enum GL_TEXTURE_MAX_LOD = 0x813B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_MAX_LOD); }))) {
            mixin(enumMixinStr_GL_TEXTURE_MAX_LOD);
        }
    }




    static if(!is(typeof(GL_TEXTURE_MIN_LOD))) {
        private enum enumMixinStr_GL_TEXTURE_MIN_LOD = `enum GL_TEXTURE_MIN_LOD = 0x813A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_MIN_LOD); }))) {
            mixin(enumMixinStr_GL_TEXTURE_MIN_LOD);
        }
    }




    static if(!is(typeof(GL_MAX_ELEMENTS_INDICES))) {
        private enum enumMixinStr_GL_MAX_ELEMENTS_INDICES = `enum GL_MAX_ELEMENTS_INDICES = 0x80E9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_ELEMENTS_INDICES); }))) {
            mixin(enumMixinStr_GL_MAX_ELEMENTS_INDICES);
        }
    }




    static if(!is(typeof(GL_MAX_ELEMENTS_VERTICES))) {
        private enum enumMixinStr_GL_MAX_ELEMENTS_VERTICES = `enum GL_MAX_ELEMENTS_VERTICES = 0x80E8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_ELEMENTS_VERTICES); }))) {
            mixin(enumMixinStr_GL_MAX_ELEMENTS_VERTICES);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_2_10_10_10_REV))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_2_10_10_10_REV = `enum GL_UNSIGNED_INT_2_10_10_10_REV = 0x8368;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_2_10_10_10_REV); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_2_10_10_10_REV);
        }
    }




    static if(!is(typeof(GL_MAX_3D_TEXTURE_SIZE))) {
        private enum enumMixinStr_GL_MAX_3D_TEXTURE_SIZE = `enum GL_MAX_3D_TEXTURE_SIZE = 0x8073;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_3D_TEXTURE_SIZE); }))) {
            mixin(enumMixinStr_GL_MAX_3D_TEXTURE_SIZE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_WRAP_R))) {
        private enum enumMixinStr_GL_TEXTURE_WRAP_R = `enum GL_TEXTURE_WRAP_R = 0x8072;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_WRAP_R); }))) {
            mixin(enumMixinStr_GL_TEXTURE_WRAP_R);
        }
    }




    static if(!is(typeof(GL_TEXTURE_3D))) {
        private enum enumMixinStr_GL_TEXTURE_3D = `enum GL_TEXTURE_3D = 0x806F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_3D); }))) {
            mixin(enumMixinStr_GL_TEXTURE_3D);
        }
    }




    static if(!is(typeof(GL_UNPACK_IMAGE_HEIGHT))) {
        private enum enumMixinStr_GL_UNPACK_IMAGE_HEIGHT = `enum GL_UNPACK_IMAGE_HEIGHT = 0x806E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNPACK_IMAGE_HEIGHT); }))) {
            mixin(enumMixinStr_GL_UNPACK_IMAGE_HEIGHT);
        }
    }




    static if(!is(typeof(GL_UNPACK_SKIP_IMAGES))) {
        private enum enumMixinStr_GL_UNPACK_SKIP_IMAGES = `enum GL_UNPACK_SKIP_IMAGES = 0x806D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNPACK_SKIP_IMAGES); }))) {
            mixin(enumMixinStr_GL_UNPACK_SKIP_IMAGES);
        }
    }




    static if(!is(typeof(GL_TEXTURE_BINDING_3D))) {
        private enum enumMixinStr_GL_TEXTURE_BINDING_3D = `enum GL_TEXTURE_BINDING_3D = 0x806A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_BINDING_3D); }))) {
            mixin(enumMixinStr_GL_TEXTURE_BINDING_3D);
        }
    }




    static if(!is(typeof(GL_RGB10_A2))) {
        private enum enumMixinStr_GL_RGB10_A2 = `enum GL_RGB10_A2 = 0x8059;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB10_A2); }))) {
            mixin(enumMixinStr_GL_RGB10_A2);
        }
    }




    static if(!is(typeof(GL_RGBA8))) {
        private enum enumMixinStr_GL_RGBA8 = `enum GL_RGBA8 = 0x8058;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGBA8); }))) {
            mixin(enumMixinStr_GL_RGBA8);
        }
    }




    static if(!is(typeof(GL_RGB8))) {
        private enum enumMixinStr_GL_RGB8 = `enum GL_RGB8 = 0x8051;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB8); }))) {
            mixin(enumMixinStr_GL_RGB8);
        }
    }




    static if(!is(typeof(GL_RED))) {
        private enum enumMixinStr_GL_RED = `enum GL_RED = 0x1903;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RED); }))) {
            mixin(enumMixinStr_GL_RED);
        }
    }




    static if(!is(typeof(GL_STENCIL))) {
        private enum enumMixinStr_GL_STENCIL = `enum GL_STENCIL = 0x1802;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL); }))) {
            mixin(enumMixinStr_GL_STENCIL);
        }
    }




    static if(!is(typeof(GL_DEPTH))) {
        private enum enumMixinStr_GL_DEPTH = `enum GL_DEPTH = 0x1801;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH); }))) {
            mixin(enumMixinStr_GL_DEPTH);
        }
    }




    static if(!is(typeof(GL_COLOR))) {
        private enum enumMixinStr_GL_COLOR = `enum GL_COLOR = 0x1800;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR); }))) {
            mixin(enumMixinStr_GL_COLOR);
        }
    }




    static if(!is(typeof(GL_PACK_SKIP_PIXELS))) {
        private enum enumMixinStr_GL_PACK_SKIP_PIXELS = `enum GL_PACK_SKIP_PIXELS = 0x0D04;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PACK_SKIP_PIXELS); }))) {
            mixin(enumMixinStr_GL_PACK_SKIP_PIXELS);
        }
    }




    static if(!is(typeof(GL_PACK_SKIP_ROWS))) {
        private enum enumMixinStr_GL_PACK_SKIP_ROWS = `enum GL_PACK_SKIP_ROWS = 0x0D03;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PACK_SKIP_ROWS); }))) {
            mixin(enumMixinStr_GL_PACK_SKIP_ROWS);
        }
    }




    static if(!is(typeof(GL_PACK_ROW_LENGTH))) {
        private enum enumMixinStr_GL_PACK_ROW_LENGTH = `enum GL_PACK_ROW_LENGTH = 0x0D02;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PACK_ROW_LENGTH); }))) {
            mixin(enumMixinStr_GL_PACK_ROW_LENGTH);
        }
    }




    static if(!is(typeof(GL_UNPACK_SKIP_PIXELS))) {
        private enum enumMixinStr_GL_UNPACK_SKIP_PIXELS = `enum GL_UNPACK_SKIP_PIXELS = 0x0CF4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNPACK_SKIP_PIXELS); }))) {
            mixin(enumMixinStr_GL_UNPACK_SKIP_PIXELS);
        }
    }




    static if(!is(typeof(GL_UNPACK_SKIP_ROWS))) {
        private enum enumMixinStr_GL_UNPACK_SKIP_ROWS = `enum GL_UNPACK_SKIP_ROWS = 0x0CF3;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNPACK_SKIP_ROWS); }))) {
            mixin(enumMixinStr_GL_UNPACK_SKIP_ROWS);
        }
    }




    static if(!is(typeof(GL_UNPACK_ROW_LENGTH))) {
        private enum enumMixinStr_GL_UNPACK_ROW_LENGTH = `enum GL_UNPACK_ROW_LENGTH = 0x0CF2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNPACK_ROW_LENGTH); }))) {
            mixin(enumMixinStr_GL_UNPACK_ROW_LENGTH);
        }
    }




    static if(!is(typeof(GL_READ_BUFFER))) {
        private enum enumMixinStr_GL_READ_BUFFER = `enum GL_READ_BUFFER = 0x0C02;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_READ_BUFFER); }))) {
            mixin(enumMixinStr_GL_READ_BUFFER);
        }
    }




    static if(!is(typeof(GL_ES_VERSION_3_0))) {
        private enum enumMixinStr_GL_ES_VERSION_3_0 = `enum GL_ES_VERSION_3_0 = 1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ES_VERSION_3_0); }))) {
            mixin(enumMixinStr_GL_ES_VERSION_3_0);
        }
    }




    static if(!is(typeof(GL_INVALID_FRAMEBUFFER_OPERATION))) {
        private enum enumMixinStr_GL_INVALID_FRAMEBUFFER_OPERATION = `enum GL_INVALID_FRAMEBUFFER_OPERATION = 0x0506;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INVALID_FRAMEBUFFER_OPERATION); }))) {
            mixin(enumMixinStr_GL_INVALID_FRAMEBUFFER_OPERATION);
        }
    }




    static if(!is(typeof(GL_MAX_RENDERBUFFER_SIZE))) {
        private enum enumMixinStr_GL_MAX_RENDERBUFFER_SIZE = `enum GL_MAX_RENDERBUFFER_SIZE = 0x84E8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_RENDERBUFFER_SIZE); }))) {
            mixin(enumMixinStr_GL_MAX_RENDERBUFFER_SIZE);
        }
    }




    static if(!is(typeof(GL_RENDERBUFFER_BINDING))) {
        private enum enumMixinStr_GL_RENDERBUFFER_BINDING = `enum GL_RENDERBUFFER_BINDING = 0x8CA7;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RENDERBUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_RENDERBUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_BINDING))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_BINDING = `enum GL_FRAMEBUFFER_BINDING = 0x8CA6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_UNSUPPORTED))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_UNSUPPORTED = `enum GL_FRAMEBUFFER_UNSUPPORTED = 0x8CDD;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_UNSUPPORTED); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_UNSUPPORTED);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS = `enum GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS = 0x8CD9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT = `enum GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT = 0x8CD7;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT = `enum GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT = 0x8CD6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_COMPLETE))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_COMPLETE = `enum GL_FRAMEBUFFER_COMPLETE = 0x8CD5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_COMPLETE); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_COMPLETE);
        }
    }




    static if(!is(typeof(GL_NONE))) {
        private enum enumMixinStr_GL_NONE = `enum GL_NONE = 0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NONE); }))) {
            mixin(enumMixinStr_GL_NONE);
        }
    }




    static if(!is(typeof(GL_STENCIL_ATTACHMENT))) {
        private enum enumMixinStr_GL_STENCIL_ATTACHMENT = `enum GL_STENCIL_ATTACHMENT = 0x8D20;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_ATTACHMENT); }))) {
            mixin(enumMixinStr_GL_STENCIL_ATTACHMENT);
        }
    }




    static if(!is(typeof(GL_DEPTH_ATTACHMENT))) {
        private enum enumMixinStr_GL_DEPTH_ATTACHMENT = `enum GL_DEPTH_ATTACHMENT = 0x8D00;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_ATTACHMENT); }))) {
            mixin(enumMixinStr_GL_DEPTH_ATTACHMENT);
        }
    }




    static if(!is(typeof(GL_COLOR_ATTACHMENT0))) {
        private enum enumMixinStr_GL_COLOR_ATTACHMENT0 = `enum GL_COLOR_ATTACHMENT0 = 0x8CE0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_ATTACHMENT0); }))) {
            mixin(enumMixinStr_GL_COLOR_ATTACHMENT0);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE = `enum GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE = 0x8CD3;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL = `enum GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL = 0x8CD2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME = `enum GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME = 0x8CD1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE = `enum GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE = 0x8CD0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE);
        }
    }




    static if(!is(typeof(GL_RENDERBUFFER_STENCIL_SIZE))) {
        private enum enumMixinStr_GL_RENDERBUFFER_STENCIL_SIZE = `enum GL_RENDERBUFFER_STENCIL_SIZE = 0x8D55;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RENDERBUFFER_STENCIL_SIZE); }))) {
            mixin(enumMixinStr_GL_RENDERBUFFER_STENCIL_SIZE);
        }
    }




    static if(!is(typeof(GL_RENDERBUFFER_DEPTH_SIZE))) {
        private enum enumMixinStr_GL_RENDERBUFFER_DEPTH_SIZE = `enum GL_RENDERBUFFER_DEPTH_SIZE = 0x8D54;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RENDERBUFFER_DEPTH_SIZE); }))) {
            mixin(enumMixinStr_GL_RENDERBUFFER_DEPTH_SIZE);
        }
    }




    static if(!is(typeof(GL_RENDERBUFFER_ALPHA_SIZE))) {
        private enum enumMixinStr_GL_RENDERBUFFER_ALPHA_SIZE = `enum GL_RENDERBUFFER_ALPHA_SIZE = 0x8D53;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RENDERBUFFER_ALPHA_SIZE); }))) {
            mixin(enumMixinStr_GL_RENDERBUFFER_ALPHA_SIZE);
        }
    }




    static if(!is(typeof(GL_RENDERBUFFER_BLUE_SIZE))) {
        private enum enumMixinStr_GL_RENDERBUFFER_BLUE_SIZE = `enum GL_RENDERBUFFER_BLUE_SIZE = 0x8D52;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RENDERBUFFER_BLUE_SIZE); }))) {
            mixin(enumMixinStr_GL_RENDERBUFFER_BLUE_SIZE);
        }
    }




    static if(!is(typeof(GL_RENDERBUFFER_GREEN_SIZE))) {
        private enum enumMixinStr_GL_RENDERBUFFER_GREEN_SIZE = `enum GL_RENDERBUFFER_GREEN_SIZE = 0x8D51;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RENDERBUFFER_GREEN_SIZE); }))) {
            mixin(enumMixinStr_GL_RENDERBUFFER_GREEN_SIZE);
        }
    }




    static if(!is(typeof(GL_RENDERBUFFER_RED_SIZE))) {
        private enum enumMixinStr_GL_RENDERBUFFER_RED_SIZE = `enum GL_RENDERBUFFER_RED_SIZE = 0x8D50;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RENDERBUFFER_RED_SIZE); }))) {
            mixin(enumMixinStr_GL_RENDERBUFFER_RED_SIZE);
        }
    }




    static if(!is(typeof(GL_RENDERBUFFER_INTERNAL_FORMAT))) {
        private enum enumMixinStr_GL_RENDERBUFFER_INTERNAL_FORMAT = `enum GL_RENDERBUFFER_INTERNAL_FORMAT = 0x8D44;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RENDERBUFFER_INTERNAL_FORMAT); }))) {
            mixin(enumMixinStr_GL_RENDERBUFFER_INTERNAL_FORMAT);
        }
    }




    static if(!is(typeof(GL_RENDERBUFFER_HEIGHT))) {
        private enum enumMixinStr_GL_RENDERBUFFER_HEIGHT = `enum GL_RENDERBUFFER_HEIGHT = 0x8D43;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RENDERBUFFER_HEIGHT); }))) {
            mixin(enumMixinStr_GL_RENDERBUFFER_HEIGHT);
        }
    }




    static if(!is(typeof(GL_RENDERBUFFER_WIDTH))) {
        private enum enumMixinStr_GL_RENDERBUFFER_WIDTH = `enum GL_RENDERBUFFER_WIDTH = 0x8D42;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RENDERBUFFER_WIDTH); }))) {
            mixin(enumMixinStr_GL_RENDERBUFFER_WIDTH);
        }
    }




    static if(!is(typeof(GL_STENCIL_INDEX8))) {
        private enum enumMixinStr_GL_STENCIL_INDEX8 = `enum GL_STENCIL_INDEX8 = 0x8D48;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_INDEX8); }))) {
            mixin(enumMixinStr_GL_STENCIL_INDEX8);
        }
    }




    static if(!is(typeof(GL_DEPTH_COMPONENT16))) {
        private enum enumMixinStr_GL_DEPTH_COMPONENT16 = `enum GL_DEPTH_COMPONENT16 = 0x81A5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_COMPONENT16); }))) {
            mixin(enumMixinStr_GL_DEPTH_COMPONENT16);
        }
    }




    static if(!is(typeof(GL_RGB565))) {
        private enum enumMixinStr_GL_RGB565 = `enum GL_RGB565 = 0x8D62;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB565); }))) {
            mixin(enumMixinStr_GL_RGB565);
        }
    }




    static if(!is(typeof(GL_RGB5_A1))) {
        private enum enumMixinStr_GL_RGB5_A1 = `enum GL_RGB5_A1 = 0x8057;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB5_A1); }))) {
            mixin(enumMixinStr_GL_RGB5_A1);
        }
    }




    static if(!is(typeof(GL_RGBA4))) {
        private enum enumMixinStr_GL_RGBA4 = `enum GL_RGBA4 = 0x8056;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGBA4); }))) {
            mixin(enumMixinStr_GL_RGBA4);
        }
    }




    static if(!is(typeof(GL_RENDERBUFFER))) {
        private enum enumMixinStr_GL_RENDERBUFFER = `enum GL_RENDERBUFFER = 0x8D41;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RENDERBUFFER); }))) {
            mixin(enumMixinStr_GL_RENDERBUFFER);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER))) {
        private enum enumMixinStr_GL_FRAMEBUFFER = `enum GL_FRAMEBUFFER = 0x8D40;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER);
        }
    }




    static if(!is(typeof(GL_HIGH_INT))) {
        private enum enumMixinStr_GL_HIGH_INT = `enum GL_HIGH_INT = 0x8DF5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_HIGH_INT); }))) {
            mixin(enumMixinStr_GL_HIGH_INT);
        }
    }




    static if(!is(typeof(GL_MEDIUM_INT))) {
        private enum enumMixinStr_GL_MEDIUM_INT = `enum GL_MEDIUM_INT = 0x8DF4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MEDIUM_INT); }))) {
            mixin(enumMixinStr_GL_MEDIUM_INT);
        }
    }




    static if(!is(typeof(GL_LOW_INT))) {
        private enum enumMixinStr_GL_LOW_INT = `enum GL_LOW_INT = 0x8DF3;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LOW_INT); }))) {
            mixin(enumMixinStr_GL_LOW_INT);
        }
    }




    static if(!is(typeof(GL_HIGH_FLOAT))) {
        private enum enumMixinStr_GL_HIGH_FLOAT = `enum GL_HIGH_FLOAT = 0x8DF2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_HIGH_FLOAT); }))) {
            mixin(enumMixinStr_GL_HIGH_FLOAT);
        }
    }




    static if(!is(typeof(GL_MEDIUM_FLOAT))) {
        private enum enumMixinStr_GL_MEDIUM_FLOAT = `enum GL_MEDIUM_FLOAT = 0x8DF1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MEDIUM_FLOAT); }))) {
            mixin(enumMixinStr_GL_MEDIUM_FLOAT);
        }
    }




    static if(!is(typeof(GL_LOW_FLOAT))) {
        private enum enumMixinStr_GL_LOW_FLOAT = `enum GL_LOW_FLOAT = 0x8DF0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LOW_FLOAT); }))) {
            mixin(enumMixinStr_GL_LOW_FLOAT);
        }
    }




    static if(!is(typeof(GL_NUM_SHADER_BINARY_FORMATS))) {
        private enum enumMixinStr_GL_NUM_SHADER_BINARY_FORMATS = `enum GL_NUM_SHADER_BINARY_FORMATS = 0x8DF9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NUM_SHADER_BINARY_FORMATS); }))) {
            mixin(enumMixinStr_GL_NUM_SHADER_BINARY_FORMATS);
        }
    }




    static if(!is(typeof(GL_SHADER_BINARY_FORMATS))) {
        private enum enumMixinStr_GL_SHADER_BINARY_FORMATS = `enum GL_SHADER_BINARY_FORMATS = 0x8DF8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SHADER_BINARY_FORMATS); }))) {
            mixin(enumMixinStr_GL_SHADER_BINARY_FORMATS);
        }
    }




    static if(!is(typeof(GL_SHADER_COMPILER))) {
        private enum enumMixinStr_GL_SHADER_COMPILER = `enum GL_SHADER_COMPILER = 0x8DFA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SHADER_COMPILER); }))) {
            mixin(enumMixinStr_GL_SHADER_COMPILER);
        }
    }




    static if(!is(typeof(GL_SHADER_SOURCE_LENGTH))) {
        private enum enumMixinStr_GL_SHADER_SOURCE_LENGTH = `enum GL_SHADER_SOURCE_LENGTH = 0x8B88;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SHADER_SOURCE_LENGTH); }))) {
            mixin(enumMixinStr_GL_SHADER_SOURCE_LENGTH);
        }
    }




    static if(!is(typeof(GL_INFO_LOG_LENGTH))) {
        private enum enumMixinStr_GL_INFO_LOG_LENGTH = `enum GL_INFO_LOG_LENGTH = 0x8B84;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INFO_LOG_LENGTH); }))) {
            mixin(enumMixinStr_GL_INFO_LOG_LENGTH);
        }
    }




    static if(!is(typeof(GL_COMPILE_STATUS))) {
        private enum enumMixinStr_GL_COMPILE_STATUS = `enum GL_COMPILE_STATUS = 0x8B81;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPILE_STATUS); }))) {
            mixin(enumMixinStr_GL_COMPILE_STATUS);
        }
    }




    static if(!is(typeof(GL_IMPLEMENTATION_COLOR_READ_FORMAT))) {
        private enum enumMixinStr_GL_IMPLEMENTATION_COLOR_READ_FORMAT = `enum GL_IMPLEMENTATION_COLOR_READ_FORMAT = 0x8B9B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMPLEMENTATION_COLOR_READ_FORMAT); }))) {
            mixin(enumMixinStr_GL_IMPLEMENTATION_COLOR_READ_FORMAT);
        }
    }




    static if(!is(typeof(GL_IMPLEMENTATION_COLOR_READ_TYPE))) {
        private enum enumMixinStr_GL_IMPLEMENTATION_COLOR_READ_TYPE = `enum GL_IMPLEMENTATION_COLOR_READ_TYPE = 0x8B9A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMPLEMENTATION_COLOR_READ_TYPE); }))) {
            mixin(enumMixinStr_GL_IMPLEMENTATION_COLOR_READ_TYPE);
        }
    }




    static if(!is(typeof(GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING))) {
        private enum enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = `enum GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = 0x889F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_VERTEX_ATTRIB_ARRAY_POINTER))) {
        private enum enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_POINTER = `enum GL_VERTEX_ATTRIB_ARRAY_POINTER = 0x8645;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_POINTER); }))) {
            mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_POINTER);
        }
    }




    static if(!is(typeof(GL_VERTEX_ATTRIB_ARRAY_NORMALIZED))) {
        private enum enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_NORMALIZED = `enum GL_VERTEX_ATTRIB_ARRAY_NORMALIZED = 0x886A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_NORMALIZED); }))) {
            mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_NORMALIZED);
        }
    }




    static if(!is(typeof(GL_VERTEX_ATTRIB_ARRAY_TYPE))) {
        private enum enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_TYPE = `enum GL_VERTEX_ATTRIB_ARRAY_TYPE = 0x8625;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_TYPE); }))) {
            mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_TYPE);
        }
    }




    static if(!is(typeof(GL_VERTEX_ATTRIB_ARRAY_STRIDE))) {
        private enum enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_STRIDE = `enum GL_VERTEX_ATTRIB_ARRAY_STRIDE = 0x8624;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_STRIDE); }))) {
            mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_STRIDE);
        }
    }




    static if(!is(typeof(GL_VERTEX_ATTRIB_ARRAY_SIZE))) {
        private enum enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_SIZE = `enum GL_VERTEX_ATTRIB_ARRAY_SIZE = 0x8623;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_SIZE); }))) {
            mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_SIZE);
        }
    }




    static if(!is(typeof(GL_VERTEX_ATTRIB_ARRAY_ENABLED))) {
        private enum enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_ENABLED = `enum GL_VERTEX_ATTRIB_ARRAY_ENABLED = 0x8622;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_ENABLED); }))) {
            mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_ENABLED);
        }
    }




    static if(!is(typeof(GL_SAMPLER_CUBE))) {
        private enum enumMixinStr_GL_SAMPLER_CUBE = `enum GL_SAMPLER_CUBE = 0x8B60;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLER_CUBE); }))) {
            mixin(enumMixinStr_GL_SAMPLER_CUBE);
        }
    }




    static if(!is(typeof(GL_SAMPLER_2D))) {
        private enum enumMixinStr_GL_SAMPLER_2D = `enum GL_SAMPLER_2D = 0x8B5E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLER_2D); }))) {
            mixin(enumMixinStr_GL_SAMPLER_2D);
        }
    }




    static if(!is(typeof(GL_FLOAT_MAT4))) {
        private enum enumMixinStr_GL_FLOAT_MAT4 = `enum GL_FLOAT_MAT4 = 0x8B5C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FLOAT_MAT4); }))) {
            mixin(enumMixinStr_GL_FLOAT_MAT4);
        }
    }




    static if(!is(typeof(GL_FLOAT_MAT3))) {
        private enum enumMixinStr_GL_FLOAT_MAT3 = `enum GL_FLOAT_MAT3 = 0x8B5B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FLOAT_MAT3); }))) {
            mixin(enumMixinStr_GL_FLOAT_MAT3);
        }
    }




    static if(!is(typeof(GL_FLOAT_MAT2))) {
        private enum enumMixinStr_GL_FLOAT_MAT2 = `enum GL_FLOAT_MAT2 = 0x8B5A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FLOAT_MAT2); }))) {
            mixin(enumMixinStr_GL_FLOAT_MAT2);
        }
    }




    static if(!is(typeof(GL_BOOL_VEC4))) {
        private enum enumMixinStr_GL_BOOL_VEC4 = `enum GL_BOOL_VEC4 = 0x8B59;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BOOL_VEC4); }))) {
            mixin(enumMixinStr_GL_BOOL_VEC4);
        }
    }




    static if(!is(typeof(GL_BOOL_VEC3))) {
        private enum enumMixinStr_GL_BOOL_VEC3 = `enum GL_BOOL_VEC3 = 0x8B58;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BOOL_VEC3); }))) {
            mixin(enumMixinStr_GL_BOOL_VEC3);
        }
    }




    static if(!is(typeof(GL_BOOL_VEC2))) {
        private enum enumMixinStr_GL_BOOL_VEC2 = `enum GL_BOOL_VEC2 = 0x8B57;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BOOL_VEC2); }))) {
            mixin(enumMixinStr_GL_BOOL_VEC2);
        }
    }




    static if(!is(typeof(GL_BOOL))) {
        private enum enumMixinStr_GL_BOOL = `enum GL_BOOL = 0x8B56;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BOOL); }))) {
            mixin(enumMixinStr_GL_BOOL);
        }
    }




    static if(!is(typeof(GL_INT_VEC4))) {
        private enum enumMixinStr_GL_INT_VEC4 = `enum GL_INT_VEC4 = 0x8B55;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INT_VEC4); }))) {
            mixin(enumMixinStr_GL_INT_VEC4);
        }
    }




    static if(!is(typeof(GL_INT_VEC3))) {
        private enum enumMixinStr_GL_INT_VEC3 = `enum GL_INT_VEC3 = 0x8B54;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INT_VEC3); }))) {
            mixin(enumMixinStr_GL_INT_VEC3);
        }
    }




    static if(!is(typeof(GL_INT_VEC2))) {
        private enum enumMixinStr_GL_INT_VEC2 = `enum GL_INT_VEC2 = 0x8B53;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INT_VEC2); }))) {
            mixin(enumMixinStr_GL_INT_VEC2);
        }
    }




    static if(!is(typeof(GL_FLOAT_VEC4))) {
        private enum enumMixinStr_GL_FLOAT_VEC4 = `enum GL_FLOAT_VEC4 = 0x8B52;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FLOAT_VEC4); }))) {
            mixin(enumMixinStr_GL_FLOAT_VEC4);
        }
    }




    static if(!is(typeof(GL_FLOAT_VEC3))) {
        private enum enumMixinStr_GL_FLOAT_VEC3 = `enum GL_FLOAT_VEC3 = 0x8B51;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FLOAT_VEC3); }))) {
            mixin(enumMixinStr_GL_FLOAT_VEC3);
        }
    }




    static if(!is(typeof(GL_FLOAT_VEC2))) {
        private enum enumMixinStr_GL_FLOAT_VEC2 = `enum GL_FLOAT_VEC2 = 0x8B50;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FLOAT_VEC2); }))) {
            mixin(enumMixinStr_GL_FLOAT_VEC2);
        }
    }




    static if(!is(typeof(GL_MIRRORED_REPEAT))) {
        private enum enumMixinStr_GL_MIRRORED_REPEAT = `enum GL_MIRRORED_REPEAT = 0x8370;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MIRRORED_REPEAT); }))) {
            mixin(enumMixinStr_GL_MIRRORED_REPEAT);
        }
    }




    static if(!is(typeof(GL_CLAMP_TO_EDGE))) {
        private enum enumMixinStr_GL_CLAMP_TO_EDGE = `enum GL_CLAMP_TO_EDGE = 0x812F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_CLAMP_TO_EDGE); }))) {
            mixin(enumMixinStr_GL_CLAMP_TO_EDGE);
        }
    }




    static if(!is(typeof(GL_REPEAT))) {
        private enum enumMixinStr_GL_REPEAT = `enum GL_REPEAT = 0x2901;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_REPEAT); }))) {
            mixin(enumMixinStr_GL_REPEAT);
        }
    }




    static if(!is(typeof(GL_ACTIVE_TEXTURE))) {
        private enum enumMixinStr_GL_ACTIVE_TEXTURE = `enum GL_ACTIVE_TEXTURE = 0x84E0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ACTIVE_TEXTURE); }))) {
            mixin(enumMixinStr_GL_ACTIVE_TEXTURE);
        }
    }




    static if(!is(typeof(GL_TEXTURE31))) {
        private enum enumMixinStr_GL_TEXTURE31 = `enum GL_TEXTURE31 = 0x84DF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE31); }))) {
            mixin(enumMixinStr_GL_TEXTURE31);
        }
    }




    static if(!is(typeof(GL_TEXTURE30))) {
        private enum enumMixinStr_GL_TEXTURE30 = `enum GL_TEXTURE30 = 0x84DE;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE30); }))) {
            mixin(enumMixinStr_GL_TEXTURE30);
        }
    }




    static if(!is(typeof(GL_TEXTURE29))) {
        private enum enumMixinStr_GL_TEXTURE29 = `enum GL_TEXTURE29 = 0x84DD;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE29); }))) {
            mixin(enumMixinStr_GL_TEXTURE29);
        }
    }




    static if(!is(typeof(GL_TEXTURE28))) {
        private enum enumMixinStr_GL_TEXTURE28 = `enum GL_TEXTURE28 = 0x84DC;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE28); }))) {
            mixin(enumMixinStr_GL_TEXTURE28);
        }
    }




    static if(!is(typeof(GL_TEXTURE27))) {
        private enum enumMixinStr_GL_TEXTURE27 = `enum GL_TEXTURE27 = 0x84DB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE27); }))) {
            mixin(enumMixinStr_GL_TEXTURE27);
        }
    }




    static if(!is(typeof(GL_TEXTURE26))) {
        private enum enumMixinStr_GL_TEXTURE26 = `enum GL_TEXTURE26 = 0x84DA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE26); }))) {
            mixin(enumMixinStr_GL_TEXTURE26);
        }
    }




    static if(!is(typeof(GL_TEXTURE25))) {
        private enum enumMixinStr_GL_TEXTURE25 = `enum GL_TEXTURE25 = 0x84D9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE25); }))) {
            mixin(enumMixinStr_GL_TEXTURE25);
        }
    }




    static if(!is(typeof(GL_TEXTURE24))) {
        private enum enumMixinStr_GL_TEXTURE24 = `enum GL_TEXTURE24 = 0x84D8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE24); }))) {
            mixin(enumMixinStr_GL_TEXTURE24);
        }
    }




    static if(!is(typeof(GL_TEXTURE23))) {
        private enum enumMixinStr_GL_TEXTURE23 = `enum GL_TEXTURE23 = 0x84D7;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE23); }))) {
            mixin(enumMixinStr_GL_TEXTURE23);
        }
    }




    static if(!is(typeof(GL_TEXTURE22))) {
        private enum enumMixinStr_GL_TEXTURE22 = `enum GL_TEXTURE22 = 0x84D6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE22); }))) {
            mixin(enumMixinStr_GL_TEXTURE22);
        }
    }




    static if(!is(typeof(GL_TEXTURE21))) {
        private enum enumMixinStr_GL_TEXTURE21 = `enum GL_TEXTURE21 = 0x84D5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE21); }))) {
            mixin(enumMixinStr_GL_TEXTURE21);
        }
    }




    static if(!is(typeof(GL_TEXTURE20))) {
        private enum enumMixinStr_GL_TEXTURE20 = `enum GL_TEXTURE20 = 0x84D4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE20); }))) {
            mixin(enumMixinStr_GL_TEXTURE20);
        }
    }




    static if(!is(typeof(GL_TEXTURE19))) {
        private enum enumMixinStr_GL_TEXTURE19 = `enum GL_TEXTURE19 = 0x84D3;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE19); }))) {
            mixin(enumMixinStr_GL_TEXTURE19);
        }
    }




    static if(!is(typeof(GL_TEXTURE18))) {
        private enum enumMixinStr_GL_TEXTURE18 = `enum GL_TEXTURE18 = 0x84D2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE18); }))) {
            mixin(enumMixinStr_GL_TEXTURE18);
        }
    }




    static if(!is(typeof(GL_TEXTURE17))) {
        private enum enumMixinStr_GL_TEXTURE17 = `enum GL_TEXTURE17 = 0x84D1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE17); }))) {
            mixin(enumMixinStr_GL_TEXTURE17);
        }
    }




    static if(!is(typeof(GL_TEXTURE16))) {
        private enum enumMixinStr_GL_TEXTURE16 = `enum GL_TEXTURE16 = 0x84D0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE16); }))) {
            mixin(enumMixinStr_GL_TEXTURE16);
        }
    }




    static if(!is(typeof(GL_TEXTURE15))) {
        private enum enumMixinStr_GL_TEXTURE15 = `enum GL_TEXTURE15 = 0x84CF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE15); }))) {
            mixin(enumMixinStr_GL_TEXTURE15);
        }
    }




    static if(!is(typeof(GL_TEXTURE14))) {
        private enum enumMixinStr_GL_TEXTURE14 = `enum GL_TEXTURE14 = 0x84CE;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE14); }))) {
            mixin(enumMixinStr_GL_TEXTURE14);
        }
    }




    static if(!is(typeof(GL_TEXTURE13))) {
        private enum enumMixinStr_GL_TEXTURE13 = `enum GL_TEXTURE13 = 0x84CD;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE13); }))) {
            mixin(enumMixinStr_GL_TEXTURE13);
        }
    }




    static if(!is(typeof(GL_TEXTURE12))) {
        private enum enumMixinStr_GL_TEXTURE12 = `enum GL_TEXTURE12 = 0x84CC;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE12); }))) {
            mixin(enumMixinStr_GL_TEXTURE12);
        }
    }




    static if(!is(typeof(GL_TEXTURE11))) {
        private enum enumMixinStr_GL_TEXTURE11 = `enum GL_TEXTURE11 = 0x84CB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE11); }))) {
            mixin(enumMixinStr_GL_TEXTURE11);
        }
    }




    static if(!is(typeof(GL_TEXTURE10))) {
        private enum enumMixinStr_GL_TEXTURE10 = `enum GL_TEXTURE10 = 0x84CA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE10); }))) {
            mixin(enumMixinStr_GL_TEXTURE10);
        }
    }




    static if(!is(typeof(GL_TEXTURE9))) {
        private enum enumMixinStr_GL_TEXTURE9 = `enum GL_TEXTURE9 = 0x84C9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE9); }))) {
            mixin(enumMixinStr_GL_TEXTURE9);
        }
    }




    static if(!is(typeof(GL_TEXTURE8))) {
        private enum enumMixinStr_GL_TEXTURE8 = `enum GL_TEXTURE8 = 0x84C8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE8); }))) {
            mixin(enumMixinStr_GL_TEXTURE8);
        }
    }




    static if(!is(typeof(GL_TEXTURE7))) {
        private enum enumMixinStr_GL_TEXTURE7 = `enum GL_TEXTURE7 = 0x84C7;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE7); }))) {
            mixin(enumMixinStr_GL_TEXTURE7);
        }
    }




    static if(!is(typeof(GL_TEXTURE6))) {
        private enum enumMixinStr_GL_TEXTURE6 = `enum GL_TEXTURE6 = 0x84C6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE6); }))) {
            mixin(enumMixinStr_GL_TEXTURE6);
        }
    }




    static if(!is(typeof(GL_TEXTURE5))) {
        private enum enumMixinStr_GL_TEXTURE5 = `enum GL_TEXTURE5 = 0x84C5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE5); }))) {
            mixin(enumMixinStr_GL_TEXTURE5);
        }
    }




    static if(!is(typeof(GL_TEXTURE4))) {
        private enum enumMixinStr_GL_TEXTURE4 = `enum GL_TEXTURE4 = 0x84C4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE4); }))) {
            mixin(enumMixinStr_GL_TEXTURE4);
        }
    }




    static if(!is(typeof(GL_TEXTURE3))) {
        private enum enumMixinStr_GL_TEXTURE3 = `enum GL_TEXTURE3 = 0x84C3;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE3); }))) {
            mixin(enumMixinStr_GL_TEXTURE3);
        }
    }




    static if(!is(typeof(GL_TEXTURE2))) {
        private enum enumMixinStr_GL_TEXTURE2 = `enum GL_TEXTURE2 = 0x84C2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE2); }))) {
            mixin(enumMixinStr_GL_TEXTURE2);
        }
    }




    static if(!is(typeof(GL_TEXTURE1))) {
        private enum enumMixinStr_GL_TEXTURE1 = `enum GL_TEXTURE1 = 0x84C1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE1); }))) {
            mixin(enumMixinStr_GL_TEXTURE1);
        }
    }




    static if(!is(typeof(GL_TEXTURE0))) {
        private enum enumMixinStr_GL_TEXTURE0 = `enum GL_TEXTURE0 = 0x84C0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE0); }))) {
            mixin(enumMixinStr_GL_TEXTURE0);
        }
    }




    static if(!is(typeof(GL_MAX_CUBE_MAP_TEXTURE_SIZE))) {
        private enum enumMixinStr_GL_MAX_CUBE_MAP_TEXTURE_SIZE = `enum GL_MAX_CUBE_MAP_TEXTURE_SIZE = 0x851C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_CUBE_MAP_TEXTURE_SIZE); }))) {
            mixin(enumMixinStr_GL_MAX_CUBE_MAP_TEXTURE_SIZE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z))) {
        private enum enumMixinStr_GL_TEXTURE_CUBE_MAP_NEGATIVE_Z = `enum GL_TEXTURE_CUBE_MAP_NEGATIVE_Z = 0x851A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_CUBE_MAP_NEGATIVE_Z); }))) {
            mixin(enumMixinStr_GL_TEXTURE_CUBE_MAP_NEGATIVE_Z);
        }
    }




    static if(!is(typeof(GL_TEXTURE_CUBE_MAP_POSITIVE_Z))) {
        private enum enumMixinStr_GL_TEXTURE_CUBE_MAP_POSITIVE_Z = `enum GL_TEXTURE_CUBE_MAP_POSITIVE_Z = 0x8519;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_CUBE_MAP_POSITIVE_Z); }))) {
            mixin(enumMixinStr_GL_TEXTURE_CUBE_MAP_POSITIVE_Z);
        }
    }




    static if(!is(typeof(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y))) {
        private enum enumMixinStr_GL_TEXTURE_CUBE_MAP_NEGATIVE_Y = `enum GL_TEXTURE_CUBE_MAP_NEGATIVE_Y = 0x8518;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_CUBE_MAP_NEGATIVE_Y); }))) {
            mixin(enumMixinStr_GL_TEXTURE_CUBE_MAP_NEGATIVE_Y);
        }
    }




    static if(!is(typeof(GL_TEXTURE_CUBE_MAP_POSITIVE_Y))) {
        private enum enumMixinStr_GL_TEXTURE_CUBE_MAP_POSITIVE_Y = `enum GL_TEXTURE_CUBE_MAP_POSITIVE_Y = 0x8517;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_CUBE_MAP_POSITIVE_Y); }))) {
            mixin(enumMixinStr_GL_TEXTURE_CUBE_MAP_POSITIVE_Y);
        }
    }




    static if(!is(typeof(GL_TEXTURE_CUBE_MAP_NEGATIVE_X))) {
        private enum enumMixinStr_GL_TEXTURE_CUBE_MAP_NEGATIVE_X = `enum GL_TEXTURE_CUBE_MAP_NEGATIVE_X = 0x8516;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_CUBE_MAP_NEGATIVE_X); }))) {
            mixin(enumMixinStr_GL_TEXTURE_CUBE_MAP_NEGATIVE_X);
        }
    }




    static if(!is(typeof(GL_TEXTURE_CUBE_MAP_POSITIVE_X))) {
        private enum enumMixinStr_GL_TEXTURE_CUBE_MAP_POSITIVE_X = `enum GL_TEXTURE_CUBE_MAP_POSITIVE_X = 0x8515;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_CUBE_MAP_POSITIVE_X); }))) {
            mixin(enumMixinStr_GL_TEXTURE_CUBE_MAP_POSITIVE_X);
        }
    }




    static if(!is(typeof(GL_TEXTURE_BINDING_CUBE_MAP))) {
        private enum enumMixinStr_GL_TEXTURE_BINDING_CUBE_MAP = `enum GL_TEXTURE_BINDING_CUBE_MAP = 0x8514;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_BINDING_CUBE_MAP); }))) {
            mixin(enumMixinStr_GL_TEXTURE_BINDING_CUBE_MAP);
        }
    }




    static if(!is(typeof(GL_TEXTURE_CUBE_MAP))) {
        private enum enumMixinStr_GL_TEXTURE_CUBE_MAP = `enum GL_TEXTURE_CUBE_MAP = 0x8513;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_CUBE_MAP); }))) {
            mixin(enumMixinStr_GL_TEXTURE_CUBE_MAP);
        }
    }




    static if(!is(typeof(GL_TEXTURE))) {
        private enum enumMixinStr_GL_TEXTURE = `enum GL_TEXTURE = 0x1702;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE); }))) {
            mixin(enumMixinStr_GL_TEXTURE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_WRAP_T))) {
        private enum enumMixinStr_GL_TEXTURE_WRAP_T = `enum GL_TEXTURE_WRAP_T = 0x2803;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_WRAP_T); }))) {
            mixin(enumMixinStr_GL_TEXTURE_WRAP_T);
        }
    }




    static if(!is(typeof(GL_TEXTURE_WRAP_S))) {
        private enum enumMixinStr_GL_TEXTURE_WRAP_S = `enum GL_TEXTURE_WRAP_S = 0x2802;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_WRAP_S); }))) {
            mixin(enumMixinStr_GL_TEXTURE_WRAP_S);
        }
    }




    static if(!is(typeof(GL_TEXTURE_MIN_FILTER))) {
        private enum enumMixinStr_GL_TEXTURE_MIN_FILTER = `enum GL_TEXTURE_MIN_FILTER = 0x2801;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_MIN_FILTER); }))) {
            mixin(enumMixinStr_GL_TEXTURE_MIN_FILTER);
        }
    }




    static if(!is(typeof(GL_TEXTURE_MAG_FILTER))) {
        private enum enumMixinStr_GL_TEXTURE_MAG_FILTER = `enum GL_TEXTURE_MAG_FILTER = 0x2800;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_MAG_FILTER); }))) {
            mixin(enumMixinStr_GL_TEXTURE_MAG_FILTER);
        }
    }




    static if(!is(typeof(GL_LINEAR_MIPMAP_LINEAR))) {
        private enum enumMixinStr_GL_LINEAR_MIPMAP_LINEAR = `enum GL_LINEAR_MIPMAP_LINEAR = 0x2703;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LINEAR_MIPMAP_LINEAR); }))) {
            mixin(enumMixinStr_GL_LINEAR_MIPMAP_LINEAR);
        }
    }




    static if(!is(typeof(GL_NEAREST_MIPMAP_LINEAR))) {
        private enum enumMixinStr_GL_NEAREST_MIPMAP_LINEAR = `enum GL_NEAREST_MIPMAP_LINEAR = 0x2702;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NEAREST_MIPMAP_LINEAR); }))) {
            mixin(enumMixinStr_GL_NEAREST_MIPMAP_LINEAR);
        }
    }




    static if(!is(typeof(GL_LINEAR_MIPMAP_NEAREST))) {
        private enum enumMixinStr_GL_LINEAR_MIPMAP_NEAREST = `enum GL_LINEAR_MIPMAP_NEAREST = 0x2701;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LINEAR_MIPMAP_NEAREST); }))) {
            mixin(enumMixinStr_GL_LINEAR_MIPMAP_NEAREST);
        }
    }




    static if(!is(typeof(GL_NEAREST_MIPMAP_NEAREST))) {
        private enum enumMixinStr_GL_NEAREST_MIPMAP_NEAREST = `enum GL_NEAREST_MIPMAP_NEAREST = 0x2700;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NEAREST_MIPMAP_NEAREST); }))) {
            mixin(enumMixinStr_GL_NEAREST_MIPMAP_NEAREST);
        }
    }




    static if(!is(typeof(GL_LINEAR))) {
        private enum enumMixinStr_GL_LINEAR = `enum GL_LINEAR = 0x2601;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LINEAR); }))) {
            mixin(enumMixinStr_GL_LINEAR);
        }
    }




    static if(!is(typeof(GL_NEAREST))) {
        private enum enumMixinStr_GL_NEAREST = `enum GL_NEAREST = 0x2600;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NEAREST); }))) {
            mixin(enumMixinStr_GL_NEAREST);
        }
    }




    static if(!is(typeof(GL_EXTENSIONS))) {
        private enum enumMixinStr_GL_EXTENSIONS = `enum GL_EXTENSIONS = 0x1F03;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_EXTENSIONS); }))) {
            mixin(enumMixinStr_GL_EXTENSIONS);
        }
    }




    static if(!is(typeof(GL_VERSION))) {
        private enum enumMixinStr_GL_VERSION = `enum GL_VERSION = 0x1F02;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERSION); }))) {
            mixin(enumMixinStr_GL_VERSION);
        }
    }




    static if(!is(typeof(GL_RENDERER))) {
        private enum enumMixinStr_GL_RENDERER = `enum GL_RENDERER = 0x1F01;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RENDERER); }))) {
            mixin(enumMixinStr_GL_RENDERER);
        }
    }




    static if(!is(typeof(GL_VENDOR))) {
        private enum enumMixinStr_GL_VENDOR = `enum GL_VENDOR = 0x1F00;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VENDOR); }))) {
            mixin(enumMixinStr_GL_VENDOR);
        }
    }




    static if(!is(typeof(GL_DECR_WRAP))) {
        private enum enumMixinStr_GL_DECR_WRAP = `enum GL_DECR_WRAP = 0x8508;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DECR_WRAP); }))) {
            mixin(enumMixinStr_GL_DECR_WRAP);
        }
    }




    static if(!is(typeof(GL_INCR_WRAP))) {
        private enum enumMixinStr_GL_INCR_WRAP = `enum GL_INCR_WRAP = 0x8507;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INCR_WRAP); }))) {
            mixin(enumMixinStr_GL_INCR_WRAP);
        }
    }




    static if(!is(typeof(GL_INVERT))) {
        private enum enumMixinStr_GL_INVERT = `enum GL_INVERT = 0x150A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INVERT); }))) {
            mixin(enumMixinStr_GL_INVERT);
        }
    }




    static if(!is(typeof(GL_DECR))) {
        private enum enumMixinStr_GL_DECR = `enum GL_DECR = 0x1E03;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DECR); }))) {
            mixin(enumMixinStr_GL_DECR);
        }
    }




    static if(!is(typeof(GL_INCR))) {
        private enum enumMixinStr_GL_INCR = `enum GL_INCR = 0x1E02;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INCR); }))) {
            mixin(enumMixinStr_GL_INCR);
        }
    }




    static if(!is(typeof(GL_REPLACE))) {
        private enum enumMixinStr_GL_REPLACE = `enum GL_REPLACE = 0x1E01;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_REPLACE); }))) {
            mixin(enumMixinStr_GL_REPLACE);
        }
    }




    static if(!is(typeof(GL_KEEP))) {
        private enum enumMixinStr_GL_KEEP = `enum GL_KEEP = 0x1E00;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_KEEP); }))) {
            mixin(enumMixinStr_GL_KEEP);
        }
    }




    static if(!is(typeof(GL_ALWAYS))) {
        private enum enumMixinStr_GL_ALWAYS = `enum GL_ALWAYS = 0x0207;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ALWAYS); }))) {
            mixin(enumMixinStr_GL_ALWAYS);
        }
    }




    static if(!is(typeof(GL_GEQUAL))) {
        private enum enumMixinStr_GL_GEQUAL = `enum GL_GEQUAL = 0x0206;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_GEQUAL); }))) {
            mixin(enumMixinStr_GL_GEQUAL);
        }
    }




    static if(!is(typeof(GL_NOTEQUAL))) {
        private enum enumMixinStr_GL_NOTEQUAL = `enum GL_NOTEQUAL = 0x0205;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NOTEQUAL); }))) {
            mixin(enumMixinStr_GL_NOTEQUAL);
        }
    }




    static if(!is(typeof(GL_GREATER))) {
        private enum enumMixinStr_GL_GREATER = `enum GL_GREATER = 0x0204;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_GREATER); }))) {
            mixin(enumMixinStr_GL_GREATER);
        }
    }




    static if(!is(typeof(GL_LEQUAL))) {
        private enum enumMixinStr_GL_LEQUAL = `enum GL_LEQUAL = 0x0203;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LEQUAL); }))) {
            mixin(enumMixinStr_GL_LEQUAL);
        }
    }




    static if(!is(typeof(GL_EQUAL))) {
        private enum enumMixinStr_GL_EQUAL = `enum GL_EQUAL = 0x0202;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_EQUAL); }))) {
            mixin(enumMixinStr_GL_EQUAL);
        }
    }




    static if(!is(typeof(GL_LESS))) {
        private enum enumMixinStr_GL_LESS = `enum GL_LESS = 0x0201;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LESS); }))) {
            mixin(enumMixinStr_GL_LESS);
        }
    }




    static if(!is(typeof(GL_NEVER))) {
        private enum enumMixinStr_GL_NEVER = `enum GL_NEVER = 0x0200;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NEVER); }))) {
            mixin(enumMixinStr_GL_NEVER);
        }
    }




    static if(!is(typeof(GL_CURRENT_PROGRAM))) {
        private enum enumMixinStr_GL_CURRENT_PROGRAM = `enum GL_CURRENT_PROGRAM = 0x8B8D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_CURRENT_PROGRAM); }))) {
            mixin(enumMixinStr_GL_CURRENT_PROGRAM);
        }
    }




    static if(!is(typeof(GL_SHADING_LANGUAGE_VERSION))) {
        private enum enumMixinStr_GL_SHADING_LANGUAGE_VERSION = `enum GL_SHADING_LANGUAGE_VERSION = 0x8B8C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SHADING_LANGUAGE_VERSION); }))) {
            mixin(enumMixinStr_GL_SHADING_LANGUAGE_VERSION);
        }
    }




    static if(!is(typeof(GL_ACTIVE_ATTRIBUTE_MAX_LENGTH))) {
        private enum enumMixinStr_GL_ACTIVE_ATTRIBUTE_MAX_LENGTH = `enum GL_ACTIVE_ATTRIBUTE_MAX_LENGTH = 0x8B8A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ACTIVE_ATTRIBUTE_MAX_LENGTH); }))) {
            mixin(enumMixinStr_GL_ACTIVE_ATTRIBUTE_MAX_LENGTH);
        }
    }




    static if(!is(typeof(GL_ACTIVE_ATTRIBUTES))) {
        private enum enumMixinStr_GL_ACTIVE_ATTRIBUTES = `enum GL_ACTIVE_ATTRIBUTES = 0x8B89;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ACTIVE_ATTRIBUTES); }))) {
            mixin(enumMixinStr_GL_ACTIVE_ATTRIBUTES);
        }
    }




    static if(!is(typeof(GL_ACTIVE_UNIFORM_MAX_LENGTH))) {
        private enum enumMixinStr_GL_ACTIVE_UNIFORM_MAX_LENGTH = `enum GL_ACTIVE_UNIFORM_MAX_LENGTH = 0x8B87;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ACTIVE_UNIFORM_MAX_LENGTH); }))) {
            mixin(enumMixinStr_GL_ACTIVE_UNIFORM_MAX_LENGTH);
        }
    }




    static if(!is(typeof(GL_ACTIVE_UNIFORMS))) {
        private enum enumMixinStr_GL_ACTIVE_UNIFORMS = `enum GL_ACTIVE_UNIFORMS = 0x8B86;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ACTIVE_UNIFORMS); }))) {
            mixin(enumMixinStr_GL_ACTIVE_UNIFORMS);
        }
    }




    static if(!is(typeof(GL_ATTACHED_SHADERS))) {
        private enum enumMixinStr_GL_ATTACHED_SHADERS = `enum GL_ATTACHED_SHADERS = 0x8B85;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ATTACHED_SHADERS); }))) {
            mixin(enumMixinStr_GL_ATTACHED_SHADERS);
        }
    }




    static if(!is(typeof(GL_ES_VERSION_3_1))) {
        private enum enumMixinStr_GL_ES_VERSION_3_1 = `enum GL_ES_VERSION_3_1 = 1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ES_VERSION_3_1); }))) {
            mixin(enumMixinStr_GL_ES_VERSION_3_1);
        }
    }




    static if(!is(typeof(GL_COMPUTE_SHADER))) {
        private enum enumMixinStr_GL_COMPUTE_SHADER = `enum GL_COMPUTE_SHADER = 0x91B9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPUTE_SHADER); }))) {
            mixin(enumMixinStr_GL_COMPUTE_SHADER);
        }
    }




    static if(!is(typeof(GL_MAX_COMPUTE_UNIFORM_BLOCKS))) {
        private enum enumMixinStr_GL_MAX_COMPUTE_UNIFORM_BLOCKS = `enum GL_MAX_COMPUTE_UNIFORM_BLOCKS = 0x91BB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMPUTE_UNIFORM_BLOCKS); }))) {
            mixin(enumMixinStr_GL_MAX_COMPUTE_UNIFORM_BLOCKS);
        }
    }




    static if(!is(typeof(GL_MAX_COMPUTE_TEXTURE_IMAGE_UNITS))) {
        private enum enumMixinStr_GL_MAX_COMPUTE_TEXTURE_IMAGE_UNITS = `enum GL_MAX_COMPUTE_TEXTURE_IMAGE_UNITS = 0x91BC;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMPUTE_TEXTURE_IMAGE_UNITS); }))) {
            mixin(enumMixinStr_GL_MAX_COMPUTE_TEXTURE_IMAGE_UNITS);
        }
    }




    static if(!is(typeof(GL_MAX_COMPUTE_IMAGE_UNIFORMS))) {
        private enum enumMixinStr_GL_MAX_COMPUTE_IMAGE_UNIFORMS = `enum GL_MAX_COMPUTE_IMAGE_UNIFORMS = 0x91BD;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMPUTE_IMAGE_UNIFORMS); }))) {
            mixin(enumMixinStr_GL_MAX_COMPUTE_IMAGE_UNIFORMS);
        }
    }




    static if(!is(typeof(GL_MAX_COMPUTE_SHARED_MEMORY_SIZE))) {
        private enum enumMixinStr_GL_MAX_COMPUTE_SHARED_MEMORY_SIZE = `enum GL_MAX_COMPUTE_SHARED_MEMORY_SIZE = 0x8262;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMPUTE_SHARED_MEMORY_SIZE); }))) {
            mixin(enumMixinStr_GL_MAX_COMPUTE_SHARED_MEMORY_SIZE);
        }
    }




    static if(!is(typeof(GL_MAX_COMPUTE_UNIFORM_COMPONENTS))) {
        private enum enumMixinStr_GL_MAX_COMPUTE_UNIFORM_COMPONENTS = `enum GL_MAX_COMPUTE_UNIFORM_COMPONENTS = 0x8263;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMPUTE_UNIFORM_COMPONENTS); }))) {
            mixin(enumMixinStr_GL_MAX_COMPUTE_UNIFORM_COMPONENTS);
        }
    }




    static if(!is(typeof(GL_MAX_COMPUTE_ATOMIC_COUNTER_BUFFERS))) {
        private enum enumMixinStr_GL_MAX_COMPUTE_ATOMIC_COUNTER_BUFFERS = `enum GL_MAX_COMPUTE_ATOMIC_COUNTER_BUFFERS = 0x8264;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMPUTE_ATOMIC_COUNTER_BUFFERS); }))) {
            mixin(enumMixinStr_GL_MAX_COMPUTE_ATOMIC_COUNTER_BUFFERS);
        }
    }




    static if(!is(typeof(GL_MAX_COMPUTE_ATOMIC_COUNTERS))) {
        private enum enumMixinStr_GL_MAX_COMPUTE_ATOMIC_COUNTERS = `enum GL_MAX_COMPUTE_ATOMIC_COUNTERS = 0x8265;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMPUTE_ATOMIC_COUNTERS); }))) {
            mixin(enumMixinStr_GL_MAX_COMPUTE_ATOMIC_COUNTERS);
        }
    }




    static if(!is(typeof(GL_MAX_COMBINED_COMPUTE_UNIFORM_COMPONENTS))) {
        private enum enumMixinStr_GL_MAX_COMBINED_COMPUTE_UNIFORM_COMPONENTS = `enum GL_MAX_COMBINED_COMPUTE_UNIFORM_COMPONENTS = 0x8266;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMBINED_COMPUTE_UNIFORM_COMPONENTS); }))) {
            mixin(enumMixinStr_GL_MAX_COMBINED_COMPUTE_UNIFORM_COMPONENTS);
        }
    }




    static if(!is(typeof(GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS))) {
        private enum enumMixinStr_GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS = `enum GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS = 0x90EB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS); }))) {
            mixin(enumMixinStr_GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS);
        }
    }




    static if(!is(typeof(GL_MAX_COMPUTE_WORK_GROUP_COUNT))) {
        private enum enumMixinStr_GL_MAX_COMPUTE_WORK_GROUP_COUNT = `enum GL_MAX_COMPUTE_WORK_GROUP_COUNT = 0x91BE;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMPUTE_WORK_GROUP_COUNT); }))) {
            mixin(enumMixinStr_GL_MAX_COMPUTE_WORK_GROUP_COUNT);
        }
    }




    static if(!is(typeof(GL_MAX_COMPUTE_WORK_GROUP_SIZE))) {
        private enum enumMixinStr_GL_MAX_COMPUTE_WORK_GROUP_SIZE = `enum GL_MAX_COMPUTE_WORK_GROUP_SIZE = 0x91BF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMPUTE_WORK_GROUP_SIZE); }))) {
            mixin(enumMixinStr_GL_MAX_COMPUTE_WORK_GROUP_SIZE);
        }
    }




    static if(!is(typeof(GL_COMPUTE_WORK_GROUP_SIZE))) {
        private enum enumMixinStr_GL_COMPUTE_WORK_GROUP_SIZE = `enum GL_COMPUTE_WORK_GROUP_SIZE = 0x8267;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPUTE_WORK_GROUP_SIZE); }))) {
            mixin(enumMixinStr_GL_COMPUTE_WORK_GROUP_SIZE);
        }
    }




    static if(!is(typeof(GL_DISPATCH_INDIRECT_BUFFER))) {
        private enum enumMixinStr_GL_DISPATCH_INDIRECT_BUFFER = `enum GL_DISPATCH_INDIRECT_BUFFER = 0x90EE;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DISPATCH_INDIRECT_BUFFER); }))) {
            mixin(enumMixinStr_GL_DISPATCH_INDIRECT_BUFFER);
        }
    }




    static if(!is(typeof(GL_DISPATCH_INDIRECT_BUFFER_BINDING))) {
        private enum enumMixinStr_GL_DISPATCH_INDIRECT_BUFFER_BINDING = `enum GL_DISPATCH_INDIRECT_BUFFER_BINDING = 0x90EF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DISPATCH_INDIRECT_BUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_DISPATCH_INDIRECT_BUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_COMPUTE_SHADER_BIT))) {
        private enum enumMixinStr_GL_COMPUTE_SHADER_BIT = `enum GL_COMPUTE_SHADER_BIT = 0x00000020;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPUTE_SHADER_BIT); }))) {
            mixin(enumMixinStr_GL_COMPUTE_SHADER_BIT);
        }
    }




    static if(!is(typeof(GL_DRAW_INDIRECT_BUFFER))) {
        private enum enumMixinStr_GL_DRAW_INDIRECT_BUFFER = `enum GL_DRAW_INDIRECT_BUFFER = 0x8F3F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_INDIRECT_BUFFER); }))) {
            mixin(enumMixinStr_GL_DRAW_INDIRECT_BUFFER);
        }
    }




    static if(!is(typeof(GL_DRAW_INDIRECT_BUFFER_BINDING))) {
        private enum enumMixinStr_GL_DRAW_INDIRECT_BUFFER_BINDING = `enum GL_DRAW_INDIRECT_BUFFER_BINDING = 0x8F43;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DRAW_INDIRECT_BUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_DRAW_INDIRECT_BUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_MAX_UNIFORM_LOCATIONS))) {
        private enum enumMixinStr_GL_MAX_UNIFORM_LOCATIONS = `enum GL_MAX_UNIFORM_LOCATIONS = 0x826E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_UNIFORM_LOCATIONS); }))) {
            mixin(enumMixinStr_GL_MAX_UNIFORM_LOCATIONS);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_DEFAULT_WIDTH))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_DEFAULT_WIDTH = `enum GL_FRAMEBUFFER_DEFAULT_WIDTH = 0x9310;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_DEFAULT_WIDTH); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_DEFAULT_WIDTH);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_DEFAULT_HEIGHT))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_DEFAULT_HEIGHT = `enum GL_FRAMEBUFFER_DEFAULT_HEIGHT = 0x9311;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_DEFAULT_HEIGHT); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_DEFAULT_HEIGHT);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_DEFAULT_SAMPLES))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_DEFAULT_SAMPLES = `enum GL_FRAMEBUFFER_DEFAULT_SAMPLES = 0x9313;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_DEFAULT_SAMPLES); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_DEFAULT_SAMPLES);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS = `enum GL_FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS = 0x9314;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS);
        }
    }




    static if(!is(typeof(GL_MAX_FRAMEBUFFER_WIDTH))) {
        private enum enumMixinStr_GL_MAX_FRAMEBUFFER_WIDTH = `enum GL_MAX_FRAMEBUFFER_WIDTH = 0x9315;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_FRAMEBUFFER_WIDTH); }))) {
            mixin(enumMixinStr_GL_MAX_FRAMEBUFFER_WIDTH);
        }
    }




    static if(!is(typeof(GL_MAX_FRAMEBUFFER_HEIGHT))) {
        private enum enumMixinStr_GL_MAX_FRAMEBUFFER_HEIGHT = `enum GL_MAX_FRAMEBUFFER_HEIGHT = 0x9316;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_FRAMEBUFFER_HEIGHT); }))) {
            mixin(enumMixinStr_GL_MAX_FRAMEBUFFER_HEIGHT);
        }
    }




    static if(!is(typeof(GL_MAX_FRAMEBUFFER_SAMPLES))) {
        private enum enumMixinStr_GL_MAX_FRAMEBUFFER_SAMPLES = `enum GL_MAX_FRAMEBUFFER_SAMPLES = 0x9318;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_FRAMEBUFFER_SAMPLES); }))) {
            mixin(enumMixinStr_GL_MAX_FRAMEBUFFER_SAMPLES);
        }
    }




    static if(!is(typeof(GL_UNIFORM))) {
        private enum enumMixinStr_GL_UNIFORM = `enum GL_UNIFORM = 0x92E1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM); }))) {
            mixin(enumMixinStr_GL_UNIFORM);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BLOCK))) {
        private enum enumMixinStr_GL_UNIFORM_BLOCK = `enum GL_UNIFORM_BLOCK = 0x92E2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BLOCK); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BLOCK);
        }
    }




    static if(!is(typeof(GL_PROGRAM_INPUT))) {
        private enum enumMixinStr_GL_PROGRAM_INPUT = `enum GL_PROGRAM_INPUT = 0x92E3;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PROGRAM_INPUT); }))) {
            mixin(enumMixinStr_GL_PROGRAM_INPUT);
        }
    }




    static if(!is(typeof(GL_PROGRAM_OUTPUT))) {
        private enum enumMixinStr_GL_PROGRAM_OUTPUT = `enum GL_PROGRAM_OUTPUT = 0x92E4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PROGRAM_OUTPUT); }))) {
            mixin(enumMixinStr_GL_PROGRAM_OUTPUT);
        }
    }




    static if(!is(typeof(GL_BUFFER_VARIABLE))) {
        private enum enumMixinStr_GL_BUFFER_VARIABLE = `enum GL_BUFFER_VARIABLE = 0x92E5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BUFFER_VARIABLE); }))) {
            mixin(enumMixinStr_GL_BUFFER_VARIABLE);
        }
    }




    static if(!is(typeof(GL_SHADER_STORAGE_BLOCK))) {
        private enum enumMixinStr_GL_SHADER_STORAGE_BLOCK = `enum GL_SHADER_STORAGE_BLOCK = 0x92E6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SHADER_STORAGE_BLOCK); }))) {
            mixin(enumMixinStr_GL_SHADER_STORAGE_BLOCK);
        }
    }




    static if(!is(typeof(GL_ATOMIC_COUNTER_BUFFER))) {
        private enum enumMixinStr_GL_ATOMIC_COUNTER_BUFFER = `enum GL_ATOMIC_COUNTER_BUFFER = 0x92C0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ATOMIC_COUNTER_BUFFER); }))) {
            mixin(enumMixinStr_GL_ATOMIC_COUNTER_BUFFER);
        }
    }




    static if(!is(typeof(GL_TRANSFORM_FEEDBACK_VARYING))) {
        private enum enumMixinStr_GL_TRANSFORM_FEEDBACK_VARYING = `enum GL_TRANSFORM_FEEDBACK_VARYING = 0x92F4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_VARYING); }))) {
            mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_VARYING);
        }
    }




    static if(!is(typeof(GL_ACTIVE_RESOURCES))) {
        private enum enumMixinStr_GL_ACTIVE_RESOURCES = `enum GL_ACTIVE_RESOURCES = 0x92F5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ACTIVE_RESOURCES); }))) {
            mixin(enumMixinStr_GL_ACTIVE_RESOURCES);
        }
    }




    static if(!is(typeof(GL_MAX_NAME_LENGTH))) {
        private enum enumMixinStr_GL_MAX_NAME_LENGTH = `enum GL_MAX_NAME_LENGTH = 0x92F6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_NAME_LENGTH); }))) {
            mixin(enumMixinStr_GL_MAX_NAME_LENGTH);
        }
    }




    static if(!is(typeof(GL_MAX_NUM_ACTIVE_VARIABLES))) {
        private enum enumMixinStr_GL_MAX_NUM_ACTIVE_VARIABLES = `enum GL_MAX_NUM_ACTIVE_VARIABLES = 0x92F7;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_NUM_ACTIVE_VARIABLES); }))) {
            mixin(enumMixinStr_GL_MAX_NUM_ACTIVE_VARIABLES);
        }
    }




    static if(!is(typeof(GL_NAME_LENGTH))) {
        private enum enumMixinStr_GL_NAME_LENGTH = `enum GL_NAME_LENGTH = 0x92F9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NAME_LENGTH); }))) {
            mixin(enumMixinStr_GL_NAME_LENGTH);
        }
    }




    static if(!is(typeof(GL_TYPE))) {
        private enum enumMixinStr_GL_TYPE = `enum GL_TYPE = 0x92FA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TYPE); }))) {
            mixin(enumMixinStr_GL_TYPE);
        }
    }




    static if(!is(typeof(GL_ARRAY_SIZE))) {
        private enum enumMixinStr_GL_ARRAY_SIZE = `enum GL_ARRAY_SIZE = 0x92FB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ARRAY_SIZE); }))) {
            mixin(enumMixinStr_GL_ARRAY_SIZE);
        }
    }




    static if(!is(typeof(GL_OFFSET))) {
        private enum enumMixinStr_GL_OFFSET = `enum GL_OFFSET = 0x92FC;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_OFFSET); }))) {
            mixin(enumMixinStr_GL_OFFSET);
        }
    }




    static if(!is(typeof(GL_BLOCK_INDEX))) {
        private enum enumMixinStr_GL_BLOCK_INDEX = `enum GL_BLOCK_INDEX = 0x92FD;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BLOCK_INDEX); }))) {
            mixin(enumMixinStr_GL_BLOCK_INDEX);
        }
    }




    static if(!is(typeof(GL_ARRAY_STRIDE))) {
        private enum enumMixinStr_GL_ARRAY_STRIDE = `enum GL_ARRAY_STRIDE = 0x92FE;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ARRAY_STRIDE); }))) {
            mixin(enumMixinStr_GL_ARRAY_STRIDE);
        }
    }




    static if(!is(typeof(GL_MATRIX_STRIDE))) {
        private enum enumMixinStr_GL_MATRIX_STRIDE = `enum GL_MATRIX_STRIDE = 0x92FF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MATRIX_STRIDE); }))) {
            mixin(enumMixinStr_GL_MATRIX_STRIDE);
        }
    }




    static if(!is(typeof(GL_IS_ROW_MAJOR))) {
        private enum enumMixinStr_GL_IS_ROW_MAJOR = `enum GL_IS_ROW_MAJOR = 0x9300;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IS_ROW_MAJOR); }))) {
            mixin(enumMixinStr_GL_IS_ROW_MAJOR);
        }
    }




    static if(!is(typeof(GL_ATOMIC_COUNTER_BUFFER_INDEX))) {
        private enum enumMixinStr_GL_ATOMIC_COUNTER_BUFFER_INDEX = `enum GL_ATOMIC_COUNTER_BUFFER_INDEX = 0x9301;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ATOMIC_COUNTER_BUFFER_INDEX); }))) {
            mixin(enumMixinStr_GL_ATOMIC_COUNTER_BUFFER_INDEX);
        }
    }




    static if(!is(typeof(GL_BUFFER_BINDING))) {
        private enum enumMixinStr_GL_BUFFER_BINDING = `enum GL_BUFFER_BINDING = 0x9302;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_BUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_BUFFER_DATA_SIZE))) {
        private enum enumMixinStr_GL_BUFFER_DATA_SIZE = `enum GL_BUFFER_DATA_SIZE = 0x9303;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BUFFER_DATA_SIZE); }))) {
            mixin(enumMixinStr_GL_BUFFER_DATA_SIZE);
        }
    }




    static if(!is(typeof(GL_NUM_ACTIVE_VARIABLES))) {
        private enum enumMixinStr_GL_NUM_ACTIVE_VARIABLES = `enum GL_NUM_ACTIVE_VARIABLES = 0x9304;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NUM_ACTIVE_VARIABLES); }))) {
            mixin(enumMixinStr_GL_NUM_ACTIVE_VARIABLES);
        }
    }




    static if(!is(typeof(GL_ACTIVE_VARIABLES))) {
        private enum enumMixinStr_GL_ACTIVE_VARIABLES = `enum GL_ACTIVE_VARIABLES = 0x9305;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ACTIVE_VARIABLES); }))) {
            mixin(enumMixinStr_GL_ACTIVE_VARIABLES);
        }
    }




    static if(!is(typeof(GL_REFERENCED_BY_VERTEX_SHADER))) {
        private enum enumMixinStr_GL_REFERENCED_BY_VERTEX_SHADER = `enum GL_REFERENCED_BY_VERTEX_SHADER = 0x9306;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_REFERENCED_BY_VERTEX_SHADER); }))) {
            mixin(enumMixinStr_GL_REFERENCED_BY_VERTEX_SHADER);
        }
    }




    static if(!is(typeof(GL_REFERENCED_BY_FRAGMENT_SHADER))) {
        private enum enumMixinStr_GL_REFERENCED_BY_FRAGMENT_SHADER = `enum GL_REFERENCED_BY_FRAGMENT_SHADER = 0x930A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_REFERENCED_BY_FRAGMENT_SHADER); }))) {
            mixin(enumMixinStr_GL_REFERENCED_BY_FRAGMENT_SHADER);
        }
    }




    static if(!is(typeof(GL_REFERENCED_BY_COMPUTE_SHADER))) {
        private enum enumMixinStr_GL_REFERENCED_BY_COMPUTE_SHADER = `enum GL_REFERENCED_BY_COMPUTE_SHADER = 0x930B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_REFERENCED_BY_COMPUTE_SHADER); }))) {
            mixin(enumMixinStr_GL_REFERENCED_BY_COMPUTE_SHADER);
        }
    }




    static if(!is(typeof(GL_TOP_LEVEL_ARRAY_SIZE))) {
        private enum enumMixinStr_GL_TOP_LEVEL_ARRAY_SIZE = `enum GL_TOP_LEVEL_ARRAY_SIZE = 0x930C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TOP_LEVEL_ARRAY_SIZE); }))) {
            mixin(enumMixinStr_GL_TOP_LEVEL_ARRAY_SIZE);
        }
    }




    static if(!is(typeof(GL_TOP_LEVEL_ARRAY_STRIDE))) {
        private enum enumMixinStr_GL_TOP_LEVEL_ARRAY_STRIDE = `enum GL_TOP_LEVEL_ARRAY_STRIDE = 0x930D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TOP_LEVEL_ARRAY_STRIDE); }))) {
            mixin(enumMixinStr_GL_TOP_LEVEL_ARRAY_STRIDE);
        }
    }




    static if(!is(typeof(GL_LOCATION))) {
        private enum enumMixinStr_GL_LOCATION = `enum GL_LOCATION = 0x930E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LOCATION); }))) {
            mixin(enumMixinStr_GL_LOCATION);
        }
    }




    static if(!is(typeof(GL_VERTEX_SHADER_BIT))) {
        private enum enumMixinStr_GL_VERTEX_SHADER_BIT = `enum GL_VERTEX_SHADER_BIT = 0x00000001;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_SHADER_BIT); }))) {
            mixin(enumMixinStr_GL_VERTEX_SHADER_BIT);
        }
    }




    static if(!is(typeof(GL_FRAGMENT_SHADER_BIT))) {
        private enum enumMixinStr_GL_FRAGMENT_SHADER_BIT = `enum GL_FRAGMENT_SHADER_BIT = 0x00000002;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAGMENT_SHADER_BIT); }))) {
            mixin(enumMixinStr_GL_FRAGMENT_SHADER_BIT);
        }
    }




    static if(!is(typeof(GL_ALL_SHADER_BITS))) {
        private enum enumMixinStr_GL_ALL_SHADER_BITS = `enum GL_ALL_SHADER_BITS = 0xFFFFFFFF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ALL_SHADER_BITS); }))) {
            mixin(enumMixinStr_GL_ALL_SHADER_BITS);
        }
    }




    static if(!is(typeof(GL_PROGRAM_SEPARABLE))) {
        private enum enumMixinStr_GL_PROGRAM_SEPARABLE = `enum GL_PROGRAM_SEPARABLE = 0x8258;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PROGRAM_SEPARABLE); }))) {
            mixin(enumMixinStr_GL_PROGRAM_SEPARABLE);
        }
    }




    static if(!is(typeof(GL_ACTIVE_PROGRAM))) {
        private enum enumMixinStr_GL_ACTIVE_PROGRAM = `enum GL_ACTIVE_PROGRAM = 0x8259;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ACTIVE_PROGRAM); }))) {
            mixin(enumMixinStr_GL_ACTIVE_PROGRAM);
        }
    }




    static if(!is(typeof(GL_PROGRAM_PIPELINE_BINDING))) {
        private enum enumMixinStr_GL_PROGRAM_PIPELINE_BINDING = `enum GL_PROGRAM_PIPELINE_BINDING = 0x825A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PROGRAM_PIPELINE_BINDING); }))) {
            mixin(enumMixinStr_GL_PROGRAM_PIPELINE_BINDING);
        }
    }




    static if(!is(typeof(GL_ATOMIC_COUNTER_BUFFER_BINDING))) {
        private enum enumMixinStr_GL_ATOMIC_COUNTER_BUFFER_BINDING = `enum GL_ATOMIC_COUNTER_BUFFER_BINDING = 0x92C1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ATOMIC_COUNTER_BUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_ATOMIC_COUNTER_BUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_ATOMIC_COUNTER_BUFFER_START))) {
        private enum enumMixinStr_GL_ATOMIC_COUNTER_BUFFER_START = `enum GL_ATOMIC_COUNTER_BUFFER_START = 0x92C2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ATOMIC_COUNTER_BUFFER_START); }))) {
            mixin(enumMixinStr_GL_ATOMIC_COUNTER_BUFFER_START);
        }
    }




    static if(!is(typeof(GL_ATOMIC_COUNTER_BUFFER_SIZE))) {
        private enum enumMixinStr_GL_ATOMIC_COUNTER_BUFFER_SIZE = `enum GL_ATOMIC_COUNTER_BUFFER_SIZE = 0x92C3;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ATOMIC_COUNTER_BUFFER_SIZE); }))) {
            mixin(enumMixinStr_GL_ATOMIC_COUNTER_BUFFER_SIZE);
        }
    }




    static if(!is(typeof(GL_MAX_VERTEX_ATOMIC_COUNTER_BUFFERS))) {
        private enum enumMixinStr_GL_MAX_VERTEX_ATOMIC_COUNTER_BUFFERS = `enum GL_MAX_VERTEX_ATOMIC_COUNTER_BUFFERS = 0x92CC;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VERTEX_ATOMIC_COUNTER_BUFFERS); }))) {
            mixin(enumMixinStr_GL_MAX_VERTEX_ATOMIC_COUNTER_BUFFERS);
        }
    }




    static if(!is(typeof(GL_MAX_FRAGMENT_ATOMIC_COUNTER_BUFFERS))) {
        private enum enumMixinStr_GL_MAX_FRAGMENT_ATOMIC_COUNTER_BUFFERS = `enum GL_MAX_FRAGMENT_ATOMIC_COUNTER_BUFFERS = 0x92D0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_FRAGMENT_ATOMIC_COUNTER_BUFFERS); }))) {
            mixin(enumMixinStr_GL_MAX_FRAGMENT_ATOMIC_COUNTER_BUFFERS);
        }
    }




    static if(!is(typeof(GL_MAX_COMBINED_ATOMIC_COUNTER_BUFFERS))) {
        private enum enumMixinStr_GL_MAX_COMBINED_ATOMIC_COUNTER_BUFFERS = `enum GL_MAX_COMBINED_ATOMIC_COUNTER_BUFFERS = 0x92D1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMBINED_ATOMIC_COUNTER_BUFFERS); }))) {
            mixin(enumMixinStr_GL_MAX_COMBINED_ATOMIC_COUNTER_BUFFERS);
        }
    }




    static if(!is(typeof(GL_MAX_VERTEX_ATOMIC_COUNTERS))) {
        private enum enumMixinStr_GL_MAX_VERTEX_ATOMIC_COUNTERS = `enum GL_MAX_VERTEX_ATOMIC_COUNTERS = 0x92D2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VERTEX_ATOMIC_COUNTERS); }))) {
            mixin(enumMixinStr_GL_MAX_VERTEX_ATOMIC_COUNTERS);
        }
    }




    static if(!is(typeof(GL_MAX_FRAGMENT_ATOMIC_COUNTERS))) {
        private enum enumMixinStr_GL_MAX_FRAGMENT_ATOMIC_COUNTERS = `enum GL_MAX_FRAGMENT_ATOMIC_COUNTERS = 0x92D6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_FRAGMENT_ATOMIC_COUNTERS); }))) {
            mixin(enumMixinStr_GL_MAX_FRAGMENT_ATOMIC_COUNTERS);
        }
    }




    static if(!is(typeof(GL_MAX_COMBINED_ATOMIC_COUNTERS))) {
        private enum enumMixinStr_GL_MAX_COMBINED_ATOMIC_COUNTERS = `enum GL_MAX_COMBINED_ATOMIC_COUNTERS = 0x92D7;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMBINED_ATOMIC_COUNTERS); }))) {
            mixin(enumMixinStr_GL_MAX_COMBINED_ATOMIC_COUNTERS);
        }
    }




    static if(!is(typeof(GL_MAX_ATOMIC_COUNTER_BUFFER_SIZE))) {
        private enum enumMixinStr_GL_MAX_ATOMIC_COUNTER_BUFFER_SIZE = `enum GL_MAX_ATOMIC_COUNTER_BUFFER_SIZE = 0x92D8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_ATOMIC_COUNTER_BUFFER_SIZE); }))) {
            mixin(enumMixinStr_GL_MAX_ATOMIC_COUNTER_BUFFER_SIZE);
        }
    }




    static if(!is(typeof(GL_MAX_ATOMIC_COUNTER_BUFFER_BINDINGS))) {
        private enum enumMixinStr_GL_MAX_ATOMIC_COUNTER_BUFFER_BINDINGS = `enum GL_MAX_ATOMIC_COUNTER_BUFFER_BINDINGS = 0x92DC;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_ATOMIC_COUNTER_BUFFER_BINDINGS); }))) {
            mixin(enumMixinStr_GL_MAX_ATOMIC_COUNTER_BUFFER_BINDINGS);
        }
    }




    static if(!is(typeof(GL_ACTIVE_ATOMIC_COUNTER_BUFFERS))) {
        private enum enumMixinStr_GL_ACTIVE_ATOMIC_COUNTER_BUFFERS = `enum GL_ACTIVE_ATOMIC_COUNTER_BUFFERS = 0x92D9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ACTIVE_ATOMIC_COUNTER_BUFFERS); }))) {
            mixin(enumMixinStr_GL_ACTIVE_ATOMIC_COUNTER_BUFFERS);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_ATOMIC_COUNTER))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_ATOMIC_COUNTER = `enum GL_UNSIGNED_INT_ATOMIC_COUNTER = 0x92DB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_ATOMIC_COUNTER); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_ATOMIC_COUNTER);
        }
    }




    static if(!is(typeof(GL_MAX_IMAGE_UNITS))) {
        private enum enumMixinStr_GL_MAX_IMAGE_UNITS = `enum GL_MAX_IMAGE_UNITS = 0x8F38;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_IMAGE_UNITS); }))) {
            mixin(enumMixinStr_GL_MAX_IMAGE_UNITS);
        }
    }




    static if(!is(typeof(GL_MAX_VERTEX_IMAGE_UNIFORMS))) {
        private enum enumMixinStr_GL_MAX_VERTEX_IMAGE_UNIFORMS = `enum GL_MAX_VERTEX_IMAGE_UNIFORMS = 0x90CA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VERTEX_IMAGE_UNIFORMS); }))) {
            mixin(enumMixinStr_GL_MAX_VERTEX_IMAGE_UNIFORMS);
        }
    }




    static if(!is(typeof(GL_MAX_FRAGMENT_IMAGE_UNIFORMS))) {
        private enum enumMixinStr_GL_MAX_FRAGMENT_IMAGE_UNIFORMS = `enum GL_MAX_FRAGMENT_IMAGE_UNIFORMS = 0x90CE;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_FRAGMENT_IMAGE_UNIFORMS); }))) {
            mixin(enumMixinStr_GL_MAX_FRAGMENT_IMAGE_UNIFORMS);
        }
    }




    static if(!is(typeof(GL_MAX_COMBINED_IMAGE_UNIFORMS))) {
        private enum enumMixinStr_GL_MAX_COMBINED_IMAGE_UNIFORMS = `enum GL_MAX_COMBINED_IMAGE_UNIFORMS = 0x90CF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMBINED_IMAGE_UNIFORMS); }))) {
            mixin(enumMixinStr_GL_MAX_COMBINED_IMAGE_UNIFORMS);
        }
    }




    static if(!is(typeof(GL_IMAGE_BINDING_NAME))) {
        private enum enumMixinStr_GL_IMAGE_BINDING_NAME = `enum GL_IMAGE_BINDING_NAME = 0x8F3A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMAGE_BINDING_NAME); }))) {
            mixin(enumMixinStr_GL_IMAGE_BINDING_NAME);
        }
    }




    static if(!is(typeof(GL_IMAGE_BINDING_LEVEL))) {
        private enum enumMixinStr_GL_IMAGE_BINDING_LEVEL = `enum GL_IMAGE_BINDING_LEVEL = 0x8F3B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMAGE_BINDING_LEVEL); }))) {
            mixin(enumMixinStr_GL_IMAGE_BINDING_LEVEL);
        }
    }




    static if(!is(typeof(GL_IMAGE_BINDING_LAYERED))) {
        private enum enumMixinStr_GL_IMAGE_BINDING_LAYERED = `enum GL_IMAGE_BINDING_LAYERED = 0x8F3C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMAGE_BINDING_LAYERED); }))) {
            mixin(enumMixinStr_GL_IMAGE_BINDING_LAYERED);
        }
    }




    static if(!is(typeof(GL_IMAGE_BINDING_LAYER))) {
        private enum enumMixinStr_GL_IMAGE_BINDING_LAYER = `enum GL_IMAGE_BINDING_LAYER = 0x8F3D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMAGE_BINDING_LAYER); }))) {
            mixin(enumMixinStr_GL_IMAGE_BINDING_LAYER);
        }
    }




    static if(!is(typeof(GL_IMAGE_BINDING_ACCESS))) {
        private enum enumMixinStr_GL_IMAGE_BINDING_ACCESS = `enum GL_IMAGE_BINDING_ACCESS = 0x8F3E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMAGE_BINDING_ACCESS); }))) {
            mixin(enumMixinStr_GL_IMAGE_BINDING_ACCESS);
        }
    }




    static if(!is(typeof(GL_IMAGE_BINDING_FORMAT))) {
        private enum enumMixinStr_GL_IMAGE_BINDING_FORMAT = `enum GL_IMAGE_BINDING_FORMAT = 0x906E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMAGE_BINDING_FORMAT); }))) {
            mixin(enumMixinStr_GL_IMAGE_BINDING_FORMAT);
        }
    }




    static if(!is(typeof(GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT))) {
        private enum enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT = `enum GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT = 0x00000001;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT); }))) {
            mixin(enumMixinStr_GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT);
        }
    }




    static if(!is(typeof(GL_ELEMENT_ARRAY_BARRIER_BIT))) {
        private enum enumMixinStr_GL_ELEMENT_ARRAY_BARRIER_BIT = `enum GL_ELEMENT_ARRAY_BARRIER_BIT = 0x00000002;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ELEMENT_ARRAY_BARRIER_BIT); }))) {
            mixin(enumMixinStr_GL_ELEMENT_ARRAY_BARRIER_BIT);
        }
    }




    static if(!is(typeof(GL_UNIFORM_BARRIER_BIT))) {
        private enum enumMixinStr_GL_UNIFORM_BARRIER_BIT = `enum GL_UNIFORM_BARRIER_BIT = 0x00000004;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNIFORM_BARRIER_BIT); }))) {
            mixin(enumMixinStr_GL_UNIFORM_BARRIER_BIT);
        }
    }




    static if(!is(typeof(GL_TEXTURE_FETCH_BARRIER_BIT))) {
        private enum enumMixinStr_GL_TEXTURE_FETCH_BARRIER_BIT = `enum GL_TEXTURE_FETCH_BARRIER_BIT = 0x00000008;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_FETCH_BARRIER_BIT); }))) {
            mixin(enumMixinStr_GL_TEXTURE_FETCH_BARRIER_BIT);
        }
    }




    static if(!is(typeof(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT))) {
        private enum enumMixinStr_GL_SHADER_IMAGE_ACCESS_BARRIER_BIT = `enum GL_SHADER_IMAGE_ACCESS_BARRIER_BIT = 0x00000020;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SHADER_IMAGE_ACCESS_BARRIER_BIT); }))) {
            mixin(enumMixinStr_GL_SHADER_IMAGE_ACCESS_BARRIER_BIT);
        }
    }




    static if(!is(typeof(GL_COMMAND_BARRIER_BIT))) {
        private enum enumMixinStr_GL_COMMAND_BARRIER_BIT = `enum GL_COMMAND_BARRIER_BIT = 0x00000040;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMMAND_BARRIER_BIT); }))) {
            mixin(enumMixinStr_GL_COMMAND_BARRIER_BIT);
        }
    }




    static if(!is(typeof(GL_PIXEL_BUFFER_BARRIER_BIT))) {
        private enum enumMixinStr_GL_PIXEL_BUFFER_BARRIER_BIT = `enum GL_PIXEL_BUFFER_BARRIER_BIT = 0x00000080;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PIXEL_BUFFER_BARRIER_BIT); }))) {
            mixin(enumMixinStr_GL_PIXEL_BUFFER_BARRIER_BIT);
        }
    }




    static if(!is(typeof(GL_TEXTURE_UPDATE_BARRIER_BIT))) {
        private enum enumMixinStr_GL_TEXTURE_UPDATE_BARRIER_BIT = `enum GL_TEXTURE_UPDATE_BARRIER_BIT = 0x00000100;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_UPDATE_BARRIER_BIT); }))) {
            mixin(enumMixinStr_GL_TEXTURE_UPDATE_BARRIER_BIT);
        }
    }




    static if(!is(typeof(GL_BUFFER_UPDATE_BARRIER_BIT))) {
        private enum enumMixinStr_GL_BUFFER_UPDATE_BARRIER_BIT = `enum GL_BUFFER_UPDATE_BARRIER_BIT = 0x00000200;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BUFFER_UPDATE_BARRIER_BIT); }))) {
            mixin(enumMixinStr_GL_BUFFER_UPDATE_BARRIER_BIT);
        }
    }




    static if(!is(typeof(GL_FRAMEBUFFER_BARRIER_BIT))) {
        private enum enumMixinStr_GL_FRAMEBUFFER_BARRIER_BIT = `enum GL_FRAMEBUFFER_BARRIER_BIT = 0x00000400;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAMEBUFFER_BARRIER_BIT); }))) {
            mixin(enumMixinStr_GL_FRAMEBUFFER_BARRIER_BIT);
        }
    }




    static if(!is(typeof(GL_TRANSFORM_FEEDBACK_BARRIER_BIT))) {
        private enum enumMixinStr_GL_TRANSFORM_FEEDBACK_BARRIER_BIT = `enum GL_TRANSFORM_FEEDBACK_BARRIER_BIT = 0x00000800;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_BARRIER_BIT); }))) {
            mixin(enumMixinStr_GL_TRANSFORM_FEEDBACK_BARRIER_BIT);
        }
    }




    static if(!is(typeof(GL_ATOMIC_COUNTER_BARRIER_BIT))) {
        private enum enumMixinStr_GL_ATOMIC_COUNTER_BARRIER_BIT = `enum GL_ATOMIC_COUNTER_BARRIER_BIT = 0x00001000;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ATOMIC_COUNTER_BARRIER_BIT); }))) {
            mixin(enumMixinStr_GL_ATOMIC_COUNTER_BARRIER_BIT);
        }
    }




    static if(!is(typeof(GL_ALL_BARRIER_BITS))) {
        private enum enumMixinStr_GL_ALL_BARRIER_BITS = `enum GL_ALL_BARRIER_BITS = 0xFFFFFFFF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ALL_BARRIER_BITS); }))) {
            mixin(enumMixinStr_GL_ALL_BARRIER_BITS);
        }
    }




    static if(!is(typeof(GL_IMAGE_2D))) {
        private enum enumMixinStr_GL_IMAGE_2D = `enum GL_IMAGE_2D = 0x904D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMAGE_2D); }))) {
            mixin(enumMixinStr_GL_IMAGE_2D);
        }
    }




    static if(!is(typeof(GL_IMAGE_3D))) {
        private enum enumMixinStr_GL_IMAGE_3D = `enum GL_IMAGE_3D = 0x904E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMAGE_3D); }))) {
            mixin(enumMixinStr_GL_IMAGE_3D);
        }
    }




    static if(!is(typeof(GL_IMAGE_CUBE))) {
        private enum enumMixinStr_GL_IMAGE_CUBE = `enum GL_IMAGE_CUBE = 0x9050;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMAGE_CUBE); }))) {
            mixin(enumMixinStr_GL_IMAGE_CUBE);
        }
    }




    static if(!is(typeof(GL_IMAGE_2D_ARRAY))) {
        private enum enumMixinStr_GL_IMAGE_2D_ARRAY = `enum GL_IMAGE_2D_ARRAY = 0x9053;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMAGE_2D_ARRAY); }))) {
            mixin(enumMixinStr_GL_IMAGE_2D_ARRAY);
        }
    }




    static if(!is(typeof(GL_INT_IMAGE_2D))) {
        private enum enumMixinStr_GL_INT_IMAGE_2D = `enum GL_INT_IMAGE_2D = 0x9058;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INT_IMAGE_2D); }))) {
            mixin(enumMixinStr_GL_INT_IMAGE_2D);
        }
    }




    static if(!is(typeof(GL_INT_IMAGE_3D))) {
        private enum enumMixinStr_GL_INT_IMAGE_3D = `enum GL_INT_IMAGE_3D = 0x9059;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INT_IMAGE_3D); }))) {
            mixin(enumMixinStr_GL_INT_IMAGE_3D);
        }
    }




    static if(!is(typeof(GL_INT_IMAGE_CUBE))) {
        private enum enumMixinStr_GL_INT_IMAGE_CUBE = `enum GL_INT_IMAGE_CUBE = 0x905B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INT_IMAGE_CUBE); }))) {
            mixin(enumMixinStr_GL_INT_IMAGE_CUBE);
        }
    }




    static if(!is(typeof(GL_INT_IMAGE_2D_ARRAY))) {
        private enum enumMixinStr_GL_INT_IMAGE_2D_ARRAY = `enum GL_INT_IMAGE_2D_ARRAY = 0x905E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INT_IMAGE_2D_ARRAY); }))) {
            mixin(enumMixinStr_GL_INT_IMAGE_2D_ARRAY);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_IMAGE_2D))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_IMAGE_2D = `enum GL_UNSIGNED_INT_IMAGE_2D = 0x9063;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_IMAGE_2D); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_IMAGE_2D);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_IMAGE_3D))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_IMAGE_3D = `enum GL_UNSIGNED_INT_IMAGE_3D = 0x9064;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_IMAGE_3D); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_IMAGE_3D);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_IMAGE_CUBE))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_IMAGE_CUBE = `enum GL_UNSIGNED_INT_IMAGE_CUBE = 0x9066;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_IMAGE_CUBE); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_IMAGE_CUBE);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_IMAGE_2D_ARRAY))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_IMAGE_2D_ARRAY = `enum GL_UNSIGNED_INT_IMAGE_2D_ARRAY = 0x9069;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_IMAGE_2D_ARRAY); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_IMAGE_2D_ARRAY);
        }
    }




    static if(!is(typeof(GL_IMAGE_FORMAT_COMPATIBILITY_TYPE))) {
        private enum enumMixinStr_GL_IMAGE_FORMAT_COMPATIBILITY_TYPE = `enum GL_IMAGE_FORMAT_COMPATIBILITY_TYPE = 0x90C7;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMAGE_FORMAT_COMPATIBILITY_TYPE); }))) {
            mixin(enumMixinStr_GL_IMAGE_FORMAT_COMPATIBILITY_TYPE);
        }
    }




    static if(!is(typeof(GL_IMAGE_FORMAT_COMPATIBILITY_BY_SIZE))) {
        private enum enumMixinStr_GL_IMAGE_FORMAT_COMPATIBILITY_BY_SIZE = `enum GL_IMAGE_FORMAT_COMPATIBILITY_BY_SIZE = 0x90C8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMAGE_FORMAT_COMPATIBILITY_BY_SIZE); }))) {
            mixin(enumMixinStr_GL_IMAGE_FORMAT_COMPATIBILITY_BY_SIZE);
        }
    }




    static if(!is(typeof(GL_IMAGE_FORMAT_COMPATIBILITY_BY_CLASS))) {
        private enum enumMixinStr_GL_IMAGE_FORMAT_COMPATIBILITY_BY_CLASS = `enum GL_IMAGE_FORMAT_COMPATIBILITY_BY_CLASS = 0x90C9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_IMAGE_FORMAT_COMPATIBILITY_BY_CLASS); }))) {
            mixin(enumMixinStr_GL_IMAGE_FORMAT_COMPATIBILITY_BY_CLASS);
        }
    }




    static if(!is(typeof(GL_READ_ONLY))) {
        private enum enumMixinStr_GL_READ_ONLY = `enum GL_READ_ONLY = 0x88B8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_READ_ONLY); }))) {
            mixin(enumMixinStr_GL_READ_ONLY);
        }
    }




    static if(!is(typeof(GL_WRITE_ONLY))) {
        private enum enumMixinStr_GL_WRITE_ONLY = `enum GL_WRITE_ONLY = 0x88B9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_WRITE_ONLY); }))) {
            mixin(enumMixinStr_GL_WRITE_ONLY);
        }
    }




    static if(!is(typeof(GL_READ_WRITE))) {
        private enum enumMixinStr_GL_READ_WRITE = `enum GL_READ_WRITE = 0x88BA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_READ_WRITE); }))) {
            mixin(enumMixinStr_GL_READ_WRITE);
        }
    }




    static if(!is(typeof(GL_SHADER_STORAGE_BUFFER))) {
        private enum enumMixinStr_GL_SHADER_STORAGE_BUFFER = `enum GL_SHADER_STORAGE_BUFFER = 0x90D2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SHADER_STORAGE_BUFFER); }))) {
            mixin(enumMixinStr_GL_SHADER_STORAGE_BUFFER);
        }
    }




    static if(!is(typeof(GL_SHADER_STORAGE_BUFFER_BINDING))) {
        private enum enumMixinStr_GL_SHADER_STORAGE_BUFFER_BINDING = `enum GL_SHADER_STORAGE_BUFFER_BINDING = 0x90D3;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SHADER_STORAGE_BUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_SHADER_STORAGE_BUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_SHADER_STORAGE_BUFFER_START))) {
        private enum enumMixinStr_GL_SHADER_STORAGE_BUFFER_START = `enum GL_SHADER_STORAGE_BUFFER_START = 0x90D4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SHADER_STORAGE_BUFFER_START); }))) {
            mixin(enumMixinStr_GL_SHADER_STORAGE_BUFFER_START);
        }
    }




    static if(!is(typeof(GL_SHADER_STORAGE_BUFFER_SIZE))) {
        private enum enumMixinStr_GL_SHADER_STORAGE_BUFFER_SIZE = `enum GL_SHADER_STORAGE_BUFFER_SIZE = 0x90D5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SHADER_STORAGE_BUFFER_SIZE); }))) {
            mixin(enumMixinStr_GL_SHADER_STORAGE_BUFFER_SIZE);
        }
    }




    static if(!is(typeof(GL_MAX_VERTEX_SHADER_STORAGE_BLOCKS))) {
        private enum enumMixinStr_GL_MAX_VERTEX_SHADER_STORAGE_BLOCKS = `enum GL_MAX_VERTEX_SHADER_STORAGE_BLOCKS = 0x90D6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VERTEX_SHADER_STORAGE_BLOCKS); }))) {
            mixin(enumMixinStr_GL_MAX_VERTEX_SHADER_STORAGE_BLOCKS);
        }
    }




    static if(!is(typeof(GL_MAX_FRAGMENT_SHADER_STORAGE_BLOCKS))) {
        private enum enumMixinStr_GL_MAX_FRAGMENT_SHADER_STORAGE_BLOCKS = `enum GL_MAX_FRAGMENT_SHADER_STORAGE_BLOCKS = 0x90DA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_FRAGMENT_SHADER_STORAGE_BLOCKS); }))) {
            mixin(enumMixinStr_GL_MAX_FRAGMENT_SHADER_STORAGE_BLOCKS);
        }
    }




    static if(!is(typeof(GL_MAX_COMPUTE_SHADER_STORAGE_BLOCKS))) {
        private enum enumMixinStr_GL_MAX_COMPUTE_SHADER_STORAGE_BLOCKS = `enum GL_MAX_COMPUTE_SHADER_STORAGE_BLOCKS = 0x90DB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMPUTE_SHADER_STORAGE_BLOCKS); }))) {
            mixin(enumMixinStr_GL_MAX_COMPUTE_SHADER_STORAGE_BLOCKS);
        }
    }




    static if(!is(typeof(GL_MAX_COMBINED_SHADER_STORAGE_BLOCKS))) {
        private enum enumMixinStr_GL_MAX_COMBINED_SHADER_STORAGE_BLOCKS = `enum GL_MAX_COMBINED_SHADER_STORAGE_BLOCKS = 0x90DC;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMBINED_SHADER_STORAGE_BLOCKS); }))) {
            mixin(enumMixinStr_GL_MAX_COMBINED_SHADER_STORAGE_BLOCKS);
        }
    }




    static if(!is(typeof(GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS))) {
        private enum enumMixinStr_GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS = `enum GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS = 0x90DD;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS); }))) {
            mixin(enumMixinStr_GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS);
        }
    }




    static if(!is(typeof(GL_MAX_SHADER_STORAGE_BLOCK_SIZE))) {
        private enum enumMixinStr_GL_MAX_SHADER_STORAGE_BLOCK_SIZE = `enum GL_MAX_SHADER_STORAGE_BLOCK_SIZE = 0x90DE;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_SHADER_STORAGE_BLOCK_SIZE); }))) {
            mixin(enumMixinStr_GL_MAX_SHADER_STORAGE_BLOCK_SIZE);
        }
    }




    static if(!is(typeof(GL_SHADER_STORAGE_BUFFER_OFFSET_ALIGNMENT))) {
        private enum enumMixinStr_GL_SHADER_STORAGE_BUFFER_OFFSET_ALIGNMENT = `enum GL_SHADER_STORAGE_BUFFER_OFFSET_ALIGNMENT = 0x90DF;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SHADER_STORAGE_BUFFER_OFFSET_ALIGNMENT); }))) {
            mixin(enumMixinStr_GL_SHADER_STORAGE_BUFFER_OFFSET_ALIGNMENT);
        }
    }




    static if(!is(typeof(GL_SHADER_STORAGE_BARRIER_BIT))) {
        private enum enumMixinStr_GL_SHADER_STORAGE_BARRIER_BIT = `enum GL_SHADER_STORAGE_BARRIER_BIT = 0x00002000;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SHADER_STORAGE_BARRIER_BIT); }))) {
            mixin(enumMixinStr_GL_SHADER_STORAGE_BARRIER_BIT);
        }
    }




    static if(!is(typeof(GL_MAX_COMBINED_SHADER_OUTPUT_RESOURCES))) {
        private enum enumMixinStr_GL_MAX_COMBINED_SHADER_OUTPUT_RESOURCES = `enum GL_MAX_COMBINED_SHADER_OUTPUT_RESOURCES = 0x8F39;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMBINED_SHADER_OUTPUT_RESOURCES); }))) {
            mixin(enumMixinStr_GL_MAX_COMBINED_SHADER_OUTPUT_RESOURCES);
        }
    }




    static if(!is(typeof(GL_DEPTH_STENCIL_TEXTURE_MODE))) {
        private enum enumMixinStr_GL_DEPTH_STENCIL_TEXTURE_MODE = `enum GL_DEPTH_STENCIL_TEXTURE_MODE = 0x90EA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_STENCIL_TEXTURE_MODE); }))) {
            mixin(enumMixinStr_GL_DEPTH_STENCIL_TEXTURE_MODE);
        }
    }




    static if(!is(typeof(GL_STENCIL_INDEX))) {
        private enum enumMixinStr_GL_STENCIL_INDEX = `enum GL_STENCIL_INDEX = 0x1901;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_INDEX); }))) {
            mixin(enumMixinStr_GL_STENCIL_INDEX);
        }
    }




    static if(!is(typeof(GL_MIN_PROGRAM_TEXTURE_GATHER_OFFSET))) {
        private enum enumMixinStr_GL_MIN_PROGRAM_TEXTURE_GATHER_OFFSET = `enum GL_MIN_PROGRAM_TEXTURE_GATHER_OFFSET = 0x8E5E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MIN_PROGRAM_TEXTURE_GATHER_OFFSET); }))) {
            mixin(enumMixinStr_GL_MIN_PROGRAM_TEXTURE_GATHER_OFFSET);
        }
    }




    static if(!is(typeof(GL_MAX_PROGRAM_TEXTURE_GATHER_OFFSET))) {
        private enum enumMixinStr_GL_MAX_PROGRAM_TEXTURE_GATHER_OFFSET = `enum GL_MAX_PROGRAM_TEXTURE_GATHER_OFFSET = 0x8E5F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_PROGRAM_TEXTURE_GATHER_OFFSET); }))) {
            mixin(enumMixinStr_GL_MAX_PROGRAM_TEXTURE_GATHER_OFFSET);
        }
    }




    static if(!is(typeof(GL_SAMPLE_POSITION))) {
        private enum enumMixinStr_GL_SAMPLE_POSITION = `enum GL_SAMPLE_POSITION = 0x8E50;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLE_POSITION); }))) {
            mixin(enumMixinStr_GL_SAMPLE_POSITION);
        }
    }




    static if(!is(typeof(GL_SAMPLE_MASK))) {
        private enum enumMixinStr_GL_SAMPLE_MASK = `enum GL_SAMPLE_MASK = 0x8E51;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLE_MASK); }))) {
            mixin(enumMixinStr_GL_SAMPLE_MASK);
        }
    }




    static if(!is(typeof(GL_SAMPLE_MASK_VALUE))) {
        private enum enumMixinStr_GL_SAMPLE_MASK_VALUE = `enum GL_SAMPLE_MASK_VALUE = 0x8E52;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLE_MASK_VALUE); }))) {
            mixin(enumMixinStr_GL_SAMPLE_MASK_VALUE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_2D_MULTISAMPLE))) {
        private enum enumMixinStr_GL_TEXTURE_2D_MULTISAMPLE = `enum GL_TEXTURE_2D_MULTISAMPLE = 0x9100;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_2D_MULTISAMPLE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_2D_MULTISAMPLE);
        }
    }




    static if(!is(typeof(GL_MAX_SAMPLE_MASK_WORDS))) {
        private enum enumMixinStr_GL_MAX_SAMPLE_MASK_WORDS = `enum GL_MAX_SAMPLE_MASK_WORDS = 0x8E59;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_SAMPLE_MASK_WORDS); }))) {
            mixin(enumMixinStr_GL_MAX_SAMPLE_MASK_WORDS);
        }
    }




    static if(!is(typeof(GL_MAX_COLOR_TEXTURE_SAMPLES))) {
        private enum enumMixinStr_GL_MAX_COLOR_TEXTURE_SAMPLES = `enum GL_MAX_COLOR_TEXTURE_SAMPLES = 0x910E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COLOR_TEXTURE_SAMPLES); }))) {
            mixin(enumMixinStr_GL_MAX_COLOR_TEXTURE_SAMPLES);
        }
    }




    static if(!is(typeof(GL_MAX_DEPTH_TEXTURE_SAMPLES))) {
        private enum enumMixinStr_GL_MAX_DEPTH_TEXTURE_SAMPLES = `enum GL_MAX_DEPTH_TEXTURE_SAMPLES = 0x910F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_DEPTH_TEXTURE_SAMPLES); }))) {
            mixin(enumMixinStr_GL_MAX_DEPTH_TEXTURE_SAMPLES);
        }
    }




    static if(!is(typeof(GL_MAX_INTEGER_SAMPLES))) {
        private enum enumMixinStr_GL_MAX_INTEGER_SAMPLES = `enum GL_MAX_INTEGER_SAMPLES = 0x9110;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_INTEGER_SAMPLES); }))) {
            mixin(enumMixinStr_GL_MAX_INTEGER_SAMPLES);
        }
    }




    static if(!is(typeof(GL_TEXTURE_BINDING_2D_MULTISAMPLE))) {
        private enum enumMixinStr_GL_TEXTURE_BINDING_2D_MULTISAMPLE = `enum GL_TEXTURE_BINDING_2D_MULTISAMPLE = 0x9104;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_BINDING_2D_MULTISAMPLE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_BINDING_2D_MULTISAMPLE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_SAMPLES))) {
        private enum enumMixinStr_GL_TEXTURE_SAMPLES = `enum GL_TEXTURE_SAMPLES = 0x9106;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_SAMPLES); }))) {
            mixin(enumMixinStr_GL_TEXTURE_SAMPLES);
        }
    }




    static if(!is(typeof(GL_TEXTURE_FIXED_SAMPLE_LOCATIONS))) {
        private enum enumMixinStr_GL_TEXTURE_FIXED_SAMPLE_LOCATIONS = `enum GL_TEXTURE_FIXED_SAMPLE_LOCATIONS = 0x9107;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_FIXED_SAMPLE_LOCATIONS); }))) {
            mixin(enumMixinStr_GL_TEXTURE_FIXED_SAMPLE_LOCATIONS);
        }
    }




    static if(!is(typeof(GL_TEXTURE_WIDTH))) {
        private enum enumMixinStr_GL_TEXTURE_WIDTH = `enum GL_TEXTURE_WIDTH = 0x1000;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_WIDTH); }))) {
            mixin(enumMixinStr_GL_TEXTURE_WIDTH);
        }
    }




    static if(!is(typeof(GL_TEXTURE_HEIGHT))) {
        private enum enumMixinStr_GL_TEXTURE_HEIGHT = `enum GL_TEXTURE_HEIGHT = 0x1001;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_HEIGHT); }))) {
            mixin(enumMixinStr_GL_TEXTURE_HEIGHT);
        }
    }




    static if(!is(typeof(GL_TEXTURE_DEPTH))) {
        private enum enumMixinStr_GL_TEXTURE_DEPTH = `enum GL_TEXTURE_DEPTH = 0x8071;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_DEPTH); }))) {
            mixin(enumMixinStr_GL_TEXTURE_DEPTH);
        }
    }




    static if(!is(typeof(GL_TEXTURE_INTERNAL_FORMAT))) {
        private enum enumMixinStr_GL_TEXTURE_INTERNAL_FORMAT = `enum GL_TEXTURE_INTERNAL_FORMAT = 0x1003;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_INTERNAL_FORMAT); }))) {
            mixin(enumMixinStr_GL_TEXTURE_INTERNAL_FORMAT);
        }
    }




    static if(!is(typeof(GL_TEXTURE_RED_SIZE))) {
        private enum enumMixinStr_GL_TEXTURE_RED_SIZE = `enum GL_TEXTURE_RED_SIZE = 0x805C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_RED_SIZE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_RED_SIZE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_GREEN_SIZE))) {
        private enum enumMixinStr_GL_TEXTURE_GREEN_SIZE = `enum GL_TEXTURE_GREEN_SIZE = 0x805D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_GREEN_SIZE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_GREEN_SIZE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_BLUE_SIZE))) {
        private enum enumMixinStr_GL_TEXTURE_BLUE_SIZE = `enum GL_TEXTURE_BLUE_SIZE = 0x805E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_BLUE_SIZE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_BLUE_SIZE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_ALPHA_SIZE))) {
        private enum enumMixinStr_GL_TEXTURE_ALPHA_SIZE = `enum GL_TEXTURE_ALPHA_SIZE = 0x805F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_ALPHA_SIZE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_ALPHA_SIZE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_DEPTH_SIZE))) {
        private enum enumMixinStr_GL_TEXTURE_DEPTH_SIZE = `enum GL_TEXTURE_DEPTH_SIZE = 0x884A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_DEPTH_SIZE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_DEPTH_SIZE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_STENCIL_SIZE))) {
        private enum enumMixinStr_GL_TEXTURE_STENCIL_SIZE = `enum GL_TEXTURE_STENCIL_SIZE = 0x88F1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_STENCIL_SIZE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_STENCIL_SIZE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_SHARED_SIZE))) {
        private enum enumMixinStr_GL_TEXTURE_SHARED_SIZE = `enum GL_TEXTURE_SHARED_SIZE = 0x8C3F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_SHARED_SIZE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_SHARED_SIZE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_RED_TYPE))) {
        private enum enumMixinStr_GL_TEXTURE_RED_TYPE = `enum GL_TEXTURE_RED_TYPE = 0x8C10;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_RED_TYPE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_RED_TYPE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_GREEN_TYPE))) {
        private enum enumMixinStr_GL_TEXTURE_GREEN_TYPE = `enum GL_TEXTURE_GREEN_TYPE = 0x8C11;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_GREEN_TYPE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_GREEN_TYPE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_BLUE_TYPE))) {
        private enum enumMixinStr_GL_TEXTURE_BLUE_TYPE = `enum GL_TEXTURE_BLUE_TYPE = 0x8C12;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_BLUE_TYPE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_BLUE_TYPE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_ALPHA_TYPE))) {
        private enum enumMixinStr_GL_TEXTURE_ALPHA_TYPE = `enum GL_TEXTURE_ALPHA_TYPE = 0x8C13;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_ALPHA_TYPE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_ALPHA_TYPE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_DEPTH_TYPE))) {
        private enum enumMixinStr_GL_TEXTURE_DEPTH_TYPE = `enum GL_TEXTURE_DEPTH_TYPE = 0x8C16;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_DEPTH_TYPE); }))) {
            mixin(enumMixinStr_GL_TEXTURE_DEPTH_TYPE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_COMPRESSED))) {
        private enum enumMixinStr_GL_TEXTURE_COMPRESSED = `enum GL_TEXTURE_COMPRESSED = 0x86A1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_COMPRESSED); }))) {
            mixin(enumMixinStr_GL_TEXTURE_COMPRESSED);
        }
    }




    static if(!is(typeof(GL_SAMPLER_2D_MULTISAMPLE))) {
        private enum enumMixinStr_GL_SAMPLER_2D_MULTISAMPLE = `enum GL_SAMPLER_2D_MULTISAMPLE = 0x9108;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLER_2D_MULTISAMPLE); }))) {
            mixin(enumMixinStr_GL_SAMPLER_2D_MULTISAMPLE);
        }
    }




    static if(!is(typeof(GL_INT_SAMPLER_2D_MULTISAMPLE))) {
        private enum enumMixinStr_GL_INT_SAMPLER_2D_MULTISAMPLE = `enum GL_INT_SAMPLER_2D_MULTISAMPLE = 0x9109;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INT_SAMPLER_2D_MULTISAMPLE); }))) {
            mixin(enumMixinStr_GL_INT_SAMPLER_2D_MULTISAMPLE);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE))) {
        private enum enumMixinStr_GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE = `enum GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE = 0x910A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE);
        }
    }




    static if(!is(typeof(GL_VERTEX_ATTRIB_BINDING))) {
        private enum enumMixinStr_GL_VERTEX_ATTRIB_BINDING = `enum GL_VERTEX_ATTRIB_BINDING = 0x82D4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_ATTRIB_BINDING); }))) {
            mixin(enumMixinStr_GL_VERTEX_ATTRIB_BINDING);
        }
    }




    static if(!is(typeof(GL_VERTEX_ATTRIB_RELATIVE_OFFSET))) {
        private enum enumMixinStr_GL_VERTEX_ATTRIB_RELATIVE_OFFSET = `enum GL_VERTEX_ATTRIB_RELATIVE_OFFSET = 0x82D5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_ATTRIB_RELATIVE_OFFSET); }))) {
            mixin(enumMixinStr_GL_VERTEX_ATTRIB_RELATIVE_OFFSET);
        }
    }




    static if(!is(typeof(GL_VERTEX_BINDING_DIVISOR))) {
        private enum enumMixinStr_GL_VERTEX_BINDING_DIVISOR = `enum GL_VERTEX_BINDING_DIVISOR = 0x82D6;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_BINDING_DIVISOR); }))) {
            mixin(enumMixinStr_GL_VERTEX_BINDING_DIVISOR);
        }
    }




    static if(!is(typeof(GL_VERTEX_BINDING_OFFSET))) {
        private enum enumMixinStr_GL_VERTEX_BINDING_OFFSET = `enum GL_VERTEX_BINDING_OFFSET = 0x82D7;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_BINDING_OFFSET); }))) {
            mixin(enumMixinStr_GL_VERTEX_BINDING_OFFSET);
        }
    }




    static if(!is(typeof(GL_VERTEX_BINDING_STRIDE))) {
        private enum enumMixinStr_GL_VERTEX_BINDING_STRIDE = `enum GL_VERTEX_BINDING_STRIDE = 0x82D8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_BINDING_STRIDE); }))) {
            mixin(enumMixinStr_GL_VERTEX_BINDING_STRIDE);
        }
    }




    static if(!is(typeof(GL_VERTEX_BINDING_BUFFER))) {
        private enum enumMixinStr_GL_VERTEX_BINDING_BUFFER = `enum GL_VERTEX_BINDING_BUFFER = 0x8F4F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_BINDING_BUFFER); }))) {
            mixin(enumMixinStr_GL_VERTEX_BINDING_BUFFER);
        }
    }




    static if(!is(typeof(GL_MAX_VERTEX_ATTRIB_RELATIVE_OFFSET))) {
        private enum enumMixinStr_GL_MAX_VERTEX_ATTRIB_RELATIVE_OFFSET = `enum GL_MAX_VERTEX_ATTRIB_RELATIVE_OFFSET = 0x82D9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VERTEX_ATTRIB_RELATIVE_OFFSET); }))) {
            mixin(enumMixinStr_GL_MAX_VERTEX_ATTRIB_RELATIVE_OFFSET);
        }
    }




    static if(!is(typeof(GL_MAX_VERTEX_ATTRIB_BINDINGS))) {
        private enum enumMixinStr_GL_MAX_VERTEX_ATTRIB_BINDINGS = `enum GL_MAX_VERTEX_ATTRIB_BINDINGS = 0x82DA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VERTEX_ATTRIB_BINDINGS); }))) {
            mixin(enumMixinStr_GL_MAX_VERTEX_ATTRIB_BINDINGS);
        }
    }




    static if(!is(typeof(GL_MAX_VERTEX_ATTRIB_STRIDE))) {
        private enum enumMixinStr_GL_MAX_VERTEX_ATTRIB_STRIDE = `enum GL_MAX_VERTEX_ATTRIB_STRIDE = 0x82E5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VERTEX_ATTRIB_STRIDE); }))) {
            mixin(enumMixinStr_GL_MAX_VERTEX_ATTRIB_STRIDE);
        }
    }




    static if(!is(typeof(GL_VALIDATE_STATUS))) {
        private enum enumMixinStr_GL_VALIDATE_STATUS = `enum GL_VALIDATE_STATUS = 0x8B83;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VALIDATE_STATUS); }))) {
            mixin(enumMixinStr_GL_VALIDATE_STATUS);
        }
    }




    static if(!is(typeof(GL_LINK_STATUS))) {
        private enum enumMixinStr_GL_LINK_STATUS = `enum GL_LINK_STATUS = 0x8B82;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LINK_STATUS); }))) {
            mixin(enumMixinStr_GL_LINK_STATUS);
        }
    }




    static if(!is(typeof(GL_DELETE_STATUS))) {
        private enum enumMixinStr_GL_DELETE_STATUS = `enum GL_DELETE_STATUS = 0x8B80;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DELETE_STATUS); }))) {
            mixin(enumMixinStr_GL_DELETE_STATUS);
        }
    }




    static if(!is(typeof(GL_SHADER_TYPE))) {
        private enum enumMixinStr_GL_SHADER_TYPE = `enum GL_SHADER_TYPE = 0x8B4F;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SHADER_TYPE); }))) {
            mixin(enumMixinStr_GL_SHADER_TYPE);
        }
    }




    static if(!is(typeof(GL_MAX_FRAGMENT_UNIFORM_VECTORS))) {
        private enum enumMixinStr_GL_MAX_FRAGMENT_UNIFORM_VECTORS = `enum GL_MAX_FRAGMENT_UNIFORM_VECTORS = 0x8DFD;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_FRAGMENT_UNIFORM_VECTORS); }))) {
            mixin(enumMixinStr_GL_MAX_FRAGMENT_UNIFORM_VECTORS);
        }
    }




    static if(!is(typeof(GL_MAX_TEXTURE_IMAGE_UNITS))) {
        private enum enumMixinStr_GL_MAX_TEXTURE_IMAGE_UNITS = `enum GL_MAX_TEXTURE_IMAGE_UNITS = 0x8872;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_TEXTURE_IMAGE_UNITS); }))) {
            mixin(enumMixinStr_GL_MAX_TEXTURE_IMAGE_UNITS);
        }
    }




    static if(!is(typeof(GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS))) {
        private enum enumMixinStr_GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS = `enum GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS = 0x8B4C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS); }))) {
            mixin(enumMixinStr_GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS);
        }
    }




    static if(!is(typeof(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS))) {
        private enum enumMixinStr_GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS = `enum GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS = 0x8B4D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS); }))) {
            mixin(enumMixinStr_GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS);
        }
    }




    static if(!is(typeof(GL_MAX_VARYING_VECTORS))) {
        private enum enumMixinStr_GL_MAX_VARYING_VECTORS = `enum GL_MAX_VARYING_VECTORS = 0x8DFC;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VARYING_VECTORS); }))) {
            mixin(enumMixinStr_GL_MAX_VARYING_VECTORS);
        }
    }




    static if(!is(typeof(GL_MAX_VERTEX_UNIFORM_VECTORS))) {
        private enum enumMixinStr_GL_MAX_VERTEX_UNIFORM_VECTORS = `enum GL_MAX_VERTEX_UNIFORM_VECTORS = 0x8DFB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VERTEX_UNIFORM_VECTORS); }))) {
            mixin(enumMixinStr_GL_MAX_VERTEX_UNIFORM_VECTORS);
        }
    }




    static if(!is(typeof(GL_MAX_VERTEX_ATTRIBS))) {
        private enum enumMixinStr_GL_MAX_VERTEX_ATTRIBS = `enum GL_MAX_VERTEX_ATTRIBS = 0x8869;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VERTEX_ATTRIBS); }))) {
            mixin(enumMixinStr_GL_MAX_VERTEX_ATTRIBS);
        }
    }




    static if(!is(typeof(GL_VERTEX_SHADER))) {
        private enum enumMixinStr_GL_VERTEX_SHADER = `enum GL_VERTEX_SHADER = 0x8B31;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VERTEX_SHADER); }))) {
            mixin(enumMixinStr_GL_VERTEX_SHADER);
        }
    }




    static if(!is(typeof(GL_FRAGMENT_SHADER))) {
        private enum enumMixinStr_GL_FRAGMENT_SHADER = `enum GL_FRAGMENT_SHADER = 0x8B30;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRAGMENT_SHADER); }))) {
            mixin(enumMixinStr_GL_FRAGMENT_SHADER);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_SHORT_5_6_5))) {
        private enum enumMixinStr_GL_UNSIGNED_SHORT_5_6_5 = `enum GL_UNSIGNED_SHORT_5_6_5 = 0x8363;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_SHORT_5_6_5); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_SHORT_5_6_5);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_SHORT_5_5_5_1))) {
        private enum enumMixinStr_GL_UNSIGNED_SHORT_5_5_5_1 = `enum GL_UNSIGNED_SHORT_5_5_5_1 = 0x8034;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_SHORT_5_5_5_1); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_SHORT_5_5_5_1);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_SHORT_4_4_4_4))) {
        private enum enumMixinStr_GL_UNSIGNED_SHORT_4_4_4_4 = `enum GL_UNSIGNED_SHORT_4_4_4_4 = 0x8033;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_SHORT_4_4_4_4); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_SHORT_4_4_4_4);
        }
    }




    static if(!is(typeof(GL_LUMINANCE_ALPHA))) {
        private enum enumMixinStr_GL_LUMINANCE_ALPHA = `enum GL_LUMINANCE_ALPHA = 0x190A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LUMINANCE_ALPHA); }))) {
            mixin(enumMixinStr_GL_LUMINANCE_ALPHA);
        }
    }




    static if(!is(typeof(GL_LUMINANCE))) {
        private enum enumMixinStr_GL_LUMINANCE = `enum GL_LUMINANCE = 0x1909;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LUMINANCE); }))) {
            mixin(enumMixinStr_GL_LUMINANCE);
        }
    }




    static if(!is(typeof(GL_RGBA))) {
        private enum enumMixinStr_GL_RGBA = `enum GL_RGBA = 0x1908;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGBA); }))) {
            mixin(enumMixinStr_GL_RGBA);
        }
    }




    static if(!is(typeof(GL_RGB))) {
        private enum enumMixinStr_GL_RGB = `enum GL_RGB = 0x1907;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RGB); }))) {
            mixin(enumMixinStr_GL_RGB);
        }
    }




    static if(!is(typeof(GL_ALPHA))) {
        private enum enumMixinStr_GL_ALPHA = `enum GL_ALPHA = 0x1906;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ALPHA); }))) {
            mixin(enumMixinStr_GL_ALPHA);
        }
    }




    static if(!is(typeof(GL_DEPTH_COMPONENT))) {
        private enum enumMixinStr_GL_DEPTH_COMPONENT = `enum GL_DEPTH_COMPONENT = 0x1902;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_COMPONENT); }))) {
            mixin(enumMixinStr_GL_DEPTH_COMPONENT);
        }
    }




    static if(!is(typeof(GL_FIXED))) {
        private enum enumMixinStr_GL_FIXED = `enum GL_FIXED = 0x140C;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FIXED); }))) {
            mixin(enumMixinStr_GL_FIXED);
        }
    }




    static if(!is(typeof(GL_FLOAT))) {
        private enum enumMixinStr_GL_FLOAT = `enum GL_FLOAT = 0x1406;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FLOAT); }))) {
            mixin(enumMixinStr_GL_FLOAT);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_INT))) {
        private enum enumMixinStr_GL_UNSIGNED_INT = `enum GL_UNSIGNED_INT = 0x1405;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_INT); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_INT);
        }
    }




    static if(!is(typeof(GL_INT))) {
        private enum enumMixinStr_GL_INT = `enum GL_INT = 0x1404;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INT); }))) {
            mixin(enumMixinStr_GL_INT);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_SHORT))) {
        private enum enumMixinStr_GL_UNSIGNED_SHORT = `enum GL_UNSIGNED_SHORT = 0x1403;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_SHORT); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_SHORT);
        }
    }




    static if(!is(typeof(GL_SHORT))) {
        private enum enumMixinStr_GL_SHORT = `enum GL_SHORT = 0x1402;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SHORT); }))) {
            mixin(enumMixinStr_GL_SHORT);
        }
    }




    static if(!is(typeof(GL_UNSIGNED_BYTE))) {
        private enum enumMixinStr_GL_UNSIGNED_BYTE = `enum GL_UNSIGNED_BYTE = 0x1401;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNSIGNED_BYTE); }))) {
            mixin(enumMixinStr_GL_UNSIGNED_BYTE);
        }
    }




    static if(!is(typeof(GL_BYTE))) {
        private enum enumMixinStr_GL_BYTE = `enum GL_BYTE = 0x1400;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BYTE); }))) {
            mixin(enumMixinStr_GL_BYTE);
        }
    }




    static if(!is(typeof(GL_GENERATE_MIPMAP_HINT))) {
        private enum enumMixinStr_GL_GENERATE_MIPMAP_HINT = `enum GL_GENERATE_MIPMAP_HINT = 0x8192;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_GENERATE_MIPMAP_HINT); }))) {
            mixin(enumMixinStr_GL_GENERATE_MIPMAP_HINT);
        }
    }




    static if(!is(typeof(GL_NICEST))) {
        private enum enumMixinStr_GL_NICEST = `enum GL_NICEST = 0x1102;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NICEST); }))) {
            mixin(enumMixinStr_GL_NICEST);
        }
    }




    static if(!is(typeof(GL_FASTEST))) {
        private enum enumMixinStr_GL_FASTEST = `enum GL_FASTEST = 0x1101;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FASTEST); }))) {
            mixin(enumMixinStr_GL_FASTEST);
        }
    }




    static if(!is(typeof(GL_DONT_CARE))) {
        private enum enumMixinStr_GL_DONT_CARE = `enum GL_DONT_CARE = 0x1100;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DONT_CARE); }))) {
            mixin(enumMixinStr_GL_DONT_CARE);
        }
    }




    static if(!is(typeof(GL_COMPRESSED_TEXTURE_FORMATS))) {
        private enum enumMixinStr_GL_COMPRESSED_TEXTURE_FORMATS = `enum GL_COMPRESSED_TEXTURE_FORMATS = 0x86A3;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COMPRESSED_TEXTURE_FORMATS); }))) {
            mixin(enumMixinStr_GL_COMPRESSED_TEXTURE_FORMATS);
        }
    }




    static if(!is(typeof(GL_NUM_COMPRESSED_TEXTURE_FORMATS))) {
        private enum enumMixinStr_GL_NUM_COMPRESSED_TEXTURE_FORMATS = `enum GL_NUM_COMPRESSED_TEXTURE_FORMATS = 0x86A2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NUM_COMPRESSED_TEXTURE_FORMATS); }))) {
            mixin(enumMixinStr_GL_NUM_COMPRESSED_TEXTURE_FORMATS);
        }
    }




    static if(!is(typeof(GL_SAMPLE_COVERAGE_INVERT))) {
        private enum enumMixinStr_GL_SAMPLE_COVERAGE_INVERT = `enum GL_SAMPLE_COVERAGE_INVERT = 0x80AB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLE_COVERAGE_INVERT); }))) {
            mixin(enumMixinStr_GL_SAMPLE_COVERAGE_INVERT);
        }
    }




    static if(!is(typeof(GL_SAMPLE_COVERAGE_VALUE))) {
        private enum enumMixinStr_GL_SAMPLE_COVERAGE_VALUE = `enum GL_SAMPLE_COVERAGE_VALUE = 0x80AA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLE_COVERAGE_VALUE); }))) {
            mixin(enumMixinStr_GL_SAMPLE_COVERAGE_VALUE);
        }
    }




    static if(!is(typeof(GL_SAMPLES))) {
        private enum enumMixinStr_GL_SAMPLES = `enum GL_SAMPLES = 0x80A9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLES); }))) {
            mixin(enumMixinStr_GL_SAMPLES);
        }
    }




    static if(!is(typeof(GL_SAMPLE_BUFFERS))) {
        private enum enumMixinStr_GL_SAMPLE_BUFFERS = `enum GL_SAMPLE_BUFFERS = 0x80A8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLE_BUFFERS); }))) {
            mixin(enumMixinStr_GL_SAMPLE_BUFFERS);
        }
    }




    static if(!is(typeof(GL_TEXTURE_BINDING_2D))) {
        private enum enumMixinStr_GL_TEXTURE_BINDING_2D = `enum GL_TEXTURE_BINDING_2D = 0x8069;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_BINDING_2D); }))) {
            mixin(enumMixinStr_GL_TEXTURE_BINDING_2D);
        }
    }




    static if(!is(typeof(GL_POLYGON_OFFSET_FACTOR))) {
        private enum enumMixinStr_GL_POLYGON_OFFSET_FACTOR = `enum GL_POLYGON_OFFSET_FACTOR = 0x8038;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_POLYGON_OFFSET_FACTOR); }))) {
            mixin(enumMixinStr_GL_POLYGON_OFFSET_FACTOR);
        }
    }




    static if(!is(typeof(GL_POLYGON_OFFSET_UNITS))) {
        private enum enumMixinStr_GL_POLYGON_OFFSET_UNITS = `enum GL_POLYGON_OFFSET_UNITS = 0x2A00;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_POLYGON_OFFSET_UNITS); }))) {
            mixin(enumMixinStr_GL_POLYGON_OFFSET_UNITS);
        }
    }




    static if(!is(typeof(GL_STENCIL_BITS))) {
        private enum enumMixinStr_GL_STENCIL_BITS = `enum GL_STENCIL_BITS = 0x0D57;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_BITS); }))) {
            mixin(enumMixinStr_GL_STENCIL_BITS);
        }
    }




    static if(!is(typeof(GL_DEPTH_BITS))) {
        private enum enumMixinStr_GL_DEPTH_BITS = `enum GL_DEPTH_BITS = 0x0D56;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_BITS); }))) {
            mixin(enumMixinStr_GL_DEPTH_BITS);
        }
    }




    static if(!is(typeof(GL_ALPHA_BITS))) {
        private enum enumMixinStr_GL_ALPHA_BITS = `enum GL_ALPHA_BITS = 0x0D55;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ALPHA_BITS); }))) {
            mixin(enumMixinStr_GL_ALPHA_BITS);
        }
    }




    static if(!is(typeof(GL_BLUE_BITS))) {
        private enum enumMixinStr_GL_BLUE_BITS = `enum GL_BLUE_BITS = 0x0D54;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BLUE_BITS); }))) {
            mixin(enumMixinStr_GL_BLUE_BITS);
        }
    }




    static if(!is(typeof(GL_GREEN_BITS))) {
        private enum enumMixinStr_GL_GREEN_BITS = `enum GL_GREEN_BITS = 0x0D53;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_GREEN_BITS); }))) {
            mixin(enumMixinStr_GL_GREEN_BITS);
        }
    }




    static if(!is(typeof(GL_RED_BITS))) {
        private enum enumMixinStr_GL_RED_BITS = `enum GL_RED_BITS = 0x0D52;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_RED_BITS); }))) {
            mixin(enumMixinStr_GL_RED_BITS);
        }
    }




    static if(!is(typeof(GL_SUBPIXEL_BITS))) {
        private enum enumMixinStr_GL_SUBPIXEL_BITS = `enum GL_SUBPIXEL_BITS = 0x0D50;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SUBPIXEL_BITS); }))) {
            mixin(enumMixinStr_GL_SUBPIXEL_BITS);
        }
    }




    static if(!is(typeof(GL_MAX_VIEWPORT_DIMS))) {
        private enum enumMixinStr_GL_MAX_VIEWPORT_DIMS = `enum GL_MAX_VIEWPORT_DIMS = 0x0D3A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_VIEWPORT_DIMS); }))) {
            mixin(enumMixinStr_GL_MAX_VIEWPORT_DIMS);
        }
    }




    static if(!is(typeof(GL_MAX_TEXTURE_SIZE))) {
        private enum enumMixinStr_GL_MAX_TEXTURE_SIZE = `enum GL_MAX_TEXTURE_SIZE = 0x0D33;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_MAX_TEXTURE_SIZE); }))) {
            mixin(enumMixinStr_GL_MAX_TEXTURE_SIZE);
        }
    }




    static if(!is(typeof(GL_PACK_ALIGNMENT))) {
        private enum enumMixinStr_GL_PACK_ALIGNMENT = `enum GL_PACK_ALIGNMENT = 0x0D05;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_PACK_ALIGNMENT); }))) {
            mixin(enumMixinStr_GL_PACK_ALIGNMENT);
        }
    }




    static if(!is(typeof(GL_UNPACK_ALIGNMENT))) {
        private enum enumMixinStr_GL_UNPACK_ALIGNMENT = `enum GL_UNPACK_ALIGNMENT = 0x0CF5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_UNPACK_ALIGNMENT); }))) {
            mixin(enumMixinStr_GL_UNPACK_ALIGNMENT);
        }
    }




    static if(!is(typeof(GL_COLOR_WRITEMASK))) {
        private enum enumMixinStr_GL_COLOR_WRITEMASK = `enum GL_COLOR_WRITEMASK = 0x0C23;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_WRITEMASK); }))) {
            mixin(enumMixinStr_GL_COLOR_WRITEMASK);
        }
    }




    static if(!is(typeof(GL_COLOR_CLEAR_VALUE))) {
        private enum enumMixinStr_GL_COLOR_CLEAR_VALUE = `enum GL_COLOR_CLEAR_VALUE = 0x0C22;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_CLEAR_VALUE); }))) {
            mixin(enumMixinStr_GL_COLOR_CLEAR_VALUE);
        }
    }




    static if(!is(typeof(GL_SCISSOR_BOX))) {
        private enum enumMixinStr_GL_SCISSOR_BOX = `enum GL_SCISSOR_BOX = 0x0C10;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SCISSOR_BOX); }))) {
            mixin(enumMixinStr_GL_SCISSOR_BOX);
        }
    }




    static if(!is(typeof(GL_VIEWPORT))) {
        private enum enumMixinStr_GL_VIEWPORT = `enum GL_VIEWPORT = 0x0BA2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_VIEWPORT); }))) {
            mixin(enumMixinStr_GL_VIEWPORT);
        }
    }




    static if(!is(typeof(GL_STENCIL_BACK_WRITEMASK))) {
        private enum enumMixinStr_GL_STENCIL_BACK_WRITEMASK = `enum GL_STENCIL_BACK_WRITEMASK = 0x8CA5;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_BACK_WRITEMASK); }))) {
            mixin(enumMixinStr_GL_STENCIL_BACK_WRITEMASK);
        }
    }




    static if(!is(typeof(GL_STENCIL_BACK_VALUE_MASK))) {
        private enum enumMixinStr_GL_STENCIL_BACK_VALUE_MASK = `enum GL_STENCIL_BACK_VALUE_MASK = 0x8CA4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_BACK_VALUE_MASK); }))) {
            mixin(enumMixinStr_GL_STENCIL_BACK_VALUE_MASK);
        }
    }




    static if(!is(typeof(GL_STENCIL_BACK_REF))) {
        private enum enumMixinStr_GL_STENCIL_BACK_REF = `enum GL_STENCIL_BACK_REF = 0x8CA3;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_BACK_REF); }))) {
            mixin(enumMixinStr_GL_STENCIL_BACK_REF);
        }
    }




    static if(!is(typeof(GL_STENCIL_BACK_PASS_DEPTH_PASS))) {
        private enum enumMixinStr_GL_STENCIL_BACK_PASS_DEPTH_PASS = `enum GL_STENCIL_BACK_PASS_DEPTH_PASS = 0x8803;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_BACK_PASS_DEPTH_PASS); }))) {
            mixin(enumMixinStr_GL_STENCIL_BACK_PASS_DEPTH_PASS);
        }
    }




    static if(!is(typeof(GL_STENCIL_BACK_PASS_DEPTH_FAIL))) {
        private enum enumMixinStr_GL_STENCIL_BACK_PASS_DEPTH_FAIL = `enum GL_STENCIL_BACK_PASS_DEPTH_FAIL = 0x8802;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_BACK_PASS_DEPTH_FAIL); }))) {
            mixin(enumMixinStr_GL_STENCIL_BACK_PASS_DEPTH_FAIL);
        }
    }




    static if(!is(typeof(GL_STENCIL_BACK_FAIL))) {
        private enum enumMixinStr_GL_STENCIL_BACK_FAIL = `enum GL_STENCIL_BACK_FAIL = 0x8801;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_BACK_FAIL); }))) {
            mixin(enumMixinStr_GL_STENCIL_BACK_FAIL);
        }
    }




    static if(!is(typeof(GL_STENCIL_BACK_FUNC))) {
        private enum enumMixinStr_GL_STENCIL_BACK_FUNC = `enum GL_STENCIL_BACK_FUNC = 0x8800;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_BACK_FUNC); }))) {
            mixin(enumMixinStr_GL_STENCIL_BACK_FUNC);
        }
    }




    static if(!is(typeof(GL_STENCIL_WRITEMASK))) {
        private enum enumMixinStr_GL_STENCIL_WRITEMASK = `enum GL_STENCIL_WRITEMASK = 0x0B98;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_WRITEMASK); }))) {
            mixin(enumMixinStr_GL_STENCIL_WRITEMASK);
        }
    }




    static if(!is(typeof(GL_STENCIL_VALUE_MASK))) {
        private enum enumMixinStr_GL_STENCIL_VALUE_MASK = `enum GL_STENCIL_VALUE_MASK = 0x0B93;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_VALUE_MASK); }))) {
            mixin(enumMixinStr_GL_STENCIL_VALUE_MASK);
        }
    }




    static if(!is(typeof(GL_STENCIL_REF))) {
        private enum enumMixinStr_GL_STENCIL_REF = `enum GL_STENCIL_REF = 0x0B97;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_REF); }))) {
            mixin(enumMixinStr_GL_STENCIL_REF);
        }
    }




    static if(!is(typeof(GL_STENCIL_PASS_DEPTH_PASS))) {
        private enum enumMixinStr_GL_STENCIL_PASS_DEPTH_PASS = `enum GL_STENCIL_PASS_DEPTH_PASS = 0x0B96;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_PASS_DEPTH_PASS); }))) {
            mixin(enumMixinStr_GL_STENCIL_PASS_DEPTH_PASS);
        }
    }




    static if(!is(typeof(GL_STENCIL_PASS_DEPTH_FAIL))) {
        private enum enumMixinStr_GL_STENCIL_PASS_DEPTH_FAIL = `enum GL_STENCIL_PASS_DEPTH_FAIL = 0x0B95;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_PASS_DEPTH_FAIL); }))) {
            mixin(enumMixinStr_GL_STENCIL_PASS_DEPTH_FAIL);
        }
    }




    static if(!is(typeof(GL_STENCIL_FAIL))) {
        private enum enumMixinStr_GL_STENCIL_FAIL = `enum GL_STENCIL_FAIL = 0x0B94;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_FAIL); }))) {
            mixin(enumMixinStr_GL_STENCIL_FAIL);
        }
    }




    static if(!is(typeof(GL_STENCIL_FUNC))) {
        private enum enumMixinStr_GL_STENCIL_FUNC = `enum GL_STENCIL_FUNC = 0x0B92;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_FUNC); }))) {
            mixin(enumMixinStr_GL_STENCIL_FUNC);
        }
    }




    static if(!is(typeof(GL_STENCIL_CLEAR_VALUE))) {
        private enum enumMixinStr_GL_STENCIL_CLEAR_VALUE = `enum GL_STENCIL_CLEAR_VALUE = 0x0B91;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_CLEAR_VALUE); }))) {
            mixin(enumMixinStr_GL_STENCIL_CLEAR_VALUE);
        }
    }




    static if(!is(typeof(GL_DEPTH_FUNC))) {
        private enum enumMixinStr_GL_DEPTH_FUNC = `enum GL_DEPTH_FUNC = 0x0B74;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_FUNC); }))) {
            mixin(enumMixinStr_GL_DEPTH_FUNC);
        }
    }




    static if(!is(typeof(GL_DEPTH_CLEAR_VALUE))) {
        private enum enumMixinStr_GL_DEPTH_CLEAR_VALUE = `enum GL_DEPTH_CLEAR_VALUE = 0x0B73;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_CLEAR_VALUE); }))) {
            mixin(enumMixinStr_GL_DEPTH_CLEAR_VALUE);
        }
    }




    static if(!is(typeof(GL_DEPTH_WRITEMASK))) {
        private enum enumMixinStr_GL_DEPTH_WRITEMASK = `enum GL_DEPTH_WRITEMASK = 0x0B72;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_WRITEMASK); }))) {
            mixin(enumMixinStr_GL_DEPTH_WRITEMASK);
        }
    }




    static if(!is(typeof(GL_DEPTH_RANGE))) {
        private enum enumMixinStr_GL_DEPTH_RANGE = `enum GL_DEPTH_RANGE = 0x0B70;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_RANGE); }))) {
            mixin(enumMixinStr_GL_DEPTH_RANGE);
        }
    }




    static if(!is(typeof(GL_FRONT_FACE))) {
        private enum enumMixinStr_GL_FRONT_FACE = `enum GL_FRONT_FACE = 0x0B46;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRONT_FACE); }))) {
            mixin(enumMixinStr_GL_FRONT_FACE);
        }
    }




    static if(!is(typeof(GL_CULL_FACE_MODE))) {
        private enum enumMixinStr_GL_CULL_FACE_MODE = `enum GL_CULL_FACE_MODE = 0x0B45;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_CULL_FACE_MODE); }))) {
            mixin(enumMixinStr_GL_CULL_FACE_MODE);
        }
    }




    static if(!is(typeof(GL_ALIASED_LINE_WIDTH_RANGE))) {
        private enum enumMixinStr_GL_ALIASED_LINE_WIDTH_RANGE = `enum GL_ALIASED_LINE_WIDTH_RANGE = 0x846E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ALIASED_LINE_WIDTH_RANGE); }))) {
            mixin(enumMixinStr_GL_ALIASED_LINE_WIDTH_RANGE);
        }
    }




    static if(!is(typeof(GL_ALIASED_POINT_SIZE_RANGE))) {
        private enum enumMixinStr_GL_ALIASED_POINT_SIZE_RANGE = `enum GL_ALIASED_POINT_SIZE_RANGE = 0x846D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ALIASED_POINT_SIZE_RANGE); }))) {
            mixin(enumMixinStr_GL_ALIASED_POINT_SIZE_RANGE);
        }
    }




    static if(!is(typeof(GL_LINE_WIDTH))) {
        private enum enumMixinStr_GL_LINE_WIDTH = `enum GL_LINE_WIDTH = 0x0B21;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LINE_WIDTH); }))) {
            mixin(enumMixinStr_GL_LINE_WIDTH);
        }
    }




    static if(!is(typeof(GL_CCW))) {
        private enum enumMixinStr_GL_CCW = `enum GL_CCW = 0x0901;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_CCW); }))) {
            mixin(enumMixinStr_GL_CCW);
        }
    }




    static if(!is(typeof(GL_CW))) {
        private enum enumMixinStr_GL_CW = `enum GL_CW = 0x0900;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_CW); }))) {
            mixin(enumMixinStr_GL_CW);
        }
    }




    static if(!is(typeof(GL_OUT_OF_MEMORY))) {
        private enum enumMixinStr_GL_OUT_OF_MEMORY = `enum GL_OUT_OF_MEMORY = 0x0505;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_OUT_OF_MEMORY); }))) {
            mixin(enumMixinStr_GL_OUT_OF_MEMORY);
        }
    }




    static if(!is(typeof(GL_INVALID_OPERATION))) {
        private enum enumMixinStr_GL_INVALID_OPERATION = `enum GL_INVALID_OPERATION = 0x0502;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INVALID_OPERATION); }))) {
            mixin(enumMixinStr_GL_INVALID_OPERATION);
        }
    }




    static if(!is(typeof(GL_INVALID_VALUE))) {
        private enum enumMixinStr_GL_INVALID_VALUE = `enum GL_INVALID_VALUE = 0x0501;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INVALID_VALUE); }))) {
            mixin(enumMixinStr_GL_INVALID_VALUE);
        }
    }




    static if(!is(typeof(GL_INVALID_ENUM))) {
        private enum enumMixinStr_GL_INVALID_ENUM = `enum GL_INVALID_ENUM = 0x0500;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_INVALID_ENUM); }))) {
            mixin(enumMixinStr_GL_INVALID_ENUM);
        }
    }




    static if(!is(typeof(GL_NO_ERROR))) {
        private enum enumMixinStr_GL_NO_ERROR = `enum GL_NO_ERROR = 0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_NO_ERROR); }))) {
            mixin(enumMixinStr_GL_NO_ERROR);
        }
    }




    static if(!is(typeof(GL_SAMPLE_COVERAGE))) {
        private enum enumMixinStr_GL_SAMPLE_COVERAGE = `enum GL_SAMPLE_COVERAGE = 0x80A0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLE_COVERAGE); }))) {
            mixin(enumMixinStr_GL_SAMPLE_COVERAGE);
        }
    }




    static if(!is(typeof(GL_SAMPLE_ALPHA_TO_COVERAGE))) {
        private enum enumMixinStr_GL_SAMPLE_ALPHA_TO_COVERAGE = `enum GL_SAMPLE_ALPHA_TO_COVERAGE = 0x809E;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SAMPLE_ALPHA_TO_COVERAGE); }))) {
            mixin(enumMixinStr_GL_SAMPLE_ALPHA_TO_COVERAGE);
        }
    }




    static if(!is(typeof(GL_POLYGON_OFFSET_FILL))) {
        private enum enumMixinStr_GL_POLYGON_OFFSET_FILL = `enum GL_POLYGON_OFFSET_FILL = 0x8037;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_POLYGON_OFFSET_FILL); }))) {
            mixin(enumMixinStr_GL_POLYGON_OFFSET_FILL);
        }
    }




    static if(!is(typeof(GL_SCISSOR_TEST))) {
        private enum enumMixinStr_GL_SCISSOR_TEST = `enum GL_SCISSOR_TEST = 0x0C11;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SCISSOR_TEST); }))) {
            mixin(enumMixinStr_GL_SCISSOR_TEST);
        }
    }




    static if(!is(typeof(GL_DEPTH_TEST))) {
        private enum enumMixinStr_GL_DEPTH_TEST = `enum GL_DEPTH_TEST = 0x0B71;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_TEST); }))) {
            mixin(enumMixinStr_GL_DEPTH_TEST);
        }
    }




    static if(!is(typeof(GL_STENCIL_TEST))) {
        private enum enumMixinStr_GL_STENCIL_TEST = `enum GL_STENCIL_TEST = 0x0B90;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_TEST); }))) {
            mixin(enumMixinStr_GL_STENCIL_TEST);
        }
    }




    static if(!is(typeof(GL_DITHER))) {
        private enum enumMixinStr_GL_DITHER = `enum GL_DITHER = 0x0BD0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DITHER); }))) {
            mixin(enumMixinStr_GL_DITHER);
        }
    }




    static if(!is(typeof(GL_BLEND))) {
        private enum enumMixinStr_GL_BLEND = `enum GL_BLEND = 0x0BE2;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BLEND); }))) {
            mixin(enumMixinStr_GL_BLEND);
        }
    }




    static if(!is(typeof(GL_CULL_FACE))) {
        private enum enumMixinStr_GL_CULL_FACE = `enum GL_CULL_FACE = 0x0B44;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_CULL_FACE); }))) {
            mixin(enumMixinStr_GL_CULL_FACE);
        }
    }




    static if(!is(typeof(GL_TEXTURE_2D))) {
        private enum enumMixinStr_GL_TEXTURE_2D = `enum GL_TEXTURE_2D = 0x0DE1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TEXTURE_2D); }))) {
            mixin(enumMixinStr_GL_TEXTURE_2D);
        }
    }




    static if(!is(typeof(GL_FRONT_AND_BACK))) {
        private enum enumMixinStr_GL_FRONT_AND_BACK = `enum GL_FRONT_AND_BACK = 0x0408;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRONT_AND_BACK); }))) {
            mixin(enumMixinStr_GL_FRONT_AND_BACK);
        }
    }




    static if(!is(typeof(GL_BACK))) {
        private enum enumMixinStr_GL_BACK = `enum GL_BACK = 0x0405;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BACK); }))) {
            mixin(enumMixinStr_GL_BACK);
        }
    }




    static if(!is(typeof(GL_FRONT))) {
        private enum enumMixinStr_GL_FRONT = `enum GL_FRONT = 0x0404;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FRONT); }))) {
            mixin(enumMixinStr_GL_FRONT);
        }
    }




    static if(!is(typeof(GL_CURRENT_VERTEX_ATTRIB))) {
        private enum enumMixinStr_GL_CURRENT_VERTEX_ATTRIB = `enum GL_CURRENT_VERTEX_ATTRIB = 0x8626;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_CURRENT_VERTEX_ATTRIB); }))) {
            mixin(enumMixinStr_GL_CURRENT_VERTEX_ATTRIB);
        }
    }




    static if(!is(typeof(GL_BUFFER_USAGE))) {
        private enum enumMixinStr_GL_BUFFER_USAGE = `enum GL_BUFFER_USAGE = 0x8765;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BUFFER_USAGE); }))) {
            mixin(enumMixinStr_GL_BUFFER_USAGE);
        }
    }




    static if(!is(typeof(GL_BUFFER_SIZE))) {
        private enum enumMixinStr_GL_BUFFER_SIZE = `enum GL_BUFFER_SIZE = 0x8764;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BUFFER_SIZE); }))) {
            mixin(enumMixinStr_GL_BUFFER_SIZE);
        }
    }




    static if(!is(typeof(GL_DYNAMIC_DRAW))) {
        private enum enumMixinStr_GL_DYNAMIC_DRAW = `enum GL_DYNAMIC_DRAW = 0x88E8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DYNAMIC_DRAW); }))) {
            mixin(enumMixinStr_GL_DYNAMIC_DRAW);
        }
    }




    static if(!is(typeof(GL_STATIC_DRAW))) {
        private enum enumMixinStr_GL_STATIC_DRAW = `enum GL_STATIC_DRAW = 0x88E4;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STATIC_DRAW); }))) {
            mixin(enumMixinStr_GL_STATIC_DRAW);
        }
    }




    static if(!is(typeof(GL_STREAM_DRAW))) {
        private enum enumMixinStr_GL_STREAM_DRAW = `enum GL_STREAM_DRAW = 0x88E0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STREAM_DRAW); }))) {
            mixin(enumMixinStr_GL_STREAM_DRAW);
        }
    }




    static if(!is(typeof(GL_ELEMENT_ARRAY_BUFFER_BINDING))) {
        private enum enumMixinStr_GL_ELEMENT_ARRAY_BUFFER_BINDING = `enum GL_ELEMENT_ARRAY_BUFFER_BINDING = 0x8895;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ELEMENT_ARRAY_BUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_ELEMENT_ARRAY_BUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_ARRAY_BUFFER_BINDING))) {
        private enum enumMixinStr_GL_ARRAY_BUFFER_BINDING = `enum GL_ARRAY_BUFFER_BINDING = 0x8894;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ARRAY_BUFFER_BINDING); }))) {
            mixin(enumMixinStr_GL_ARRAY_BUFFER_BINDING);
        }
    }




    static if(!is(typeof(GL_ELEMENT_ARRAY_BUFFER))) {
        private enum enumMixinStr_GL_ELEMENT_ARRAY_BUFFER = `enum GL_ELEMENT_ARRAY_BUFFER = 0x8893;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ELEMENT_ARRAY_BUFFER); }))) {
            mixin(enumMixinStr_GL_ELEMENT_ARRAY_BUFFER);
        }
    }




    static if(!is(typeof(GL_ARRAY_BUFFER))) {
        private enum enumMixinStr_GL_ARRAY_BUFFER = `enum GL_ARRAY_BUFFER = 0x8892;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ARRAY_BUFFER); }))) {
            mixin(enumMixinStr_GL_ARRAY_BUFFER);
        }
    }




    static if(!is(typeof(GL_BLEND_COLOR))) {
        private enum enumMixinStr_GL_BLEND_COLOR = `enum GL_BLEND_COLOR = 0x8005;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BLEND_COLOR); }))) {
            mixin(enumMixinStr_GL_BLEND_COLOR);
        }
    }




    static if(!is(typeof(GL_ONE_MINUS_CONSTANT_ALPHA))) {
        private enum enumMixinStr_GL_ONE_MINUS_CONSTANT_ALPHA = `enum GL_ONE_MINUS_CONSTANT_ALPHA = 0x8004;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ONE_MINUS_CONSTANT_ALPHA); }))) {
            mixin(enumMixinStr_GL_ONE_MINUS_CONSTANT_ALPHA);
        }
    }




    static if(!is(typeof(GL_CONSTANT_ALPHA))) {
        private enum enumMixinStr_GL_CONSTANT_ALPHA = `enum GL_CONSTANT_ALPHA = 0x8003;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_CONSTANT_ALPHA); }))) {
            mixin(enumMixinStr_GL_CONSTANT_ALPHA);
        }
    }




    static if(!is(typeof(GL_ONE_MINUS_CONSTANT_COLOR))) {
        private enum enumMixinStr_GL_ONE_MINUS_CONSTANT_COLOR = `enum GL_ONE_MINUS_CONSTANT_COLOR = 0x8002;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ONE_MINUS_CONSTANT_COLOR); }))) {
            mixin(enumMixinStr_GL_ONE_MINUS_CONSTANT_COLOR);
        }
    }




    static if(!is(typeof(GL_CONSTANT_COLOR))) {
        private enum enumMixinStr_GL_CONSTANT_COLOR = `enum GL_CONSTANT_COLOR = 0x8001;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_CONSTANT_COLOR); }))) {
            mixin(enumMixinStr_GL_CONSTANT_COLOR);
        }
    }




    static if(!is(typeof(GL_BLEND_SRC_ALPHA))) {
        private enum enumMixinStr_GL_BLEND_SRC_ALPHA = `enum GL_BLEND_SRC_ALPHA = 0x80CB;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BLEND_SRC_ALPHA); }))) {
            mixin(enumMixinStr_GL_BLEND_SRC_ALPHA);
        }
    }




    static if(!is(typeof(GL_BLEND_DST_ALPHA))) {
        private enum enumMixinStr_GL_BLEND_DST_ALPHA = `enum GL_BLEND_DST_ALPHA = 0x80CA;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BLEND_DST_ALPHA); }))) {
            mixin(enumMixinStr_GL_BLEND_DST_ALPHA);
        }
    }




    static if(!is(typeof(GL_BLEND_SRC_RGB))) {
        private enum enumMixinStr_GL_BLEND_SRC_RGB = `enum GL_BLEND_SRC_RGB = 0x80C9;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BLEND_SRC_RGB); }))) {
            mixin(enumMixinStr_GL_BLEND_SRC_RGB);
        }
    }




    static if(!is(typeof(GL_BLEND_DST_RGB))) {
        private enum enumMixinStr_GL_BLEND_DST_RGB = `enum GL_BLEND_DST_RGB = 0x80C8;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BLEND_DST_RGB); }))) {
            mixin(enumMixinStr_GL_BLEND_DST_RGB);
        }
    }




    static if(!is(typeof(GL_FUNC_REVERSE_SUBTRACT))) {
        private enum enumMixinStr_GL_FUNC_REVERSE_SUBTRACT = `enum GL_FUNC_REVERSE_SUBTRACT = 0x800B;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FUNC_REVERSE_SUBTRACT); }))) {
            mixin(enumMixinStr_GL_FUNC_REVERSE_SUBTRACT);
        }
    }




    static if(!is(typeof(GL_FUNC_SUBTRACT))) {
        private enum enumMixinStr_GL_FUNC_SUBTRACT = `enum GL_FUNC_SUBTRACT = 0x800A;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FUNC_SUBTRACT); }))) {
            mixin(enumMixinStr_GL_FUNC_SUBTRACT);
        }
    }




    static if(!is(typeof(GL_BLEND_EQUATION_ALPHA))) {
        private enum enumMixinStr_GL_BLEND_EQUATION_ALPHA = `enum GL_BLEND_EQUATION_ALPHA = 0x883D;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BLEND_EQUATION_ALPHA); }))) {
            mixin(enumMixinStr_GL_BLEND_EQUATION_ALPHA);
        }
    }




    static if(!is(typeof(GL_BLEND_EQUATION_RGB))) {
        private enum enumMixinStr_GL_BLEND_EQUATION_RGB = `enum GL_BLEND_EQUATION_RGB = 0x8009;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BLEND_EQUATION_RGB); }))) {
            mixin(enumMixinStr_GL_BLEND_EQUATION_RGB);
        }
    }




    static if(!is(typeof(GL_BLEND_EQUATION))) {
        private enum enumMixinStr_GL_BLEND_EQUATION = `enum GL_BLEND_EQUATION = 0x8009;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_BLEND_EQUATION); }))) {
            mixin(enumMixinStr_GL_BLEND_EQUATION);
        }
    }




    static if(!is(typeof(GL_FUNC_ADD))) {
        private enum enumMixinStr_GL_FUNC_ADD = `enum GL_FUNC_ADD = 0x8006;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FUNC_ADD); }))) {
            mixin(enumMixinStr_GL_FUNC_ADD);
        }
    }




    static if(!is(typeof(GL_SRC_ALPHA_SATURATE))) {
        private enum enumMixinStr_GL_SRC_ALPHA_SATURATE = `enum GL_SRC_ALPHA_SATURATE = 0x0308;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SRC_ALPHA_SATURATE); }))) {
            mixin(enumMixinStr_GL_SRC_ALPHA_SATURATE);
        }
    }




    static if(!is(typeof(GL_ONE_MINUS_DST_COLOR))) {
        private enum enumMixinStr_GL_ONE_MINUS_DST_COLOR = `enum GL_ONE_MINUS_DST_COLOR = 0x0307;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ONE_MINUS_DST_COLOR); }))) {
            mixin(enumMixinStr_GL_ONE_MINUS_DST_COLOR);
        }
    }




    static if(!is(typeof(GL_DST_COLOR))) {
        private enum enumMixinStr_GL_DST_COLOR = `enum GL_DST_COLOR = 0x0306;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DST_COLOR); }))) {
            mixin(enumMixinStr_GL_DST_COLOR);
        }
    }




    static if(!is(typeof(GL_ONE_MINUS_DST_ALPHA))) {
        private enum enumMixinStr_GL_ONE_MINUS_DST_ALPHA = `enum GL_ONE_MINUS_DST_ALPHA = 0x0305;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ONE_MINUS_DST_ALPHA); }))) {
            mixin(enumMixinStr_GL_ONE_MINUS_DST_ALPHA);
        }
    }




    static if(!is(typeof(GL_DST_ALPHA))) {
        private enum enumMixinStr_GL_DST_ALPHA = `enum GL_DST_ALPHA = 0x0304;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DST_ALPHA); }))) {
            mixin(enumMixinStr_GL_DST_ALPHA);
        }
    }




    static if(!is(typeof(GL_ONE_MINUS_SRC_ALPHA))) {
        private enum enumMixinStr_GL_ONE_MINUS_SRC_ALPHA = `enum GL_ONE_MINUS_SRC_ALPHA = 0x0303;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ONE_MINUS_SRC_ALPHA); }))) {
            mixin(enumMixinStr_GL_ONE_MINUS_SRC_ALPHA);
        }
    }




    static if(!is(typeof(GL_SRC_ALPHA))) {
        private enum enumMixinStr_GL_SRC_ALPHA = `enum GL_SRC_ALPHA = 0x0302;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SRC_ALPHA); }))) {
            mixin(enumMixinStr_GL_SRC_ALPHA);
        }
    }




    static if(!is(typeof(GL_ONE_MINUS_SRC_COLOR))) {
        private enum enumMixinStr_GL_ONE_MINUS_SRC_COLOR = `enum GL_ONE_MINUS_SRC_COLOR = 0x0301;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ONE_MINUS_SRC_COLOR); }))) {
            mixin(enumMixinStr_GL_ONE_MINUS_SRC_COLOR);
        }
    }




    static if(!is(typeof(GL_SRC_COLOR))) {
        private enum enumMixinStr_GL_SRC_COLOR = `enum GL_SRC_COLOR = 0x0300;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_SRC_COLOR); }))) {
            mixin(enumMixinStr_GL_SRC_COLOR);
        }
    }




    static if(!is(typeof(GL_ONE))) {
        private enum enumMixinStr_GL_ONE = `enum GL_ONE = 1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ONE); }))) {
            mixin(enumMixinStr_GL_ONE);
        }
    }




    static if(!is(typeof(GL_ZERO))) {
        private enum enumMixinStr_GL_ZERO = `enum GL_ZERO = 0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ZERO); }))) {
            mixin(enumMixinStr_GL_ZERO);
        }
    }




    static if(!is(typeof(GL_TRIANGLE_FAN))) {
        private enum enumMixinStr_GL_TRIANGLE_FAN = `enum GL_TRIANGLE_FAN = 0x0006;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRIANGLE_FAN); }))) {
            mixin(enumMixinStr_GL_TRIANGLE_FAN);
        }
    }




    static if(!is(typeof(GL_TRIANGLE_STRIP))) {
        private enum enumMixinStr_GL_TRIANGLE_STRIP = `enum GL_TRIANGLE_STRIP = 0x0005;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRIANGLE_STRIP); }))) {
            mixin(enumMixinStr_GL_TRIANGLE_STRIP);
        }
    }




    static if(!is(typeof(GL_TRIANGLES))) {
        private enum enumMixinStr_GL_TRIANGLES = `enum GL_TRIANGLES = 0x0004;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRIANGLES); }))) {
            mixin(enumMixinStr_GL_TRIANGLES);
        }
    }




    static if(!is(typeof(GL_LINE_STRIP))) {
        private enum enumMixinStr_GL_LINE_STRIP = `enum GL_LINE_STRIP = 0x0003;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LINE_STRIP); }))) {
            mixin(enumMixinStr_GL_LINE_STRIP);
        }
    }




    static if(!is(typeof(GL_LINE_LOOP))) {
        private enum enumMixinStr_GL_LINE_LOOP = `enum GL_LINE_LOOP = 0x0002;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LINE_LOOP); }))) {
            mixin(enumMixinStr_GL_LINE_LOOP);
        }
    }




    static if(!is(typeof(GL_LINES))) {
        private enum enumMixinStr_GL_LINES = `enum GL_LINES = 0x0001;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_LINES); }))) {
            mixin(enumMixinStr_GL_LINES);
        }
    }




    static if(!is(typeof(GL_POINTS))) {
        private enum enumMixinStr_GL_POINTS = `enum GL_POINTS = 0x0000;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_POINTS); }))) {
            mixin(enumMixinStr_GL_POINTS);
        }
    }




    static if(!is(typeof(GL_TRUE))) {
        private enum enumMixinStr_GL_TRUE = `enum GL_TRUE = 1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_TRUE); }))) {
            mixin(enumMixinStr_GL_TRUE);
        }
    }




    static if(!is(typeof(GL_FALSE))) {
        private enum enumMixinStr_GL_FALSE = `enum GL_FALSE = 0;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_FALSE); }))) {
            mixin(enumMixinStr_GL_FALSE);
        }
    }




    static if(!is(typeof(GL_COLOR_BUFFER_BIT))) {
        private enum enumMixinStr_GL_COLOR_BUFFER_BIT = `enum GL_COLOR_BUFFER_BIT = 0x00004000;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_COLOR_BUFFER_BIT); }))) {
            mixin(enumMixinStr_GL_COLOR_BUFFER_BIT);
        }
    }




    static if(!is(typeof(GL_STENCIL_BUFFER_BIT))) {
        private enum enumMixinStr_GL_STENCIL_BUFFER_BIT = `enum GL_STENCIL_BUFFER_BIT = 0x00000400;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_STENCIL_BUFFER_BIT); }))) {
            mixin(enumMixinStr_GL_STENCIL_BUFFER_BIT);
        }
    }




    static if(!is(typeof(GL_DEPTH_BUFFER_BIT))) {
        private enum enumMixinStr_GL_DEPTH_BUFFER_BIT = `enum GL_DEPTH_BUFFER_BIT = 0x00000100;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_DEPTH_BUFFER_BIT); }))) {
            mixin(enumMixinStr_GL_DEPTH_BUFFER_BIT);
        }
    }




    static if(!is(typeof(GL_ES_VERSION_2_0))) {
        private enum enumMixinStr_GL_ES_VERSION_2_0 = `enum GL_ES_VERSION_2_0 = 1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_ES_VERSION_2_0); }))) {
            mixin(enumMixinStr_GL_ES_VERSION_2_0);
        }
    }




    static if(!is(typeof(GL_GLES_PROTOTYPES))) {
        private enum enumMixinStr_GL_GLES_PROTOTYPES = `enum GL_GLES_PROTOTYPES = 1;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_GLES_PROTOTYPES); }))) {
            mixin(enumMixinStr_GL_GLES_PROTOTYPES);
        }
    }




    static if(!is(typeof(GL_APIENTRYP))) {
        private enum enumMixinStr_GL_APIENTRYP = `enum GL_APIENTRYP = GL_APIENTRY *;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_APIENTRYP); }))) {
            mixin(enumMixinStr_GL_APIENTRYP);
        }
    }




    static if(!is(typeof(__gl31_h_))) {
        private enum enumMixinStr___gl31_h_ = `enum __gl31_h_ = 1;`;
        static if(is(typeof({ mixin(enumMixinStr___gl31_h_); }))) {
            mixin(enumMixinStr___gl31_h_);
        }
    }






    static if(!is(typeof(GL_APICALL))) {
        private enum enumMixinStr_GL_APICALL = `enum GL_APICALL = KHRONOS_APICALL;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_APICALL); }))) {
            mixin(enumMixinStr_GL_APICALL);
        }
    }




    static if(!is(typeof(GL_APIENTRY))) {
        private enum enumMixinStr_GL_APIENTRY = `enum GL_APIENTRY = KHRONOS_APIENTRY;`;
        static if(is(typeof({ mixin(enumMixinStr_GL_APIENTRY); }))) {
            mixin(enumMixinStr_GL_APIENTRY);
        }
    }






    static if(!is(typeof(KHRONOS_APICALL))) {
        private enum enumMixinStr_KHRONOS_APICALL = `enum KHRONOS_APICALL = __declspec ( dllimport );`;
        static if(is(typeof({ mixin(enumMixinStr_KHRONOS_APICALL); }))) {
            mixin(enumMixinStr_KHRONOS_APICALL);
        }
    }




    static if(!is(typeof(KHRONOS_APIENTRY))) {
        private enum enumMixinStr_KHRONOS_APIENTRY = `enum KHRONOS_APIENTRY = __stdcall;`;
        static if(is(typeof({ mixin(enumMixinStr_KHRONOS_APIENTRY); }))) {
            mixin(enumMixinStr_KHRONOS_APIENTRY);
        }
    }






    static if(!is(typeof(KHRONOS_SUPPORT_INT64))) {
        private enum enumMixinStr_KHRONOS_SUPPORT_INT64 = `enum KHRONOS_SUPPORT_INT64 = 1;`;
        static if(is(typeof({ mixin(enumMixinStr_KHRONOS_SUPPORT_INT64); }))) {
            mixin(enumMixinStr_KHRONOS_SUPPORT_INT64);
        }
    }




    static if(!is(typeof(KHRONOS_SUPPORT_FLOAT))) {
        private enum enumMixinStr_KHRONOS_SUPPORT_FLOAT = `enum KHRONOS_SUPPORT_FLOAT = 1;`;
        static if(is(typeof({ mixin(enumMixinStr_KHRONOS_SUPPORT_FLOAT); }))) {
            mixin(enumMixinStr_KHRONOS_SUPPORT_FLOAT);
        }
    }




    static if(!is(typeof(KHRONOS_MAX_ENUM))) {
        private enum enumMixinStr_KHRONOS_MAX_ENUM = `enum KHRONOS_MAX_ENUM = 0x7FFFFFFF;`;
        static if(is(typeof({ mixin(enumMixinStr_KHRONOS_MAX_ENUM); }))) {
            mixin(enumMixinStr_KHRONOS_MAX_ENUM);
        }
    }
    static if(!is(typeof(_Benign_race_begin_))) {
        private enum enumMixinStr__Benign_race_begin_ = `enum _Benign_race_begin_ =
;`;
        static if(is(typeof({ mixin(enumMixinStr__Benign_race_begin_); }))) {
            mixin(enumMixinStr__Benign_race_begin_);
        }
    }




    static if(!is(typeof(_Benign_race_end_))) {
        private enum enumMixinStr__Benign_race_end_ = `enum _Benign_race_end_ =
;`;
        static if(is(typeof({ mixin(enumMixinStr__Benign_race_end_); }))) {
            mixin(enumMixinStr__Benign_race_end_);
        }
    }




    static if(!is(typeof(_No_competing_thread_begin_))) {
        private enum enumMixinStr__No_competing_thread_begin_ = `enum _No_competing_thread_begin_ =
;`;
        static if(is(typeof({ mixin(enumMixinStr__No_competing_thread_begin_); }))) {
            mixin(enumMixinStr__No_competing_thread_begin_);
        }
    }




    static if(!is(typeof(_No_competing_thread_end_))) {
        private enum enumMixinStr__No_competing_thread_end_ = `enum _No_competing_thread_end_ =
;`;
        static if(is(typeof({ mixin(enumMixinStr__No_competing_thread_end_); }))) {
            mixin(enumMixinStr__No_competing_thread_end_);
        }
    }
    static if(!is(typeof(BENIGN_RACE_BEGIN))) {
        private enum enumMixinStr_BENIGN_RACE_BEGIN = `enum BENIGN_RACE_BEGIN =
;`;
        static if(is(typeof({ mixin(enumMixinStr_BENIGN_RACE_BEGIN); }))) {
            mixin(enumMixinStr_BENIGN_RACE_BEGIN);
        }
    }




    static if(!is(typeof(BENIGN_RACE_END))) {
        private enum enumMixinStr_BENIGN_RACE_END = `enum BENIGN_RACE_END =
;`;
        static if(is(typeof({ mixin(enumMixinStr_BENIGN_RACE_END); }))) {
            mixin(enumMixinStr_BENIGN_RACE_END);
        }
    }




    static if(!is(typeof(NO_COMPETING_THREAD_BEGIN))) {
        private enum enumMixinStr_NO_COMPETING_THREAD_BEGIN = `enum NO_COMPETING_THREAD_BEGIN =
;`;
        static if(is(typeof({ mixin(enumMixinStr_NO_COMPETING_THREAD_BEGIN); }))) {
            mixin(enumMixinStr_NO_COMPETING_THREAD_BEGIN);
        }
    }




    static if(!is(typeof(NO_COMPETING_THREAD_END))) {
        private enum enumMixinStr_NO_COMPETING_THREAD_END = `enum NO_COMPETING_THREAD_END =
;`;
        static if(is(typeof({ mixin(enumMixinStr_NO_COMPETING_THREAD_END); }))) {
            mixin(enumMixinStr_NO_COMPETING_THREAD_END);
        }
    }
    static if(!is(typeof(_CRT_PACKING))) {
        private enum enumMixinStr__CRT_PACKING = `enum _CRT_PACKING = 8;`;
        static if(is(typeof({ mixin(enumMixinStr__CRT_PACKING); }))) {
            mixin(enumMixinStr__CRT_PACKING);
        }
    }
    static if(!is(typeof(_MRTIMP))) {
        private enum enumMixinStr__MRTIMP = `enum _MRTIMP = __declspec ( dllimport );`;
        static if(is(typeof({ mixin(enumMixinStr__MRTIMP); }))) {
            mixin(enumMixinStr__MRTIMP);
        }
    }
    static if(!is(typeof(__CLRCALL_OR_CDECL))) {
        private enum enumMixinStr___CLRCALL_OR_CDECL = `enum __CLRCALL_OR_CDECL = __cdecl;`;
        static if(is(typeof({ mixin(enumMixinStr___CLRCALL_OR_CDECL); }))) {
            mixin(enumMixinStr___CLRCALL_OR_CDECL);
        }
    }




    static if(!is(typeof(_CRTIMP_PURE))) {
        private enum enumMixinStr__CRTIMP_PURE = `enum _CRTIMP_PURE = ;`;
        static if(is(typeof({ mixin(enumMixinStr__CRTIMP_PURE); }))) {
            mixin(enumMixinStr__CRTIMP_PURE);
        }
    }
    static if(!is(typeof(__GOT_SECURE_LIB__))) {
        private enum enumMixinStr___GOT_SECURE_LIB__ = `enum __GOT_SECURE_LIB__ = __STDC_SECURE_LIB__;`;
        static if(is(typeof({ mixin(enumMixinStr___GOT_SECURE_LIB__); }))) {
            mixin(enumMixinStr___GOT_SECURE_LIB__);
        }
    }
    static if(!is(typeof(_SECURECRT_FILL_BUFFER_PATTERN))) {
        private enum enumMixinStr__SECURECRT_FILL_BUFFER_PATTERN = `enum _SECURECRT_FILL_BUFFER_PATTERN = 0xFE;`;
        static if(is(typeof({ mixin(enumMixinStr__SECURECRT_FILL_BUFFER_PATTERN); }))) {
            mixin(enumMixinStr__SECURECRT_FILL_BUFFER_PATTERN);
        }
    }
    static if(!is(typeof(_ARM_WINAPI_PARTITION_DESKTOP_SDK_AVAILABLE))) {
        private enum enumMixinStr__ARM_WINAPI_PARTITION_DESKTOP_SDK_AVAILABLE = `enum _ARM_WINAPI_PARTITION_DESKTOP_SDK_AVAILABLE = 0;`;
        static if(is(typeof({ mixin(enumMixinStr__ARM_WINAPI_PARTITION_DESKTOP_SDK_AVAILABLE); }))) {
            mixin(enumMixinStr__ARM_WINAPI_PARTITION_DESKTOP_SDK_AVAILABLE);
        }
    }




    static if(!is(typeof(_CRT_BUILD_DESKTOP_APP))) {
        private enum enumMixinStr__CRT_BUILD_DESKTOP_APP = `enum _CRT_BUILD_DESKTOP_APP = 1;`;
        static if(is(typeof({ mixin(enumMixinStr__CRT_BUILD_DESKTOP_APP); }))) {
            mixin(enumMixinStr__CRT_BUILD_DESKTOP_APP);
        }
    }






    static if(!is(typeof(_CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES))) {
        private enum enumMixinStr__CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES = `enum _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES = 0;`;
        static if(is(typeof({ mixin(enumMixinStr__CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES); }))) {
            mixin(enumMixinStr__CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES);
        }
    }




    static if(!is(typeof(_CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_COUNT))) {
        private enum enumMixinStr__CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_COUNT = `enum _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_COUNT = 0;`;
        static if(is(typeof({ mixin(enumMixinStr__CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_COUNT); }))) {
            mixin(enumMixinStr__CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_COUNT);
        }
    }




    static if(!is(typeof(_CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES))) {
        private enum enumMixinStr__CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES = `enum _CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES = 1;`;
        static if(is(typeof({ mixin(enumMixinStr__CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES); }))) {
            mixin(enumMixinStr__CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES);
        }
    }




    static if(!is(typeof(_CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY))) {
        private enum enumMixinStr__CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY = `enum _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY = 0;`;
        static if(is(typeof({ mixin(enumMixinStr__CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY); }))) {
            mixin(enumMixinStr__CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY);
        }
    }




    static if(!is(typeof(_CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES_MEMORY))) {
        private enum enumMixinStr__CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES_MEMORY = `enum _CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES_MEMORY = 0;`;
        static if(is(typeof({ mixin(enumMixinStr__CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES_MEMORY); }))) {
            mixin(enumMixinStr__CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES_MEMORY);
        }
    }




    static if(!is(typeof(_CRT_SECURE_CPP_NOTHROW))) {
        private enum enumMixinStr__CRT_SECURE_CPP_NOTHROW = `enum _CRT_SECURE_CPP_NOTHROW = throw ( );`;
        static if(is(typeof({ mixin(enumMixinStr__CRT_SECURE_CPP_NOTHROW); }))) {
            mixin(enumMixinStr__CRT_SECURE_CPP_NOTHROW);
        }
    }
    static if(!is(typeof(_UNALIGNED))) {
        private enum enumMixinStr__UNALIGNED = `enum _UNALIGNED = __unaligned;`;
        static if(is(typeof({ mixin(enumMixinStr__UNALIGNED); }))) {
            mixin(enumMixinStr__UNALIGNED);
        }
    }






    static if(!is(typeof(_CRTNOALIAS))) {
        private enum enumMixinStr__CRTNOALIAS = `enum _CRTNOALIAS = __declspec ( noalias );`;
        static if(is(typeof({ mixin(enumMixinStr__CRTNOALIAS); }))) {
            mixin(enumMixinStr__CRTNOALIAS);
        }
    }




    static if(!is(typeof(_CRTRESTRICT))) {
        private enum enumMixinStr__CRTRESTRICT = `enum _CRTRESTRICT = __declspec cast( restrict );`;
        static if(is(typeof({ mixin(enumMixinStr__CRTRESTRICT); }))) {
            mixin(enumMixinStr__CRTRESTRICT);
        }
    }




    static if(!is(typeof(__CRTDECL))) {
        private enum enumMixinStr___CRTDECL = `enum __CRTDECL = __cdecl;`;
        static if(is(typeof({ mixin(enumMixinStr___CRTDECL); }))) {
            mixin(enumMixinStr___CRTDECL);
        }
    }
    static if(!is(typeof(__FILEW__))) {
        private enum enumMixinStr___FILEW__ = `enum __FILEW__ = L".\\gl31.d.tmp";`;
        static if(is(typeof({ mixin(enumMixinStr___FILEW__); }))) {
            mixin(enumMixinStr___FILEW__);
        }
    }




    static if(!is(typeof(__FUNCTIONW__))) {
        private enum enumMixinStr___FUNCTIONW__ = `enum __FUNCTIONW__ = _STR2WSTR cast( __FUNCTION__ );`;
        static if(is(typeof({ mixin(enumMixinStr___FUNCTIONW__); }))) {
            mixin(enumMixinStr___FUNCTIONW__);
        }
    }






    static if(!is(typeof(_ARGMAX))) {
        private enum enumMixinStr__ARGMAX = `enum _ARGMAX = 100;`;
        static if(is(typeof({ mixin(enumMixinStr__ARGMAX); }))) {
            mixin(enumMixinStr__ARGMAX);
        }
    }




    static if(!is(typeof(_TRUNCATE))) {
        private enum enumMixinStr__TRUNCATE = `enum _TRUNCATE = ( cast( size_t ) - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr__TRUNCATE); }))) {
            mixin(enumMixinStr__TRUNCATE);
        }
    }
    static if(!is(typeof(_SAL_VERSION))) {
        private enum enumMixinStr__SAL_VERSION = `enum _SAL_VERSION = 20;`;
        static if(is(typeof({ mixin(enumMixinStr__SAL_VERSION); }))) {
            mixin(enumMixinStr__SAL_VERSION);
        }
    }




    static if(!is(typeof(__SAL_H_VERSION))) {
        private enum enumMixinStr___SAL_H_VERSION = `enum __SAL_H_VERSION = 180000000;`;
        static if(is(typeof({ mixin(enumMixinStr___SAL_H_VERSION); }))) {
            mixin(enumMixinStr___SAL_H_VERSION);
        }
    }




    static if(!is(typeof(_USE_DECLSPECS_FOR_SAL))) {
        private enum enumMixinStr__USE_DECLSPECS_FOR_SAL = `enum _USE_DECLSPECS_FOR_SAL = 0;`;
        static if(is(typeof({ mixin(enumMixinStr__USE_DECLSPECS_FOR_SAL); }))) {
            mixin(enumMixinStr__USE_DECLSPECS_FOR_SAL);
        }
    }




    static if(!is(typeof(_USE_ATTRIBUTES_FOR_SAL))) {
        private enum enumMixinStr__USE_ATTRIBUTES_FOR_SAL = `enum _USE_ATTRIBUTES_FOR_SAL = 0;`;
        static if(is(typeof({ mixin(enumMixinStr__USE_ATTRIBUTES_FOR_SAL); }))) {
            mixin(enumMixinStr__USE_ATTRIBUTES_FOR_SAL);
        }
    }
    static if(!is(typeof(_Use_decl_annotations_))) {
        private enum enumMixinStr__Use_decl_annotations_ = `enum _Use_decl_annotations_ = _Use_decl_anno_impl_;`;
        static if(is(typeof({ mixin(enumMixinStr__Use_decl_annotations_); }))) {
            mixin(enumMixinStr__Use_decl_annotations_);
        }
    }




    static if(!is(typeof(_Notref_))) {
        private enum enumMixinStr__Notref_ = `enum _Notref_ = _Notref_impl_;`;
        static if(is(typeof({ mixin(enumMixinStr__Notref_); }))) {
            mixin(enumMixinStr__Notref_);
        }
    }




    static if(!is(typeof(_Pre_defensive_))) {
        private enum enumMixinStr__Pre_defensive_ = `enum _Pre_defensive_ = _SA_annotes0 ( SAL_pre_defensive );`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_defensive_); }))) {
            mixin(enumMixinStr__Pre_defensive_);
        }
    }




    static if(!is(typeof(_Post_defensive_))) {
        private enum enumMixinStr__Post_defensive_ = `enum _Post_defensive_ = _SA_annotes0 ( SAL_post_defensive );`;
        static if(is(typeof({ mixin(enumMixinStr__Post_defensive_); }))) {
            mixin(enumMixinStr__Post_defensive_);
        }
    }
    static if(!is(typeof(_Reserved_))) {
        private enum enumMixinStr__Reserved_ = `enum _Reserved_ = _SA_annotes3 ( SAL_name , "_Reserved_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __null_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Reserved_); }))) {
            mixin(enumMixinStr__Reserved_);
        }
    }




    static if(!is(typeof(_Const_))) {
        private enum enumMixinStr__Const_ = `enum _Const_ = _SA_annotes3 ( SAL_name , "_Const_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __readaccess_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Const_); }))) {
            mixin(enumMixinStr__Const_);
        }
    }




    static if(!is(typeof(_In_))) {
        private enum enumMixinStr__In_ = `enum _In_ = _SA_annotes3 ( SAL_name , "_In_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __notnull_impl_notref ) _Pre_valid_impl_ _Deref_pre1_impl_ ( __readaccess_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__In_); }))) {
            mixin(enumMixinStr__In_);
        }
    }




    static if(!is(typeof(_In_opt_))) {
        private enum enumMixinStr__In_opt_ = `enum _In_opt_ = _SA_annotes3 ( SAL_name , "_In_opt_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __maybenull_impl_notref ) _Pre_valid_impl_ _Deref_pre_readonly_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__In_opt_); }))) {
            mixin(enumMixinStr__In_opt_);
        }
    }




    static if(!is(typeof(_In_z_))) {
        private enum enumMixinStr__In_z_ = `enum _In_z_ = _SA_annotes3 ( SAL_name , "_In_z_" , "" , "2" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_In_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __notnull_impl_notref ) _Pre_valid_impl_ _Deref_pre1_impl_ ( __readaccess_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ ) _Pre1_impl_ ( __zterm_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__In_z_); }))) {
            mixin(enumMixinStr__In_z_);
        }
    }




    static if(!is(typeof(_In_opt_z_))) {
        private enum enumMixinStr__In_opt_z_ = `enum _In_opt_z_ = _SA_annotes3 ( SAL_name , "_In_opt_z_" , "" , "2" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_In_opt_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __maybenull_impl_notref ) _Pre_valid_impl_ _Deref_pre_readonly_ _SAL_nop_impl_ _SAL_nop_impl_ ) _Pre1_impl_ ( __zterm_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__In_opt_z_); }))) {
            mixin(enumMixinStr__In_opt_z_);
        }
    }
    static if(!is(typeof(_Out_))) {
        private enum enumMixinStr__Out_ = `enum _Out_ = _SA_annotes3 ( SAL_name , "_Out_" , "" , "2" ) _Group_impl_ ( _Out_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Out_); }))) {
            mixin(enumMixinStr__Out_);
        }
    }




    static if(!is(typeof(_Out_opt_))) {
        private enum enumMixinStr__Out_opt_ = `enum _Out_opt_ = _SA_annotes3 ( SAL_name , "_Out_opt_" , "" , "2" ) _Group_impl_ ( _Out_opt_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Out_opt_); }))) {
            mixin(enumMixinStr__Out_opt_);
        }
    }
    static if(!is(typeof(_Inout_))) {
        private enum enumMixinStr__Inout_ = `enum _Inout_ = _SA_annotes3 ( SAL_name , "_Inout_" , "" , "2" ) _Group_impl_ ( _Prepost_valid_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Inout_); }))) {
            mixin(enumMixinStr__Inout_);
        }
    }




    static if(!is(typeof(_Inout_opt_))) {
        private enum enumMixinStr__Inout_opt_ = `enum _Inout_opt_ = _SA_annotes3 ( SAL_name , "_Inout_opt_" , "" , "2" ) _Group_impl_ ( _Prepost_opt_valid_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Inout_opt_); }))) {
            mixin(enumMixinStr__Inout_opt_);
        }
    }




    static if(!is(typeof(_Inout_z_))) {
        private enum enumMixinStr__Inout_z_ = `enum _Inout_z_ = _SA_annotes3 ( SAL_name , "_Inout_z_" , "" , "2" ) _Group_impl_ ( _Prepost_z_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Inout_z_); }))) {
            mixin(enumMixinStr__Inout_z_);
        }
    }




    static if(!is(typeof(_Inout_opt_z_))) {
        private enum enumMixinStr__Inout_opt_z_ = `enum _Inout_opt_z_ = _SA_annotes3 ( SAL_name , "_Inout_opt_z_" , "" , "2" ) _Group_impl_ ( _Prepost_opt_z_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Inout_opt_z_); }))) {
            mixin(enumMixinStr__Inout_opt_z_);
        }
    }
    static if(!is(typeof(_Outptr_))) {
        private enum enumMixinStr__Outptr_ = `enum _Outptr_ = _SA_annotes3 ( SAL_name , "_Outptr_" , "" , "2" ) _Group_impl_ ( _Out_impl_ _Deref_post2_impl_ ( __notnull_impl_notref , __count_impl ( 1 ) ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Outptr_); }))) {
            mixin(enumMixinStr__Outptr_);
        }
    }




    static if(!is(typeof(_Outptr_result_maybenull_))) {
        private enum enumMixinStr__Outptr_result_maybenull_ = `enum _Outptr_result_maybenull_ = _SA_annotes3 ( SAL_name , "_Outptr_result_maybenull_" , "" , "2" ) _Group_impl_ ( _Out_impl_ _Deref_post2_impl_ ( __maybenull_impl_notref , __count_impl ( 1 ) ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Outptr_result_maybenull_); }))) {
            mixin(enumMixinStr__Outptr_result_maybenull_);
        }
    }




    static if(!is(typeof(_Outptr_opt_))) {
        private enum enumMixinStr__Outptr_opt_ = `enum _Outptr_opt_ = _SA_annotes3 ( SAL_name , "_Outptr_opt_" , "" , "2" ) _Group_impl_ ( _Out_opt_impl_ _Deref_post2_impl_ ( __notnull_impl_notref , __count_impl ( 1 ) ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Outptr_opt_); }))) {
            mixin(enumMixinStr__Outptr_opt_);
        }
    }




    static if(!is(typeof(_Outptr_opt_result_maybenull_))) {
        private enum enumMixinStr__Outptr_opt_result_maybenull_ = `enum _Outptr_opt_result_maybenull_ = _SA_annotes3 ( SAL_name , "_Outptr_opt_result_maybenull_" , "" , "2" ) _Group_impl_ ( _Out_opt_impl_ _Deref_post2_impl_ ( __maybenull_impl_notref , __count_impl ( 1 ) ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Outptr_opt_result_maybenull_); }))) {
            mixin(enumMixinStr__Outptr_opt_result_maybenull_);
        }
    }




    static if(!is(typeof(_Outptr_result_z_))) {
        private enum enumMixinStr__Outptr_result_z_ = `enum _Outptr_result_z_ = _SA_annotes3 ( SAL_name , "_Outptr_result_z_" , "" , "2" ) _Group_impl_ ( _Out_impl_ _Deref_post_z_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Outptr_result_z_); }))) {
            mixin(enumMixinStr__Outptr_result_z_);
        }
    }




    static if(!is(typeof(_Outptr_opt_result_z_))) {
        private enum enumMixinStr__Outptr_opt_result_z_ = `enum _Outptr_opt_result_z_ = _SA_annotes3 ( SAL_name , "_Outptr_opt_result_z_" , "" , "2" ) _Group_impl_ ( _Out_opt_impl_ _Deref_post_z_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Outptr_opt_result_z_); }))) {
            mixin(enumMixinStr__Outptr_opt_result_z_);
        }
    }




    static if(!is(typeof(_Outptr_result_maybenull_z_))) {
        private enum enumMixinStr__Outptr_result_maybenull_z_ = `enum _Outptr_result_maybenull_z_ = _SA_annotes3 ( SAL_name , "_Outptr_result_maybenull_z_" , "" , "2" ) _Group_impl_ ( _Out_impl_ _Deref_post_opt_z_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Outptr_result_maybenull_z_); }))) {
            mixin(enumMixinStr__Outptr_result_maybenull_z_);
        }
    }




    static if(!is(typeof(_Outptr_opt_result_maybenull_z_))) {
        private enum enumMixinStr__Outptr_opt_result_maybenull_z_ = `enum _Outptr_opt_result_maybenull_z_ = _SA_annotes3 ( SAL_name , "_Outptr_opt_result_maybenull_z_" , "" , "2" ) _Group_impl_ ( _Out_opt_impl_ _Deref_post_opt_z_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Outptr_opt_result_maybenull_z_); }))) {
            mixin(enumMixinStr__Outptr_opt_result_maybenull_z_);
        }
    }




    static if(!is(typeof(_Outptr_result_nullonfailure_))) {
        private enum enumMixinStr__Outptr_result_nullonfailure_ = `enum _Outptr_result_nullonfailure_ = _SA_annotes3 ( SAL_name , "_Outptr_result_nullonfailure_" , "" , "2" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Outptr_" , "" , "2" ) _Group_impl_ ( _Out_impl_ _Deref_post2_impl_ ( __notnull_impl_notref , __count_impl ( 1 ) ) _SAL_nop_impl_ _SAL_nop_impl_ ) _On_failure_impl_ ( _Deref_post_null_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Outptr_result_nullonfailure_); }))) {
            mixin(enumMixinStr__Outptr_result_nullonfailure_);
        }
    }




    static if(!is(typeof(_Outptr_opt_result_nullonfailure_))) {
        private enum enumMixinStr__Outptr_opt_result_nullonfailure_ = `enum _Outptr_opt_result_nullonfailure_ = _SA_annotes3 ( SAL_name , "_Outptr_opt_result_nullonfailure_" , "" , "2" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Outptr_opt_" , "" , "2" ) _Group_impl_ ( _Out_opt_impl_ _Deref_post2_impl_ ( __notnull_impl_notref , __count_impl ( 1 ) ) _SAL_nop_impl_ _SAL_nop_impl_ ) _On_failure_impl_ ( _Deref_post_null_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Outptr_opt_result_nullonfailure_); }))) {
            mixin(enumMixinStr__Outptr_opt_result_nullonfailure_);
        }
    }




    static if(!is(typeof(_COM_Outptr_))) {
        private enum enumMixinStr__COM_Outptr_ = `enum _COM_Outptr_ = _SA_annotes3 ( SAL_name , "_COM_Outptr_" , "" , "2" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Outptr_" , "" , "2" ) _Group_impl_ ( _Out_impl_ _Deref_post2_impl_ ( __notnull_impl_notref , __count_impl ( 1 ) ) _SAL_nop_impl_ _SAL_nop_impl_ ) _On_failure_impl_ ( _Deref_post_null_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__COM_Outptr_); }))) {
            mixin(enumMixinStr__COM_Outptr_);
        }
    }




    static if(!is(typeof(_COM_Outptr_result_maybenull_))) {
        private enum enumMixinStr__COM_Outptr_result_maybenull_ = `enum _COM_Outptr_result_maybenull_ = _SA_annotes3 ( SAL_name , "_COM_Outptr_result_maybenull_" , "" , "2" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Outptr_result_maybenull_" , "" , "2" ) _Group_impl_ ( _Out_impl_ _Deref_post2_impl_ ( __maybenull_impl_notref , __count_impl ( 1 ) ) _SAL_nop_impl_ _SAL_nop_impl_ ) _On_failure_impl_ ( _Deref_post_null_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__COM_Outptr_result_maybenull_); }))) {
            mixin(enumMixinStr__COM_Outptr_result_maybenull_);
        }
    }




    static if(!is(typeof(_COM_Outptr_opt_))) {
        private enum enumMixinStr__COM_Outptr_opt_ = `enum _COM_Outptr_opt_ = _SA_annotes3 ( SAL_name , "_COM_Outptr_opt_" , "" , "2" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Outptr_opt_" , "" , "2" ) _Group_impl_ ( _Out_opt_impl_ _Deref_post2_impl_ ( __notnull_impl_notref , __count_impl ( 1 ) ) _SAL_nop_impl_ _SAL_nop_impl_ ) _On_failure_impl_ ( _Deref_post_null_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__COM_Outptr_opt_); }))) {
            mixin(enumMixinStr__COM_Outptr_opt_);
        }
    }




    static if(!is(typeof(_COM_Outptr_opt_result_maybenull_))) {
        private enum enumMixinStr__COM_Outptr_opt_result_maybenull_ = `enum _COM_Outptr_opt_result_maybenull_ = _SA_annotes3 ( SAL_name , "_COM_Outptr_opt_result_maybenull_" , "" , "2" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Outptr_opt_result_maybenull_" , "" , "2" ) _Group_impl_ ( _Out_opt_impl_ _Deref_post2_impl_ ( __maybenull_impl_notref , __count_impl ( 1 ) ) _SAL_nop_impl_ _SAL_nop_impl_ ) _On_failure_impl_ ( _Deref_post_null_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__COM_Outptr_opt_result_maybenull_); }))) {
            mixin(enumMixinStr__COM_Outptr_opt_result_maybenull_);
        }
    }
    static if(!is(typeof(_Outref_))) {
        private enum enumMixinStr__Outref_ = `enum _Outref_ = _SA_annotes3 ( SAL_name , "_Outref_" , "" , "2" ) _Group_impl_ ( _Out_impl_ _Post_notnull_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Outref_); }))) {
            mixin(enumMixinStr__Outref_);
        }
    }




    static if(!is(typeof(_Outref_result_maybenull_))) {
        private enum enumMixinStr__Outref_result_maybenull_ = `enum _Outref_result_maybenull_ = _SA_annotes3 ( SAL_name , "_Outref_result_maybenull_" , "" , "2" ) _Group_impl_ ( _Pre2_impl_ ( __notnull_impl_notref , __cap_c_one_notref_impl ) _Post_maybenull_ _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Outref_result_maybenull_); }))) {
            mixin(enumMixinStr__Outref_result_maybenull_);
        }
    }
    static if(!is(typeof(_Outref_result_nullonfailure_))) {
        private enum enumMixinStr__Outref_result_nullonfailure_ = `enum _Outref_result_nullonfailure_ = _SA_annotes3 ( SAL_name , "_Outref_result_nullonfailure_" , "" , "2" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Outref_" , "" , "2" ) _Group_impl_ ( _Out_impl_ _Post_notnull_ _SAL_nop_impl_ _SAL_nop_impl_ ) _On_failure_impl_ ( _Post_null_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Outref_result_nullonfailure_); }))) {
            mixin(enumMixinStr__Outref_result_nullonfailure_);
        }
    }




    static if(!is(typeof(_Result_nullonfailure_))) {
        private enum enumMixinStr__Result_nullonfailure_ = `enum _Result_nullonfailure_ = _SA_annotes3 ( SAL_name , "_Result_nullonfailure_" , "" , "2" ) _Group_impl_ ( _On_failure_impl_ ( _Notref_impl_ _Deref_impl_ _Post_null_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Result_nullonfailure_); }))) {
            mixin(enumMixinStr__Result_nullonfailure_);
        }
    }




    static if(!is(typeof(_Result_zeroonfailure_))) {
        private enum enumMixinStr__Result_zeroonfailure_ = `enum _Result_zeroonfailure_ = _SA_annotes3 ( SAL_name , "_Result_zeroonfailure_" , "" , "2" ) _Group_impl_ ( _On_failure_impl_ ( _Notref_impl_ _Deref_impl_ _Out_range_ ( == , 0 ) _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Result_zeroonfailure_); }))) {
            mixin(enumMixinStr__Result_zeroonfailure_);
        }
    }




    static if(!is(typeof(_Ret_z_))) {
        private enum enumMixinStr__Ret_z_ = `enum _Ret_z_ = _SA_annotes3 ( SAL_name , "_Ret_z_" , "" , "2" ) _Group_impl_ ( _Ret2_impl_ ( __notnull_impl , __zterm_impl ) _Ret_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Ret_z_); }))) {
            mixin(enumMixinStr__Ret_z_);
        }
    }




    static if(!is(typeof(_Ret_maybenull_z_))) {
        private enum enumMixinStr__Ret_maybenull_z_ = `enum _Ret_maybenull_z_ = _SA_annotes3 ( SAL_name , "_Ret_maybenull_z_" , "" , "2" ) _Group_impl_ ( _Ret2_impl_ ( __maybenull_impl , __zterm_impl ) _Ret_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Ret_maybenull_z_); }))) {
            mixin(enumMixinStr__Ret_maybenull_z_);
        }
    }




    static if(!is(typeof(_Ret_notnull_))) {
        private enum enumMixinStr__Ret_notnull_ = `enum _Ret_notnull_ = _SA_annotes3 ( SAL_name , "_Ret_notnull_" , "" , "2" ) _Group_impl_ ( _Ret1_impl_ ( __notnull_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Ret_notnull_); }))) {
            mixin(enumMixinStr__Ret_notnull_);
        }
    }




    static if(!is(typeof(_Ret_maybenull_))) {
        private enum enumMixinStr__Ret_maybenull_ = `enum _Ret_maybenull_ = _SA_annotes3 ( SAL_name , "_Ret_maybenull_" , "" , "2" ) _Group_impl_ ( _Ret1_impl_ ( __maybenull_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Ret_maybenull_); }))) {
            mixin(enumMixinStr__Ret_maybenull_);
        }
    }




    static if(!is(typeof(_Ret_null_))) {
        private enum enumMixinStr__Ret_null_ = `enum _Ret_null_ = _SA_annotes3 ( SAL_name , "_Ret_null_" , "" , "2" ) _Group_impl_ ( _Ret1_impl_ ( __null_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Ret_null_); }))) {
            mixin(enumMixinStr__Ret_null_);
        }
    }




    static if(!is(typeof(_Ret_valid_))) {
        private enum enumMixinStr__Ret_valid_ = `enum _Ret_valid_ = _SA_annotes3 ( SAL_name , "_Ret_valid_" , "" , "2" ) _Group_impl_ ( _Ret1_impl_ ( __notnull_impl_notref ) _Ret_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Ret_valid_); }))) {
            mixin(enumMixinStr__Ret_valid_);
        }
    }
    static if(!is(typeof(_Points_to_data_))) {
        private enum enumMixinStr__Points_to_data_ = `enum _Points_to_data_ = _SA_annotes3 ( SAL_name , "_Points_to_data_" , "" , "2" ) _Group_impl_ ( _Pre_ _Points_to_data_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Points_to_data_); }))) {
            mixin(enumMixinStr__Points_to_data_);
        }
    }




    static if(!is(typeof(_Literal_))) {
        private enum enumMixinStr__Literal_ = `enum _Literal_ = _SA_annotes3 ( SAL_name , "_Literal_" , "" , "2" ) _Group_impl_ ( _Pre_ _Literal_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Literal_); }))) {
            mixin(enumMixinStr__Literal_);
        }
    }




    static if(!is(typeof(_Notliteral_))) {
        private enum enumMixinStr__Notliteral_ = `enum _Notliteral_ = _SA_annotes3 ( SAL_name , "_Notliteral_" , "" , "2" ) _Group_impl_ ( _Pre_ _Notliteral_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Notliteral_); }))) {
            mixin(enumMixinStr__Notliteral_);
        }
    }




    static if(!is(typeof(_Check_return_))) {
        private enum enumMixinStr__Check_return_ = `enum _Check_return_ = _SA_annotes3 ( SAL_name , "_Check_return_" , "" , "2" ) _Group_impl_ ( _Check_return_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Check_return_); }))) {
            mixin(enumMixinStr__Check_return_);
        }
    }




    static if(!is(typeof(_Must_inspect_result_))) {
        private enum enumMixinStr__Must_inspect_result_ = `enum _Must_inspect_result_ = _SA_annotes3 ( SAL_name , "_Must_inspect_result_" , "" , "2" ) _Group_impl_ ( _Must_inspect_impl_ _Check_return_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Must_inspect_result_); }))) {
            mixin(enumMixinStr__Must_inspect_result_);
        }
    }




    static if(!is(typeof(_Printf_format_string_))) {
        private enum enumMixinStr__Printf_format_string_ = `enum _Printf_format_string_ = _SA_annotes3 ( SAL_name , "_Printf_format_string_" , "" , "2" ) _Group_impl_ ( _Printf_format_string_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Printf_format_string_); }))) {
            mixin(enumMixinStr__Printf_format_string_);
        }
    }




    static if(!is(typeof(_Scanf_format_string_))) {
        private enum enumMixinStr__Scanf_format_string_ = `enum _Scanf_format_string_ = _SA_annotes3 ( SAL_name , "_Scanf_format_string_" , "" , "2" ) _Group_impl_ ( _Scanf_format_string_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Scanf_format_string_); }))) {
            mixin(enumMixinStr__Scanf_format_string_);
        }
    }




    static if(!is(typeof(_Scanf_s_format_string_))) {
        private enum enumMixinStr__Scanf_s_format_string_ = `enum _Scanf_s_format_string_ = _SA_annotes3 ( SAL_name , "_Scanf_s_format_string_" , "" , "2" ) _Group_impl_ ( _Scanf_s_format_string_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Scanf_s_format_string_); }))) {
            mixin(enumMixinStr__Scanf_s_format_string_);
        }
    }
    static if(!is(typeof(_Field_z_))) {
        private enum enumMixinStr__Field_z_ = `enum _Field_z_ = _SA_annotes3 ( SAL_name , "_Field_z_" , "" , "2" ) _Group_impl_ ( _Null_terminated_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Field_z_); }))) {
            mixin(enumMixinStr__Field_z_);
        }
    }






    static if(!is(typeof(_Pre_))) {
        private enum enumMixinStr__Pre_ = `enum _Pre_ = _Pre_impl_;`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_); }))) {
            mixin(enumMixinStr__Pre_);
        }
    }




    static if(!is(typeof(_Post_))) {
        private enum enumMixinStr__Post_ = `enum _Post_ = _Post_impl_;`;
        static if(is(typeof({ mixin(enumMixinStr__Post_); }))) {
            mixin(enumMixinStr__Post_);
        }
    }




    static if(!is(typeof(_Valid_))) {
        private enum enumMixinStr__Valid_ = `enum _Valid_ = _Valid_impl_;`;
        static if(is(typeof({ mixin(enumMixinStr__Valid_); }))) {
            mixin(enumMixinStr__Valid_);
        }
    }




    static if(!is(typeof(_Notvalid_))) {
        private enum enumMixinStr__Notvalid_ = `enum _Notvalid_ = _Notvalid_impl_;`;
        static if(is(typeof({ mixin(enumMixinStr__Notvalid_); }))) {
            mixin(enumMixinStr__Notvalid_);
        }
    }




    static if(!is(typeof(_Maybevalid_))) {
        private enum enumMixinStr__Maybevalid_ = `enum _Maybevalid_ = _Maybevalid_impl_;`;
        static if(is(typeof({ mixin(enumMixinStr__Maybevalid_); }))) {
            mixin(enumMixinStr__Maybevalid_);
        }
    }
    static if(!is(typeof(_Null_terminated_))) {
        private enum enumMixinStr__Null_terminated_ = `enum _Null_terminated_ = _SA_annotes3 ( SAL_name , "_Null_terminated_" , "" , "2" ) _Group_impl_ ( _Null_terminated_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Null_terminated_); }))) {
            mixin(enumMixinStr__Null_terminated_);
        }
    }




    static if(!is(typeof(_NullNull_terminated_))) {
        private enum enumMixinStr__NullNull_terminated_ = `enum _NullNull_terminated_ = _SA_annotes3 ( SAL_name , "_NullNull_terminated_" , "" , "2" ) _Group_impl_ ( _NullNull_terminated_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__NullNull_terminated_); }))) {
            mixin(enumMixinStr__NullNull_terminated_);
        }
    }
    static if(!is(typeof(_Null_))) {
        private enum enumMixinStr__Null_ = `enum _Null_ = _SA_annotes3 ( SAL_name , "_Null_" , "" , "2" ) _Group_impl_ ( _Null_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Null_); }))) {
            mixin(enumMixinStr__Null_);
        }
    }




    static if(!is(typeof(_Notnull_))) {
        private enum enumMixinStr__Notnull_ = `enum _Notnull_ = _SA_annotes3 ( SAL_name , "_Notnull_" , "" , "2" ) _Group_impl_ ( _Notnull_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Notnull_); }))) {
            mixin(enumMixinStr__Notnull_);
        }
    }




    static if(!is(typeof(_Maybenull_))) {
        private enum enumMixinStr__Maybenull_ = `enum _Maybenull_ = _SA_annotes3 ( SAL_name , "_Maybenull_" , "" , "2" ) _Group_impl_ ( _Maybenull_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Maybenull_); }))) {
            mixin(enumMixinStr__Maybenull_);
        }
    }




    static if(!is(typeof(_Pre_z_))) {
        private enum enumMixinStr__Pre_z_ = `enum _Pre_z_ = _SA_annotes3 ( SAL_name , "_Pre_z_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __zterm_impl ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_z_); }))) {
            mixin(enumMixinStr__Pre_z_);
        }
    }




    static if(!is(typeof(_Pre_valid_))) {
        private enum enumMixinStr__Pre_valid_ = `enum _Pre_valid_ = _SA_annotes3 ( SAL_name , "_Pre_valid_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __notnull_impl_notref ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_valid_); }))) {
            mixin(enumMixinStr__Pre_valid_);
        }
    }




    static if(!is(typeof(_Pre_opt_valid_))) {
        private enum enumMixinStr__Pre_opt_valid_ = `enum _Pre_opt_valid_ = _SA_annotes3 ( SAL_name , "_Pre_opt_valid_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __maybenull_impl_notref ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_opt_valid_); }))) {
            mixin(enumMixinStr__Pre_opt_valid_);
        }
    }




    static if(!is(typeof(_Pre_invalid_))) {
        private enum enumMixinStr__Pre_invalid_ = `enum _Pre_invalid_ = _SA_annotes3 ( SAL_name , "_Pre_invalid_" , "" , "2" ) _Group_impl_ ( _Deref_pre1_impl_ ( __notvalid_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_invalid_); }))) {
            mixin(enumMixinStr__Pre_invalid_);
        }
    }




    static if(!is(typeof(_Pre_unknown_))) {
        private enum enumMixinStr__Pre_unknown_ = `enum _Pre_unknown_ = _SA_annotes3 ( SAL_name , "_Pre_unknown_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __maybevalid_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_unknown_); }))) {
            mixin(enumMixinStr__Pre_unknown_);
        }
    }




    static if(!is(typeof(_Pre_notnull_))) {
        private enum enumMixinStr__Pre_notnull_ = `enum _Pre_notnull_ = _SA_annotes3 ( SAL_name , "_Pre_notnull_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __notnull_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_notnull_); }))) {
            mixin(enumMixinStr__Pre_notnull_);
        }
    }




    static if(!is(typeof(_Pre_maybenull_))) {
        private enum enumMixinStr__Pre_maybenull_ = `enum _Pre_maybenull_ = _SA_annotes3 ( SAL_name , "_Pre_maybenull_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __maybenull_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_maybenull_); }))) {
            mixin(enumMixinStr__Pre_maybenull_);
        }
    }




    static if(!is(typeof(_Pre_null_))) {
        private enum enumMixinStr__Pre_null_ = `enum _Pre_null_ = _SA_annotes3 ( SAL_name , "_Pre_null_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __null_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_null_); }))) {
            mixin(enumMixinStr__Pre_null_);
        }
    }




    static if(!is(typeof(_Post_z_))) {
        private enum enumMixinStr__Post_z_ = `enum _Post_z_ = _SA_annotes3 ( SAL_name , "_Post_z_" , "" , "2" ) _Group_impl_ ( _Post1_impl_ ( __zterm_impl ) _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Post_z_); }))) {
            mixin(enumMixinStr__Post_z_);
        }
    }




    static if(!is(typeof(_Post_valid_))) {
        private enum enumMixinStr__Post_valid_ = `enum _Post_valid_ = _SA_annotes3 ( SAL_name , "_Post_valid_" , "" , "2" ) _Group_impl_ ( _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Post_valid_); }))) {
            mixin(enumMixinStr__Post_valid_);
        }
    }




    static if(!is(typeof(_Post_invalid_))) {
        private enum enumMixinStr__Post_invalid_ = `enum _Post_invalid_ = _SA_annotes3 ( SAL_name , "_Post_invalid_" , "" , "2" ) _Group_impl_ ( _Deref_post1_impl_ ( __notvalid_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Post_invalid_); }))) {
            mixin(enumMixinStr__Post_invalid_);
        }
    }




    static if(!is(typeof(_Post_ptr_invalid_))) {
        private enum enumMixinStr__Post_ptr_invalid_ = `enum _Post_ptr_invalid_ = _SA_annotes3 ( SAL_name , "_Post_ptr_invalid_" , "" , "2" ) _Group_impl_ ( _Post1_impl_ ( __notvalid_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Post_ptr_invalid_); }))) {
            mixin(enumMixinStr__Post_ptr_invalid_);
        }
    }




    static if(!is(typeof(_Post_notnull_))) {
        private enum enumMixinStr__Post_notnull_ = `enum _Post_notnull_ = _SA_annotes3 ( SAL_name , "_Post_notnull_" , "" , "2" ) _Group_impl_ ( _Post1_impl_ ( __notnull_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Post_notnull_); }))) {
            mixin(enumMixinStr__Post_notnull_);
        }
    }




    static if(!is(typeof(_Post_null_))) {
        private enum enumMixinStr__Post_null_ = `enum _Post_null_ = _SA_annotes3 ( SAL_name , "_Post_null_" , "" , "2" ) _Group_impl_ ( _Post1_impl_ ( __null_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Post_null_); }))) {
            mixin(enumMixinStr__Post_null_);
        }
    }




    static if(!is(typeof(_Post_maybenull_))) {
        private enum enumMixinStr__Post_maybenull_ = `enum _Post_maybenull_ = _SA_annotes3 ( SAL_name , "_Post_maybenull_" , "" , "2" ) _Group_impl_ ( _Post1_impl_ ( __maybenull_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Post_maybenull_); }))) {
            mixin(enumMixinStr__Post_maybenull_);
        }
    }




    static if(!is(typeof(_Prepost_z_))) {
        private enum enumMixinStr__Prepost_z_ = `enum _Prepost_z_ = _SA_annotes3 ( SAL_name , "_Prepost_z_" , "" , "2" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Pre_z_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __zterm_impl ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SA_annotes3 ( SAL_name , "_Post_z_" , "" , "2" ) _Group_impl_ ( _Post1_impl_ ( __zterm_impl ) _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Prepost_z_); }))) {
            mixin(enumMixinStr__Prepost_z_);
        }
    }
    static if(!is(typeof(_Ret_))) {
        private enum enumMixinStr__Ret_ = `enum _Ret_ = _SA_annotes3 ( SAL_name , "_Ret_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Ret_valid_" , "" , "2" ) _Group_impl_ ( _Ret1_impl_ ( __notnull_impl_notref ) _Ret_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Ret_); }))) {
            mixin(enumMixinStr__Ret_);
        }
    }




    static if(!is(typeof(_Ret_opt_))) {
        private enum enumMixinStr__Ret_opt_ = `enum _Ret_opt_ = _SA_annotes3 ( SAL_name , "_Ret_opt_" , "" , "1.1" ) _Group_impl_ ( _Ret_opt_valid_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Ret_opt_); }))) {
            mixin(enumMixinStr__Ret_opt_);
        }
    }




    static if(!is(typeof(_In_bound_))) {
        private enum enumMixinStr__In_bound_ = `enum _In_bound_ = _SA_annotes3 ( SAL_name , "_In_bound_" , "" , "1.1" ) _Group_impl_ ( _In_bound_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__In_bound_); }))) {
            mixin(enumMixinStr__In_bound_);
        }
    }




    static if(!is(typeof(_Out_bound_))) {
        private enum enumMixinStr__Out_bound_ = `enum _Out_bound_ = _SA_annotes3 ( SAL_name , "_Out_bound_" , "" , "1.1" ) _Group_impl_ ( _Out_bound_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Out_bound_); }))) {
            mixin(enumMixinStr__Out_bound_);
        }
    }




    static if(!is(typeof(_Ret_bound_))) {
        private enum enumMixinStr__Ret_bound_ = `enum _Ret_bound_ = _SA_annotes3 ( SAL_name , "_Ret_bound_" , "" , "1.1" ) _Group_impl_ ( _Ret_bound_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Ret_bound_); }))) {
            mixin(enumMixinStr__Ret_bound_);
        }
    }




    static if(!is(typeof(_Deref_in_bound_))) {
        private enum enumMixinStr__Deref_in_bound_ = `enum _Deref_in_bound_ = _SA_annotes3 ( SAL_name , "_Deref_in_bound_" , "" , "1.1" ) _Group_impl_ ( _Deref_in_bound_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_in_bound_); }))) {
            mixin(enumMixinStr__Deref_in_bound_);
        }
    }




    static if(!is(typeof(_Deref_out_bound_))) {
        private enum enumMixinStr__Deref_out_bound_ = `enum _Deref_out_bound_ = _SA_annotes3 ( SAL_name , "_Deref_out_bound_" , "" , "1.1" ) _Group_impl_ ( _Deref_out_bound_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_out_bound_); }))) {
            mixin(enumMixinStr__Deref_out_bound_);
        }
    }




    static if(!is(typeof(_Deref_inout_bound_))) {
        private enum enumMixinStr__Deref_inout_bound_ = `enum _Deref_inout_bound_ = _SA_annotes3 ( SAL_name , "_Deref_inout_bound_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Deref_in_bound_" , "" , "1.1" ) _Group_impl_ ( _Deref_in_bound_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SA_annotes3 ( SAL_name , "_Deref_out_bound_" , "" , "1.1" ) _Group_impl_ ( _Deref_out_bound_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_inout_bound_); }))) {
            mixin(enumMixinStr__Deref_inout_bound_);
        }
    }




    static if(!is(typeof(_Deref_ret_bound_))) {
        private enum enumMixinStr__Deref_ret_bound_ = `enum _Deref_ret_bound_ = _SA_annotes3 ( SAL_name , "_Deref_ret_bound_" , "" , "1.1" ) _Group_impl_ ( _Deref_ret_bound_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_ret_bound_); }))) {
            mixin(enumMixinStr__Deref_ret_bound_);
        }
    }




    static if(!is(typeof(_Deref_out_))) {
        private enum enumMixinStr__Deref_out_ = `enum _Deref_out_ = _SA_annotes3 ( SAL_name , "_Deref_out_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Out_" , "" , "2" ) _Group_impl_ ( _Out_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _Deref_post_valid_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_out_); }))) {
            mixin(enumMixinStr__Deref_out_);
        }
    }




    static if(!is(typeof(_Deref_out_opt_))) {
        private enum enumMixinStr__Deref_out_opt_ = `enum _Deref_out_opt_ = _SA_annotes3 ( SAL_name , "_Deref_out_opt_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Out_" , "" , "2" ) _Group_impl_ ( _Out_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _Deref_post_opt_valid_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_out_opt_); }))) {
            mixin(enumMixinStr__Deref_out_opt_);
        }
    }




    static if(!is(typeof(_Deref_opt_out_))) {
        private enum enumMixinStr__Deref_opt_out_ = `enum _Deref_opt_out_ = _SA_annotes3 ( SAL_name , "_Deref_opt_out_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Out_opt_" , "" , "2" ) _Group_impl_ ( _Out_opt_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _Deref_post_valid_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_opt_out_); }))) {
            mixin(enumMixinStr__Deref_opt_out_);
        }
    }




    static if(!is(typeof(_Deref_opt_out_opt_))) {
        private enum enumMixinStr__Deref_opt_out_opt_ = `enum _Deref_opt_out_opt_ = _SA_annotes3 ( SAL_name , "_Deref_opt_out_opt_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Out_opt_" , "" , "2" ) _Group_impl_ ( _Out_opt_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _Deref_post_opt_valid_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_opt_out_opt_); }))) {
            mixin(enumMixinStr__Deref_opt_out_opt_);
        }
    }




    static if(!is(typeof(_Deref_out_z_))) {
        private enum enumMixinStr__Deref_out_z_ = `enum _Deref_out_z_ = _SA_annotes3 ( SAL_name , "_Deref_out_z_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Out_" , "" , "2" ) _Group_impl_ ( _Out_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _Deref_post_z_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_out_z_); }))) {
            mixin(enumMixinStr__Deref_out_z_);
        }
    }




    static if(!is(typeof(_Deref_out_opt_z_))) {
        private enum enumMixinStr__Deref_out_opt_z_ = `enum _Deref_out_opt_z_ = _SA_annotes3 ( SAL_name , "_Deref_out_opt_z_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Out_" , "" , "2" ) _Group_impl_ ( _Out_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _Deref_post_opt_z_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_out_opt_z_); }))) {
            mixin(enumMixinStr__Deref_out_opt_z_);
        }
    }




    static if(!is(typeof(_Deref_opt_out_z_))) {
        private enum enumMixinStr__Deref_opt_out_z_ = `enum _Deref_opt_out_z_ = _SA_annotes3 ( SAL_name , "_Deref_opt_out_z_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Out_opt_" , "" , "2" ) _Group_impl_ ( _Out_opt_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _Deref_post_z_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_opt_out_z_); }))) {
            mixin(enumMixinStr__Deref_opt_out_z_);
        }
    }




    static if(!is(typeof(_Deref_opt_out_opt_z_))) {
        private enum enumMixinStr__Deref_opt_out_opt_z_ = `enum _Deref_opt_out_opt_z_ = _SA_annotes3 ( SAL_name , "_Deref_opt_out_opt_z_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Out_opt_" , "" , "2" ) _Group_impl_ ( _Out_opt_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _Deref_post_opt_z_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_opt_out_opt_z_); }))) {
            mixin(enumMixinStr__Deref_opt_out_opt_z_);
        }
    }




    static if(!is(typeof(_Deref_pre_z_))) {
        private enum enumMixinStr__Deref_pre_z_ = `enum _Deref_pre_z_ = _SA_annotes3 ( SAL_name , "_Deref_pre_z_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __notnull_impl_notref ) _Deref_pre1_impl_ ( __zterm_impl ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_pre_z_); }))) {
            mixin(enumMixinStr__Deref_pre_z_);
        }
    }




    static if(!is(typeof(_Deref_pre_opt_z_))) {
        private enum enumMixinStr__Deref_pre_opt_z_ = `enum _Deref_pre_opt_z_ = _SA_annotes3 ( SAL_name , "_Deref_pre_opt_z_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __maybenull_impl_notref ) _Deref_pre1_impl_ ( __zterm_impl ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_pre_opt_z_); }))) {
            mixin(enumMixinStr__Deref_pre_opt_z_);
        }
    }
    static if(!is(typeof(_Deref_pre_valid_))) {
        private enum enumMixinStr__Deref_pre_valid_ = `enum _Deref_pre_valid_ = _SA_annotes3 ( SAL_name , "_Deref_pre_valid_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __notnull_impl_notref ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_pre_valid_); }))) {
            mixin(enumMixinStr__Deref_pre_valid_);
        }
    }




    static if(!is(typeof(_Deref_pre_opt_valid_))) {
        private enum enumMixinStr__Deref_pre_opt_valid_ = `enum _Deref_pre_opt_valid_ = _SA_annotes3 ( SAL_name , "_Deref_pre_opt_valid_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __maybenull_impl_notref ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_pre_opt_valid_); }))) {
            mixin(enumMixinStr__Deref_pre_opt_valid_);
        }
    }




    static if(!is(typeof(_Deref_pre_invalid_))) {
        private enum enumMixinStr__Deref_pre_invalid_ = `enum _Deref_pre_invalid_ = _SA_annotes3 ( SAL_name , "_Deref_pre_invalid_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __notvalid_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_pre_invalid_); }))) {
            mixin(enumMixinStr__Deref_pre_invalid_);
        }
    }




    static if(!is(typeof(_Deref_pre_notnull_))) {
        private enum enumMixinStr__Deref_pre_notnull_ = `enum _Deref_pre_notnull_ = _SA_annotes3 ( SAL_name , "_Deref_pre_notnull_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __notnull_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_pre_notnull_); }))) {
            mixin(enumMixinStr__Deref_pre_notnull_);
        }
    }




    static if(!is(typeof(_Deref_pre_maybenull_))) {
        private enum enumMixinStr__Deref_pre_maybenull_ = `enum _Deref_pre_maybenull_ = _SA_annotes3 ( SAL_name , "_Deref_pre_maybenull_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __maybenull_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_pre_maybenull_); }))) {
            mixin(enumMixinStr__Deref_pre_maybenull_);
        }
    }




    static if(!is(typeof(_Deref_pre_null_))) {
        private enum enumMixinStr__Deref_pre_null_ = `enum _Deref_pre_null_ = _SA_annotes3 ( SAL_name , "_Deref_pre_null_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __null_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_pre_null_); }))) {
            mixin(enumMixinStr__Deref_pre_null_);
        }
    }




    static if(!is(typeof(_Deref_pre_readonly_))) {
        private enum enumMixinStr__Deref_pre_readonly_ = `enum _Deref_pre_readonly_ = _SA_annotes3 ( SAL_name , "_Deref_pre_readonly_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __readaccess_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_pre_readonly_); }))) {
            mixin(enumMixinStr__Deref_pre_readonly_);
        }
    }




    static if(!is(typeof(_Deref_pre_writeonly_))) {
        private enum enumMixinStr__Deref_pre_writeonly_ = `enum _Deref_pre_writeonly_ = _SA_annotes3 ( SAL_name , "_Deref_pre_writeonly_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __writeaccess_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_pre_writeonly_); }))) {
            mixin(enumMixinStr__Deref_pre_writeonly_);
        }
    }




    static if(!is(typeof(_Deref_post_z_))) {
        private enum enumMixinStr__Deref_post_z_ = `enum _Deref_post_z_ = _SA_annotes3 ( SAL_name , "_Deref_post_z_" , "" , "1.1" ) _Group_impl_ ( _Deref_post1_impl_ ( __notnull_impl_notref ) _Deref_post1_impl_ ( __zterm_impl ) _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_post_z_); }))) {
            mixin(enumMixinStr__Deref_post_z_);
        }
    }




    static if(!is(typeof(_Deref_post_opt_z_))) {
        private enum enumMixinStr__Deref_post_opt_z_ = `enum _Deref_post_opt_z_ = _SA_annotes3 ( SAL_name , "_Deref_post_opt_z_" , "" , "1.1" ) _Group_impl_ ( _Deref_post1_impl_ ( __maybenull_impl_notref ) _Deref_post1_impl_ ( __zterm_impl ) _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_post_opt_z_); }))) {
            mixin(enumMixinStr__Deref_post_opt_z_);
        }
    }
    static if(!is(typeof(_Deref_post_valid_))) {
        private enum enumMixinStr__Deref_post_valid_ = `enum _Deref_post_valid_ = _SA_annotes3 ( SAL_name , "_Deref_post_valid_" , "" , "1.1" ) _Group_impl_ ( _Deref_post1_impl_ ( __notnull_impl_notref ) _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_post_valid_); }))) {
            mixin(enumMixinStr__Deref_post_valid_);
        }
    }




    static if(!is(typeof(_Deref_post_opt_valid_))) {
        private enum enumMixinStr__Deref_post_opt_valid_ = `enum _Deref_post_opt_valid_ = _SA_annotes3 ( SAL_name , "_Deref_post_opt_valid_" , "" , "1.1" ) _Group_impl_ ( _Deref_post1_impl_ ( __maybenull_impl_notref ) _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_post_opt_valid_); }))) {
            mixin(enumMixinStr__Deref_post_opt_valid_);
        }
    }




    static if(!is(typeof(_Deref_post_notnull_))) {
        private enum enumMixinStr__Deref_post_notnull_ = `enum _Deref_post_notnull_ = _SA_annotes3 ( SAL_name , "_Deref_post_notnull_" , "" , "1.1" ) _Group_impl_ ( _Deref_post1_impl_ ( __notnull_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_post_notnull_); }))) {
            mixin(enumMixinStr__Deref_post_notnull_);
        }
    }




    static if(!is(typeof(_Deref_post_maybenull_))) {
        private enum enumMixinStr__Deref_post_maybenull_ = `enum _Deref_post_maybenull_ = _SA_annotes3 ( SAL_name , "_Deref_post_maybenull_" , "" , "1.1" ) _Group_impl_ ( _Deref_post1_impl_ ( __maybenull_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_post_maybenull_); }))) {
            mixin(enumMixinStr__Deref_post_maybenull_);
        }
    }




    static if(!is(typeof(_Deref_post_null_))) {
        private enum enumMixinStr__Deref_post_null_ = `enum _Deref_post_null_ = _SA_annotes3 ( SAL_name , "_Deref_post_null_" , "" , "1.1" ) _Group_impl_ ( _Deref_post1_impl_ ( __null_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_post_null_); }))) {
            mixin(enumMixinStr__Deref_post_null_);
        }
    }




    static if(!is(typeof(_Deref_ret_z_))) {
        private enum enumMixinStr__Deref_ret_z_ = `enum _Deref_ret_z_ = _SA_annotes3 ( SAL_name , "_Deref_ret_z_" , "" , "1.1" ) _Group_impl_ ( _Deref_ret1_impl_ ( __notnull_impl_notref ) _Deref_ret1_impl_ ( __zterm_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_ret_z_); }))) {
            mixin(enumMixinStr__Deref_ret_z_);
        }
    }




    static if(!is(typeof(_Deref_ret_opt_z_))) {
        private enum enumMixinStr__Deref_ret_opt_z_ = `enum _Deref_ret_opt_z_ = _SA_annotes3 ( SAL_name , "_Deref_ret_opt_z_" , "" , "1.1" ) _Group_impl_ ( _Deref_ret1_impl_ ( __maybenull_impl_notref ) _Ret1_impl_ ( __zterm_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_ret_opt_z_); }))) {
            mixin(enumMixinStr__Deref_ret_opt_z_);
        }
    }




    static if(!is(typeof(_Deref2_pre_readonly_))) {
        private enum enumMixinStr__Deref2_pre_readonly_ = `enum _Deref2_pre_readonly_ = _SA_annotes3 ( SAL_name , "_Deref2_pre_readonly_" , "" , "1.1" ) _Group_impl_ ( _Deref2_pre1_impl_ ( __readaccess_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref2_pre_readonly_); }))) {
            mixin(enumMixinStr__Deref2_pre_readonly_);
        }
    }




    static if(!is(typeof(_Ret_opt_valid_))) {
        private enum enumMixinStr__Ret_opt_valid_ = `enum _Ret_opt_valid_ = _SA_annotes3 ( SAL_name , "_Ret_opt_valid_" , "" , "1.1" ) _Group_impl_ ( _Ret1_impl_ ( __maybenull_impl_notref ) _Ret_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Ret_opt_valid_); }))) {
            mixin(enumMixinStr__Ret_opt_valid_);
        }
    }




    static if(!is(typeof(_Ret_opt_z_))) {
        private enum enumMixinStr__Ret_opt_z_ = `enum _Ret_opt_z_ = _SA_annotes3 ( SAL_name , "_Ret_opt_z_" , "" , "1.1" ) _Group_impl_ ( _Ret2_impl_ ( __maybenull_impl , __zterm_impl ) _Ret_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Ret_opt_z_); }))) {
            mixin(enumMixinStr__Ret_opt_z_);
        }
    }
    static if(!is(typeof(_Pre_opt_z_))) {
        private enum enumMixinStr__Pre_opt_z_ = `enum _Pre_opt_z_ = _SA_annotes3 ( SAL_name , "_Pre_opt_z_" , "" , "1.1" ) _Group_impl_ ( _Pre1_impl_ ( __maybenull_impl_notref ) _Pre1_impl_ ( __zterm_impl ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_opt_z_); }))) {
            mixin(enumMixinStr__Pre_opt_z_);
        }
    }




    static if(!is(typeof(_Pre_readonly_))) {
        private enum enumMixinStr__Pre_readonly_ = `enum _Pre_readonly_ = _SA_annotes3 ( SAL_name , "_Pre_readonly_" , "" , "1.1" ) _Group_impl_ ( _Pre1_impl_ ( __readaccess_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_readonly_); }))) {
            mixin(enumMixinStr__Pre_readonly_);
        }
    }




    static if(!is(typeof(_Pre_writeonly_))) {
        private enum enumMixinStr__Pre_writeonly_ = `enum _Pre_writeonly_ = _SA_annotes3 ( SAL_name , "_Pre_writeonly_" , "" , "1.1" ) _Group_impl_ ( _Pre1_impl_ ( __writeaccess_impl_notref ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_writeonly_); }))) {
            mixin(enumMixinStr__Pre_writeonly_);
        }
    }
    static if(!is(typeof(_Pre_cap_c_one_))) {
        private enum enumMixinStr__Pre_cap_c_one_ = `enum _Pre_cap_c_one_ = _SA_annotes3 ( SAL_name , "_Pre_cap_c_one_" , "" , "1.1" ) _Group_impl_ ( _Pre1_impl_ ( __notnull_impl_notref ) _Pre1_impl_ ( __cap_c_one_notref_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_cap_c_one_); }))) {
            mixin(enumMixinStr__Pre_cap_c_one_);
        }
    }




    static if(!is(typeof(_Pre_opt_cap_c_one_))) {
        private enum enumMixinStr__Pre_opt_cap_c_one_ = `enum _Pre_opt_cap_c_one_ = _SA_annotes3 ( SAL_name , "_Pre_opt_cap_c_one_" , "" , "1.1" ) _Group_impl_ ( _Pre1_impl_ ( __maybenull_impl_notref ) _Pre1_impl_ ( __cap_c_one_notref_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Pre_opt_cap_c_one_); }))) {
            mixin(enumMixinStr__Pre_opt_cap_c_one_);
        }
    }
    static if(!is(typeof(_Post_maybez_))) {
        private enum enumMixinStr__Post_maybez_ = `enum _Post_maybez_ = _SA_annotes3 ( SAL_name , "_Post_maybez_" , "" , "2" ) _Group_impl_ ( _Post1_impl_ ( __maybezterm_impl ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Post_maybez_); }))) {
            mixin(enumMixinStr__Post_maybez_);
        }
    }
    static if(!is(typeof(_Prepost_opt_z_))) {
        private enum enumMixinStr__Prepost_opt_z_ = `enum _Prepost_opt_z_ = _SA_annotes3 ( SAL_name , "_Prepost_opt_z_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Pre_opt_z_" , "" , "1.1" ) _Group_impl_ ( _Pre1_impl_ ( __maybenull_impl_notref ) _Pre1_impl_ ( __zterm_impl ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SA_annotes3 ( SAL_name , "_Post_z_" , "" , "2" ) _Group_impl_ ( _Post1_impl_ ( __zterm_impl ) _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Prepost_opt_z_); }))) {
            mixin(enumMixinStr__Prepost_opt_z_);
        }
    }
    static if(!is(typeof(_Prepost_valid_))) {
        private enum enumMixinStr__Prepost_valid_ = `enum _Prepost_valid_ = _SA_annotes3 ( SAL_name , "_Prepost_valid_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Pre_valid_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __notnull_impl_notref ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SA_annotes3 ( SAL_name , "_Post_valid_" , "" , "2" ) _Group_impl_ ( _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Prepost_valid_); }))) {
            mixin(enumMixinStr__Prepost_valid_);
        }
    }




    static if(!is(typeof(_Prepost_opt_valid_))) {
        private enum enumMixinStr__Prepost_opt_valid_ = `enum _Prepost_opt_valid_ = _SA_annotes3 ( SAL_name , "_Prepost_opt_valid_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Pre_opt_valid_" , "" , "2" ) _Group_impl_ ( _Pre1_impl_ ( __maybenull_impl_notref ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SA_annotes3 ( SAL_name , "_Post_valid_" , "" , "2" ) _Group_impl_ ( _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Prepost_opt_valid_); }))) {
            mixin(enumMixinStr__Prepost_opt_valid_);
        }
    }




    static if(!is(typeof(_Deref_prepost_z_))) {
        private enum enumMixinStr__Deref_prepost_z_ = `enum _Deref_prepost_z_ = _SA_annotes3 ( SAL_name , "_Deref_prepost_z_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Deref_pre_z_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __notnull_impl_notref ) _Deref_pre1_impl_ ( __zterm_impl ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SA_annotes3 ( SAL_name , "_Deref_post_z_" , "" , "1.1" ) _Group_impl_ ( _Deref_post1_impl_ ( __notnull_impl_notref ) _Deref_post1_impl_ ( __zterm_impl ) _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_prepost_z_); }))) {
            mixin(enumMixinStr__Deref_prepost_z_);
        }
    }




    static if(!is(typeof(_Deref_prepost_opt_z_))) {
        private enum enumMixinStr__Deref_prepost_opt_z_ = `enum _Deref_prepost_opt_z_ = _SA_annotes3 ( SAL_name , "_Deref_prepost_opt_z_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Deref_pre_opt_z_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __maybenull_impl_notref ) _Deref_pre1_impl_ ( __zterm_impl ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SA_annotes3 ( SAL_name , "_Deref_post_opt_z_" , "" , "1.1" ) _Group_impl_ ( _Deref_post1_impl_ ( __maybenull_impl_notref ) _Deref_post1_impl_ ( __zterm_impl ) _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_prepost_opt_z_); }))) {
            mixin(enumMixinStr__Deref_prepost_opt_z_);
        }
    }
    static if(!is(typeof(_Deref_prepost_valid_))) {
        private enum enumMixinStr__Deref_prepost_valid_ = `enum _Deref_prepost_valid_ = _SA_annotes3 ( SAL_name , "_Deref_prepost_valid_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Deref_pre_valid_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __notnull_impl_notref ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SA_annotes3 ( SAL_name , "_Deref_post_valid_" , "" , "1.1" ) _Group_impl_ ( _Deref_post1_impl_ ( __notnull_impl_notref ) _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_prepost_valid_); }))) {
            mixin(enumMixinStr__Deref_prepost_valid_);
        }
    }




    static if(!is(typeof(_Deref_prepost_opt_valid_))) {
        private enum enumMixinStr__Deref_prepost_opt_valid_ = `enum _Deref_prepost_opt_valid_ = _SA_annotes3 ( SAL_name , "_Deref_prepost_opt_valid_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Deref_pre_opt_valid_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __maybenull_impl_notref ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SA_annotes3 ( SAL_name , "_Deref_post_opt_valid_" , "" , "1.1" ) _Group_impl_ ( _Deref_post1_impl_ ( __maybenull_impl_notref ) _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_prepost_opt_valid_); }))) {
            mixin(enumMixinStr__Deref_prepost_opt_valid_);
        }
    }
    static if(!is(typeof(_Deref_inout_z_))) {
        private enum enumMixinStr__Deref_inout_z_ = `enum _Deref_inout_z_ = _SA_annotes3 ( SAL_name , "_Deref_inout_z_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Deref_prepost_z_" , "" , "1.1" ) _Group_impl_ ( _SA_annotes3 ( SAL_name , "_Deref_pre_z_" , "" , "1.1" ) _Group_impl_ ( _Deref_pre1_impl_ ( __notnull_impl_notref ) _Deref_pre1_impl_ ( __zterm_impl ) _Pre_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SA_annotes3 ( SAL_name , "_Deref_post_z_" , "" , "1.1" ) _Group_impl_ ( _Deref_post1_impl_ ( __notnull_impl_notref ) _Deref_post1_impl_ ( __zterm_impl ) _Post_valid_impl_ _SAL_nop_impl_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ ) _SAL_nop_impl_ _SAL_nop_impl_ );`;
        static if(is(typeof({ mixin(enumMixinStr__Deref_inout_z_); }))) {
            mixin(enumMixinStr__Deref_inout_z_);
        }
    }
    static if(!is(typeof(_SAL_nop_impl_))) {
        private enum enumMixinStr__SAL_nop_impl_ = `enum _SAL_nop_impl_ = X;`;
        static if(is(typeof({ mixin(enumMixinStr__SAL_nop_impl_); }))) {
            mixin(enumMixinStr__SAL_nop_impl_);
        }
    }
    static if(!is(typeof(__in))) {
        private enum enumMixinStr___in = `enum __in = ;`;
        static if(is(typeof({ mixin(enumMixinStr___in); }))) {
            mixin(enumMixinStr___in);
        }
    }
    static if(!is(typeof(__in_z))) {
        private enum enumMixinStr___in_z = `enum __in_z = ;`;
        static if(is(typeof({ mixin(enumMixinStr___in_z); }))) {
            mixin(enumMixinStr___in_z);
        }
    }
    static if(!is(typeof(__in_nz))) {
        private enum enumMixinStr___in_nz = `enum __in_nz = ;`;
        static if(is(typeof({ mixin(enumMixinStr___in_nz); }))) {
            mixin(enumMixinStr___in_nz);
        }
    }
    static if(!is(typeof(__out))) {
        private enum enumMixinStr___out = `enum __out = ;`;
        static if(is(typeof({ mixin(enumMixinStr___out); }))) {
            mixin(enumMixinStr___out);
        }
    }
    static if(!is(typeof(__out_z))) {
        private enum enumMixinStr___out_z = `enum __out_z = ;`;
        static if(is(typeof({ mixin(enumMixinStr___out_z); }))) {
            mixin(enumMixinStr___out_z);
        }
    }




    static if(!is(typeof(__out_z_opt))) {
        private enum enumMixinStr___out_z_opt = `enum __out_z_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___out_z_opt); }))) {
            mixin(enumMixinStr___out_z_opt);
        }
    }
    static if(!is(typeof(__out_nz))) {
        private enum enumMixinStr___out_nz = `enum __out_nz = ;`;
        static if(is(typeof({ mixin(enumMixinStr___out_nz); }))) {
            mixin(enumMixinStr___out_nz);
        }
    }




    static if(!is(typeof(__out_nz_opt))) {
        private enum enumMixinStr___out_nz_opt = `enum __out_nz_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___out_nz_opt); }))) {
            mixin(enumMixinStr___out_nz_opt);
        }
    }
    static if(!is(typeof(__inout))) {
        private enum enumMixinStr___inout = `enum __inout = ;`;
        static if(is(typeof({ mixin(enumMixinStr___inout); }))) {
            mixin(enumMixinStr___inout);
        }
    }
    static if(!is(typeof(__inout_z))) {
        private enum enumMixinStr___inout_z = `enum __inout_z = ;`;
        static if(is(typeof({ mixin(enumMixinStr___inout_z); }))) {
            mixin(enumMixinStr___inout_z);
        }
    }
    static if(!is(typeof(__inout_nz))) {
        private enum enumMixinStr___inout_nz = `enum __inout_nz = ;`;
        static if(is(typeof({ mixin(enumMixinStr___inout_nz); }))) {
            mixin(enumMixinStr___inout_nz);
        }
    }
    static if(!is(typeof(__in_opt))) {
        private enum enumMixinStr___in_opt = `enum __in_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___in_opt); }))) {
            mixin(enumMixinStr___in_opt);
        }
    }
    static if(!is(typeof(__in_z_opt))) {
        private enum enumMixinStr___in_z_opt = `enum __in_z_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___in_z_opt); }))) {
            mixin(enumMixinStr___in_z_opt);
        }
    }
    static if(!is(typeof(__in_nz_opt))) {
        private enum enumMixinStr___in_nz_opt = `enum __in_nz_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___in_nz_opt); }))) {
            mixin(enumMixinStr___in_nz_opt);
        }
    }
    static if(!is(typeof(__out_opt))) {
        private enum enumMixinStr___out_opt = `enum __out_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___out_opt); }))) {
            mixin(enumMixinStr___out_opt);
        }
    }
    static if(!is(typeof(__inout_opt))) {
        private enum enumMixinStr___inout_opt = `enum __inout_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___inout_opt); }))) {
            mixin(enumMixinStr___inout_opt);
        }
    }
    static if(!is(typeof(__inout_z_opt))) {
        private enum enumMixinStr___inout_z_opt = `enum __inout_z_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___inout_z_opt); }))) {
            mixin(enumMixinStr___inout_z_opt);
        }
    }
    static if(!is(typeof(__inout_nz_opt))) {
        private enum enumMixinStr___inout_nz_opt = `enum __inout_nz_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___inout_nz_opt); }))) {
            mixin(enumMixinStr___inout_nz_opt);
        }
    }
    static if(!is(typeof(__deref_out))) {
        private enum enumMixinStr___deref_out = `enum __deref_out = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_out); }))) {
            mixin(enumMixinStr___deref_out);
        }
    }
    static if(!is(typeof(__deref_out_z))) {
        private enum enumMixinStr___deref_out_z = `enum __deref_out_z = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_out_z); }))) {
            mixin(enumMixinStr___deref_out_z);
        }
    }
    static if(!is(typeof(__deref_out_nz))) {
        private enum enumMixinStr___deref_out_nz = `enum __deref_out_nz = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_out_nz); }))) {
            mixin(enumMixinStr___deref_out_nz);
        }
    }
    static if(!is(typeof(__deref_inout))) {
        private enum enumMixinStr___deref_inout = `enum __deref_inout = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_inout); }))) {
            mixin(enumMixinStr___deref_inout);
        }
    }




    static if(!is(typeof(__deref_inout_z))) {
        private enum enumMixinStr___deref_inout_z = `enum __deref_inout_z = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_inout_z); }))) {
            mixin(enumMixinStr___deref_inout_z);
        }
    }
    static if(!is(typeof(__deref_inout_nz))) {
        private enum enumMixinStr___deref_inout_nz = `enum __deref_inout_nz = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_inout_nz); }))) {
            mixin(enumMixinStr___deref_inout_nz);
        }
    }
    static if(!is(typeof(__deref_out_opt))) {
        private enum enumMixinStr___deref_out_opt = `enum __deref_out_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_out_opt); }))) {
            mixin(enumMixinStr___deref_out_opt);
        }
    }
    static if(!is(typeof(__deref_out_z_opt))) {
        private enum enumMixinStr___deref_out_z_opt = `enum __deref_out_z_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_out_z_opt); }))) {
            mixin(enumMixinStr___deref_out_z_opt);
        }
    }
    static if(!is(typeof(__deref_out_nz_opt))) {
        private enum enumMixinStr___deref_out_nz_opt = `enum __deref_out_nz_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_out_nz_opt); }))) {
            mixin(enumMixinStr___deref_out_nz_opt);
        }
    }
    static if(!is(typeof(__deref_inout_opt))) {
        private enum enumMixinStr___deref_inout_opt = `enum __deref_inout_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_inout_opt); }))) {
            mixin(enumMixinStr___deref_inout_opt);
        }
    }
    static if(!is(typeof(__deref_inout_z_opt))) {
        private enum enumMixinStr___deref_inout_z_opt = `enum __deref_inout_z_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_inout_z_opt); }))) {
            mixin(enumMixinStr___deref_inout_z_opt);
        }
    }
    static if(!is(typeof(__deref_inout_nz_opt))) {
        private enum enumMixinStr___deref_inout_nz_opt = `enum __deref_inout_nz_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_inout_nz_opt); }))) {
            mixin(enumMixinStr___deref_inout_nz_opt);
        }
    }
    static if(!is(typeof(__deref_opt_out))) {
        private enum enumMixinStr___deref_opt_out = `enum __deref_opt_out = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_opt_out); }))) {
            mixin(enumMixinStr___deref_opt_out);
        }
    }




    static if(!is(typeof(__deref_opt_out_z))) {
        private enum enumMixinStr___deref_opt_out_z = `enum __deref_opt_out_z = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_opt_out_z); }))) {
            mixin(enumMixinStr___deref_opt_out_z);
        }
    }
    static if(!is(typeof(__deref_opt_inout))) {
        private enum enumMixinStr___deref_opt_inout = `enum __deref_opt_inout = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_opt_inout); }))) {
            mixin(enumMixinStr___deref_opt_inout);
        }
    }
    static if(!is(typeof(__deref_opt_inout_z))) {
        private enum enumMixinStr___deref_opt_inout_z = `enum __deref_opt_inout_z = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_opt_inout_z); }))) {
            mixin(enumMixinStr___deref_opt_inout_z);
        }
    }
    static if(!is(typeof(__deref_opt_inout_nz))) {
        private enum enumMixinStr___deref_opt_inout_nz = `enum __deref_opt_inout_nz = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_opt_inout_nz); }))) {
            mixin(enumMixinStr___deref_opt_inout_nz);
        }
    }
    static if(!is(typeof(__deref_opt_out_opt))) {
        private enum enumMixinStr___deref_opt_out_opt = `enum __deref_opt_out_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_opt_out_opt); }))) {
            mixin(enumMixinStr___deref_opt_out_opt);
        }
    }
    static if(!is(typeof(__deref_opt_out_z_opt))) {
        private enum enumMixinStr___deref_opt_out_z_opt = `enum __deref_opt_out_z_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_opt_out_z_opt); }))) {
            mixin(enumMixinStr___deref_opt_out_z_opt);
        }
    }
    static if(!is(typeof(__deref_opt_out_nz_opt))) {
        private enum enumMixinStr___deref_opt_out_nz_opt = `enum __deref_opt_out_nz_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_opt_out_nz_opt); }))) {
            mixin(enumMixinStr___deref_opt_out_nz_opt);
        }
    }
    static if(!is(typeof(__deref_opt_inout_opt))) {
        private enum enumMixinStr___deref_opt_inout_opt = `enum __deref_opt_inout_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_opt_inout_opt); }))) {
            mixin(enumMixinStr___deref_opt_inout_opt);
        }
    }
    static if(!is(typeof(__deref_opt_inout_z_opt))) {
        private enum enumMixinStr___deref_opt_inout_z_opt = `enum __deref_opt_inout_z_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_opt_inout_z_opt); }))) {
            mixin(enumMixinStr___deref_opt_inout_z_opt);
        }
    }
    static if(!is(typeof(__deref_opt_inout_nz_opt))) {
        private enum enumMixinStr___deref_opt_inout_nz_opt = `enum __deref_opt_inout_nz_opt = ;`;
        static if(is(typeof({ mixin(enumMixinStr___deref_opt_inout_nz_opt); }))) {
            mixin(enumMixinStr___deref_opt_inout_nz_opt);
        }
    }
    static if(!is(typeof(__nullterminated))) {
        private enum enumMixinStr___nullterminated = `enum __nullterminated = ;`;
        static if(is(typeof({ mixin(enumMixinStr___nullterminated); }))) {
            mixin(enumMixinStr___nullterminated);
        }
    }




    static if(!is(typeof(__nullnullterminated))) {
        private enum enumMixinStr___nullnullterminated = `enum __nullnullterminated = ;`;
        static if(is(typeof({ mixin(enumMixinStr___nullnullterminated); }))) {
            mixin(enumMixinStr___nullnullterminated);
        }
    }




    static if(!is(typeof(__reserved))) {
        private enum enumMixinStr___reserved = `enum __reserved = ;`;
        static if(is(typeof({ mixin(enumMixinStr___reserved); }))) {
            mixin(enumMixinStr___reserved);
        }
    }




    static if(!is(typeof(__checkReturn))) {
        private enum enumMixinStr___checkReturn = `enum __checkReturn = ;`;
        static if(is(typeof({ mixin(enumMixinStr___checkReturn); }))) {
            mixin(enumMixinStr___checkReturn);
        }
    }






    static if(!is(typeof(__override))) {
        private enum enumMixinStr___override = `enum __override = ;`;
        static if(is(typeof({ mixin(enumMixinStr___override); }))) {
            mixin(enumMixinStr___override);
        }
    }




    static if(!is(typeof(__callback))) {
        private enum enumMixinStr___callback = `enum __callback = ;`;
        static if(is(typeof({ mixin(enumMixinStr___callback); }))) {
            mixin(enumMixinStr___callback);
        }
    }




    static if(!is(typeof(__format_string))) {
        private enum enumMixinStr___format_string = `enum __format_string = ;`;
        static if(is(typeof({ mixin(enumMixinStr___format_string); }))) {
            mixin(enumMixinStr___format_string);
        }
    }
    static if(!is(typeof(__useHeader))) {
        private enum enumMixinStr___useHeader = `enum __useHeader = ;`;
        static if(is(typeof({ mixin(enumMixinStr___useHeader); }))) {
            mixin(enumMixinStr___useHeader);
        }
    }






    static if(!is(typeof(__fallthrough))) {
        private enum enumMixinStr___fallthrough = `enum __fallthrough = ;`;
        static if(is(typeof({ mixin(enumMixinStr___fallthrough); }))) {
            mixin(enumMixinStr___fallthrough);
        }
    }
    static if(!is(typeof(_Analysis_noreturn_))) {
        private enum enumMixinStr__Analysis_noreturn_ = `enum _Analysis_noreturn_ = ;`;
        static if(is(typeof({ mixin(enumMixinStr__Analysis_noreturn_); }))) {
            mixin(enumMixinStr__Analysis_noreturn_);
        }
    }
    static if(!is(typeof(_Enum_is_bitflag_))) {
        private enum enumMixinStr__Enum_is_bitflag_ = `enum _Enum_is_bitflag_ = ;`;
        static if(is(typeof({ mixin(enumMixinStr__Enum_is_bitflag_); }))) {
            mixin(enumMixinStr__Enum_is_bitflag_);
        }
    }




    static if(!is(typeof(_Strict_type_match_))) {
        private enum enumMixinStr__Strict_type_match_ = `enum _Strict_type_match_ = ;`;
        static if(is(typeof({ mixin(enumMixinStr__Strict_type_match_); }))) {
            mixin(enumMixinStr__Strict_type_match_);
        }
    }




    static if(!is(typeof(_Maybe_raises_SEH_exception_))) {
        private enum enumMixinStr__Maybe_raises_SEH_exception_ = `enum _Maybe_raises_SEH_exception_ = ;`;
        static if(is(typeof({ mixin(enumMixinStr__Maybe_raises_SEH_exception_); }))) {
            mixin(enumMixinStr__Maybe_raises_SEH_exception_);
        }
    }




    static if(!is(typeof(_Raises_SEH_exception_))) {
        private enum enumMixinStr__Raises_SEH_exception_ = `enum _Raises_SEH_exception_ = ;`;
        static if(is(typeof({ mixin(enumMixinStr__Raises_SEH_exception_); }))) {
            mixin(enumMixinStr__Raises_SEH_exception_);
        }
    }






    static if(!is(typeof(INT8_MIN))) {
        private enum enumMixinStr_INT8_MIN = `enum INT8_MIN = ( - 127i8 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_INT8_MIN); }))) {
            mixin(enumMixinStr_INT8_MIN);
        }
    }




    static if(!is(typeof(INT16_MIN))) {
        private enum enumMixinStr_INT16_MIN = `enum INT16_MIN = ( - 32767i16 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_INT16_MIN); }))) {
            mixin(enumMixinStr_INT16_MIN);
        }
    }




    static if(!is(typeof(INT32_MIN))) {
        private enum enumMixinStr_INT32_MIN = `enum INT32_MIN = ( - 2147483647i32 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_INT32_MIN); }))) {
            mixin(enumMixinStr_INT32_MIN);
        }
    }




    static if(!is(typeof(INT64_MIN))) {
        private enum enumMixinStr_INT64_MIN = `enum INT64_MIN = ( - 9223372036854775807i64 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_INT64_MIN); }))) {
            mixin(enumMixinStr_INT64_MIN);
        }
    }




    static if(!is(typeof(INT8_MAX))) {
        private enum enumMixinStr_INT8_MAX = `enum INT8_MAX = 12;`;
        static if(is(typeof({ mixin(enumMixinStr_INT8_MAX); }))) {
            mixin(enumMixinStr_INT8_MAX);
        }
    }




    static if(!is(typeof(INT16_MAX))) {
        private enum enumMixinStr_INT16_MAX = `enum INT16_MAX = 32767;`;
        static if(is(typeof({ mixin(enumMixinStr_INT16_MAX); }))) {
            mixin(enumMixinStr_INT16_MAX);
        }
    }




    static if(!is(typeof(INT32_MAX))) {
        private enum enumMixinStr_INT32_MAX = `enum INT32_MAX = 2147483647;`;
        static if(is(typeof({ mixin(enumMixinStr_INT32_MAX); }))) {
            mixin(enumMixinStr_INT32_MAX);
        }
    }




    static if(!is(typeof(INT64_MAX))) {
        private enum enumMixinStr_INT64_MAX = `enum INT64_MAX = 9223372036854775807L;`;
        static if(is(typeof({ mixin(enumMixinStr_INT64_MAX); }))) {
            mixin(enumMixinStr_INT64_MAX);
        }
    }




    static if(!is(typeof(UINT8_MAX))) {
        private enum enumMixinStr_UINT8_MAX = `enum UINT8_MAX = 0xff;`;
        static if(is(typeof({ mixin(enumMixinStr_UINT8_MAX); }))) {
            mixin(enumMixinStr_UINT8_MAX);
        }
    }




    static if(!is(typeof(UINT16_MAX))) {
        private enum enumMixinStr_UINT16_MAX = `enum UINT16_MAX = 0xffffu;`;
        static if(is(typeof({ mixin(enumMixinStr_UINT16_MAX); }))) {
            mixin(enumMixinStr_UINT16_MAX);
        }
    }




    static if(!is(typeof(UINT32_MAX))) {
        private enum enumMixinStr_UINT32_MAX = `enum UINT32_MAX = 0xffffffffu;`;
        static if(is(typeof({ mixin(enumMixinStr_UINT32_MAX); }))) {
            mixin(enumMixinStr_UINT32_MAX);
        }
    }




    static if(!is(typeof(UINT64_MAX))) {
        private enum enumMixinStr_UINT64_MAX = `enum UINT64_MAX = 0xffffffffffffffffuL;`;
        static if(is(typeof({ mixin(enumMixinStr_UINT64_MAX); }))) {
            mixin(enumMixinStr_UINT64_MAX);
        }
    }




    static if(!is(typeof(INT_LEAST8_MIN))) {
        private enum enumMixinStr_INT_LEAST8_MIN = `enum INT_LEAST8_MIN = ( - 127i8 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_INT_LEAST8_MIN); }))) {
            mixin(enumMixinStr_INT_LEAST8_MIN);
        }
    }




    static if(!is(typeof(INT_LEAST16_MIN))) {
        private enum enumMixinStr_INT_LEAST16_MIN = `enum INT_LEAST16_MIN = ( - 32767i16 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_INT_LEAST16_MIN); }))) {
            mixin(enumMixinStr_INT_LEAST16_MIN);
        }
    }




    static if(!is(typeof(INT_LEAST32_MIN))) {
        private enum enumMixinStr_INT_LEAST32_MIN = `enum INT_LEAST32_MIN = ( - 2147483647i32 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_INT_LEAST32_MIN); }))) {
            mixin(enumMixinStr_INT_LEAST32_MIN);
        }
    }




    static if(!is(typeof(INT_LEAST64_MIN))) {
        private enum enumMixinStr_INT_LEAST64_MIN = `enum INT_LEAST64_MIN = ( - 9223372036854775807i64 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_INT_LEAST64_MIN); }))) {
            mixin(enumMixinStr_INT_LEAST64_MIN);
        }
    }




    static if(!is(typeof(INT_LEAST8_MAX))) {
        private enum enumMixinStr_INT_LEAST8_MAX = `enum INT_LEAST8_MAX = 12;`;
        static if(is(typeof({ mixin(enumMixinStr_INT_LEAST8_MAX); }))) {
            mixin(enumMixinStr_INT_LEAST8_MAX);
        }
    }




    static if(!is(typeof(INT_LEAST16_MAX))) {
        private enum enumMixinStr_INT_LEAST16_MAX = `enum INT_LEAST16_MAX = 32767;`;
        static if(is(typeof({ mixin(enumMixinStr_INT_LEAST16_MAX); }))) {
            mixin(enumMixinStr_INT_LEAST16_MAX);
        }
    }




    static if(!is(typeof(INT_LEAST32_MAX))) {
        private enum enumMixinStr_INT_LEAST32_MAX = `enum INT_LEAST32_MAX = 2147483647;`;
        static if(is(typeof({ mixin(enumMixinStr_INT_LEAST32_MAX); }))) {
            mixin(enumMixinStr_INT_LEAST32_MAX);
        }
    }




    static if(!is(typeof(INT_LEAST64_MAX))) {
        private enum enumMixinStr_INT_LEAST64_MAX = `enum INT_LEAST64_MAX = 9223372036854775807L;`;
        static if(is(typeof({ mixin(enumMixinStr_INT_LEAST64_MAX); }))) {
            mixin(enumMixinStr_INT_LEAST64_MAX);
        }
    }




    static if(!is(typeof(UINT_LEAST8_MAX))) {
        private enum enumMixinStr_UINT_LEAST8_MAX = `enum UINT_LEAST8_MAX = 0xff;`;
        static if(is(typeof({ mixin(enumMixinStr_UINT_LEAST8_MAX); }))) {
            mixin(enumMixinStr_UINT_LEAST8_MAX);
        }
    }




    static if(!is(typeof(UINT_LEAST16_MAX))) {
        private enum enumMixinStr_UINT_LEAST16_MAX = `enum UINT_LEAST16_MAX = 0xffffu;`;
        static if(is(typeof({ mixin(enumMixinStr_UINT_LEAST16_MAX); }))) {
            mixin(enumMixinStr_UINT_LEAST16_MAX);
        }
    }




    static if(!is(typeof(UINT_LEAST32_MAX))) {
        private enum enumMixinStr_UINT_LEAST32_MAX = `enum UINT_LEAST32_MAX = 0xffffffffu;`;
        static if(is(typeof({ mixin(enumMixinStr_UINT_LEAST32_MAX); }))) {
            mixin(enumMixinStr_UINT_LEAST32_MAX);
        }
    }




    static if(!is(typeof(UINT_LEAST64_MAX))) {
        private enum enumMixinStr_UINT_LEAST64_MAX = `enum UINT_LEAST64_MAX = 0xffffffffffffffffuL;`;
        static if(is(typeof({ mixin(enumMixinStr_UINT_LEAST64_MAX); }))) {
            mixin(enumMixinStr_UINT_LEAST64_MAX);
        }
    }




    static if(!is(typeof(INT_FAST8_MIN))) {
        private enum enumMixinStr_INT_FAST8_MIN = `enum INT_FAST8_MIN = ( - 127i8 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_INT_FAST8_MIN); }))) {
            mixin(enumMixinStr_INT_FAST8_MIN);
        }
    }




    static if(!is(typeof(INT_FAST16_MIN))) {
        private enum enumMixinStr_INT_FAST16_MIN = `enum INT_FAST16_MIN = ( - 2147483647i32 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_INT_FAST16_MIN); }))) {
            mixin(enumMixinStr_INT_FAST16_MIN);
        }
    }




    static if(!is(typeof(INT_FAST32_MIN))) {
        private enum enumMixinStr_INT_FAST32_MIN = `enum INT_FAST32_MIN = ( - 2147483647i32 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_INT_FAST32_MIN); }))) {
            mixin(enumMixinStr_INT_FAST32_MIN);
        }
    }




    static if(!is(typeof(INT_FAST64_MIN))) {
        private enum enumMixinStr_INT_FAST64_MIN = `enum INT_FAST64_MIN = ( - 9223372036854775807i64 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_INT_FAST64_MIN); }))) {
            mixin(enumMixinStr_INT_FAST64_MIN);
        }
    }




    static if(!is(typeof(INT_FAST8_MAX))) {
        private enum enumMixinStr_INT_FAST8_MAX = `enum INT_FAST8_MAX = 12;`;
        static if(is(typeof({ mixin(enumMixinStr_INT_FAST8_MAX); }))) {
            mixin(enumMixinStr_INT_FAST8_MAX);
        }
    }




    static if(!is(typeof(INT_FAST16_MAX))) {
        private enum enumMixinStr_INT_FAST16_MAX = `enum INT_FAST16_MAX = 2147483647;`;
        static if(is(typeof({ mixin(enumMixinStr_INT_FAST16_MAX); }))) {
            mixin(enumMixinStr_INT_FAST16_MAX);
        }
    }




    static if(!is(typeof(INT_FAST32_MAX))) {
        private enum enumMixinStr_INT_FAST32_MAX = `enum INT_FAST32_MAX = 2147483647;`;
        static if(is(typeof({ mixin(enumMixinStr_INT_FAST32_MAX); }))) {
            mixin(enumMixinStr_INT_FAST32_MAX);
        }
    }




    static if(!is(typeof(INT_FAST64_MAX))) {
        private enum enumMixinStr_INT_FAST64_MAX = `enum INT_FAST64_MAX = 9223372036854775807L;`;
        static if(is(typeof({ mixin(enumMixinStr_INT_FAST64_MAX); }))) {
            mixin(enumMixinStr_INT_FAST64_MAX);
        }
    }




    static if(!is(typeof(UINT_FAST8_MAX))) {
        private enum enumMixinStr_UINT_FAST8_MAX = `enum UINT_FAST8_MAX = 0xff;`;
        static if(is(typeof({ mixin(enumMixinStr_UINT_FAST8_MAX); }))) {
            mixin(enumMixinStr_UINT_FAST8_MAX);
        }
    }




    static if(!is(typeof(UINT_FAST16_MAX))) {
        private enum enumMixinStr_UINT_FAST16_MAX = `enum UINT_FAST16_MAX = 0xffffffffu;`;
        static if(is(typeof({ mixin(enumMixinStr_UINT_FAST16_MAX); }))) {
            mixin(enumMixinStr_UINT_FAST16_MAX);
        }
    }




    static if(!is(typeof(UINT_FAST32_MAX))) {
        private enum enumMixinStr_UINT_FAST32_MAX = `enum UINT_FAST32_MAX = 0xffffffffu;`;
        static if(is(typeof({ mixin(enumMixinStr_UINT_FAST32_MAX); }))) {
            mixin(enumMixinStr_UINT_FAST32_MAX);
        }
    }




    static if(!is(typeof(UINT_FAST64_MAX))) {
        private enum enumMixinStr_UINT_FAST64_MAX = `enum UINT_FAST64_MAX = 0xffffffffffffffffuL;`;
        static if(is(typeof({ mixin(enumMixinStr_UINT_FAST64_MAX); }))) {
            mixin(enumMixinStr_UINT_FAST64_MAX);
        }
    }




    static if(!is(typeof(INTPTR_MIN))) {
        private enum enumMixinStr_INTPTR_MIN = `enum INTPTR_MIN = ( - 9223372036854775807i64 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_INTPTR_MIN); }))) {
            mixin(enumMixinStr_INTPTR_MIN);
        }
    }




    static if(!is(typeof(INTPTR_MAX))) {
        private enum enumMixinStr_INTPTR_MAX = `enum INTPTR_MAX = 9223372036854775807L;`;
        static if(is(typeof({ mixin(enumMixinStr_INTPTR_MAX); }))) {
            mixin(enumMixinStr_INTPTR_MAX);
        }
    }




    static if(!is(typeof(UINTPTR_MAX))) {
        private enum enumMixinStr_UINTPTR_MAX = `enum UINTPTR_MAX = 0xffffffffffffffffuL;`;
        static if(is(typeof({ mixin(enumMixinStr_UINTPTR_MAX); }))) {
            mixin(enumMixinStr_UINTPTR_MAX);
        }
    }




    static if(!is(typeof(INTMAX_MIN))) {
        private enum enumMixinStr_INTMAX_MIN = `enum INTMAX_MIN = ( - 9223372036854775807i64 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_INTMAX_MIN); }))) {
            mixin(enumMixinStr_INTMAX_MIN);
        }
    }




    static if(!is(typeof(INTMAX_MAX))) {
        private enum enumMixinStr_INTMAX_MAX = `enum INTMAX_MAX = 9223372036854775807L;`;
        static if(is(typeof({ mixin(enumMixinStr_INTMAX_MAX); }))) {
            mixin(enumMixinStr_INTMAX_MAX);
        }
    }




    static if(!is(typeof(UINTMAX_MAX))) {
        private enum enumMixinStr_UINTMAX_MAX = `enum UINTMAX_MAX = 0xffffffffffffffffuL;`;
        static if(is(typeof({ mixin(enumMixinStr_UINTMAX_MAX); }))) {
            mixin(enumMixinStr_UINTMAX_MAX);
        }
    }




    static if(!is(typeof(PTRDIFF_MIN))) {
        private enum enumMixinStr_PTRDIFF_MIN = `enum PTRDIFF_MIN = ( - 9223372036854775807i64 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_PTRDIFF_MIN); }))) {
            mixin(enumMixinStr_PTRDIFF_MIN);
        }
    }




    static if(!is(typeof(PTRDIFF_MAX))) {
        private enum enumMixinStr_PTRDIFF_MAX = `enum PTRDIFF_MAX = 9223372036854775807L;`;
        static if(is(typeof({ mixin(enumMixinStr_PTRDIFF_MAX); }))) {
            mixin(enumMixinStr_PTRDIFF_MAX);
        }
    }




    static if(!is(typeof(SIZE_MAX))) {
        private enum enumMixinStr_SIZE_MAX = `enum SIZE_MAX = 0xffffffffffffffffuL;`;
        static if(is(typeof({ mixin(enumMixinStr_SIZE_MAX); }))) {
            mixin(enumMixinStr_SIZE_MAX);
        }
    }




    static if(!is(typeof(SIG_ATOMIC_MIN))) {
        private enum enumMixinStr_SIG_ATOMIC_MIN = `enum SIG_ATOMIC_MIN = ( - 2147483647i32 - 1 );`;
        static if(is(typeof({ mixin(enumMixinStr_SIG_ATOMIC_MIN); }))) {
            mixin(enumMixinStr_SIG_ATOMIC_MIN);
        }
    }




    static if(!is(typeof(SIG_ATOMIC_MAX))) {
        private enum enumMixinStr_SIG_ATOMIC_MAX = `enum SIG_ATOMIC_MAX = 2147483647;`;
        static if(is(typeof({ mixin(enumMixinStr_SIG_ATOMIC_MAX); }))) {
            mixin(enumMixinStr_SIG_ATOMIC_MAX);
        }
    }




    static if(!is(typeof(WCHAR_MIN))) {
        private enum enumMixinStr_WCHAR_MIN = `enum WCHAR_MIN = 0x0000;`;
        static if(is(typeof({ mixin(enumMixinStr_WCHAR_MIN); }))) {
            mixin(enumMixinStr_WCHAR_MIN);
        }
    }




    static if(!is(typeof(WCHAR_MAX))) {
        private enum enumMixinStr_WCHAR_MAX = `enum WCHAR_MAX = 0xffff;`;
        static if(is(typeof({ mixin(enumMixinStr_WCHAR_MAX); }))) {
            mixin(enumMixinStr_WCHAR_MAX);
        }
    }




    static if(!is(typeof(WINT_MIN))) {
        private enum enumMixinStr_WINT_MIN = `enum WINT_MIN = 0x0000;`;
        static if(is(typeof({ mixin(enumMixinStr_WINT_MIN); }))) {
            mixin(enumMixinStr_WINT_MIN);
        }
    }




    static if(!is(typeof(WINT_MAX))) {
        private enum enumMixinStr_WINT_MAX = `enum WINT_MAX = 0xffff;`;
        static if(is(typeof({ mixin(enumMixinStr_WINT_MAX); }))) {
            mixin(enumMixinStr_WINT_MAX);
        }
    }
}


struct lconv;
