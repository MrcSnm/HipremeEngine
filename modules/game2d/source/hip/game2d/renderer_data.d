module hip.game2d.renderer_data;

///See hip.graphics.g2d.spritebatch
    import hip.math.vector;
    import hip.api.graphics.color;
    struct HipSpriteVertex
    {
        Vector3 vPosition = Vector3.zero;
        HipColor vColor = HipColor.white;
        Vector2 vTexST = Vector2.zero;
        float vTexID = 0;
    }

    ///see hip.graphics.g2d.textrenderer
    struct HipTextRendererVertex
    {
        import hip.math.vector;
        Vector3 vPosition;
        Vector2 vTexST;

        this(Vector3 vPosition, Vector2 vTexST)
        {
            this.vPosition = vPosition;
            this.vTexST = vTexST;
        }
    }
///