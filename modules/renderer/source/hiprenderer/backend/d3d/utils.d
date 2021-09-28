/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hiprenderer.backend.d3d.utils;
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