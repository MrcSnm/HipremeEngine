#version 330 core

uniform vec4 globalColor;

in vec4 vertexColor;
in vec2 texCoord;
uniform sampler2D tex1;

void main()
{
    gl_FragColor = texture(tex1, texCoord)*globalColor*vertexColor;
}