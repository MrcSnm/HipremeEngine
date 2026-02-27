INOUT vec4 inVertexColor;
#ifdef VERTEX
ATTRIBUTE(0) vec3 vPosition;
ATTRIBUTE(1) vec4 vColor;

UNIFORM_BUFFER_OBJECT(0, Geom, geom, 
{
    mat4 uMVP;
});
void vertexMain()
{
    gl_Position = geom.uMVP*vec4(vPosition, 1.0);
    inVertexColor = vColor;
}
#endif


#ifdef FRAGMENT
UNIFORM_BUFFER_OBJECT(0, FragVars, frag, 
{
    vec4 uGlobalColor;
});

void fragmentMain()
{
    OUT_COLOR = inVertexColor * frag.uGlobalColor;
}
#endif