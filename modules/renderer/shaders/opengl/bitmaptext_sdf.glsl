INOUT vec2 inTexST;
#ifdef VERTEX
UNIFORM_BUFFER_OBJECT(0, Cbuf, cbuf,
{
    mat4 uMVP;
});
ATTRIBUTE(0) vec3 vPosition;
ATTRIBUTE(1) vec2 vTexST;
void vertexMain()
{
    gl_Position = cbuf.uMVP * vec4(vPosition, 1.0);
    inTexST = vTexST;
}
#endif

#ifdef FRAGMENT
uniform sampler2D uTex;
UNIFORM_BUFFER_OBJECT(0, FragVars, pixel, 
{
    vec4 uColor;
});
float screenPxRange = 4.5;
void fragmentMain()
{
    float sd = texture(uTex, inTexST).r;
    float screenPxDistance = screenPxRange*(sd - 0.5);
    float opacity = clamp(screenPxDistance + 0.5, 0.0, 1.0);
    // color = mix(bgColor, fgColor, opacity);
    OUT_COLOR = uColor * opacity;

}
#endif
