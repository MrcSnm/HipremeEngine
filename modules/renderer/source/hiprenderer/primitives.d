/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hiprenderer.primitives;
import bindbc.opengl;

/**
*   I'll try to be betterC compliant with the renderer for being easier to setup a 
*   backend for an unsupported platform
*/
struct Geometry
{
    uint vbo;
    float* vertexData;

    static Geometry opCall()
    {
        Geometry ret;
        glGenBuffers(1, &ret.vbo);
        return ret;
    }

    void assignVertexes(float* vertexData, GLsizei vertexDataLength)
    {
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, vertexDataLength * float.sizeof , vertexData, GL_DYNAMIC_DRAW);
        
    }

    void dispose()
    {
        vbo = -1;
    }
}

float[] triangleVertices = [
    -0.5f, -0.5f, 0.0f,
     0.5f, -0.5f, 0.0f,
     0.0f,  0.5f, 0.0f
];

public static class Primitives
{
    public static void drawTriangle();
    public static void drawRectangle();
    public static void fillTriangle();
    public static void fillRectangle();
    public static void drawPixel();
}