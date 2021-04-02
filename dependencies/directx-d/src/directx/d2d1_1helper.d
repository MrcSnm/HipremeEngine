module directx.d2d1_1helper;
/*=========================================================================*\

    Copyright (c) Microsoft Corporation.  All rights reserved.

    File: D2D1_1Helper.h

    Module Name: D2D

    Description: Helper files over the D2D interfaces and APIs.

\*=========================================================================*/

version(Windows):

public import directx.d2d1_1;
import directx.d2d1helper;

template TypeTraits(T : INT32)
{
    alias Point =  D2D1_POINT_2L;
    alias Rect = D2D1_RECT_L;
}

template TypeTraits(T : LONG)
{
    alias Point = D2D1_POINT_2L;
    alias Rect = D2D1_RECT_L;
}

struct Matrix4x3F // : D2D1_MATRIX_4X3_F
{
    D2D1_MATRIX_4X3_F matrix;
    alias matrix this;

    nothrow this(D2D1_MATRIX_4X3_F m) { matrix = m; }
    nothrow this(
        FLOAT m11, FLOAT m12, FLOAT m13,
        FLOAT m21, FLOAT m22, FLOAT m23,
        FLOAT m31, FLOAT m32, FLOAT m33,
        FLOAT m41, FLOAT m42, FLOAT m43
        )
    {
        _11 = m11;
        _12 = m12;
        _13 = m13;

        _21 = m21;
        _22 = m22;
        _23 = m23;

        _31 = m31;
        _32 = m32;
        _33 = m33;

        _41 = m41;
        _42 = m42;
        _43 = m43;
    }

    // this()
    /// Use this instead of default constructor
    static @property nothrow Identity()
    {
        return Matrix4x3F(
            1, 0, 0,
            0, 1, 0,
            0, 0, 1,
            0, 0, 0
        );
    }
}

struct Matrix4x4F // : public D2D1_MATRIX_4X4_F
{
    D2D1_MATRIX_4X4_F matrix;
    alias matrix this;

    nothrow this(D2D1_MATRIX_4X4_F m) { matrix = m; }
    nothrow this(
        FLOAT m11, FLOAT m12, FLOAT m13, FLOAT m14,
        FLOAT m21, FLOAT m22, FLOAT m23, FLOAT m24,
        FLOAT m31, FLOAT m32, FLOAT m33, FLOAT m34,
        FLOAT m41, FLOAT m42, FLOAT m43, FLOAT m44
        )
    {
        _11 = m11;
        _12 = m12;
        _13 = m13;
        _14 = m14;

        _21 = m21;
        _22 = m22;
        _23 = m23;
        _24 = m24;

        _31 = m31;
        _32 = m32;
        _33 = m33;
        _34 = m34;

        _41 = m41;
        _42 = m42;
        _43 = m43;
        _44 = m44;
    }

    // this()
    /// Use this instead of default constructor
    static nothrow @property Identity()
    {
        return Matrix4x4F(
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        );
    }

    bool opEquals(
        const Matrix4x4F r
        ) const
    {
        return _11 == r._11 && _12 == r._12 && _13 == r._13 && _14 == r._14 &&
                _21 == r._21 && _22 == r._22 && _23 == r._23 && _24 == r._24 &&
                _31 == r._31 && _32 == r._32 && _33 == r._33 && _34 == r._34 &&
                _41 == r._41 && _42 == r._42 && _43 == r._43 && _44 == r._44;
    }

    static
    Matrix4x4F
    Translation(FLOAT x, FLOAT y, FLOAT z)
    {
        Matrix4x4F translation;

        translation._11 = 1.0; translation._12 = 0.0; translation._13 = 0.0; translation._14 = 0.0;
        translation._21 = 0.0; translation._22 = 1.0; translation._23 = 0.0; translation._24 = 0.0;
        translation._31 = 0.0; translation._32 = 0.0; translation._33 = 1.0; translation._34 = 0.0;
        translation._41 = x;   translation._42 = y;   translation._43 = z;   translation._44 = 1.0;

        return translation;
    }

    static
    Matrix4x4F
    Scale(FLOAT x, FLOAT y, FLOAT z)
    {
        Matrix4x4F scale;

        scale._11 = x;   scale._12 = 0.0; scale._13 = 0.0; scale._14 = 0.0;
        scale._21 = 0.0; scale._22 = y;   scale._23 = 0.0; scale._24 = 0.0;
        scale._31 = 0.0; scale._32 = 0.0; scale._33 = z;   scale._34 = 0.0;
        scale._41 = 0.0; scale._42 = 0.0; scale._43 = 0.0; scale._44 = 1.0;

        return scale;
    }

    static
    Matrix4x4F
    RotationX(FLOAT degreeX)
    {
        FLOAT angleInRadian = degreeX * (3.141592654f / 180.0f);

        FLOAT sinAngle = 0.0;
        FLOAT cosAngle = 0.0;
        D2D1SinCos(angleInRadian, &sinAngle, &cosAngle);

        return Matrix4x4F(
            1, 0,         0,        0,
            0, cosAngle,  sinAngle, 0,
            0, -sinAngle, cosAngle, 0,
            0, 0,         0,        1
            );
    }

    static
    Matrix4x4F
    RotationY(FLOAT degreeY)
    {
        FLOAT angleInRadian = degreeY * (3.141592654f / 180.0f);

        FLOAT sinAngle = 0.0;
        FLOAT cosAngle = 0.0;
        D2D1SinCos(angleInRadian, &sinAngle, &cosAngle);

        return Matrix4x4F(
            cosAngle, 0, -sinAngle, 0,
            0,        1, 0,         0,
            sinAngle, 0, cosAngle,  0,
            0,        0, 0,         1
            );
    }

    static
    Matrix4x4F
    RotationZ(FLOAT degreeZ)
    {
        FLOAT angleInRadian = degreeZ * (3.141592654f / 180.0f);

        FLOAT sinAngle = 0.0;
        FLOAT cosAngle = 0.0;
        D2D1SinCos(angleInRadian, &sinAngle, &cosAngle);

        return Matrix4x4F(
            cosAngle,  sinAngle, 0, 0,
            -sinAngle, cosAngle, 0, 0,
            0,         0,        1, 0,
            0,         0,        0, 1
            );
    }

    //
    // 3D Rotation matrix for an arbitrary axis specified by x, y and z
    //
    static
    Matrix4x4F
    RotationArbitraryAxis(FLOAT x, FLOAT y, FLOAT z, FLOAT degree)
    {
        // Normalize the vector represented by x, y, and z
        FLOAT magnitude = D2D1Vec3Length(x, y, z);
        x /= magnitude;
        y /= magnitude;
        z /= magnitude;

        FLOAT angleInRadian = degree * (3.141592654f / 180.0f);

        FLOAT sinAngle = 0.0;
        FLOAT cosAngle = 0.0;
        D2D1SinCos(angleInRadian, &sinAngle, &cosAngle);

        FLOAT oneMinusCosAngle = 1 - cosAngle;

        return Matrix4x4F(
            1             + oneMinusCosAngle * (x * x - 1),
            z  * sinAngle + oneMinusCosAngle *  x * y,
            -y * sinAngle + oneMinusCosAngle *  x * z,
            0,

            -z * sinAngle + oneMinusCosAngle *  y * x,
            1             + oneMinusCosAngle * (y * y - 1),
            x  * sinAngle + oneMinusCosAngle *  y * z,
            0,

            y  * sinAngle + oneMinusCosAngle *  z * x,
            -x * sinAngle + oneMinusCosAngle *  z * y,
            1             + oneMinusCosAngle * (z * z - 1) ,
            0,

            0, 0, 0, 1
            );
    }

    static
    Matrix4x4F
    SkewX(FLOAT degreeX)
    {
        FLOAT angleInRadian = degreeX * (3.141592654f / 180.0f);

        FLOAT tanAngle = D2D1Tan(angleInRadian);

        return Matrix4x4F(
            1,          0,  0, 0,
            tanAngle,   1,  0, 0,
            0,          0,  1, 0,
            0,          0,  0, 1
            );
    }

    static
    Matrix4x4F
    SkewY(FLOAT degreeY)
    {
        FLOAT angleInRadian = degreeY * (3.141592654f / 180.0f);

        FLOAT tanAngle = D2D1Tan(angleInRadian);

        return Matrix4x4F(
            1,  tanAngle,   0, 0,
            0,  1,          0, 0,
            0,  0,          1, 0,
            0,  0,          0, 1
            );
    }


    static
    Matrix4x4F
    PerspectiveProjection(FLOAT depth)
    {
        float proj = 0;

        if (depth > 0)
        {
            proj = -1/depth;
        }

        return Matrix4x4F(
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, proj,
            0, 0, 0, 1
            );
    }

    //
    // Functions for convertion from the base D2D1_MATRIX_4X4_f to
    // this type without making a copy
    //
    static
    const(Matrix4x4F)*
    ReinterpretBaseType(const(D2D1_MATRIX_4X4_F)* pMatrix)
    {
        return cast(const(Matrix4x4F)*)pMatrix;
    }

    static
    nothrow
    Matrix4x4F*
    ReinterpretBaseType(D2D1_MATRIX_4X4_F *pMatrix)
    {
        return cast(Matrix4x4F*)(pMatrix);
    }

    nothrow
    FLOAT
    Determinant() const
    {
        FLOAT minor1 = _41 * (_12 * (_23 * _34 - _33 * _24) - _13 * (_22 * _34 - _24 * _32) + _14 * (_22 * _33 - _23 * _32));
        FLOAT minor2 = _42 * (_11 * (_21 * _34 - _31 * _24) - _13 * (_21 * _34 - _24 * _31) + _14 * (_21 * _33 - _23 * _31));
        FLOAT minor3 = _43 * (_11 * (_22 * _34 - _32 * _24) - _12 * (_21 * _34 - _24 * _31) + _14 * (_21 * _32 - _22 * _31));
        FLOAT minor4 = _44 * (_11 * (_22 * _33 - _32 * _23) - _12 * (_21 * _33 - _23 * _31) + _13 * (_21 * _32 - _22 * _31));

        return minor1 - minor2 + minor3 - minor4;
    }

    nothrow
    bool
    IsIdentity() const
    {
        return _11 == 1.0f && _12 == 0.0f && _13 == 0.0f && _14 == 0.0f
            && _21 == 0.0f && _22 == 1.0f && _23 == 0.0f && _24 == 0.0f
            && _31 == 0.0f && _32 == 0.0f && _33 == 1.0f && _34 == 0.0f
            && _41 == 0.0f && _42 == 0.0f && _43 == 0.0f && _44 == 1.0f;
    }

    nothrow
    void
    SetProduct(const Matrix4x4F a, const Matrix4x4F b)
    {
        _11 = a._11 * b._11 + a._12 * b._21 + a._13 * b._31 + a._14 * b._41;
        _12 = a._11 * b._12 + a._12 * b._22 + a._13 * b._32 + a._14 * b._42;
        _13 = a._11 * b._13 + a._12 * b._23 + a._13 * b._33 + a._14 * b._43;
        _14 = a._11 * b._14 + a._12 * b._24 + a._13 * b._34 + a._14 * b._44;

        _21 = a._21 * b._11 + a._22 * b._21 + a._23 * b._31 + a._24 * b._41;
        _22 = a._21 * b._12 + a._22 * b._22 + a._23 * b._32 + a._24 * b._42;
        _23 = a._21 * b._13 + a._22 * b._23 + a._23 * b._33 + a._24 * b._43;
        _24 = a._21 * b._14 + a._22 * b._24 + a._23 * b._34 + a._24 * b._44;

        _31 = a._31 * b._11 + a._32 * b._21 + a._33 * b._31 + a._34 * b._41;
        _32 = a._31 * b._12 + a._32 * b._22 + a._33 * b._32 + a._34 * b._42;
        _33 = a._31 * b._13 + a._32 * b._23 + a._33 * b._33 + a._34 * b._43;
        _34 = a._31 * b._14 + a._32 * b._24 + a._33 * b._34 + a._34 * b._44;

        _41 = a._41 * b._11 + a._42 * b._21 + a._43 * b._31 + a._44 * b._41;
        _42 = a._41 * b._12 + a._42 * b._22 + a._43 * b._32 + a._44 * b._42;
        _43 = a._41 * b._13 + a._42 * b._23 + a._43 * b._33 + a._44 * b._43;
        _44 = a._41 * b._14 + a._42 * b._24 + a._43 * b._34 + a._44 * b._44;
    }

    nothrow
    Matrix4x4F
    opBinary(string op)(const Matrix4x4F matrix) const if(op == "*")
    {
        Matrix4x4F result;

        result.SetProduct(*this, matrix);

        return result;
    }
}


struct Matrix5x4F // : D2D1_MATRIX_5X4_F
{
    D2D1_MATRIX_5X4_F matrix;
    alias matrix this;

    nothrow this(D2D1_MATRIX_5X4_F m) { matrix = m; }
    nothrow this(
        FLOAT m11, FLOAT m12, FLOAT m13, FLOAT m14,
        FLOAT m21, FLOAT m22, FLOAT m23, FLOAT m24,
        FLOAT m31, FLOAT m32, FLOAT m33, FLOAT m34,
        FLOAT m41, FLOAT m42, FLOAT m43, FLOAT m44,
        FLOAT m51, FLOAT m52, FLOAT m53, FLOAT m54
        )
    {
        _11 = m11;
        _12 = m12;
        _13 = m13;
        _14 = m14;

        _21 = m21;
        _22 = m22;
        _23 = m23;
        _24 = m24;

        _31 = m31;
        _32 = m32;
        _33 = m33;
        _34 = m34;

        _41 = m41;
        _42 = m42;
        _43 = m43;
        _44 = m44;

        _51 = m51;
        _52 = m52;
        _53 = m53;
        _54 = m54;
    }

    // this()
    /// Use this instead of default constructor
    static nothrow @property Identity()
    {
        return Matrix5x4F(
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1,
            0, 0, 0, 0
        );
    }
}

D2D1_COLOR_F
ConvertColorSpace(
    D2D1_COLOR_SPACE sourceColorSpace,
    D2D1_COLOR_SPACE destinationColorSpace,
    const D2D1_COLOR_F color
    )
{
    return D2D1ConvertColorSpace(
        sourceColorSpace,
        destinationColorSpace,
        &color
        );
}

D2D1_DRAWING_STATE_DESCRIPTION1
DrawingStateDescription1(
    D2D1_ANTIALIAS_MODE antialiasMode = D2D1_ANTIALIAS_MODE_PER_PRIMITIVE,
    D2D1_TEXT_ANTIALIAS_MODE textAntialiasMode = D2D1_TEXT_ANTIALIAS_MODE_DEFAULT,
    D2D1_TAG tag1 = 0,
    D2D1_TAG tag2 = 0,
    const D2D1_MATRIX_3X2_F transform = D2D1.IdentityMatrix(),
    D2D1_PRIMITIVE_BLEND primitiveBlend = D2D1_PRIMITIVE_BLEND_SOURCE_OVER,
    D2D1_UNIT_MODE unitMode = D2D1_UNIT_MODE_DIPS
    )
{
    D2D1_DRAWING_STATE_DESCRIPTION1 drawingStateDescription1;

    drawingStateDescription1.antialiasMode = antialiasMode;
    drawingStateDescription1.textAntialiasMode = textAntialiasMode;
    drawingStateDescription1.tag1 = tag1;
    drawingStateDescription1.tag2 = tag2;
    drawingStateDescription1.transform = transform;
    drawingStateDescription1.primitiveBlend = primitiveBlend;
    drawingStateDescription1.unitMode = unitMode;

    return drawingStateDescription1;
}

D2D1_DRAWING_STATE_DESCRIPTION1
DrawingStateDescription1(
    const D2D1_DRAWING_STATE_DESCRIPTION desc,
    D2D1_PRIMITIVE_BLEND primitiveBlend = D2D1_PRIMITIVE_BLEND_SOURCE_OVER,
    D2D1_UNIT_MODE unitMode = D2D1_UNIT_MODE_DIPS
    )
{
    D2D1_DRAWING_STATE_DESCRIPTION1 drawingStateDescription1;

    drawingStateDescription1.antialiasMode = desc.antialiasMode;
    drawingStateDescription1.textAntialiasMode = desc.textAntialiasMode;
    drawingStateDescription1.tag1 = desc.tag1;
    drawingStateDescription1.tag2 = desc.tag2;
    drawingStateDescription1.transform = desc.transform;
    drawingStateDescription1.primitiveBlend = primitiveBlend;
    drawingStateDescription1.unitMode = unitMode;

    return drawingStateDescription1;
}

D2D1_BITMAP_PROPERTIES1
BitmapProperties1(
    D2D1_BITMAP_OPTIONS bitmapOptions = D2D1_BITMAP_OPTIONS_NONE,
    const D2D1_PIXEL_FORMAT pixelFormat = D2D1.PixelFormat(),
    FLOAT dpiX = 96.0f,
    FLOAT dpiY = 96.0f,
    ID2D1ColorContext colorContext = null
    )
{
    D2D1_BITMAP_PROPERTIES1 bitmapProperties =
    {
        pixelFormat,
        dpiX, dpiY,
        bitmapOptions,
        colorContext
    };

    return bitmapProperties;
}    

D2D1_LAYER_PARAMETERS1
LayerParameters1(
    const D2D1_RECT_F contentBounds = D2D1.InfiniteRect(),
    ID2D1Geometry geometricMask = NULL,
    D2D1_ANTIALIAS_MODE maskAntialiasMode = D2D1_ANTIALIAS_MODE_PER_PRIMITIVE,
    D2D1_MATRIX_3X2_F maskTransform = D2D1.IdentityMatrix(),
    FLOAT opacity = 1.0,
    ID2D1Brush opacityBrush = NULL,
    D2D1_LAYER_OPTIONS1 layerOptions = D2D1_LAYER_OPTIONS1_NONE
    )
{
    D2D1_LAYER_PARAMETERS1 layerParameters;

    layerParameters.contentBounds = contentBounds;
    layerParameters.geometricMask = geometricMask;
    layerParameters.maskAntialiasMode = maskAntialiasMode;
    layerParameters.maskTransform = maskTransform;
    layerParameters.opacity = opacity;
    layerParameters.opacityBrush = opacityBrush;
    layerParameters.layerOptions = layerOptions;

    return layerParameters;
}

D2D1_STROKE_STYLE_PROPERTIES1
StrokeStyleProperties1(
    D2D1_CAP_STYLE startCap = D2D1_CAP_STYLE_FLAT,
    D2D1_CAP_STYLE endCap = D2D1_CAP_STYLE_FLAT,
    D2D1_CAP_STYLE dashCap = D2D1_CAP_STYLE_FLAT,
    D2D1_LINE_JOIN lineJoin = D2D1_LINE_JOIN_MITER,
    FLOAT miterLimit = 10.0f,
    D2D1_DASH_STYLE dashStyle = D2D1_DASH_STYLE_SOLID,
    FLOAT dashOffset = 0.0f,
    D2D1_STROKE_TRANSFORM_TYPE transformType = D2D1_STROKE_TRANSFORM_TYPE_NORMAL
    )
{
    D2D1_STROKE_STYLE_PROPERTIES1 strokeStyleProperties;

    strokeStyleProperties.startCap = startCap;
    strokeStyleProperties.endCap = endCap;
    strokeStyleProperties.dashCap = dashCap;
    strokeStyleProperties.lineJoin = lineJoin;
    strokeStyleProperties.miterLimit = miterLimit;
    strokeStyleProperties.dashStyle = dashStyle;
    strokeStyleProperties.dashOffset = dashOffset;
    strokeStyleProperties.transformType = transformType;

    return strokeStyleProperties;
}

D2D1_IMAGE_BRUSH_PROPERTIES
ImageBrushProperties(
    D2D1_RECT_F sourceRectangle,
    D2D1_EXTEND_MODE extendModeX = D2D1_EXTEND_MODE_CLAMP,
    D2D1_EXTEND_MODE extendModeY = D2D1_EXTEND_MODE_CLAMP,
    D2D1_INTERPOLATION_MODE interpolationMode = D2D1_INTERPOLATION_MODE_LINEAR
    )
{
    D2D1_IMAGE_BRUSH_PROPERTIES imageBrushProperties;

    imageBrushProperties.extendModeX = extendModeX;
    imageBrushProperties.extendModeY = extendModeY;
    imageBrushProperties.interpolationMode = interpolationMode;
    imageBrushProperties.sourceRectangle = sourceRectangle;

    return imageBrushProperties;
}

D2D1_BITMAP_BRUSH_PROPERTIES1
BitmapBrushProperties1(
    D2D1_EXTEND_MODE extendModeX = D2D1_EXTEND_MODE_CLAMP,
    D2D1_EXTEND_MODE extendModeY = D2D1_EXTEND_MODE_CLAMP,
    D2D1_INTERPOLATION_MODE interpolationMode = D2D1_INTERPOLATION_MODE_LINEAR
    )
{
    D2D1_BITMAP_BRUSH_PROPERTIES1 bitmapBrush1Properties;

    bitmapBrush1Properties.extendModeX = extendModeX;
    bitmapBrush1Properties.extendModeY = extendModeY;
    bitmapBrush1Properties.interpolationMode = interpolationMode;

    return bitmapBrush1Properties;
}

D2D1_PRINT_CONTROL_PROPERTIES
PrintControlProperties(
    D2D1_PRINT_FONT_SUBSET_MODE fontSubsetMode = D2D1_PRINT_FONT_SUBSET_MODE_DEFAULT,
    FLOAT rasterDpi = 150.0f,
    D2D1_COLOR_SPACE colorSpace = D2D1_COLOR_SPACE_SRGB
    )
{
    D2D1_PRINT_CONTROL_PROPERTIES printControlProps;

    printControlProps.fontSubset = fontSubsetMode;
    printControlProps.rasterDPI = rasterDpi;
    printControlProps.colorSpace = colorSpace;

    return printControlProps;
}

D2D1_RENDERING_CONTROLS
RenderingControls(
    D2D1_BUFFER_PRECISION bufferPrecision,
    D2D1_SIZE_U tileSize
    )
{
    D2D1_RENDERING_CONTROLS renderingControls;

    renderingControls.bufferPrecision = bufferPrecision;
    renderingControls.tileSize = tileSize;

    return renderingControls;
}

D2D1_EFFECT_INPUT_DESCRIPTION
EffectInputDescription(
    ID2D1Effect effect,
    UINT32 inputIndex,
    D2D1_RECT_F inputRectangle
    )
{
    D2D1_EFFECT_INPUT_DESCRIPTION description;

    description.effect = effect;
    description.inputIndex = inputIndex;
    description.inputRectangle = inputRectangle;

    return description;
}

D2D1_CREATION_PROPERTIES
CreationProperties(
    D2D1_THREADING_MODE threadingMode,
    D2D1_DEBUG_LEVEL debugLevel,
    D2D1_DEVICE_CONTEXT_OPTIONS options
    )
{
    D2D1_CREATION_PROPERTIES creationProperties;

    creationProperties.threadingMode = threadingMode;
    creationProperties.debugLevel = debugLevel;
    creationProperties.options = options;

    return creationProperties;
}

D2D1_VECTOR_2F
Vector2F(
    FLOAT x = 0.0f,
    FLOAT y = 0.0f
    )
{
    D2D1_VECTOR_2F vec2 = {x, y};
    return vec2;
}

D2D1_VECTOR_3F
Vector3F(
    FLOAT x = 0.0f,
    FLOAT y = 0.0f,
    FLOAT z = 0.0f
    )
{
    D2D1_VECTOR_3F vec3 = {x, y, z};
    return vec3;
}

D2D1_VECTOR_4F
Vector4F(
    FLOAT x = 0.0f,
    FLOAT y = 0.0f,
    FLOAT z = 0.0f,
    FLOAT w = 0.0f
    )
{
    D2D1_VECTOR_4F vec4 = {x, y, z, w};
    return vec4;
}

D2D1_POINT_2L
Point2L(
    INT32 x = 0,
    INT32 y = 0
    )
{
    return D2D1_POINT_2L(x, y);
}

D2D1_RECT_L
RectL(
    INT32 left = 0,
    INT32 top = 0,
    INT32 right = 0,
    INT32 bottom = 0
    )
{
    return D2D1_RECT_L(left, top, right, bottom);
}

///
/// Sets a bitmap as an effect input, while inserting a DPI compensation effect
/// to preserve visual appearance as the device context's DPI changes.
/// 
HRESULT
SetDpiCompensatedEffectInput(
    ID2D1DeviceContext deviceContext,
    ID2D1Effect effect,
    UINT32 inputIndex,
    ID2D1Bitmap inputBitmap,
    D2D1_INTERPOLATION_MODE interpolationMode = D2D1_INTERPOLATION_MODE_LINEAR,
    D2D1_BORDER_MODE borderMode = D2D1_BORDER_MODE_HARD
    )
{
    HRESULT hr = S_OK;
    ID2D1Effect dpiCompensationEffect = null;

    if (inputBitmap is null)
    {
        effect.SetInput(inputIndex, null);
        return hr;
    }

    hr = deviceContext.CreateEffect(&CLSID_D2D1DpiCompensation, &dpiCompensationEffect);

    if (SUCCEEDED(hr))
    {
            if (SUCCEEDED(hr))
            {
                dpiCompensationEffect.SetInput(0, inputBitmap);

                D2D1_POINT_2F bitmapDpi;
                inputBitmap.GetDpi(bitmapDpi.x, bitmapDpi.y);
                hr = dpiCompensationEffect.SetValue(D2D1_DPICOMPENSATION_PROP_INPUT_DPI, bitmapDpi);
            }

            if (SUCCEEDED(hr))
            {
                hr = dpiCompensationEffect.SetValue(D2D1_DPICOMPENSATION_PROP_INTERPOLATION_MODE, interpolationMode);
            }

            if (SUCCEEDED(hr))
            {
                hr = dpiCompensationEffect.SetValue(D2D1_DPICOMPENSATION_PROP_BORDER_MODE, borderMode);
            }

            if (SUCCEEDED(hr))
            {
                effect.SetInputEffect(inputIndex, dpiCompensationEffect);
            }

            if (dpiCompensationEffect !is null)
            {
                dpiCompensationEffect.Release();
            }
    }

    return hr;
}
