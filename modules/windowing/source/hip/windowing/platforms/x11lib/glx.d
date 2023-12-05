module hip.windowing.platforms.x11lib.glx;
import hip.windowing.platforms.x11lib.x11;

version(Android){}
else version(linux)
    version = X11;

version(X11):

alias GLint = int;
alias GLubyte = ubyte;
alias GLXPixmap = XID;
alias GLXDrawable = XID;
/* GLX 1.3 and later */
struct __GLXcontextRec;
alias GLXContext = __GLXcontextRec*;
struct __GLXFBConfigRec;
alias GLXFBConfig = __GLXFBConfigRec*;
alias GLXFBConfigID = XID;
alias GLXContextID = XID;
alias GLXWindow = XID;
alias GLXPbuffer = XID;


enum GLX_USE_GL           = 1;
enum GLX_BUFFER_SIZE      = 2;
enum GLX_LEVEL            = 3;
enum GLX_RGBA             = 4;
enum GLX_DOUBLEBUFFER     = 5;
enum GLX_STEREO           = 6;
enum GLX_AUX_BUFFERS      = 7;
enum GLX_RED_SIZE         = 8;
enum GLX_GREEN_SIZE       = 9;
enum GLX_BLUE_SIZE        = 10;
enum GLX_ALPHA_SIZE       = 11;
enum GLX_DEPTH_SIZE       = 12;
enum GLX_STENCIL_SIZE     =	13;
enum GLX_ACCUM_RED_SIZE   =	14;
enum GLX_ACCUM_GREEN_SIZE =	15;
enum GLX_ACCUM_BLUE_SIZE  =	16;
enum GLX_ACCUM_ALPHA_SIZE =	17;

enum GLX_SAMPLE_BUFFERS = 0x186a0; /*100000*/
enum GLX_SAMPLES        = 0x186a1; /*100001*/


/*
 * GLX 1.3 and later:
 */
enum GLX_CONFIG_CAVEAT		     = 0x20;
enum GLX_DONT_CARE			     = 0xFFFFFFFF;
enum GLX_X_VISUAL_TYPE		     = 0x22;
enum GLX_TRANSPARENT_TYPE		 = 0x23;
enum GLX_TRANSPARENT_INDEX_VALUE = 0x24;
enum GLX_TRANSPARENT_RED_VALUE	 = 0x25;
enum GLX_TRANSPARENT_GREEN_VALUE = 0x26;
enum GLX_TRANSPARENT_BLUE_VALUE	 = 0x27;
enum GLX_TRANSPARENT_ALPHA_VALUE = 0x28;
enum GLX_WINDOW_BIT			     = 0x00000001;
enum GLX_PIXMAP_BIT			     = 0x00000002;
enum GLX_PBUFFER_BIT		     = 0x00000004;
enum GLX_AUX_BUFFERS_BIT	     = 0x00000010;
enum GLX_FRONT_LEFT_BUFFER_BIT   = 0x00000001;
enum GLX_FRONT_RIGHT_BUFFER_BIT  = 0x00000002;
enum GLX_BACK_LEFT_BUFFER_BIT    = 0x00000004;
enum GLX_BACK_RIGHT_BUFFER_BIT   = 0x00000008;
enum GLX_DEPTH_BUFFER_BIT	     = 0x00000020;
enum GLX_STENCIL_BUFFER_BIT	     = 0x00000040;
enum GLX_ACCUM_BUFFER_BIT  	     = 0x00000080;
enum GLX_NONE			         = 0x8000;
enum GLX_SLOW_CONFIG		     = 0x8001;
enum GLX_TRUE_COLOR			     = 0x8002;
enum GLX_DIRECT_COLOR		     = 0x8003;
enum GLX_PSEUDO_COLOR		     = 0x8004;
enum GLX_STATIC_COLOR		     = 0x8005;
enum GLX_GRAY_SCALE			     = 0x8006;
enum GLX_STATIC_GRAY		     = 0x8007;
enum GLX_TRANSPARENT_RGB	     = 0x8008;
enum GLX_TRANSPARENT_INDEX	     = 0x8009;
enum GLX_VISUAL_ID			     = 0x800B;
enum GLX_SCREEN			         = 0x800C;
enum GLX_NON_CONFORMANT_CONFIG   = 0x800D;
enum GLX_DRAWABLE_TYPE		     = 0x8010;
enum GLX_RENDER_TYPE		     = 0x8011;
enum GLX_X_RENDERABLE		     = 0x8012;
enum GLX_FBCONFIG_ID		     = 0x8013;
enum GLX_RGBA_TYPE			     = 0x8014;
enum GLX_COLOR_INDEX_TYPE	     = 0x8015;
enum GLX_MAX_PBUFFER_WIDTH	     = 0x8016;
enum GLX_MAX_PBUFFER_HEIGHT	     = 0x8017;
enum GLX_MAX_PBUFFER_PIXELS	     = 0x8018;
enum GLX_PRESERVED_CONTENTS	     = 0x801B;
enum GLX_LARGEST_PBUFFER	     = 0x801C;
enum GLX_WIDTH			         = 0x801D;
enum GLX_HEIGHT			         = 0x801E;
enum GLX_EVENT_MASK			     = 0x801F;
enum GLX_DAMAGED			     = 0x8020;
enum GLX_SAVED			         = 0x8021;
enum GLX_WINDOW			         = 0x8022;
enum GLX_PBUFFER			     = 0x8023;
enum GLX_PBUFFER_HEIGHT          = 0x8040;
enum GLX_PBUFFER_WIDTH           = 0x8041;
enum GLX_RGBA_BIT			     = 0x00000001;
enum GLX_COLOR_INDEX_BIT	     = 0x00000002;
enum GLX_PBUFFER_CLOBBER_MASK    = 0x08000000;


enum GLX_CONTEXT_MAJOR_VERSION_ARB = 0x2091;
enum GLX_CONTEXT_MINOR_VERSION_ARB = 0x2092;
enum GLX_CONTEXT_FLAGS_ARB         = 0x2094;
enum GLX_CONTEXT_PROFILE_MASK_ARB  = 0x9126;

enum GLX_CONTEXT_DEBUG_BIT_ARB                  = 0x0001;
enum GLX_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB     = 0x000;
enum GLX_CONTEXT_CORE_PROFILE_BIT_ARB           = 0x00000001;
enum GLX_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB  = 0x00000002;
	
alias glXCreateContextAttribsARBProc = extern(C) nothrow @nogc GLXContext function(Display*, GLXFBConfig, GLXContext, Bool, const(int)*);
alias glXSwapIntervalEXTProc = extern(C) nothrow @nogc void function(Display *dpy, GLXDrawable drawable, int interval);
alias glXSwapIntervalSGIProc = extern(C) nothrow @nogc int function(int interval);
alias glXSwapIntervalMESAProc = extern(C) nothrow @nogc int function(int interval);

glXSwapIntervalEXTProc glXSwapIntervalEXT;
glXSwapIntervalMESAProc glXSwapIntervalMESA;
glXSwapIntervalSGIProc glXSwapIntervalSGI;

///https://www.khronos.org/opengl/wiki/Tutorial:_OpenGL_3.0_Context_Creation_(GLX)
nothrow @system @nogc
bool isExtensionSupported(const char *extList, const char *extension)
{
    import core.stdc.string;
    const(char)* start;
    const(char)* where, terminator;
  
    /* Extension names should not have spaces. */
    where = strchr(extension, ' ');
    if (where || *extension == '\0')
        return false;

    /* It takes a bit of care to be fool-proof about parsing the
        OpenGL extensions string. Don't be fooled by sub-strings,
        etc. */
    for (start=extList;;) 
    {
        where = strstr(start, extension);

        if (!where)
        break;

        terminator = where + strlen(extension);

        if ( where == start || *(where - 1) == ' ' )
        if ( *terminator == ' ' || *terminator == '\0' )
            return true;

        start = terminator;
    }

    return false;
}
