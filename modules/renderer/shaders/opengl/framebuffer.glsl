INOUT vec2 inTexST;
#ifdef VERTEX
ATTRIBUTE(0) vec2 vPosition;
ATTRIBUTE(1) vec2 vTexST;


void vertexMain()
{
    gl_Position = vec4(vPosition, 0.0, 1.0);
    inTexST = vTexST;
}
#endif

#ifdef FRAGMENT
uniform sampler2D uBufferTexture;
uniform vec4 uColor;

void fragmentMain()
{
    vec4 col = SAMPLE2D(uBufferTexture, inTexST);
    float grey = (col.r+col.g+col.b)/3.0;
    OUT_COLOR = grey * uColor;
}
#endif