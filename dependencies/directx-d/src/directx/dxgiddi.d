module directx.dxgiddi;
/*==========================================================================;
*
*  Copyright (C) Microsoft Corporation.  All Rights Reserved.
*
*  Content: DXGI Basic Device Driver Interface Definitions
*
***************************************************************************/

version(Windows):

public import directx.dxgitype;

import std.bitmanip : bitfields;

import directx.dxgi;
import directx.d3dukmdt;

//--------------------------------------------------------------------------------------------------------
// DXGI error codes
//--------------------------------------------------------------------------------------------------------
enum _FACDXGI_DDI = 0x87b;

pure nothrow @safe @nogc {
    HRESULT MAKE_DXGI_DDI_HRESULT(UINT code) {
        return MAKE_HRESULT(1, _FACDXGI_DDI, code);
    }

    HRESULT MAKE_DXGI_DDI_STATUS(UINT code) {
        return MAKE_HRESULT(0, _FACDXGI_DDI, code);
    }
}

// DXGI DDI error codes have moved to winerror.h

//========================================================================================================
// This is the standard DDI that any DXGI-enabled user-mode driver should support
//

//--------------------------------------------------------------------------------------------------------
alias UINT_PTR DXGI_DDI_HDEVICE;
alias UINT_PTR DXGI_DDI_HRESOURCE;

//--------------------------------------------------------------------------------------------------------
alias DWORD DXGI_DDI_RESIDENCY;
enum : DXGI_DDI_RESIDENCY
{
    DXGI_DDI_RESIDENCY_FULLY_RESIDENT = 1,
    DXGI_DDI_RESIDENCY_RESIDENT_IN_SHARED_MEMORY = 2,
    DXGI_DDI_RESIDENCY_EVICTED_TO_DISK = 3,
}

//--------------------------------------------------------------------------------------------------------
alias DWORD DXGI_DDI_FLIP_INTERVAL_TYPE;
enum : DXGI_DDI_FLIP_INTERVAL_TYPE
{
    DXGI_DDI_FLIP_INTERVAL_IMMEDIATE = 0,
    DXGI_DDI_FLIP_INTERVAL_ONE       = 1,
    DXGI_DDI_FLIP_INTERVAL_TWO       = 2,
    DXGI_DDI_FLIP_INTERVAL_THREE     = 3,
    DXGI_DDI_FLIP_INTERVAL_FOUR      = 4,
}

//--------------------------------------------------------------------------------------------------------
struct DXGI_DDI_PRESENT_FLAGS
{
    union
    {
        mixin(bitfields!(UINT, "Blt",           1,
                         UINT, "Flip",          1,
                         UINT, "PreferRight",   1,
                         UINT, "TemporaryMono", 1,
                         UINT, "Reserved",     28));
        UINT    Value;
    }
}

//--------------------------------------------------------------------------------------------------------
struct DXGI_DDI_ARG_PRESENT
{
    DXGI_DDI_HDEVICE            hDevice;             //in
    DXGI_DDI_HRESOURCE          hSurfaceToPresent;   //in
    UINT                        SrcSubResourceIndex; // Index of surface level
    DXGI_DDI_HRESOURCE          hDstResource;        // if non-zero, it's the destination of the present
    UINT                        DstSubResourceIndex; // Index of surface level
    void *                      pDXGIContext;        // opaque: Pass this to the Present callback
    DXGI_DDI_PRESENT_FLAGS      Flags;               // Presentation flags.
    DXGI_DDI_FLIP_INTERVAL_TYPE FlipInterval;        // Presentation interval (flip only)
}

//--------------------------------------------------------------------------------------------------------
struct DXGI_DDI_ARG_ROTATE_RESOURCE_IDENTITIES
{
    DXGI_DDI_HDEVICE hDevice; //in
    const(DXGI_DDI_HRESOURCE)* pResources; //in: Array of Resources to rotate identities; 0 <= 1, 1 <= 2, etc.
    UINT Resources;
}

struct DXGI_DDI_ARG_GET_GAMMA_CONTROL_CAPS
{
    DXGI_DDI_HDEVICE                        hDevice;                    //in
    DXGI_GAMMA_CONTROL_CAPABILITIES *   pGammaCapabilities; //in/out
}

struct DXGI_DDI_ARG_SET_GAMMA_CONTROL
{
    DXGI_DDI_HDEVICE                        hDevice;                    //in
    DXGI_GAMMA_CONTROL                  GammaControl;       //in
}

struct DXGI_DDI_ARG_SETDISPLAYMODE
{
    DXGI_DDI_HDEVICE                hDevice;                        //in
    DXGI_DDI_HRESOURCE          hResource;              // Source surface
    UINT                        SubResourceIndex;       // Index of surface level
}

struct DXGI_DDI_ARG_SETRESOURCEPRIORITY
{
    DXGI_DDI_HDEVICE            hDevice;                //in
    DXGI_DDI_HRESOURCE          hResource;              //in
    UINT                        Priority;               //in
}

struct DXGI_DDI_ARG_QUERYRESOURCERESIDENCY
{
    DXGI_DDI_HDEVICE            hDevice;                //in
    const(DXGI_DDI_HRESOURCE)*  pResources;             //in
    DXGI_DDI_RESIDENCY *        pStatus;                //out
    SIZE_T                      Resources;              //in
}

//--------------------------------------------------------------------------------------------------------
// Remarks: Fractional value used to represent vertical and horizontal frequencies of a video mode
//          (i.e. VSync and HSync). Vertical frequencies are stored in Hz. Horizontal frequencies
//          are stored in KHz.
//          The dynamic range of this encoding format, given 10^-7 resolution is {0..(2^32 - 1) / 10^7},
//          which translates to {0..428.4967296} [Hz] for vertical frequencies and {0..428.4967296} [KHz]
//          for horizontal frequencies. This sub-microseconds precision range should be acceptable even
//          for a pro-video application (error in one microsecond for video signal synchronization would
//          imply a time drift with a cycle of 10^7/(60*60*24) = 115.741 days.
//
//          If rational number with a finite fractional sequence, use denominator of form 10^(length of fractional sequence).
//          If rational number without a finite fractional sequence, or a sequence exceeding the precision allowed by the
//          dynamic range of the denominator, or an irrational number, use an appropriate ratio of integers which best
//          represents the value.
//
struct DXGI_DDI_RATIONAL
{
    UINT Numerator;
    UINT Denominator;
}

//--------------------------------------------------------------------------------------------------------
alias DWORD DXGI_DDI_MODE_SCANLINE_ORDER;
enum : DXGI_DDI_MODE_SCANLINE_ORDER
{
    DXGI_DDI_MODE_SCANLINE_ORDER_UNSPECIFIED = 0,
    DXGI_DDI_MODE_SCANLINE_ORDER_PROGRESSIVE = 1,
    DXGI_DDI_MODE_SCANLINE_ORDER_UPPER_FIELD_FIRST = 2,
    DXGI_DDI_MODE_SCANLINE_ORDER_LOWER_FIELD_FIRST = 3,
}

alias DWORD DXGI_DDI_MODE_SCALING;
enum : DXGI_DDI_MODE_SCALING
{
    DXGI_DDI_MODE_SCALING_UNSPECIFIED = 0,
    DXGI_DDI_MODE_SCALING_STRETCHED = 1,
    DXGI_DDI_MODE_SCALING_CENTERED = 2,
}

alias DWORD DXGI_DDI_MODE_ROTATION;
enum : DXGI_DDI_MODE_ROTATION
{
    DXGI_DDI_MODE_ROTATION_UNSPECIFIED = 0,
        DXGI_DDI_MODE_ROTATION_IDENTITY = 1,
        DXGI_DDI_MODE_ROTATION_ROTATE90 = 2,
        DXGI_DDI_MODE_ROTATION_ROTATE180 = 3,
        DXGI_DDI_MODE_ROTATION_ROTATE270 = 4,
}

struct DXGI_DDI_MODE_DESC
{
    UINT Width;
    UINT Height;
    DXGI_FORMAT Format;
    DXGI_DDI_RATIONAL RefreshRate;
    DXGI_DDI_MODE_SCANLINE_ORDER ScanlineOrdering;
    DXGI_DDI_MODE_ROTATION Rotation;
    DXGI_DDI_MODE_SCALING Scaling;
}

// Bit indicates that UMD has the option to prevent this Resource from ever being a Primary
// UMD can prevent the actual flip (from optional primary to regular primary) and use a copy
// operation, during Present. Thus, it's possible the UMD can opt out of this Resource being
// actually used as a primary.
enum DXGI_DDI_PRIMARY_OPTIONAL = 0x1;

// Bit indicates that the Primary really represents the IDENTITY rotation, eventhough it will
// be used with non-IDENTITY display modes, since the application will take on the burden of
// honoring the output orientation by rotating, say the viewport and projection matrix.
enum DXGI_DDI_PRIMARY_NONPREROTATED = 0x2;

// Bit indicates that the primary is stereoscopic.
enum DXGI_DDI_PRIMARY_STEREO = 0x4;

// Bit indicates that this primary will be used for indirect presentation
enum DXGI_DDI_PRIMARY_INDIRECT = 0x8;

// Bit indicates that the driver cannot tolerate setting any subresource of the specified
// resource as a primary. The UMD should set this bit at resource creation time if it
// chooses to implement presentation from this surface via a copy operation. The DXGI
// runtime will not employ flip-style presentation if this bit is set
enum DXGI_DDI_PRIMARY_DRIVER_FLAG_NO_SCANOUT = 0x1;

struct DXGI_DDI_PRIMARY_DESC
{
    UINT                           Flags;                       // [in]
    D3DDDI_VIDEO_PRESENT_SOURCE_ID VidPnSourceId;       // [in]
    DXGI_DDI_MODE_DESC             ModeDesc;            // [in]
    UINT                                                   DriverFlags;         // [out] Filled by the driver
}

struct DXGI_DDI_ARG_BLT_FLAGS
{
    union
    {
        mixin(bitfields!(UINT, "Resolve",   1,
                         UINT, "Convert",   1,
                         UINT, "Stretch",   1,
                         UINT, "Present",   1,
                         UINT, "Reserved", 28));
        UINT Value;
    }
}

struct DXGI_DDI_ARG_BLT
{
    DXGI_DDI_HDEVICE            hDevice;                //in
    DXGI_DDI_HRESOURCE          hDstResource;           //in
    UINT                        DstSubresource;         //in
    UINT                        DstLeft;                //in
    UINT                        DstTop;                 //in
    UINT                        DstRight;               //in
    UINT                        DstBottom;              //in
    DXGI_DDI_HRESOURCE          hSrcResource;           //in
    UINT                        SrcSubresource;         //in
    DXGI_DDI_ARG_BLT_FLAGS      Flags;                  //in
    DXGI_DDI_MODE_ROTATION      Rotate;                 //in
}

struct DXGI_DDI_ARG_RESOLVESHAREDRESOURCE
{
    DXGI_DDI_HDEVICE            hDevice;                //in
    DXGI_DDI_HRESOURCE          hResource;              //in
}

struct DXGI_DDI_ARG_BLT1
{
    DXGI_DDI_HDEVICE            hDevice;                //in
    DXGI_DDI_HRESOURCE          hDstResource;           //in
    UINT                        DstSubresource;         //in
    UINT                        DstLeft;                //in
    UINT                        DstTop;                 //in
    UINT                        DstRight;               //in
    UINT                        DstBottom;              //in
    DXGI_DDI_HRESOURCE          hSrcResource;           //in
    UINT                        SrcSubresource;         //in
    UINT                        SrcLeft;                //in
    UINT                        SrcTop;                 //in
    UINT                        SrcRight;               //in
    UINT                        SrcBottom;              //in
    DXGI_DDI_ARG_BLT_FLAGS      Flags;                  //in
    DXGI_DDI_MODE_ROTATION      Rotate;                 //in
}

struct DXGI_DDI_ARG_OFFERRESOURCES {
    DXGI_DDI_HDEVICE hDevice;                           //in:  device that created the resources
    const(DXGI_DDI_HRESOURCE)* pResources;               //in:  array of resources to reset
    UINT Resources;                                     //in:  number of elements in pResources
    D3DDDI_OFFER_PRIORITY Priority;                     //in:  priority with which to reset the resources
}

struct DXGI_DDI_ARG_RECLAIMRESOURCES {
    DXGI_DDI_HDEVICE hDevice;                           //in:  device that created the resources
    const(DXGI_DDI_HRESOURCE)* pResources;               //in:  array of resources to reset
    BOOL* pDiscarded;                                   //out: optional array of booleans specifying whether each resource was discarded
    UINT Resources;                                     //in:  number of elements in pResources and pDiscarded
}

//-----------------------------------------------------------------------------------------------------------
// Multi Plane Overlay DDI
//

enum DXGI_DDI_MAX_MULTIPLANE_OVERLAY_ALLOCATIONS = 16;

struct DXGI_DDI_MULTIPLANE_OVERLAY_CAPS
{
    UINT MaxPlanes;                  // Total number of planes supported (including the DWM's primary)
    UINT NumCapabilityGroups;        // Number of plane types supported.
}

alias DWORD DXGI_DDI_MULTIPLANE_OVERLAY_FEATURE_CAPS;
enum : DXGI_DDI_MULTIPLANE_OVERLAY_FEATURE_CAPS
{
    DXGI_DDI_MULTIPLANE_OVERLAY_FEATURE_CAPS_ROTATION_WITHOUT_INDEPENDENT_FLIP = 0x1,
    DXGI_DDI_MULTIPLANE_OVERLAY_FEATURE_CAPS_VERTICAL_FLIP                     = 0x2,
    DXGI_DDI_MULTIPLANE_OVERLAY_FEATURE_CAPS_HORIZONTAL_FLIP                   = 0x4,
    DXGI_DDI_MULTIPLANE_OVERLAY_FEATURE_CAPS_DEINTERLACE                       = 0x8,
    DXGI_DDI_MULTIPLANE_OVERLAY_FEATURE_CAPS_STEREO                            = 0x10,    // D3D10 or above only.
    DXGI_DDI_MULTIPLANE_OVERLAY_FEATURE_CAPS_RGB                               = 0x20,
    DXGI_DDI_MULTIPLANE_OVERLAY_FEATURE_CAPS_YUV                               = 0x40,
    DXGI_DDI_MULTIPLANE_OVERLAY_FEATURE_CAPS_BILINEAR_FILTER                   = 0x80,    // Can do bilinear stretching
    DXGI_DDI_MULTIPLANE_OVERLAY_FEATURE_CAPS_HIGH_FILTER                       = 0x100,   // Can do better than bilinear stretching
    DXGI_DDI_MULTIPLANE_OVERLAY_FEATURE_CAPS_ROTATION                          = 0x200,
}

alias DWORD DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_CAPS;
enum : DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_CAPS
{
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_CAPS_SEPARATE           = 0x1,
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_CAPS_ROW_INTERLEAVED    = 0x4,
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_CAPS_COLUMN_INTERLEAVED = 0x8,
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_CAPS_CHECKERBOARD       = 0x10,
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_CAPS_FLIP_MODE          = 0x20,
}

struct DXGI_DDI_MULTIPLANE_OVERLAY_GROUP_CAPS
{
    UINT  NumPlanes;
    float MaxStretchFactor;
    float MaxShrinkFactor;
    UINT  OverlayCaps;       // DXGI_DDI_MULTIPLANE_OVERLAY_FEATURE_CAPS
    UINT  StereoCaps;        // DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_CAPS
}

alias DWORD DXGI_DDI_MULTIPLANE_OVERLAY_FLAGS;
enum : DXGI_DDI_MULTIPLANE_OVERLAY_FLAGS
{
    DXGI_DDI_MULTIPLANE_OVERLAY_FLAG_VERTICAL_FLIP                 = 0x1,
    DXGI_DDI_MULTIPLANE_OVERLAY_FLAG_HORIZONTAL_FLIP               = 0x2,
}

alias DWORD DXGI_DDI_MULTIPLANE_OVERLAY_BLEND;
enum : DXGI_DDI_MULTIPLANE_OVERLAY_BLEND
{
    DXGI_DDI_MULTIPLANE_OVERLAY_BLEND_OPAQUE     = 0x0,
    DXGI_DDI_MULTIPLANE_OVERLAY_BLEND_ALPHABLEND = 0x1,
}

alias DWORD DXGI_DDI_MULTIPLANE_OVERLAY_VIDEO_FRAME_FORMAT;
enum : DXGI_DDI_MULTIPLANE_OVERLAY_VIDEO_FRAME_FORMAT
{
    DXGI_DDI_MULIIPLANE_OVERLAY_VIDEO_FRAME_FORMAT_PROGRESSIVE                   = 0,
    DXGI_DDI_MULTIPLANE_OVERLAY_VIDEO_FRAME_FORMAT_INTERLACED_TOP_FIELD_FIRST    = 1,
    DXGI_DDI_MULTIPLANE_OVERLAY_VIDEO_FRAME_FORMAT_INTERLACED_BOTTOM_FIELD_FIRST = 2
}

alias DWORD DXGI_DDI_MULTIPLANE_OVERLAY_YCbCr_FLAGS;
enum : DXGI_DDI_MULTIPLANE_OVERLAY_YCbCr_FLAGS
{
    DXGI_DDI_MULTIPLANE_OVERLAY_YCbCr_FLAG_NOMINAL_RANGE = 0x1, // 16 - 235 vs. 0 - 255
    DXGI_DDI_MULTIPLANE_OVERLAY_YCbCr_FLAG_BT709         = 0x2, // BT.709 vs. BT.601
    DXGI_DDI_MULTIPLANE_OVERLAY_YCbCr_FLAG_xvYCC         = 0x4, // xvYCC vs. conventional YCbCr
}

alias DWORD DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FORMAT;
enum : DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FORMAT
{
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FORMAT_MONO               = 0,
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FORMAT_HORIZONTAL         = 1,
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FORMAT_VERTICAL           = 2,
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FORMAT_SEPARATE           = 3,
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FORMAT_MONO_OFFSET        = 4,
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FORMAT_ROW_INTERLEAVED    = 5,
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FORMAT_COLUMN_INTERLEAVED = 6,
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FORMAT_CHECKERBOARD       = 7
}

alias DWORD DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FLIP_MODE;
enum : DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FLIP_MODE
{
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FLIP_NONE   = 0,
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FLIP_FRAME0 = 1,
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FLIP_FRAME1 = 2,
}

alias DWORD DXGI_DDI_MULTIPLANE_OVERLAY_STRETCH_QUALITY;
enum : DXGI_DDI_MULTIPLANE_OVERLAY_STRETCH_QUALITY
{
    DXGI_DDI_MULTIPLANE_OVERLAY_STRETCH_QUALITY_BILINEAR        = 0x1,  // Bilinear
    DXGI_DDI_MULTIPLANE_OVERLAY_STRETCH_QUALITY_HIGH            = 0x2,  // Maximum
}

struct DXGI_DDI_MULTIPLANE_OVERLAY_ATTRIBUTES
{
    UINT                                           Flags;      // DXGI_DDI_MULTIPLANE_OVERLAY_FLAGS
    RECT                                           SrcRect;
    RECT                                           DstRect;
    //#if (D3D_UMD_INTERFACE_VERSION >= D3D_UMD_INTERFACE_VERSION_WDDM1_3) // M1
    RECT                                           ClipRect;
    //#endif
    DXGI_DDI_MODE_ROTATION                         Rotation;
    DXGI_DDI_MULTIPLANE_OVERLAY_BLEND              Blend;
    //#if (D3D_UMD_INTERFACE_VERSION >= D3D_UMD_INTERFACE_VERSION_WDDM1_3) // MP
    UINT                                           DirtyRectCount;
    RECT*                                          pDirtyRects;
    //#else
    //UINT                                           NumFilters;
    //void*                                          pFilters;
    //#endif
    DXGI_DDI_MULTIPLANE_OVERLAY_VIDEO_FRAME_FORMAT VideoFrameFormat;
    UINT                                           YCbCrFlags; // DXGI_DDI_MULTIPLANE_OVERLAY_YCbCr_FLAGS
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FORMAT      StereoFormat;
    BOOL                                           StereoLeftViewFrame0;
    BOOL                                           StereoBaseViewFrame0;
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FLIP_MODE   StereoFlipMode;
    //#if (D3D_UMD_INTERFACE_VERSION >= D3D_UMD_INTERFACE_VERSION_WDDM1_3) // M1
    DXGI_DDI_MULTIPLANE_OVERLAY_STRETCH_QUALITY    StretchQuality;
    //#endif
}

struct DXGI_DDI_ARG_GETMULTIPLANEOVERLAYCAPS
{
    DXGI_DDI_HDEVICE                       hDevice;
    D3DDDI_VIDEO_PRESENT_SOURCE_ID         VidPnSourceId;
    DXGI_DDI_MULTIPLANE_OVERLAY_CAPS       MultiplaneOverlayCaps;
}

struct DXGI_DDI_ARG_GETMULTIPLANEOVERLAYGROUPCAPS
{
    DXGI_DDI_HDEVICE                        hDevice;
    D3DDDI_VIDEO_PRESENT_SOURCE_ID          VidPnSourceId;
    UINT                                    GroupIndex;
    DXGI_DDI_MULTIPLANE_OVERLAY_GROUP_CAPS  MultiplaneOverlayGroupCaps;
}

struct DXGI_DDI_CHECK_MULTIPLANE_OVERLAY_SUPPORT_PLANE_INFO
{
    DXGI_DDI_HRESOURCE                     hResource;
    UINT                                   SubResourceIndex;
    DXGI_DDI_MULTIPLANE_OVERLAY_ATTRIBUTES PlaneAttributes;
}

struct DXGI_DDI_ARG_CHECKMULTIPLANEOVERLAYSUPPORT
{
    DXGI_DDI_HDEVICE                                      hDevice;
    D3DDDI_VIDEO_PRESENT_SOURCE_ID                        VidPnSourceId;
    UINT                                                  NumPlaneInfo;
    DXGI_DDI_CHECK_MULTIPLANE_OVERLAY_SUPPORT_PLANE_INFO* pPlaneInfo;
    BOOL                                                  Supported; // out: driver to fill TRUE/FALSE
}

struct DXGI_DDI_PRESENT_MULTIPLANE_OVERLAY
{
    UINT                                 LayerIndex;
    BOOL                                 Enabled;
    DXGI_DDI_HRESOURCE                   hResource;
    UINT                                 SubResourceIndex;
    DXGI_DDI_MULTIPLANE_OVERLAY_ATTRIBUTES PlaneAttributes;
}

struct DXGI_DDI_ARG_PRESENTMULTIPLANEOVERLAY
{
    DXGI_DDI_HDEVICE                     hDevice;
    void *                               pDXGIContext;

    D3DDDI_VIDEO_PRESENT_SOURCE_ID       VidPnSourceId;
    DXGI_DDI_PRESENT_FLAGS               Flags;
    DXGI_DDI_FLIP_INTERVAL_TYPE          FlipInterval;

    UINT                                 PresentPlaneCount;
    DXGI_DDI_PRESENT_MULTIPLANE_OVERLAY* pPresentPlanes;
    //#if (D3D_UMD_INTERFACE_VERSION >= D3D_UMD_INTERFACE_VERSION_WDDM1_3) // M1
    UINT                                 Reserved;
    //#endif
}

struct DXGI_DDI_ARG_CHECKPRESENTDURATIONSUPPORT
{
    DXGI_DDI_HDEVICE                hDevice;
    D3DDDI_VIDEO_PRESENT_SOURCE_ID  VidPnSourceId;
    UINT                            DesiredPresentDuration;
    UINT                            ClosestSmallerDuration;  // out
    UINT                            ClosestLargerDuration;   //out
}

struct DXGI_DDI_ARG_PRESENTSURFACE
{
    DXGI_DDI_HRESOURCE hSurface;         // In
    UINT               SubResourceIndex; // Index of surface level
}

struct DXGI_DDI_ARG_PRESENT1
{
    DXGI_DDI_HDEVICE                   hDevice;             //in
    const(DXGI_DDI_ARG_PRESENTSURFACE)* phSurfacesToPresent; //in
    UINT                               SurfacesToPresent;   //in
    DXGI_DDI_HRESOURCE                 hDstResource;        // if non-zero, it's the destination of the present
    UINT                               DstSubResourceIndex; // Index of surface level
    void *                             pDXGIContext;        // opaque: Pass this to the Present callback
    DXGI_DDI_PRESENT_FLAGS             Flags;               // Presentation flags.
    DXGI_DDI_FLIP_INTERVAL_TYPE        FlipInterval;        // Presentation interval (flip only)
    UINT                               Reserved;
    const(RECT)*                        pDirtyRects;         // in: Array of dirty rects
    UINT                               DirtyRects;          // in: Number of dirty rects

    //#if (D3D_UMD_INTERFACE_VERSION >= D3D_UMD_INTERFACE_VERSION_WDDM2_0)
    // out: for LDA only.
    // Only WDDM2.0 drivers should write this value
    // The number of physical back buffer per logical back buffer.
    UINT                               BackBufferMultiplicity;
    //#endif
}

struct DXGI_DDI_ARG_TRIMRESIDENCYSET
{
    DXGI_DDI_HDEVICE                hDevice;
    D3DDDI_TRIMRESIDENCYSET_FLAGS   TrimFlags;
    UINT64                          NumBytesToTrim;
}

struct DXGI_DDI_ARG_CHECKMULTIPLANEOVERLAYCOLORSPACESUPPORT
{
    DXGI_DDI_HDEVICE                hDevice;
    D3DDDI_VIDEO_PRESENT_SOURCE_ID  VidPnSourceId;
    DXGI_FORMAT                     Format;
    D3DDDI_COLOR_SPACE_TYPE         ColorSpace;
    BOOL                            Supported;      // out
}

struct DXGI_DDI_MULTIPLANE_OVERLAY_ATTRIBUTES1
{
    UINT                                           Flags;   // DXGI_DDI_MULTIPLANE_OVERLAY_FLAGS
    RECT                                           SrcRect;
    RECT                                           DstRect;
    RECT                                           ClipRect;
    DXGI_DDI_MODE_ROTATION                         Rotation;
    DXGI_DDI_MULTIPLANE_OVERLAY_BLEND              Blend;
    UINT                                           DirtyRectCount;
    RECT*                                          pDirtyRects;
    DXGI_DDI_MULTIPLANE_OVERLAY_VIDEO_FRAME_FORMAT VideoFrameFormat;
    D3DDDI_COLOR_SPACE_TYPE                        ColorSpace;
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FORMAT      StereoFormat;
    BOOL                                           StereoLeftViewFrame0;
    BOOL                                           StereoBaseViewFrame0;
    DXGI_DDI_MULTIPLANE_OVERLAY_STEREO_FLIP_MODE   StereoFlipMode;
    DXGI_DDI_MULTIPLANE_OVERLAY_STRETCH_QUALITY    StretchQuality;
    UINT                                           ColorKey;
}

struct DXGI_DDI_PRESENT_MULTIPLANE_OVERLAY1
{
    UINT                                    LayerIndex;
    BOOL                                    Enabled;
    DXGI_DDI_HRESOURCE                      hResource;
    UINT                                    SubResourceIndex;
    DXGI_DDI_MULTIPLANE_OVERLAY_ATTRIBUTES1 PlaneAttributes;
}

struct DXGI_DDI_ARG_PRESENTMULTIPLANEOVERLAY1
{
    DXGI_DDI_HDEVICE                      hDevice;
    void *                                pDXGIContext;

    D3DDDI_VIDEO_PRESENT_SOURCE_ID        VidPnSourceId;
    DXGI_DDI_PRESENT_FLAGS                Flags;
    DXGI_DDI_FLIP_INTERVAL_TYPE           FlipInterval;

    UINT                                  PresentPlaneCount;
    DXGI_DDI_PRESENT_MULTIPLANE_OVERLAY1* pPresentPlanes;
}

//--------------------------------------------------------------------------------------------------------
struct DXGI_DDI_BASE_FUNCTIONS
{
    extern (Windows):
    HRESULT function(DXGI_DDI_ARG_PRESENT*) pfnPresent;
    HRESULT function(DXGI_DDI_ARG_GET_GAMMA_CONTROL_CAPS*) pfnGetGammaCaps;
    HRESULT function(DXGI_DDI_ARG_SETDISPLAYMODE*) pfnSetDisplayMode;
    HRESULT function(DXGI_DDI_ARG_SETRESOURCEPRIORITY*) pfnSetResourcePriority;
    HRESULT function(DXGI_DDI_ARG_QUERYRESOURCERESIDENCY*) pfnQueryResourceResidency;
    HRESULT function(DXGI_DDI_ARG_ROTATE_RESOURCE_IDENTITIES*) pfnRotateResourceIdentities;
    HRESULT function(DXGI_DDI_ARG_BLT*) pfnBlt;
}

//--------------------------------------------------------------------------------------------------------
struct DXGI1_1_DDI_BASE_FUNCTIONS
{
    extern (Windows):
    HRESULT function(DXGI_DDI_ARG_PRESENT*) pfnPresent;
    HRESULT function(DXGI_DDI_ARG_GET_GAMMA_CONTROL_CAPS*) pfnGetGammaCaps;
    HRESULT function(DXGI_DDI_ARG_SETDISPLAYMODE*) pfnSetDisplayMode;
    HRESULT function(DXGI_DDI_ARG_SETRESOURCEPRIORITY*) pfnSetResourcePriority;
    HRESULT function(DXGI_DDI_ARG_QUERYRESOURCERESIDENCY*) pfnQueryResourceResidency;
    HRESULT function(DXGI_DDI_ARG_ROTATE_RESOURCE_IDENTITIES*) pfnRotateResourceIdentities;
    HRESULT function(DXGI_DDI_ARG_BLT*) pfnBlt;
    HRESULT function(DXGI_DDI_ARG_RESOLVESHAREDRESOURCE*) pfnResolveSharedResource;
}

//--------------------------------------------------------------------------------------------------------
struct DXGI1_2_DDI_BASE_FUNCTIONS
{
    extern (Windows):
    HRESULT function(DXGI_DDI_ARG_PRESENT*) pfnPresent;
    HRESULT function(DXGI_DDI_ARG_GET_GAMMA_CONTROL_CAPS*) pfnGetGammaCaps;
    HRESULT function(DXGI_DDI_ARG_SETDISPLAYMODE*) pfnSetDisplayMode;
    HRESULT function(DXGI_DDI_ARG_SETRESOURCEPRIORITY*) pfnSetResourcePriority;
    HRESULT function(DXGI_DDI_ARG_QUERYRESOURCERESIDENCY*) pfnQueryResourceResidency;
    HRESULT function(DXGI_DDI_ARG_ROTATE_RESOURCE_IDENTITIES*) pfnRotateResourceIdentities;
    HRESULT function(DXGI_DDI_ARG_BLT*) pfnBlt;
    HRESULT function(DXGI_DDI_ARG_RESOLVESHAREDRESOURCE*) pfnResolveSharedResource;
    HRESULT function(DXGI_DDI_ARG_BLT1*) pfnBlt1;
    HRESULT function(DXGI_DDI_ARG_OFFERRESOURCES*) pfnOfferResources;
    HRESULT function(DXGI_DDI_ARG_RECLAIMRESOURCES*) pfnReclaimResources;
    // Use IS_DXGI_MULTIPLANE_OVERLAY_FUNCTIONS macro to determine these functions fields are available
    HRESULT function(DXGI_DDI_ARG_GETMULTIPLANEOVERLAYCAPS*) pfnGetMultiplaneOverlayCaps;
    HRESULT function(void*) pfnGetMultiplaneOverlayFilterRange;
    HRESULT function(DXGI_DDI_ARG_CHECKMULTIPLANEOVERLAYSUPPORT*) pfnCheckMultiplaneOverlaySupport;
    HRESULT function(DXGI_DDI_ARG_PRESENTMULTIPLANEOVERLAY*) pfnPresentMultiplaneOverlay;
}

//--------------------------------------------------------------------------------------------------------
struct DXGI1_3_DDI_BASE_FUNCTIONS
{
    extern (Windows):
    HRESULT function(DXGI_DDI_ARG_PRESENT*) pfnPresent;
    HRESULT function(DXGI_DDI_ARG_GET_GAMMA_CONTROL_CAPS*) pfnGetGammaCaps;
    HRESULT function(DXGI_DDI_ARG_SETDISPLAYMODE*) pfnSetDisplayMode;
    HRESULT function(DXGI_DDI_ARG_SETRESOURCEPRIORITY*) pfnSetResourcePriority;
    HRESULT function(DXGI_DDI_ARG_QUERYRESOURCERESIDENCY*) pfnQueryResourceResidency;
    HRESULT function(DXGI_DDI_ARG_ROTATE_RESOURCE_IDENTITIES*) pfnRotateResourceIdentities;
    HRESULT function(DXGI_DDI_ARG_BLT*) pfnBlt;
    HRESULT function(DXGI_DDI_ARG_RESOLVESHAREDRESOURCE*) pfnResolveSharedResource;
    HRESULT function(DXGI_DDI_ARG_BLT1*) pfnBlt1;
    HRESULT function(DXGI_DDI_ARG_OFFERRESOURCES*) pfnOfferResources;
    HRESULT function(DXGI_DDI_ARG_RECLAIMRESOURCES*) pfnReclaimResources;
    HRESULT function(DXGI_DDI_ARG_GETMULTIPLANEOVERLAYCAPS*) pfnGetMultiplaneOverlayCaps;
    HRESULT function(DXGI_DDI_ARG_GETMULTIPLANEOVERLAYGROUPCAPS*) pfnGetMultiplaneOverlayGroupCaps;
    HRESULT function(void*) pfnReserved1;
    HRESULT function(DXGI_DDI_ARG_PRESENTMULTIPLANEOVERLAY*) pfnPresentMultiplaneOverlay;
    HRESULT function(void*) pfnReserved2;
    HRESULT function(DXGI_DDI_ARG_PRESENT1*) pfnPresent1;
    HRESULT function(DXGI_DDI_ARG_CHECKPRESENTDURATIONSUPPORT*) pfnCheckPresentDurationSupport;
}

//--------------------------------------------------------------------------------------------------------
struct DXGI1_4_DDI_BASE_FUNCTIONS
{
    extern (Windows):
    HRESULT function(DXGI_DDI_ARG_PRESENT*) pfnPresent;
    HRESULT function(DXGI_DDI_ARG_GET_GAMMA_CONTROL_CAPS*) pfnGetGammaCaps;
    HRESULT function(DXGI_DDI_ARG_SETDISPLAYMODE*) pfnSetDisplayMode;
    HRESULT function(DXGI_DDI_ARG_SETRESOURCEPRIORITY*) pfnSetResourcePriority;
    HRESULT function(DXGI_DDI_ARG_QUERYRESOURCERESIDENCY*) pfnQueryResourceResidency;
    HRESULT function(DXGI_DDI_ARG_ROTATE_RESOURCE_IDENTITIES*) pfnRotateResourceIdentities;
    HRESULT function(DXGI_DDI_ARG_BLT*) pfnBlt;
    HRESULT function(DXGI_DDI_ARG_RESOLVESHAREDRESOURCE*) pfnResolveSharedResource;
    HRESULT function(DXGI_DDI_ARG_BLT1*) pfnBlt1;
    HRESULT function(DXGI_DDI_ARG_OFFERRESOURCES*) pfnOfferResources;
    HRESULT function(DXGI_DDI_ARG_RECLAIMRESOURCES*) pfnReclaimResources;
    HRESULT function(DXGI_DDI_ARG_GETMULTIPLANEOVERLAYCAPS*) pfnGetMultiplaneOverlayCaps;
    HRESULT function(DXGI_DDI_ARG_GETMULTIPLANEOVERLAYGROUPCAPS*) pfnGetMultiplaneOverlayGroupCaps;
    HRESULT function(void*) pfnReserved1;
    HRESULT function(DXGI_DDI_ARG_PRESENTMULTIPLANEOVERLAY*) pfnPresentMultiplaneOverlay;
    HRESULT function(void*) pfnReserved2;
    HRESULT function(DXGI_DDI_ARG_PRESENT1*) pfnPresent1;
    HRESULT function(DXGI_DDI_ARG_CHECKPRESENTDURATIONSUPPORT*) pfnCheckPresentDurationSupport;
    HRESULT function(DXGI_DDI_ARG_TRIMRESIDENCYSET*) pfnTrimResidencySet;
    HRESULT function(DXGI_DDI_ARG_CHECKMULTIPLANEOVERLAYCOLORSPACESUPPORT*) pfnCheckMultiplaneOverlayColorSpaceSupport;
    HRESULT function(DXGI_DDI_ARG_PRESENTMULTIPLANEOVERLAY1*) pfnPresentMultiplaneOverlay1;
}

//========================================================================================================
// DXGI callback definitions.
//

//--------------------------------------------------------------------------------------------------------
struct DXGIDDICB_PRESENT
{
    D3DKMT_HANDLE   hSrcAllocation;             // in: The allocation of which content will be presented
    D3DKMT_HANDLE   hDstAllocation;             // in: if non-zero, it's the destination allocation of the present
    void *          pDXGIContext;               // opaque: Fill this with the value in DXGI_DDI_ARG_PRESENT.pDXGIContext
    HANDLE          hContext;                   // in: Context being submitted to.
    UINT            BroadcastContextCount;      // in: Specifies the number of context
    //     to broadcast this present operation to.
    //     Only supported for flip operation.
    HANDLE[D3DDDI_MAX_BROADCAST_CONTEXT]          BroadcastContext; // in: Specifies the handle of the context to
    //     broadcast to.
    D3DKMT_HANDLE*              BroadcastSrcAllocation;                         // in: LDA
    D3DKMT_HANDLE*              BroadcastDstAllocation;                         // in: LDA
    UINT                        PrivateDriverDataSize;                          // in:
    PVOID                       pPrivateDriverData;                             // in: Private driver data to pass to DdiPresent and DdiSetVidPnSourceAddress
    BOOLEAN                     bOptimizeForComposition;                        // out: DWM is involved in composition
}

struct DXGIDDI_MULTIPLANE_OVERLAY_ALLOCATION_INFO
{
    D3DKMT_HANDLE PresentAllocation;
    UINT SubResourceIndex;
}

struct DXGIDDICB_PRESENT_MULTIPLANE_OVERLAY
{
    void *          pDXGIContext;               // opaque: Fill this with the value in DXGI_DDI_ARG_PRESENT.pDXGIContext
    HANDLE          hContext;

    UINT            BroadcastContextCount;
    HANDLE[D3DDDI_MAX_BROADCAST_CONTEXT]          BroadcastContext;

    DWORD           AllocationInfoCount;
    DXGIDDI_MULTIPLANE_OVERLAY_ALLOCATION_INFO[DXGI_DDI_MAX_MULTIPLANE_OVERLAY_ALLOCATIONS] AllocationInfo;
}

extern (Windows) {
    alias HRESULT function(HANDLE hDevice, DXGIDDICB_PRESENT*) PFNDDXGIDDI_PRESENTCB;

    alias HRESULT function(HANDLE hDevice, const(DXGIDDICB_PRESENT_MULTIPLANE_OVERLAY)*) PFNDDXGIDDI_PRESENT_MULTIPLANE_OVERLAYCB;
}

//--------------------------------------------------------------------------------------------------------
struct DXGI_DDI_BASE_CALLBACKS
{
    PFNDDXGIDDI_PRESENTCB                pfnPresentCb;
    //#if (D3D_UMD_INTERFACE_VERSION >= D3D_UMD_INTERFACE_VERSION_WIN8)
    // Use IS_DXGI_MULTIPLANE_OVERLAY_FUNCTIONS macro to check if field is available.
    PFNDDXGIDDI_PRESENT_MULTIPLANE_OVERLAYCB pfnPresentMultiplaneOverlayCb;
    //#endif // (D3D_UMD_INTERFACE_VERSION >= D3D_UMD_INTERFACE_VERSION_WIN8)
}

//========================================================================================================
// DXGI basic DDI device creation arguments

struct DXGI_DDI_BASE_ARGS
{
    DXGI_DDI_BASE_CALLBACKS *pDXGIBaseCallbacks;            // in: The driver should record this pointer for later use
    union
    {
        //#if (D3D_UMD_INTERFACE_VERSION >= D3D_UMD_INTERFACE_VERSION_WDDM2_0)
        DXGI1_4_DDI_BASE_FUNCTIONS *pDXGIDDIBaseFunctions5; // in/out: The driver should fill the denoted struct with DXGI base driver entry points
        //#endif
        //#if (D3D_UMD_INTERFACE_VERSION >= D3D_UMD_INTERFACE_VERSION_WDDM1_3) // M1
        DXGI1_3_DDI_BASE_FUNCTIONS *pDXGIDDIBaseFunctions4; // in/out: The driver should fill the denoted struct with DXGI base driver entry points
        //#endif
        //#if (D3D_UMD_INTERFACE_VERSION >= D3D_UMD_INTERFACE_VERSION_WIN8)
        DXGI1_2_DDI_BASE_FUNCTIONS *pDXGIDDIBaseFunctions3; // in/out: The driver should fill the denoted struct with DXGI base driver entry points
        //#endif
        DXGI1_1_DDI_BASE_FUNCTIONS *pDXGIDDIBaseFunctions2; // in/out: The driver should fill the denoted struct with DXGI base driver entry points
        DXGI_DDI_BASE_FUNCTIONS *pDXGIDDIBaseFunctions;     // in/out: The driver should fill the denoted struct with DXGI base driver entry points
    }
}
