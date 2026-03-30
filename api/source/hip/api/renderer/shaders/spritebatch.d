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
    ushort2 vPosition = [0,0];
    HipColor vColor = HipColor.white;
    @HipShaderInputNormalized ushort2 vTexST;
    ushort vZ = 0;
    // static if(!GLMaxOneBoundTexture)
    ushort vTexID = 0;

    static enum quadCount = HipSpriteVertex.sizeof*4;
    // static assert(HipSpriteVertex.floatCount == 10,  "SpriteVertex should contain 9 floats and 1 int");
}

@HipShaderInputLayout struct HipSpriteVertexInstancedPerVertex
{
    Vector2 vPosition = Vector2.zero;
}

HipSpriteVertexInstancedPerVertex[4] spriteBatchInstancedVertices = [
    HipSpriteVertexInstancedPerVertex(Vector2(0, 0)),
    HipSpriteVertexInstancedPerVertex(Vector2(1, 0)),
    HipSpriteVertexInstancedPerVertex(Vector2(1, 1)),
    HipSpriteVertexInstancedPerVertex(Vector2(0, 1)),
];

/** 
 * It is possible to actually achieve 24 bytes in that structure by applying bitfields.
 */
@HipShaderInputLayout struct HipSpriteVertexInstancedPerInstance
{
    ushort[2] vXY;
    ushort[2] vSize;
    HipColor vColor;
    float vRotation;
    ushort vZ;
    ushort vTexID;
    @HipShaderInputNormalized ushort[2] vUVMin;
    @HipShaderInputNormalized ushort[2] vUVMax;
}

@HipShaderUniform(ShaderTypes.vertex, "Cbuf1", "cbuf1")
struct HipSpriteVertexUniform
{
    Matrix4 uMVP = Matrix4.identity;
}

@HipShaderUniform(ShaderTypes.fragment, "Cbuf", "cbuf")
struct HipSpriteFragmentUniform
{
    float[4] uBatchColor = [1,1,1,1];
}