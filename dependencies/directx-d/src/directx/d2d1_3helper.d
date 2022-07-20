module directx.d2d1_3helper;
/*=========================================================================*\

    Copyright (c) Microsoft Corporation.  All rights reserved.

    File: D2D1_3Helper.h

    Module Name: D2D

    Description: Helper files over the D2D interfaces and APIs.

\*=========================================================================*/

version(Windows):

version(Direct2D_1_3)
    version = Direct2D_1_2;
version(Direct2D_1_2)
    version = Direct2D_1_1;
version(Direct2D_1_1):
    version = Direct2D_1_0;

version(DirectWrite):
version(WinCodec):
version(Direct2D_1_3):

public import directx.d2d1_3;

// TODO:
