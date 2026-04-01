INOUT vec2 inTexST;
#ifdef VERTEX

ATTRIBUTE(0) UVEC2 vPosition;
ATTRIBUTE(1) vec2 vTexST;
ATTRIBUTE(2) UINT vZ;

UNIFORM_BUFFER_OBJECT(0, Cbuf, cbuf, 
{
    mat4 uMVP;
});

void vertexMain()
{
    gl_Position = cbuf.uMVP * vec4(vec2(vPosition), float(vZ), 1.0);
    inTexST = vTexST;
}
#endif
#ifdef FRAGMENT
UNIFORM_BUFFER_OBJECT(0, FragVars, frag, 
{
    vec4 uColor;
});
uniform sampler2D uTex;

void fragmentMain()
{
    float r = SAMPLE2D(uTex, inTexST).r;
    OUT_COLOR = vec4(r,r,r,r)*frag.uColor;
}
#endif