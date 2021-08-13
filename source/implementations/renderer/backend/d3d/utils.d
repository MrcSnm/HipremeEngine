/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module implementations.renderer.backend.d3d.utils;
version(Windows):
import directx.d3d11;

string Hip_D3D11_GetErrorMessage(HRESULT hr)
{
    import std.conv:to;
    wchar[4096] buffer;
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
    null, hr, 0u, buffer.ptr, buffer.length, null);
    return to!string(buffer.ptr);
}