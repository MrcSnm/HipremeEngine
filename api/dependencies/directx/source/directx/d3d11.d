module directx.d3d11;

public import core.sys.windows.windows;

interface ID3D11Device;
interface ID3D11DeviceContext;
interface ID3D11Buffer;
interface ID3D11Texture2D;
interface ID3D11SamplerState;
interface ID3D11InputLayout;
interface ID3D11RenderTargetView;
interface ID3D11ShaderResourceView;
interface IDXGISwapChain;

alias D3D11_USAGE = uint;
alias DXGI_FORMAT = uint;
struct D3D11_INPUT_ELEMENT_DESC;
