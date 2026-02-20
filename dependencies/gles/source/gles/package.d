module gles;

version(GLES32)
    public import gles.gl32;
else version(GLES31)
    public import gles.gl31;
else version(GLES30)
    public import gles.gl30;
else version(GLES20)
{
    public import gles.gl2;
    public import gles.gl2ext;

    //Additional functions for working on hipreme engine
    pragma(inline) void glUniform1ui(int location, uint value){glUniform1i(location, cast(int)value);}
    pragma(inline) void glUniform1uiv(int location, int count, uint* value){glUniform1iv(location, count, cast(int*)value);}
    
}
else version(NO_GLES){}
else
    static assert(false, "No GLES version is present: Available versions:
    GLES20
    GLES30
    GLES31
    GLES32"
);