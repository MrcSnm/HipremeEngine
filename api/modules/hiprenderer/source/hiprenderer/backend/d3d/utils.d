
module hiprenderer.backend.d3d.utils;
version (Windows)
{
	import directx.d3d11;
	string Hip_D3D11_GetErrorMessage(HRESULT hr);
}
