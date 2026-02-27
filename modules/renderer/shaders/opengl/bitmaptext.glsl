INOUT vec2 inTexST;
#ifdef VERTEX
ATTRIBUTE(0) vec3 vPosition;
ATTRIBUTE(1) vec2 vTexST;

UNIFORM_BUFFER_OBJECT(0, Cbuf, cbuf, 
{
    mat4 uMVP;
});

void vertexMain()
{
    gl_Position = cbuf.uMVP * vec4(vPosition, 1.0);
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