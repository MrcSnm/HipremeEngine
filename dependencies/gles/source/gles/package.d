module gles;

version(GLES20)
    public import gles.gl2;
else version(GLES30)
    public import gles.gl30;
else version(GLES31)
    public import gles.gl31;
else version(GLES32)
    public import gles.gl32;
else version(NO_GLES){}
else
    static assert(false, "No GLES version is present: Available versions:
    GLES20
    GLES30
    GLES31
    GLES32"
    );