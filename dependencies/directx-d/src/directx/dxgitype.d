module directx.dxgitype;
//
//    Copyright (C) Microsoft.  All rights reserved.
//

version(Windows):

public import directx.dxgiformat;

import directx.win32;
import directx.d3dcommon;

enum _FACDXGI   = 0x87a;

HRESULT MAKE_DXGI_HRESULT(T)(T code) {
	return MAKE_HRESULT(1, _FACDXGI, code);
}

HRESULT MAKE_DXGI_STATUS(T)(T code) {
	return MAKE_HRESULT(0, _FACDXGI, code);
}

// DXGI error messages have moved to winerror.h
enum DXGI_STATUS_OCCLUDED                   = MAKE_DXGI_STATUS(1);
enum DXGI_STATUS_CLIPPED                    = MAKE_DXGI_STATUS(2);
enum DXGI_STATUS_NO_REDIRECTION             = MAKE_DXGI_STATUS(4);
enum DXGI_STATUS_NO_DESKTOP_ACCESS          = MAKE_DXGI_STATUS(5);
enum DXGI_STATUS_GRAPHICS_VIDPN_SOURCE_IN_USE = MAKE_DXGI_STATUS(6);
enum DXGI_STATUS_MODE_CHANGED               = MAKE_DXGI_STATUS(7);
enum DXGI_STATUS_MODE_CHANGE_IN_PROGRESS    = MAKE_DXGI_STATUS(8);

enum DXGI_ERROR_INVALID_CALL                = MAKE_DXGI_HRESULT(1);
enum DXGI_ERROR_NOT_FOUND                   = MAKE_DXGI_HRESULT(2);
enum DXGI_ERROR_MORE_DATA                   = MAKE_DXGI_HRESULT(3);
enum DXGI_ERROR_UNSUPPORTED                 = MAKE_DXGI_HRESULT(4);
enum DXGI_ERROR_DEVICE_REMOVED              = MAKE_DXGI_HRESULT(5);
enum DXGI_ERROR_DEVICE_HUNG                 = MAKE_DXGI_HRESULT(6);
enum DXGI_ERROR_DEVICE_RESET                = MAKE_DXGI_HRESULT(7);
enum DXGI_ERROR_WAS_STILL_DRAWING           = MAKE_DXGI_HRESULT(10);
enum DXGI_ERROR_FRAME_STATISTICS_DISJOINT   = MAKE_DXGI_HRESULT(11);
enum DXGI_ERROR_GRAPHICS_VIDPN_SOURCE_IN_USE = MAKE_DXGI_HRESULT(12);
enum DXGI_ERROR_DRIVER_INTERNAL_ERROR       = MAKE_DXGI_HRESULT(32);
enum DXGI_ERROR_NONEXCLUSIVE                = MAKE_DXGI_HRESULT(33);
enum DXGI_ERROR_NOT_CURRENTLY_AVAILABLE     = MAKE_DXGI_HRESULT(34);
enum DXGI_ERROR_REMOTE_CLIENT_DISCONNECTED  = MAKE_DXGI_HRESULT(35);
enum DXGI_ERROR_REMOTE_OUTOFMEMORY          = MAKE_DXGI_HRESULT(36);

struct DXGI_RGB
{
    float Red;
    float Green;
    float Blue;
}

struct DXGI_RGBA {
    float r;
    float g;
    float b;
    float a;
}

struct DXGI_GAMMA_CONTROL
{
    DXGI_RGB Scale;
    DXGI_RGB Offset;
    DXGI_RGB[ 1025 ] GammaCurve;
}

struct DXGI_GAMMA_CONTROL_CAPABILITIES
{
    int ScaleAndOffsetSupported;
    float MaxConvertedValue;
    float MinConvertedValue;
    uint NumGammaControlPoints;
    float[1025] ControlPointPositions;
}

struct DXGI_RATIONAL
{
    uint Numerator;
    uint Denominator;
}

alias DXGI_MODE_SCANLINE_ORDER = int;
enum : DXGI_MODE_SCANLINE_ORDER
{
    DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED        = 0,
    DXGI_MODE_SCANLINE_ORDER_PROGRESSIVE        = 1,
    DXGI_MODE_SCANLINE_ORDER_UPPER_FIELD_FIRST  = 2,
    DXGI_MODE_SCANLINE_ORDER_LOWER_FIELD_FIRST  = 3
}

alias DXGI_MODE_SCALING = int;
enum : DXGI_MODE_SCALING
{
    DXGI_MODE_SCALING_UNSPECIFIED   = 0,
    DXGI_MODE_SCALING_CENTERED      = 1,
    DXGI_MODE_SCALING_STRETCHED     = 2
}

alias DXGI_MODE_ROTATION = int;
enum : DXGI_MODE_ROTATION
{
    DXGI_MODE_ROTATION_UNSPECIFIED  = 0,
    DXGI_MODE_ROTATION_IDENTITY     = 1,
    DXGI_MODE_ROTATION_ROTATE90     = 2,
    DXGI_MODE_ROTATION_ROTATE180    = 3,
    DXGI_MODE_ROTATION_ROTATE270    = 4
}

struct DXGI_MODE_DESC
{
    uint Width;
    uint Height;
    DXGI_RATIONAL RefreshRate;
    DXGI_FORMAT Format;
    DXGI_MODE_SCANLINE_ORDER ScanlineOrdering;
    DXGI_MODE_SCALING Scaling;
}

// The following values are used with DXGI_SAMPLE_DESC::Quality:
enum DXGI_STANDARD_MULTISAMPLE_QUALITY_PATTERN = 0xffffffff;
enum DXGI_CENTER_MULTISAMPLE_QUALITY_PATTERN   = 0xfffffffe;

struct DXGI_SAMPLE_DESC
{
    uint Count;
    uint Quality;
}

alias DWORD DXGI_COLOR_SPACE_TYPE;
enum : DXGI_COLOR_SPACE_TYPE
{
    DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709             = 0,
    DXGI_COLOR_SPACE_RGB_FULL_G10_NONE_P709             = 1,
    DXGI_COLOR_SPACE_RGB_STUDIO_G22_NONE_P709           = 2,
    DXGI_COLOR_SPACE_RGB_STUDIO_G22_NONE_P2020          = 3,
    DXGI_COLOR_SPACE_RESERVED                           = 4,
    DXGI_COLOR_SPACE_YCBCR_FULL_G22_NONE_P709_X601      = 5,
    DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P601         = 6,
    DXGI_COLOR_SPACE_YCBCR_FULL_G22_LEFT_P601           = 7,
    DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P709         = 8,
    DXGI_COLOR_SPACE_YCBCR_FULL_G22_LEFT_P709           = 9,
    DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P2020        = 10,
    DXGI_COLOR_SPACE_YCBCR_FULL_G22_LEFT_P2020          = 11,
    DXGI_COLOR_SPACE_CUSTOM                             = 0xFFFFFFFF
}

struct DXGI_JPEG_DC_HUFFMAN_TABLE
{
    BYTE[12] CodeCounts;
    BYTE[12] CodeValues;
}

struct DXGI_JPEG_AC_HUFFMAN_TABLE
{
    BYTE[16] CodeCounts;
    BYTE[162] CodeValues;
}

struct DXGI_JPEG_QUANTIZATION_TABLE
{
    BYTE[64] Elements;
}
