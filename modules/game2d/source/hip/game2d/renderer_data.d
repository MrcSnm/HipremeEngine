module hip.game2d.renderer_data;

///See hip.graphics.g2d.spritebatch
    enum HipSpriteVertexFloatCount = 10;
    enum HipSpriteVertexQuadCount = HipSpriteVertexFloatCount*4;
    import hip.math.vector;
    import hip.api.color;
    struct HipSpriteVertex
    {
        Vector3 vPosition = Vector3.zero;
        HipColor vColor = HipColor.white;
        Vector2 vTexST = Vector2.zero;
        float vTexID = 0;
    }
///