module hip.game2d.renderer_data;

///See hip.graphics.g2d.spritebatch
    enum HipSpriteVertexFloatCount = 10;
    enum HipSpriteVertexQuadCount = HipSpriteVertexFloatCount*4;
    enum
    {
        //X, Y, Z (Position)
        //R, G, B, A (Color)
        //U, V (HipTexture Coordinates)
        //T (HipTexture Slot/Index)
        X1 = 0,
        Y1,
        Z1,
        R1,
        G1,
        B1,
        A1,
        U1,
        V1,
        T1,

        X2,
        Y2,
        Z2,
        R2,
        G2,
        B2,
        A2,
        U2,
        V2,
        T2,

        X3,
        Y3,
        Z3,
        R3,
        G3,
        B3,
        A3,
        U3,
        V3,
        T3,

        X4,
        Y4,
        Z4,
        R4,
        G4,
        B4,
        A4,
        U4,
        V4,
        T4
    }
///