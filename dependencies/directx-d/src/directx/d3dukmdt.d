module directx.d3dukmdt;
/******************************Module*Header************************************\
 *
 * Module Name: d3dukmdt.h
 *
 * Content: Longhorn Display Driver Model (LDDM) user/kernel mode
 *          shared data type definitions.
 *
 * Copyright (c) 2003 Microsoft Corporation.  All rights reserved.
\*******************************************************************************/

version(Windows):

import std.bitmanip : bitfields;

public import directx.win32;

alias UINT  D3DDDI_VIDEO_PRESENT_SOURCE_ID;
alias UINT  D3DDDI_VIDEO_PRESENT_TARGET_ID;

alias UINT D3DKMT_HANDLE;

alias DWORD D3DDDI_OFFER_PRIORITY;
enum : D3DDDI_OFFER_PRIORITY
{
    D3DDDI_OFFER_PRIORITY_NONE=0,               // Do not offer
    D3DDDI_OFFER_PRIORITY_LOW=1,                // Content is not useful
    D3DDDI_OFFER_PRIORITY_NORMAL,               // Content is useful but easy to regenerate
    D3DDDI_OFFER_PRIORITY_HIGH,                 // Content is useful and difficult to regenerate
    D3DDDI_OFFER_PRIORITY_AUTO,                 // Let VidMm decide offer priority based on eviction priority
}

struct D3DDDI_TRIMRESIDENCYSET_FLAGS
{
    union
    {
        mixin(bitfields!(UINT, "PeriodicTrim",         1,
                         UINT, "RestartPeriodicTrim",  1,
                         UINT, "TrimToBudget",         1,
                         UINT, "Reserved",            29));

        UINT Value;
    }
}

alias DWORD D3DDDI_COLOR_SPACE_TYPE;
enum : D3DDDI_COLOR_SPACE_TYPE
{
    D3DDDI_COLOR_SPACE_RGB_FULL_G22_NONE_P709             = 0,
    D3DDDI_COLOR_SPACE_RGB_FULL_G10_NONE_P709             = 1,
    D3DDDI_COLOR_SPACE_RGB_STUDIO_G22_NONE_P709           = 2,
    D3DDDI_COLOR_SPACE_RGB_STUDIO_G22_NONE_P2020          = 3,
    D3DDDI_COLOR_SPACE_RESERVED                           = 4,
    D3DDDI_COLOR_SPACE_YCBCR_FULL_G22_NONE_P709_X601      = 5,
    D3DDDI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P601         = 6,
    D3DDDI_COLOR_SPACE_YCBCR_FULL_G22_LEFT_P601           = 7,
    D3DDDI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P709         = 8,
    D3DDDI_COLOR_SPACE_YCBCR_FULL_G22_LEFT_P709           = 9,
    D3DDDI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P2020        = 10,
    D3DDDI_COLOR_SPACE_YCBCR_FULL_G22_LEFT_P2020          = 11,
    D3DDDI_COLOR_SPACE_CUSTOM                             = 0xFFFFFFFF
}

enum D3DDDI_MAX_BROADCAST_CONTEXT = 64;
