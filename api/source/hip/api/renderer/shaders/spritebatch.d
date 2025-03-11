module hip.api.renderer.shaders.spritebatch;
import hip.api.renderer.core;
import hip.config.renderer;

public import hip.math.vector;
public import hip.math.matrix;


/**
*   This is what to expect in each vertex sent to the sprite batch
*/
@HipShaderInputLayout struct HipSpriteVertex
{
    Vector3 vPosition = Vector3.zero;
    HipColor vColor = HipColor.white;
    Vector2 vTexST = Vector2.zero;

    static if(!GLMaxOneBoundTexture)
        float vTexID = 0;

    static enum floatCount = cast(size_t)(HipSpriteVertex.sizeof/float.sizeof);
    static enum quadCount = floatCount*4;
    // static assert(HipSpriteVertex.floatCount == 10,  "SpriteVertex should contain 9 floats and 1 int");
}


@HipShaderVertexUniform("Cbuf1")
struct HipSpriteVertexUniform
{
    Matrix4 uMVP = Matrix4.identity;
}

@HipShaderFragmentUniform("Cbuf")
struct HipSpriteFragmentUniform
{
    float[4] uBatchColor = [1,1,1,1];

    @(ShaderHint.Blackbox)
    IHipTexture[] uTex;
}