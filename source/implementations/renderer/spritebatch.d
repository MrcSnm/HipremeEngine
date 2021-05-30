module implementations.renderer.spritebatch;
import implementations.renderer.renderer;
import implementations.renderer.shader;

class SpriteBatch
{
    uint maxQuads;
    uint[] indices;

    this(uint maxQuads = 5000)
    {
        this.maxQuads = maxQuads;
        indices.reserve(maxQuads*6);

        int offset = 0;
        for(int i = 0; i < maxQuads; i+=6)
        {
            indices[i + 0] = 0+offset;
            indices[i + 1] = 1+offset;
            indices[i + 2] = 2+offset;

            indices[i + 3] = 2+offset;
            indices[i + 4] = 3+offset;
            indices[i + 5] = 0+offset;
            offset+= 4; //Offset calculated for each quad
        }
    }


    static Shader getShaderForSpriteBatch()
    {
        Shader s = HipRenderer.newShader(false);
        // s.setVertexAttribute

        return s;
    }
}