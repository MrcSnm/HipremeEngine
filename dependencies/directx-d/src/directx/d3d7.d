module directx.d3d7;

version(Windows):

import directx.win32;
import directx.com;
import directx.d3dcommon;

enum DD_ROP_SPACE = 256 / 32;

struct DDSCAPS {
    DWORD dwCaps;         // capabilities of surface wanted
}
alias LPDDSCAPS = DDSCAPS*;

enum {
    DDSD_CAPS              = 0x00000001,
    DDSD_HEIGHT            = 0x00000002,
    DDSD_WIDTH             = 0x00000004,
    DDSD_PITCH             = 0x00000008,
    DDSD_BACKBUFFERCOUNT   = 0x00000020,
    DDSD_ZBUFFERBITDEPTH   = 0x00000040,
    DDSD_ALPHABITDEPTH     = 0x00000080,
    DDSD_LPSURFACE         = 0x00000800,
    DDSD_PIXELFORMAT       = 0x00001000,
    DDSD_CKDESTOVERLAY     = 0x00002000,
    DDSD_CKDESTBLT         = 0x00004000,
    DDSD_CKSRCOVERLAY      = 0x00008000,
    DDSD_CKSRCBLT          = 0x00010000,
    DDSD_MIPMAPCOUNT       = 0x00020000,
    DDSD_REFRESHRATE       = 0x00040000,
    DDSD_LINEARSIZE        = 0x00080000,
    DDSD_TEXTURESTAGE      = 0x00100000,
    DDSD_FVF               = 0x00200000,
    DDSD_SRCVBHANDLE       = 0x00400000,
    DDSD_DEPTH             = 0x00800000,
    DDSD_ALL               = 0x00fff9ee
}

enum {
    DDSCAPS_RESERVED1                      = 0x00000001,
    DDSCAPS_ALPHA                          = 0x00000002,
    DDSCAPS_BACKBUFFER                     = 0x00000004,
    DDSCAPS_COMPLEX                        = 0x00000008,
    DDSCAPS_FLIP                           = 0x00000010,
    DDSCAPS_FRONTBUFFER                    = 0x00000020,
    DDSCAPS_OFFSCREENPLAIN                 = 0x00000040,
    DDSCAPS_OVERLAY                        = 0x00000080,
    DDSCAPS_PALETTE                        = 0x00000100,
    DDSCAPS_PRIMARYSURFACE                 = 0x00000200,
    DDSCAPS_RESERVED3                      = 0x00000400,
    DDSCAPS_PRIMARYSURFACELEFT             = 0x00000000,
    DDSCAPS_SYSTEMMEMORY                   = 0x00000800,
    DDSCAPS_TEXTURE                        = 0x00001000,
    DDSCAPS_3DDEVICE                       = 0x00002000,
    DDSCAPS_VIDEOMEMORY                    = 0x00004000,
    DDSCAPS_VISIBLE                        = 0x00008000,
    DDSCAPS_WRITEONLY                      = 0x00010000,
    DDSCAPS_ZBUFFER                        = 0x00020000,
    DDSCAPS_OWNDC                          = 0x00040000,
    DDSCAPS_LIVEVIDEO                      = 0x00080000,
    DDSCAPS_HWCODEC                        = 0x00100000,
    DDSCAPS_MODEX                          = 0x00200000,
    DDSCAPS_MIPMAP                         = 0x00400000,
    DDSCAPS_RESERVED2                      = 0x00800000,
    DDSCAPS_ALLOCONLOAD                    = 0x04000000,
    DDSCAPS_VIDEOPORT                      = 0x08000000,
    DDSCAPS_LOCALVIDMEM                    = 0x10000000,
    DDSCAPS_NONLOCALVIDMEM                 = 0x20000000,
    DDSCAPS_STANDARDVGAMODE                = 0x40000000,
    DDSCAPS_OPTIMIZED                      = 0x80000000,
    DDSCAPS2_RESERVED4                     = 0x00000002,
    DDSCAPS2_HARDWAREDEINTERLACE           = 0x00000000,
    DDSCAPS2_HINTDYNAMIC                   = 0x00000004,
    DDSCAPS2_HINTSTATIC                    = 0x00000008,
    DDSCAPS2_TEXTUREMANAGE                 = 0x00000010,
    DDSCAPS2_RESERVED1                     = 0x00000020,
    DDSCAPS2_RESERVED2                     = 0x00000040,
    DDSCAPS2_OPAQUE                        = 0x00000080,
    DDSCAPS2_HINTANTIALIASING              = 0x00000100,
    DDSCAPS2_CUBEMAP                       = 0x00000200,
    DDSCAPS2_CUBEMAP_POSITIVEX             = 0x00000400,
    DDSCAPS2_CUBEMAP_NEGATIVEX             = 0x00000800,
    DDSCAPS2_CUBEMAP_POSITIVEY             = 0x00001000,
    DDSCAPS2_CUBEMAP_NEGATIVEY             = 0x00002000,
    DDSCAPS2_CUBEMAP_POSITIVEZ             = 0x00004000,
    DDSCAPS2_CUBEMAP_NEGATIVEZ             = 0x00008000,
    DDSCAPS2_CUBEMAP_ALLFACES = DDSCAPS2_CUBEMAP_POSITIVEX |
        DDSCAPS2_CUBEMAP_NEGATIVEX |
        DDSCAPS2_CUBEMAP_POSITIVEY |
        DDSCAPS2_CUBEMAP_NEGATIVEY |
        DDSCAPS2_CUBEMAP_POSITIVEZ |
        DDSCAPS2_CUBEMAP_NEGATIVEZ,
    DDSCAPS2_MIPMAPSUBLEVEL                = 0x00010000,
    DDSCAPS2_D3DTEXTUREMANAGE              = 0x00020000,
    DDSCAPS2_DONOTPERSIST                  = 0x00040000,
    DDSCAPS2_STEREOSURFACELEFT             = 0x00080000,
    DDSCAPS2_VOLUME                        = 0x00200000,
    DDSCAPS2_NOTUSERLOCKABLE               = 0x00400000,
    DDSCAPS2_POINTS                        = 0x00800000,
    DDSCAPS2_RTPATCHES                     = 0x01000000,
    DDSCAPS2_NPATCHES                      = 0x02000000,
    DDSCAPS2_RESERVED3                     = 0x04000000,
    DDSCAPS2_DISCARDBACKBUFFER             = 0x10000000,
    DDSCAPS2_ENABLEALPHACHANNEL            = 0x20000000,
    DDSCAPS2_EXTENDEDFORMATPRIMARY         = 0x40000000,
    DDSCAPS2_ADDITIONALPRIMARY             = 0x80000000,
    DDSCAPS3_MULTISAMPLE_MASK              = 0x0000001F,
    DDSCAPS3_MULTISAMPLE_QUALITY_MASK      = 0x000000E0,
    DDSCAPS3_MULTISAMPLE_QUALITY_SHIFT     = 5,
    DDSCAPS3_RESERVED1                     = 0x00000100,
    DDSCAPS3_RESERVED2                     = 0x00000200,
    DDSCAPS3_LIGHTWEIGHTMIPMAP             = 0x00000400,
    DDSCAPS3_AUTOGENMIPMAP                 = 0x00000800,
    DDSCAPS3_DMAP                          = 0x00001000,

    /* D3D9Ex only -- */
    DDSCAPS3_CREATESHAREDRESOURCE          = 0x00002000,
    DDSCAPS3_READONLYRESOURCE              = 0x00004000,
    DDSCAPS3_OPENSHAREDRESOURCE            = 0x00008000
}

struct DDCAPS_DX7 {
    /*  0*/ DWORD   dwSize;                 // size of the DDDRIVERCAPS structure
    /*  4*/ DWORD   dwCaps;                 // driver specific capabilities
    /*  8*/ DWORD   dwCaps2;                // more driver specific capabilites
    /*  c*/ DWORD   dwCKeyCaps;             // color key capabilities of the surface
    /* 10*/ DWORD   dwFXCaps;               // driver specific stretching and effects capabilites
    /* 14*/ DWORD   dwFXAlphaCaps;          // alpha driver specific capabilities
    /* 18*/ DWORD   dwPalCaps;              // palette capabilities
    /* 1c*/ DWORD   dwSVCaps;               // stereo vision capabilities
    /* 20*/ DWORD   dwAlphaBltConstBitDepths;       // DDBD_2,4,8
    /* 24*/ DWORD   dwAlphaBltPixelBitDepths;       // DDBD_1,2,4,8
    /* 28*/ DWORD   dwAlphaBltSurfaceBitDepths;     // DDBD_1,2,4,8
    /* 2c*/ DWORD   dwAlphaOverlayConstBitDepths;   // DDBD_2,4,8
    /* 30*/ DWORD   dwAlphaOverlayPixelBitDepths;   // DDBD_1,2,4,8
    /* 34*/ DWORD   dwAlphaOverlaySurfaceBitDepths; // DDBD_1,2,4,8
    /* 38*/ DWORD   dwZBufferBitDepths;             // DDBD_8,16,24,32
    /* 3c*/ DWORD   dwVidMemTotal;          // total amount of video memory
    /* 40*/ DWORD   dwVidMemFree;           // amount of free video memory
    /* 44*/ DWORD   dwMaxVisibleOverlays;   // maximum number of visible overlays
    /* 48*/ DWORD   dwCurrVisibleOverlays;  // current number of visible overlays
    /* 4c*/ DWORD   dwNumFourCCCodes;       // number of four cc codes
    /* 50*/ DWORD   dwAlignBoundarySrc;     // source rectangle alignment
    /* 54*/ DWORD   dwAlignSizeSrc;         // source rectangle byte size
    /* 58*/ DWORD   dwAlignBoundaryDest;    // dest rectangle alignment
    /* 5c*/ DWORD   dwAlignSizeDest;        // dest rectangle byte size
    /* 60*/ DWORD   dwAlignStrideAlign;     // stride alignment
    /* 64*/ DWORD[DD_ROP_SPACE]   dwRops;   // ROPS supported
    /* 84*/ DDSCAPS ddsOldCaps;             // Was DDSCAPS  ddsCaps. ddsCaps is of type DDSCAPS2 for DX6
    /* 88*/ DWORD   dwMinOverlayStretch;    // minimum overlay stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
    /* 8c*/ DWORD   dwMaxOverlayStretch;    // maximum overlay stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
    /* 90*/ DWORD   dwMinLiveVideoStretch;  // minimum live video stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
    /* 94*/ DWORD   dwMaxLiveVideoStretch;  // maximum live video stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
    /* 98*/ DWORD   dwMinHwCodecStretch;    // minimum hardware codec stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
    /* 9c*/ DWORD   dwMaxHwCodecStretch;    // maximum hardware codec stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
    /* a0*/ DWORD   dwReserved1;            // reserved
    /* a4*/ DWORD   dwReserved2;            // reserved
    /* a8*/ DWORD   dwReserved3;            // reserved
    /* ac*/ DWORD   dwSVBCaps;              // driver specific capabilities for System->Vmem blts
    /* b0*/ DWORD   dwSVBCKeyCaps;          // driver color key capabilities for System->Vmem blts
    /* b4*/ DWORD   dwSVBFXCaps;            // driver FX capabilities for System->Vmem blts
    /* b8*/ DWORD[DD_ROP_SPACE]   dwSVBRops;// ROPS supported for System->Vmem blts
    /* d8*/ DWORD   dwVSBCaps;              // driver specific capabilities for Vmem->System blts
    /* dc*/ DWORD   dwVSBCKeyCaps;          // driver color key capabilities for Vmem->System blts
    /* e0*/ DWORD   dwVSBFXCaps;            // driver FX capabilities for Vmem->System blts
    /* e4*/ DWORD[DD_ROP_SPACE]   dwVSBRops;// ROPS supported for Vmem->System blts
    /*104*/ DWORD   dwSSBCaps;              // driver specific capabilities for System->System blts
    /*108*/ DWORD   dwSSBCKeyCaps;          // driver color key capabilities for System->System blts
    /*10c*/ DWORD   dwSSBFXCaps;            // driver FX capabilities for System->System blts
    /*110*/ DWORD[DD_ROP_SPACE]   dwSSBRops;// ROPS supported for System->System blts
    /*130*/ DWORD   dwMaxVideoPorts;        // maximum number of usable video ports
    /*134*/ DWORD   dwCurrVideoPorts;       // current number of video ports used
    /*138*/ DWORD   dwSVBCaps2;             // more driver specific capabilities for System->Vmem blts
    /*13c*/ DWORD   dwNLVBCaps;               // driver specific capabilities for non-local->local vidmem blts
    /*140*/ DWORD   dwNLVBCaps2;              // more driver specific capabilities non-local->local vidmem blts
    /*144*/ DWORD   dwNLVBCKeyCaps;           // driver color key capabilities for non-local->local vidmem blts
    /*148*/ DWORD   dwNLVBFXCaps;             // driver FX capabilities for non-local->local blts
    /*14c*/ DWORD[DD_ROP_SPACE]   dwNLVBRops; // ROPS supported for non-local->local blts
    // Members added for DX6 release
    /*16c*/ DDSCAPS2 ddsCaps;               // Surface Caps
}
alias LPDDCAPS_DX7 = DDCAPS_DX7*;

alias DDCAPS   = DDCAPS_DX7;
alias LPDDCAPS = LPDDCAPS_DX7;

struct DDCOLORKEY {
    DWORD       dwColorSpaceLowValue;   // low boundary of color space that is to
    // be treated as Color Key, inclusive
    DWORD       dwColorSpaceHighValue;  // high boundary of color space that is
    // to be treated as Color Key, inclusive
}
alias LPDDCOLORKEY = DDCOLORKEY*;

enum MAX_DDDEVICEID_STRING = 512;

struct DDDEVICEIDENTIFIER2 {
    /*
    * These elements are for presentation to the user only. They should not be used to identify particular
    * drivers, since this is unreliable and many different strings may be associated with the same
    * device, and the same driver from different vendors.
    */
    char[MAX_DDDEVICEID_STRING]    szDriver;
    char[MAX_DDDEVICEID_STRING]    szDescription;

    /*
    * This element is the version of the DirectDraw/3D driver. It is legal to do <, > comparisons
    * on the whole 64 bits. Caution should be exercised if you use this element to identify problematic
    * drivers. It is recommended that guidDeviceIdentifier is used for this purpose.
    *
    * This version has the form:
    *  wProduct = HIWORD(liDriverVersion.HighPart)
    *  wVersion = LOWORD(liDriverVersion.HighPart)
    *  wSubVersion = HIWORD(liDriverVersion.LowPart)
    *  wBuild = LOWORD(liDriverVersion.LowPart)
    */
    //    #ifdef _WIN32
    LARGE_INTEGER liDriverVersion;      /* Defined for applications and other 32 bit components */
    //    #else
    //        DWORD   dwDriverVersionLowPart;     /* Defined for 16 bit driver components */
    //        DWORD   dwDriverVersionHighPart;
    //    #endif


    /*
    * These elements can be used to identify particular chipsets. Use with extreme caution.
    *   dwVendorId     Identifies the manufacturer. May be zero if unknown.
    *   dwDeviceId     Identifies the type of chipset. May be zero if unknown.
    *   dwSubSysId     Identifies the subsystem, typically this means the particular board. May be zero if unknown.
    *   dwRevision     Identifies the revision level of the chipset. May be zero if unknown.
    */
    DWORD   dwVendorId;
    DWORD   dwDeviceId;
    DWORD   dwSubSysId;
    DWORD   dwRevision;

    /*
    * This element can be used to check changes in driver/chipset. This GUID is a unique identifier for the
    * driver/chipset pair. Use this element if you wish to track changes to the driver/chipset in order to
    * reprofile the graphics subsystem.
    * This element can also be used to identify particular problematic drivers.
    */
    GUID    guidDeviceIdentifier;

    /*
    * This element is used to determine the Windows Hardware Quality Lab (WHQL)
    * certification level for this driver/device pair.
    */
    DWORD   dwWHQLLevel;
}
alias LPDDDEVICEIDENTIFIER2 = DDDEVICEIDENTIFIER2*;

struct DDPIXELFORMAT {
    DWORD       dwSize;                 // size of structure
    DWORD       dwFlags;                // pixel format flags
    DWORD       dwFourCC;               // (FOURCC code)
    union {
        DWORD   dwRGBBitCount;          // how many bits per pixel
        DWORD   dwYUVBitCount;          // how many bits per pixel
        DWORD   dwZBufferBitDepth;      // how many total bits/pixel in z buffer (including any stencil bits)
        DWORD   dwAlphaBitDepth;        // how many bits for alpha channels
        DWORD   dwLuminanceBitCount;    // how many bits per pixel
        DWORD   dwBumpBitCount;         // how many bits per "buxel", total
        DWORD   dwPrivateFormatBitCount;// Bits per pixel of private driver formats. Only valid in texture
        // format list and if DDPF_D3DFORMAT is set
    }
    union {
        DWORD   dwRBitMask;             // mask for red bit
        DWORD   dwYBitMask;             // mask for Y bits
        DWORD   dwStencilBitDepth;      // how many stencil bits (note: dwZBufferBitDepth-dwStencilBitDepth is total Z-only bits)
        DWORD   dwLuminanceBitMask;     // mask for luminance bits
        DWORD   dwBumpDuBitMask;        // mask for bump map U delta bits
        DWORD   dwOperations;           // DDPF_D3DFORMAT Operations
    }
    union {
        DWORD   dwGBitMask;             // mask for green bits
        DWORD   dwUBitMask;             // mask for U bits
        DWORD   dwZBitMask;             // mask for Z bits
        DWORD   dwBumpDvBitMask;        // mask for bump map V delta bits
        struct {
            WORD    wFlipMSTypes;       // Multisample methods supported via flip for this D3DFORMAT
            WORD    wBltMSTypes;        // Multisample methods supported via blt for this D3DFORMAT
        }

    }
    union {
        DWORD   dwBBitMask;             // mask for blue bits
        DWORD   dwVBitMask;             // mask for V bits
        DWORD   dwStencilBitMask;       // mask for stencil bits
        DWORD   dwBumpLuminanceBitMask; // mask for luminance in bump map
    }
    union {
        DWORD   dwRGBAlphaBitMask;      // mask for alpha channel
        DWORD   dwYUVAlphaBitMask;      // mask for alpha channel
        DWORD   dwLuminanceAlphaBitMask;// mask for alpha channel
        DWORD   dwRGBZBitMask;          // mask for Z channel
        DWORD   dwYUVZBitMask;          // mask for Z channel
    }
}
alias LPDDPIXELFORMAT = DDPIXELFORMAT*;

struct DDSCAPS2 {
    DWORD       dwCaps;         // capabilities of surface wanted
    DWORD       dwCaps2;
    DWORD       dwCaps3;
    union {
        DWORD       dwCaps4;
        DWORD       dwVolumeDepth;
    }
}
alias LPDDSCAPS2 = DDSCAPS2*;

struct DDSURFACEDESC2 {
    DWORD               dwSize;                 // size of the DDSURFACEDESC structure
    DWORD               dwFlags;                // determines what fields are valid
    DWORD               dwHeight;               // height of surface to be created
    DWORD               dwWidth;                // width of input surface
    union {
        LONG            lPitch;                 // distance to start of next line (return value only)
        DWORD           dwLinearSize;           // Formless late-allocated optimized surface size
    }
    union {
        DWORD           dwBackBufferCount;      // number of back buffers requested
        DWORD           dwDepth;                // the depth if this is a volume texture
    }
    union {
        DWORD           dwMipMapCount;          // number of mip-map levels requestde
        // dwZBufferBitDepth removed, use ddpfPixelFormat one instead
        DWORD           dwRefreshRate;          // refresh rate (used when display mode is described)
        DWORD           dwSrcVBHandle;          // The source used in VB::Optimize
    }
    DWORD               dwAlphaBitDepth;        // depth of alpha buffer requested
    DWORD               dwReserved;             // reserved
    LPVOID              lpSurface;              // pointer to the associated surface memory
    union {
        DDCOLORKEY      ddckCKDestOverlay;      // color key for destination overlay use
        DWORD           dwEmptyFaceColor;       // Physical color for empty cubemap faces
    }
    DDCOLORKEY          ddckCKDestBlt;          // color key for destination blt use
    DDCOLORKEY          ddckCKSrcOverlay;       // color key for source overlay use
    DDCOLORKEY          ddckCKSrcBlt;           // color key for source blt use
    union {
        DDPIXELFORMAT   ddpfPixelFormat;        // pixel format description of the surface
        DWORD           dwFVF;                  // vertex format description of vertex buffers
    }
    DDSCAPS2            ddsCaps;                // direct draw surface capabilities
    DWORD               dwTextureStage;         // stage in multitexture cascade
}
alias LPDDSURFACEDESC2 = DDSURFACEDESC2*;

mixin(uuid!(IDirectDraw7, "15e65ec0-3b9c-11d2-b92f-00609797ea5b"));
extern (C++) interface IDirectDraw7 : IUnknown {
    HRESULT Compact();
    HRESULT CreateClipper(DWORD, LPDIRECTDRAWCLIPPER*, IUnknown);
    HRESULT CreatePalette(DWORD, LPPALETTEENTRY, LPDIRECTDRAWPALETTE*, IUnknown);
    HRESULT CreateSurface(LPDDSURFACEDESC2, LPDIRECTDRAWSURFACE7*, IUnknown);
    HRESULT DuplicateSurface(LPDIRECTDRAWSURFACE7, LPDIRECTDRAWSURFACE7*);
    HRESULT EnumDisplayModes(DWORD, LPDDSURFACEDESC2, LPVOID, LPDDENUMMODESCALLBACK2);
    HRESULT EnumSurfaces(DWORD, LPDDSURFACEDESC2, LPVOID, LPDDENUMSURFACESCALLBACK7);
    HRESULT FlipToGDISurface();
    HRESULT GetCaps(LPDDCAPS, LPDDCAPS);
    HRESULT GetDisplayMode(LPDDSURFACEDESC2);
    HRESULT GetFourCCCodes(LPDWORD, LPDWORD );
    HRESULT GetGDISurface(LPDIRECTDRAWSURFACE7*);
    HRESULT GetMonitorFrequency(LPDWORD);
    HRESULT GetScanLine(LPDWORD);
    HRESULT GetVerticalBlankStatus(LPBOOL);
    HRESULT Initialize(GUID*);
    HRESULT RestoreDisplayMode();
    HRESULT SetCooperativeLevel(HWND, DWORD);
    HRESULT SetDisplayMode(DWORD, DWORD, DWORD, DWORD, DWORD);
    HRESULT WaitForVerticalBlank(DWORD, HANDLE);
    /*** Added in the v2 interface ***/
    HRESULT GetAvailableVidMem(LPDDSCAPS2, LPDWORD, LPDWORD);
    /*** Added in the V4 Interface ***/
    HRESULT GetSurfaceFromDC(HDC, LPDIRECTDRAWSURFACE7*);
    HRESULT RestoreAllSurfaces();
    HRESULT TestCooperativeLevel();
    HRESULT GetDeviceIdentifier(LPDDDEVICEIDENTIFIER2, DWORD);
    HRESULT StartModeTest(LPSIZE, DWORD, DWORD);
    HRESULT EvaluateMode(DWORD, DWORD*);
}

extern (C++) interface IDirectDrawClipper : IUnknown {

}
alias LPDIRECTDRAWCLIPPER = IDirectDrawClipper;

extern (C++) interface IDirectDrawPalette : IUnknown {

}
alias LPDIRECTDRAWPALETTE = IDirectDrawPalette;

extern (C++) interface IDirectDrawSurface7 : IUnknown {

}
alias LPDIRECTDRAWSURFACE7 = IDirectDrawSurface7;

extern (Windows) {
    alias LPD3DVALIDATECALLBACK = HRESULT function(LPVOID lpUserArg, DWORD dwOffset);
    //alias LPD3DENUMTEXTUREFORMATSCALLBACK = HRESULT function(LPDDSURFACEDESC lpDdsd, LPVOID lpContext);
    alias LPD3DENUMPIXELFORMATSCALLBACK = HRESULT function(LPDDPIXELFORMAT lpDDPixFmt, LPVOID lpContext);

    alias LPD3DENUMDEVICESCALLBACK7 = HRESULT function
        (LPSTR lpDeviceDescription, LPSTR lpDeviceName, LPD3DDEVICEDESC7, LPVOID);
}

struct D3DVERTEXBUFFERDESC {
    DWORD dwSize;
    DWORD dwCaps;
    DWORD dwFVF;
    DWORD dwNumVertices;
}
alias LPD3DVERTEXBUFFERDESC = D3DVERTEXBUFFERDESC*;

alias D3DVALUE   = float;
alias LPD3DVALUE = D3DVALUE*;

struct D3DPRIMCAPS {
    DWORD dwSize;
    DWORD dwMiscCaps;                 /* Capability flags */
    DWORD dwRasterCaps;
    DWORD dwZCmpCaps;
    DWORD dwSrcBlendCaps;
    DWORD dwDestBlendCaps;
    DWORD dwAlphaCmpCaps;
    DWORD dwShadeCaps;
    DWORD dwTextureCaps;
    DWORD dwTextureFilterCaps;
    DWORD dwTextureBlendCaps;
    DWORD dwTextureAddressCaps;
    DWORD dwStippleWidth;             /* maximum width and height of */
    DWORD dwStippleHeight;            /* of supported stipple (up to 32x32) */
}
alias LPD3DPRIMCAPS = D3DPRIMCAPS*;

struct D3DDEVICEDESC7 {
    DWORD            dwDevCaps;              /* Capabilities of device */
    D3DPRIMCAPS      dpcLineCaps;
    D3DPRIMCAPS      dpcTriCaps;
    DWORD            dwDeviceRenderBitDepth; /* One of DDBB_8, 16, etc.. */
    DWORD            dwDeviceZBufferBitDepth;/* One of DDBD_16, 32, etc.. */

    DWORD       dwMinTextureWidth, dwMinTextureHeight;
    DWORD       dwMaxTextureWidth, dwMaxTextureHeight;

    DWORD       dwMaxTextureRepeat;
    DWORD       dwMaxTextureAspectRatio;
    DWORD       dwMaxAnisotropy;

    D3DVALUE    dvGuardBandLeft;
    D3DVALUE    dvGuardBandTop;
    D3DVALUE    dvGuardBandRight;
    D3DVALUE    dvGuardBandBottom;

    D3DVALUE    dvExtentsAdjust;
    DWORD       dwStencilCaps;

    DWORD       dwFVFCaps;
    DWORD       dwTextureOpCaps;
    WORD        wMaxTextureBlendStages;
    WORD        wMaxSimultaneousTextures;

    DWORD       dwMaxActiveLights;
    D3DVALUE    dvMaxVertexW;
    GUID        deviceGUID;

    WORD        wMaxUserClipPlanes;
    WORD        wMaxVertexBlendMatrices;

    DWORD       dwVertexProcessingCaps;

    DWORD       dwReserved1;
    DWORD       dwReserved2;
    DWORD       dwReserved3;
    DWORD       dwReserved4;
}
alias LPD3DDEVICEDESC7 = D3DDEVICEDESC7*;

mixin(uuid!(IDirect3D7, "f5049e77-4861-11d2-a407-00a0c90629a8"));
extern (C++) interface IDirect3D7 : IUnknown {
    HRESULT EnumDevices(LPD3DENUMDEVICESCALLBACK7,LPVOID);
    HRESULT CreateDevice(REFCLSID,LPDIRECTDRAWSURFACE7,LPDIRECT3DDEVICE7*);
    HRESULT CreateVertexBuffer(LPD3DVERTEXBUFFERDESC,LPDIRECT3DVERTEXBUFFER7*,DWORD);
    HRESULT EnumZBufferFormats(REFCLSID,LPD3DENUMPIXELFORMATSCALLBACK,LPVOID);
    HRESULT EvictManagedTextures();
}
alias LPDIRECT3D7 = IDirect3D7;

struct D3DCLIPSTATUS {
    DWORD dwFlags; /* Do we set 2d extents, 3D extents or status */
    DWORD dwStatus; /* Clip status */
    float minx, maxx; /* X extents */
    float miny, maxy; /* Y extents */
    float minz, maxz; /* Z extents */
}
alias LPD3DCLIPSTATUS = D3DCLIPSTATUS*;

enum {
    D3DCLIPSTATUS_STATUS       = 0x00000001,
    D3DCLIPSTATUS_EXTENTS2     = 0x00000002,
    D3DCLIPSTATUS_EXTENTS3     = 0x00000004
}

struct D3DVIEWPORT7 {
    DWORD       dwX;
    DWORD       dwY;            /* Viewport Top left */
    DWORD       dwWidth;
    DWORD       dwHeight;       /* Viewport Dimensions */
    D3DVALUE    dvMinZ;         /* Min/max of clip Volume */
    D3DVALUE    dvMaxZ;
}
alias LPD3DVIEWPORT7 = D3DVIEWPORT7*;

struct D3DMATERIAL7 {
    union {
        D3DCOLORVALUE   diffuse;        /* Diffuse color RGBA */
        D3DCOLORVALUE   dcvDiffuse;
    }
    union {
        D3DCOLORVALUE   ambient;        /* Ambient color RGB */
        D3DCOLORVALUE   dcvAmbient;
    }
    union {
        D3DCOLORVALUE   specular;       /* Specular 'shininess' */
        D3DCOLORVALUE   dcvSpecular;
    }
    union {
        D3DCOLORVALUE   emissive;       /* Emissive color RGB */
        D3DCOLORVALUE   dcvEmissive;
    }
    union {
        D3DVALUE        power;          /* Sharpness if specular highlight */
        D3DVALUE        dvPower;
    }
}
alias LPD3DMATERIAL7 = D3DMATERIAL7*;

struct D3DLIGHT7 {
    D3DLIGHTTYPE    dltType;            /* Type of light source */
    D3DCOLORVALUE   dcvDiffuse;         /* Diffuse color of light */
    D3DCOLORVALUE   dcvSpecular;        /* Specular color of light */
    D3DCOLORVALUE   dcvAmbient;         /* Ambient color of light */
    D3DVECTOR       dvPosition;         /* Position in world space */
    D3DVECTOR       dvDirection;        /* Direction in world space */
    D3DVALUE        dvRange;            /* Cutoff range */
    D3DVALUE        dvFalloff;          /* Falloff */
    D3DVALUE        dvAttenuation0;     /* Constant attenuation */
    D3DVALUE        dvAttenuation1;     /* Linear attenuation */
    D3DVALUE        dvAttenuation2;     /* Quadratic attenuation */
    D3DVALUE        dvTheta;            /* Inner angle of spotlight cone */
    D3DVALUE        dvPhi;              /* Outer angle of spotlight cone */
}
alias LPD3DLIGHT7 = D3DLIGHT7*;

struct D3DDP_PTRSTRIDE {
    LPVOID lpvData;
    DWORD  dwStride;
}

enum D3DDP_MAXTEXCOORD = 8;

struct D3DDRAWPRIMITIVESTRIDEDDATA {
    D3DDP_PTRSTRIDE position;
    D3DDP_PTRSTRIDE normal;
    D3DDP_PTRSTRIDE diffuse;
    D3DDP_PTRSTRIDE specular;
    D3DDP_PTRSTRIDE[D3DDP_MAXTEXCOORD] textureCoords;
}
alias LPD3DDRAWPRIMITIVESTRIDEDDATA = D3DDRAWPRIMITIVESTRIDEDDATA*;

mixin(uuid!(IDirect3DDevice7, "f5049e79-4861-11d2-a407-00a0c90629a8"));
extern (C++) interface IDirect3DDevice7 : IUnknown {
    HRESULT GetCaps(LPD3DDEVICEDESC7);
    HRESULT EnumTextureFormats(LPD3DENUMPIXELFORMATSCALLBACK,LPVOID);
    HRESULT BeginScene();
    HRESULT EndScene();
    HRESULT GetDirect3D(LPDIRECT3D7*);
    HRESULT SetRenderTarget(LPDIRECTDRAWSURFACE7,DWORD);
    HRESULT GetRenderTarget(LPDIRECTDRAWSURFACE7 *);
    HRESULT Clear(DWORD,LPD3DRECT,DWORD,D3DCOLOR,D3DVALUE,DWORD);
    HRESULT SetTransform(D3DTRANSFORMSTATETYPE,LPD3DMATRIX);
    HRESULT GetTransform(D3DTRANSFORMSTATETYPE,LPD3DMATRIX);
    HRESULT SetViewport(LPD3DVIEWPORT7);
    HRESULT MultiplyTransform(D3DTRANSFORMSTATETYPE,LPD3DMATRIX);
    HRESULT GetViewport(LPD3DVIEWPORT7);
    HRESULT SetMaterial(LPD3DMATERIAL7);
    HRESULT GetMaterial(LPD3DMATERIAL7);
    HRESULT SetLight(DWORD,LPD3DLIGHT7);
    HRESULT GetLight(DWORD,LPD3DLIGHT7);
    HRESULT SetRenderState(D3DRENDERSTATETYPE,DWORD);
    HRESULT GetRenderState(D3DRENDERSTATETYPE,LPDWORD);
    HRESULT BeginStateBlock();
    HRESULT EndStateBlock(LPDWORD);
    HRESULT PreLoad(LPDIRECTDRAWSURFACE7);
    HRESULT DrawPrimitive(D3DPRIMITIVETYPE,DWORD,LPVOID,DWORD,DWORD);
    HRESULT DrawIndexedPrimitive(D3DPRIMITIVETYPE,DWORD,LPVOID,DWORD,LPWORD,DWORD,DWORD);
    HRESULT SetClipStatus(LPD3DCLIPSTATUS);
    HRESULT GetClipStatus(LPD3DCLIPSTATUS);
    HRESULT DrawPrimitiveStrided(D3DPRIMITIVETYPE,DWORD,LPD3DDRAWPRIMITIVESTRIDEDDATA,DWORD,DWORD);
    HRESULT DrawIndexedPrimitiveStrided(D3DPRIMITIVETYPE,DWORD,LPD3DDRAWPRIMITIVESTRIDEDDATA,DWORD,LPWORD,DWORD,DWORD);
    HRESULT DrawPrimitiveVB(D3DPRIMITIVETYPE,LPDIRECT3DVERTEXBUFFER7,DWORD,DWORD,DWORD);
    HRESULT DrawIndexedPrimitiveVB(D3DPRIMITIVETYPE,LPDIRECT3DVERTEXBUFFER7,DWORD,DWORD,LPWORD,DWORD,DWORD);
    HRESULT ComputeSphereVisibility(LPD3DVECTOR,LPD3DVALUE,DWORD,DWORD,LPDWORD);
    HRESULT GetTexture(DWORD,LPDIRECTDRAWSURFACE7 *);
    HRESULT SetTexture(DWORD,LPDIRECTDRAWSURFACE7);
    HRESULT GetTextureStageState(DWORD,D3DTEXTURESTAGESTATETYPE,LPDWORD);
    HRESULT SetTextureStageState(DWORD,D3DTEXTURESTAGESTATETYPE,DWORD);
    HRESULT ValidateDevice(LPDWORD);
    HRESULT ApplyStateBlock(DWORD);
    HRESULT CaptureStateBlock(DWORD);
    HRESULT DeleteStateBlock(DWORD);
    HRESULT CreateStateBlock(D3DSTATEBLOCKTYPE,LPDWORD);
    HRESULT Load(LPDIRECTDRAWSURFACE7,LPPOINT,LPDIRECTDRAWSURFACE7,LPRECT,DWORD);
    HRESULT LightEnable(DWORD,BOOL);
    HRESULT GetLightEnable(DWORD,BOOL*);
    HRESULT SetClipPlane(DWORD,D3DVALUE*);
    HRESULT GetClipPlane(DWORD,D3DVALUE*);
    HRESULT GetInfo(DWORD,LPVOID,DWORD);
}
alias LPDIRECT3DDEVICE7 = IDirect3DDevice7;

extern (C++) interface IDirect3DVertexBuffer7 : IUnknown {
    HRESULT Lock(DWORD,LPVOID*,LPDWORD);
    HRESULT Unlock();
    HRESULT ProcessVertices(DWORD,DWORD,DWORD,LPDIRECT3DVERTEXBUFFER7,DWORD,LPDIRECT3DDEVICE7,DWORD);
    HRESULT GetVertexBufferDesc(LPD3DVERTEXBUFFERDESC);
    HRESULT Optimize(LPDIRECT3DDEVICE7,DWORD);
    HRESULT ProcessVerticesStrided(DWORD,DWORD,DWORD,LPD3DDRAWPRIMITIVESTRIDEDDATA,DWORD,LPDIRECT3DDEVICE7,DWORD);
};
alias LPDIRECT3DVERTEXBUFFER7 = IDirect3DVertexBuffer7;

__gshared LPDIRECTDRAWCREATEEX     DirectDrawCreateEx;
__gshared LPDIRECTDRAWENUMERATEEXA DirectDrawEnumerateExA;

extern (Windows) {
    //alias LPDDENUMMODESCALLBACK = HRESULT function(LPDDSURFACEDESC, LPVOID);
    alias LPDDENUMMODESCALLBACK2 = HRESULT function(LPDDSURFACEDESC2, LPVOID);
    //alias LPDDENUMSURFACESCALLBACK = HRESULT function(LPDIRECTDRAWSURFACE, LPDDSURFACEDESC, LPVOID);
    //alias LPDDENUMSURFACESCALLBACK2 = HRESULT function(LPDIRECTDRAWSURFACE4, LPDDSURFACEDESC2, LPVOID);
    alias LPDDENUMSURFACESCALLBACK7 = HRESULT function(LPDIRECTDRAWSURFACE7, LPDDSURFACEDESC2, LPVOID);

    alias LPCLIPPERCALLBACK = DWORD function(LPDIRECTDRAWCLIPPER lpDDClipper, HWND hWnd, DWORD code,
                                             LPVOID lpContext);

    enum {
        DDCREATE_HARDWAREONLY  = 0x00000001,
        DDCREATE_EMULATIONONLY = 0x00000002
    }

    alias LPDIRECTDRAWCREATEEX = HRESULT function(GUID* lpGUID,
                                                  LPVOID* lplpDD,
                                                  REFIID iid,
                                                  IUnknown* pUnkOuter);

    enum {
        DDENUM_ATTACHEDSECONDARYDEVICES = 0x00000001
    }

    alias LPDDENUMCALLBACKEXA = BOOL function(GUID*, LPSTR, LPSTR,
                                              LPVOID, HMONITOR);

    alias LPDIRECTDRAWENUMERATEEXA =
        HRESULT function(LPDDENUMCALLBACKEXA lpCallback,
                         LPVOID              lpContext,
                         DWORD               dwFlags);
}
