import core.sys.windows.windows;
import std.windows.charset;

import directx.d3d11, directx.d2d1_1, directx.dcomp;
import directx.d2d1helper : D2D1;

// missing ex window flags
immutable WS_EX_NOREDIRECTIONBITMAP = 0x00200000;

private void checkFailure(HRESULT hr)
{
    import std.conv : to;

    if (hr.FAILED)
        throw new Exception("Failed COM: " ~ hr.to!string);
}

class GraphicsDevice
{
    private ID3D11Device                device3;
    private ID2D1Device                 device2;
    private IDCompositionDesktopDevice  compDevice;
    private IDCompositionTarget         target;
    private IDCompositionVisual2        root;
    private IDCompositionVisual2[3]     rects;
    private IDCompositionSurface        surface;
    private IDCompositionScaleTransform scaler;

    this(HWND hwTarget)
    {
        // Initialize Direct3D, Direct2D and DirectComposition
        IDXGIDevice devicex;
        D3D11CreateDevice(null, D3D_DRIVER_TYPE_HARDWARE, null,
            D3D11_CREATE_DEVICE_BGRA_SUPPORT | D3D11_CREATE_DEVICE_DEBUG, null,
            0, D3D11_SDK_VERSION, &this.device3, null, null).checkFailure();
        this.device3.QueryInterface(&IID_IDXGIDevice, cast(void**)&devicex).checkFailure();
        scope (exit)
            devicex.Release();
        immutable cp = D2D1_CREATION_PROPERTIES(D2D1_THREADING_MODE_SINGLE_THREADED,
            D2D1_DEBUG_LEVEL_ERROR, D2D1_DEVICE_CONTEXT_OPTIONS_NONE);
        D2D1CreateDevice(devicex, &cp, &this.device2).checkFailure();
        DCompositionCreateDevice2(this.device2,
            &IID_IDCompositionDesktopDevice, cast(void**)&this.compDevice).checkFailure();

        // Create Composition Target and Visuals
        this.compDevice.CreateTargetForHwnd(hwTarget, FALSE, &this.target).checkFailure();
        this.compDevice.CreateVisual(&this.root).checkFailure();
        foreach (ref e; this.rects)
            this.compDevice.CreateVisual(&e).checkFailure();
        this.target.SetRoot(this.root).checkFailure();
        this.root.AddVisual(this.rects[0], true, null).checkFailure();
        this.root.AddVisual(this.rects[1], true, null).checkFailure();
        this.root.AddVisual(this.rects[2], true, null).checkFailure();

        // Create Content(Surface) and Scaling Transform
        this.compDevice.CreateSurface(1, 1, DXGI_FORMAT_B8G8R8A8_UNORM,
            DXGI_ALPHA_MODE_PREMULTIPLIED, &this.surface).checkFailure();
        {
            ID2D1DeviceContext con;
            POINT offs;
            this.surface.BeginDraw(null, &IID_ID2D1DeviceContext,
                cast(void**)&con, &offs).checkFailure();
            scope (exit)
            {
                this.surface.EndDraw().checkFailure();
                con.Release();
            }
            immutable Transform = D2D1.Matrix3x2F.Translation(offs.x, offs.y);
            immutable ClearColor = D2D1_COLOR_F(0.125f, 0.125f, 0.125f, 0.375f);

            con.SetTransform(cast(D2D_MATRIX_3X2_F*)&Transform);
            con.Clear(&ClearColor);
        }
        this.compDevice.CreateScaleTransform(&this.scaler).checkFailure();
        this.scaler.SetScaleX(100).checkFailure();
        this.scaler.SetScaleY(100).checkFailure();
        foreach (i, e; this.rects)
        {
            e.SetContent(this.surface).checkFailure();
            e.SetTransform(this.scaler).checkFailure();
            e.SetOffsetX(16 + i * 16).checkFailure();
            e.SetOffsetY(16 + i * 16).checkFailure();
        }

        this.compDevice.Commit().checkFailure();
    }

    ~this()
    {
        this.scaler.Release();
        this.surface.Release();
        foreach (ref e; this.rects)
            e.Release();
        this.root.Release();
        this.target.Release();
        this.compDevice.Release();
        this.device2.Release();
        this.device3.Release();
    }
}

extern (Windows) int WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR, int)
{
    import core.runtime : Runtime;

    try
    {
        Runtime.initialize();
        scope (exit)
            Runtime.terminate();

        WNDCLASSEXA wce;
        wce.cbSize = wce.sizeof;
        wce.hInstance = hInstance;
        wce.lpszClassName = "dxdcompExample".toMBSz;
        wce.lpfnWndProc = &WndProc;
        wce.hCursor = LoadCursorW(null, IDC_ARROW);
        const wndclass = RegisterClassExA(&wce);
        if (wndclass == 0)
            throw new Exception("RegisterClassEx failed");

        auto hw = CreateWindowExA(WS_EX_NOREDIRECTIONBITMAP | WS_EX_APPWINDOW,
            cast(char*) wndclass, "dcomp example".toMBSz, WS_OVERLAPPEDWINDOW,
            CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, null,
            null, hInstance, null);
        if (hw is null)
            throw new Exception("CreateWindowEx failed");

        auto g = new GraphicsDevice(hw);

        hw.ShowWindow(SW_SHOWNORMAL);
        MSG msg;
        while (GetMessageA(&msg, null, 0, 0) > 0)
            DispatchMessageA(&msg);
        return cast(int) msg.wParam;
    }
    catch (Exception e)
    {
        MessageBoxA(null, e.toString.toMBSz, null, MB_OK);
        return -1;
    }
}

extern (Windows) nothrow LRESULT WndProc(HWND hw, UINT msg, WPARAM wp, LPARAM lp)
{
    switch (msg)
    {
    case WM_DESTROY:
        PostQuitMessage(0);
        return 0;
    default:
        return DefWindowProc(hw, msg, wp, lp);
    }
}
