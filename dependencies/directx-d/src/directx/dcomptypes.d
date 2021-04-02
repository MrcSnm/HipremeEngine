module directx.dcomptypes;
//---------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.  All rights reserved.
//---------------------------------------------------------------------------

version(Windows):

public import directx.dxgitype, directx.dxgi1_5;

//
// DirectComposition types
//

enum DCOMPOSITION_BITMAP_INTERPOLATION_MODE : uint
{
    DCOMPOSITION_BITMAP_INTERPOLATION_MODE_NEAREST_NEIGHBOR = 0,
    DCOMPOSITION_BITMAP_INTERPOLATION_MODE_LINEAR           = 1,

    DCOMPOSITION_BITMAP_INTERPOLATION_MODE_INHERIT          = 0xffffffff
}

enum DCOMPOSITION_BORDER_MODE : uint
{
    DCOMPOSITION_BORDER_MODE_SOFT       = 0,
    DCOMPOSITION_BORDER_MODE_HARD       = 1,

    DCOMPOSITION_BORDER_MODE_INHERIT    = 0xffffffff
}

enum DCOMPOSITION_COMPOSITE_MODE : uint
{
    DCOMPOSITION_COMPOSITE_MODE_SOURCE_OVER        = 0,
    DCOMPOSITION_COMPOSITE_MODE_DESTINATION_INVERT = 1,
    DCOMPOSITION_COMPOSITE_MODE_MIN_BLEND          = 2,

    DCOMPOSITION_COMPOSITE_MODE_INHERIT            = 0xffffffff
}

enum DCOMPOSITION_BACKFACE_VISIBILITY : uint
{
    DCOMPOSITION_BACKFACE_VISIBILITY_VISIBLE    = 0,
    DCOMPOSITION_BACKFACE_VISIBILITY_HIDDEN     = 1,

    DCOMPOSITION_BACKFACE_VISIBILITY_INHERIT    = 0xffffffff
}

enum DCOMPOSITION_OPACITY_MODE : uint
{
    DCOMPOSITION_OPACITY_MODE_LAYER     = 0,
    DCOMPOSITION_OPACITY_MODE_MULTIPLY  = 1,

    DCOMPOSITION_OPACITY_MODE_INHERIT   = 0xffffffff
}

enum DCOMPOSITION_DEPTH_MODE : uint
{
    DCOMPOSITION_DEPTH_MODE_TREE    = 0,
    DCOMPOSITION_DEPTH_MODE_SPATIAL = 1,

    DCOMPOSITION_DEPTH_MODE_INHERIT = 0xffffffff
}

struct DCOMPOSITION_FRAME_STATISTICS
{
    LARGE_INTEGER lastFrameTime;
    DXGI_RATIONAL currentCompositionRate;
    LARGE_INTEGER currentTime;
    LARGE_INTEGER timeFrequency;
    LARGE_INTEGER nextEstimatedFrameTime;
}


//
// Composition object specific access flags
//

enum COMPOSITIONOBJECT_READ          = 0x0001L;
enum COMPOSITIONOBJECT_WRITE         = 0x0002L;

enum COMPOSITIONOBJECT_ALL_ACCESS    = COMPOSITIONOBJECT_READ | COMPOSITIONOBJECT_WRITE;
