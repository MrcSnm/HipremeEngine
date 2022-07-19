module directx.d2d1_2helper;
/*=========================================================================*\

    Copyright (c) Microsoft Corporation.  All rights reserved.

    File: D2D1_2Helper.h

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
version(Direct2D_1_2):
public import directx.d2d1_2;

// TODO:
