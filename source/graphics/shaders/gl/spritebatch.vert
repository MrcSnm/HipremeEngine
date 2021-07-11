#version 330 core

layout(location = 0) vec3 vPosition;
layout(location = 1) vec4 vColor;
layout(location = 2) vec2 vTex_UV;


uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProj;

out vec2 inTex_UV;
out vec4 inColor;

void main()
{
    gl_Position = uProj*uView*uModel*vec4(vPosition, 1.0);
    inColor = vColor;
    inTex_UV = vTex_UV;
}