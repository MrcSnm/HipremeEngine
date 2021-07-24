module implementations.renderer.backend.d3d.utils;
import directx.d3d11;

string Hip_D3D11_GetErrorMessage(HRESULT hr)
{
    import std.conv:to;
    wchar[4096] buffer;
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
    null, hr, 0u, buffer.ptr, buffer.length, null);
    return to!string(buffer.ptr);
}