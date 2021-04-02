module directx.d2derr;
/*=========================================================================*\

    Copyright (c) Microsoft Corporation.  All rights reserved.

\*=========================================================================*/

version(Windows):

import directx.com;

/*=========================================================================*\
    D2D Status Codes
\*=========================================================================*/

enum FACILITY_D2D = 0x899;

HRESULT MAKE_D2DHR(alias sev, T)(T code) {
	return MAKE_HRESULT(sev, FACILITY_D2D, code);
}

HRESULT MAKE_D2DHR_ERR(T)(T code) {
	return MAKE_D2DHR(1, code);
}

//+----------------------------------------------------------------------------
//
// D2D error codes
//
//------------------------------------------------------------------------------

//
//  Error codes shared with WINCODECS
//

//
// The pixel format is not supported.
//
//alias D2DERR_UNSUPPORTED_PIXEL_FORMAT = WINCODEC_ERR_UNSUPPORTEDPIXELFORMAT;

//
// Error codes that were already returned in prior versions and were part of the
// MIL facility.

//
// Error codes mapped from WIN32 where there isn't already another HRESULT based
// define
//

//
// The supplied buffer was too small to accommodate the data.
//
//alias D2DERR_INSUFFICIENT_BUFFER =         HRESULT_FROM_WIN32(ERROR_INSUFFICIENT_BUFFER)

//
// The file specified was not found.
//
//alias D2DERR_FILE_NOT_FOUND =              HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND)

//
// D2D specific codes now live in winerror.h
//

// some stuff from winerror.h

enum D2DERR_RECREATE_TARGET           = 0x8899000CL;
