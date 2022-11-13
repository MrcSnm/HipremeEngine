#include "pch.h"
#include <CoreWindow.h>
#include "d_game.h"
#include "input.hpp"
#include "uwpfs.h"
#include "Def.h"

using namespace winrt;
using namespace Windows;
using namespace Windows::ApplicationModel::Core;
using namespace Windows::Foundation::Numerics;
using namespace Windows::UI;
using namespace Windows::UI::Core;
using namespace Windows::UI::Composition;
using namespace Windows::Gaming::Input;


struct HipExternalCoreWindow
{
    IUnknown* coreWindow;
    uint logicalWidth;
    uint logicalHeight;
};

ID3D11Device* g_D3D11Device;
HipExternalCoreWindow g_ExternalCoreWindow;

#define ChkOk assertOk
#define ChkTrue assertOk


d_import void(*GetOutputUWP)(LPCWSTR) = &OutputDebugStringW;
d_import void OutputUWP(LPCWSTR str)
{
    OutputDebugString(str);
}
d_import ID3D11Device* getD3D11Device() { return g_D3D11Device; }
d_import HipExternalCoreWindow getCoreWindow(){ return g_ExternalCoreWindow; }

void assertOk(HRESULT res, const char* err = "")
{
    if (res != S_OK)
    {
        dprint("\n%s\n", err);
        throw std::exception();
    }
}
void assertOk(bool res, const char* err = "")
{
    if (!res)
    {
        dprint("\n%s\n", err);
        throw std::exception();
    }
}

struct App : implements<App, IFrameworkViewSource, IFrameworkView>
{
    CoreWindow window{ nullptr };
    CompositionTarget m_target{ nullptr };
    VisualCollection m_visuals{ nullptr };
    Visual m_selected{ nullptr };
    float2 m_offset{};
    com_ptr<ID3D11Device3> m_device;
    com_ptr<IDXGIDevice> m_dxgiDevice;
    com_ptr<ID3D11DeviceContext3> m_context;
    com_ptr<IDXGISwapChain3> m_swapChain;

    com_ptr<ID3D11RenderTargetView> m_renderTargetView;
    com_ptr<ID3D11DepthStencilView> m_depthStencilView;
    D3D_FEATURE_LEVEL m_featureLevel ;
    float dpi=0;
    float width=0, height=0;
    float logicalWidth=0, logicalHeight=0;
    bool m_windowClosed = false;

    IFrameworkView CreateView()
    {
        return *this;
    }

    void Initialize(CoreApplicationView const &){}

    void Load(hstring const&)
    {
        HipremeMain();

        //CreateD3D11Device();
        //CreateWindowDependentResources();
    }

    float ConvertDipsToPixels(float dips)
    {
        static const float dipsPerInch = 96.0f;
        return floorf(dips * dpi / dipsPerInch + 0.5f); //Round to nearest integer
    }

    void CreateWindowDependentResources()
    {
        dprint("\n\nCreatingWindowDependentResources\n\n");
        ID3D11RenderTargetView* nullViews[] = { nullptr };
        m_context->OMSetRenderTargets(ARRAYSIZE(nullViews), nullViews, nullptr);
        m_renderTargetView = nullptr;
        m_depthStencilView = nullptr;
        m_context->Flush1(D3D11_CONTEXT_TYPE_ALL, nullptr);

        width = (std::max)(1.0f, 800.0f);
        height= (std::max)(1.0f, 600.0f);

        if (m_swapChain == nullptr)
        {
            width = 800.0f;
            height = 600.0f;

            // Create a new swap chain using the same adapter as the existing device.
            DXGI_SWAP_CHAIN_DESC1 swapChainDesc = { 0 };
            swapChainDesc.Width = lround(width);         // Match the size of the window.
            swapChainDesc.Height = lround(height);
            swapChainDesc.Format = DXGI_FORMAT_B8G8R8A8_UNORM;              // This is the most common swap chain format.
            swapChainDesc.Stereo = FALSE;
            swapChainDesc.SampleDesc.Count = 1;                             // Don't use multi-sampling.
            swapChainDesc.SampleDesc.Quality = 0;
            swapChainDesc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
            swapChainDesc.BufferCount = 2;                                  // Use double-buffering to minimize latency.
            swapChainDesc.SwapEffect = DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL;    // All Windows Store apps must use this SwapEffect.
            swapChainDesc.Flags = 0;
            swapChainDesc.Scaling = DXGI_SCALING_STRETCH;
            swapChainDesc.AlphaMode = DXGI_ALPHA_MODE_IGNORE;

            // This sequence obtains the DXGI factory that was used to create the Direct3D device above.
            com_ptr<IDXGIDevice3> dxgiDevice;
            ChkTrue(m_device.try_as(dxgiDevice));
            com_ptr<IDXGIAdapter> dxgiAdapter;
            ChkOk(dxgiDevice->GetAdapter(dxgiAdapter.put()));
            com_ptr<IDXGIFactory4> dxgiFactory;
            ChkOk(dxgiAdapter->GetParent(__uuidof(dxgiFactory), dxgiFactory.put_void()));

            auto unkWindow = window.as<::IUnknown>();
            com_ptr<IDXGISwapChain1> swapChain;
            ChkOk(
                dxgiFactory->CreateSwapChainForCoreWindow(
                    m_device.get(),
                    unkWindow.get(),
                    &swapChainDesc,
                    nullptr,
                    swapChain.put()));
            ChkTrue(swapChain.try_as(m_swapChain));

            dprint("%p", swapChain.get());
        }
    }

    void CreateD3D11Device()
    {
        UINT creationFlags = 0;

#if defined(_DEBUG)

        HRESULT hrSdkLayersCheck = D3D11CreateDevice(
            nullptr,
            D3D_DRIVER_TYPE_NULL,       // There is no need to create a real hardware device.
            0,
            D3D11_CREATE_DEVICE_DEBUG,  // Check for the SDK layers.
            nullptr,                    // Any feature level will do.
            0,
            D3D11_SDK_VERSION,          // Always set this to D3D11_SDK_VERSION for Windows Store apps.
            nullptr,                    // No need to keep the D3D device reference.
            nullptr,                    // No need to know the feature level.
            nullptr                     // No need to keep the D3D device context reference.
        );

        if (SUCCEEDED(hrSdkLayersCheck))
        {
            // If the project is in a debug build, enable debugging via SDK Layers with this flag.
            creationFlags |= D3D11_CREATE_DEVICE_DEBUG;
        }

#endif

        // This array defines the set of DirectX hardware feature levels this app will support.
        // Note the ordering should be preserved.
        // Don't forget to declare your application's minimum required feature level in its
        // description.  All applications are assumed to support 9.1 unless otherwise stated.
        static const D3D_FEATURE_LEVEL featureLevels[] =
        {
            D3D_FEATURE_LEVEL_12_1,
            D3D_FEATURE_LEVEL_12_0,
            D3D_FEATURE_LEVEL_11_1,
            D3D_FEATURE_LEVEL_11_0,
            D3D_FEATURE_LEVEL_10_1,
            D3D_FEATURE_LEVEL_10_0,
            D3D_FEATURE_LEVEL_9_3,
            D3D_FEATURE_LEVEL_9_2,
            D3D_FEATURE_LEVEL_9_1
        };

        // Create the Direct3D 11 API device object and a corresponding context.
        com_ptr<ID3D11Device> device;
        com_ptr<ID3D11DeviceContext> context;


        HRESULT hr = D3D11CreateDevice(
            nullptr,                    // Specify nullptr to use the default adapter.
            D3D_DRIVER_TYPE_HARDWARE,   // Create a device using the hardware graphics driver.
            0,                          // Should be 0 unless the driver is D3D_DRIVER_TYPE_SOFTWARE.
            creationFlags,              // Set debug and Direct2D compatibility flags.
            featureLevels,              // List of feature levels this app can support.
            ARRAYSIZE(featureLevels),   // Size of the list above.
            D3D11_SDK_VERSION,          // Always set this to D3D11_SDK_VERSION for Windows Store apps.
            device.put(),               // Returns the Direct3D device created.
            &m_featureLevel,            // Returns feature level of device created.
            context.put()               // Returns the device immediate context.
        );

        if (FAILED(hr))
        {
            // Initialization failed, fall back to the WARP device.
            ChkOk(
                D3D11CreateDevice(
                    nullptr,
                    D3D_DRIVER_TYPE_WARP,
                    0,
                    creationFlags,
                    featureLevels,
                    ARRAYSIZE(featureLevels),
                    D3D11_SDK_VERSION,
                    device.put(),
                    &m_featureLevel,
                    context.put()));
        }

        // Store pointers to the Direct3D 11.3 API device and immediate context.
        ChkTrue(device.try_as(m_device));
        ChkTrue(context.try_as(m_context));

        // Create the Direct2D device object and a corresponding context.
        com_ptr<IDXGIDevice3> dxgiDevice;
        ChkTrue(m_device.try_as(dxgiDevice));

    }

    void Uninitialize(){}

    void Run()
    {
        window = CoreWindow::GetForCurrentThread();
        window.Activate();

        CoreDispatcher dispatcher = window.Dispatcher();
        while (!m_windowClosed)
        {
            dispatcher.ProcessEvents(CoreProcessEventsOption::ProcessAllIfPresent);
            HipremeUpdate();
            HipremeRender();
        }
        HipremeDestroy();
    }
    void OnWindowClosed(const CoreWindow& sender, const CoreWindowEventArgs& args)
    {
        (void)sender;
        (void)args;
        m_windowClosed = true;
    }

    void SetWindow(CoreWindow const& wnd)
    {
        HMODULE lib = LoadDLL(L"hipreme_engine.dll");
        dprint("Marcelo\n\n%p", lib);
        if (d_game_LoadDLL(lib) != 0)
            OutputDebugString(L"Error ocurred when loading D libs");
        window = wnd;
        logicalWidth = wnd.Bounds().Width;
        logicalHeight = wnd.Bounds().Height;


        auto windowPtr = static_cast<::IUnknown*>(winrt::get_abi(window));

        g_ExternalCoreWindow.coreWindow = windowPtr;
        g_ExternalCoreWindow.logicalWidth  = static_cast<uint>(wnd.Bounds().Width);
        g_ExternalCoreWindow.logicalHeight = static_cast<uint>(wnd.Bounds().Height);

        HipremeInit();

        window.PointerPressed({ this, &App::OnPointerPressed });
        window.PointerMoved({ this, &App::OnPointerMoved });
        window.PointerReleased({ this , &App::OnPointerReleased });
        window.PointerWheelChanged({ this , &App::OnPointerWheelChanged});
        
        Gamepad::GamepadAdded({ this, &App::OnGamepadAdded });
        Gamepad::GamepadRemoved({ this, &App::OnGamepadRemoved });
        

        window.KeyDown({ this, &App::OnKeyDown });
        window.KeyUp({ this, &App::OnKeyUp });
        window.Closed({ this, &App::OnWindowClosed });


    

    }

    void OnPointerPressed(IInspectable const &, PointerEventArgs const & args)
    {
        winrt::Windows::UI::Input::PointerPoint p = args.CurrentPoint();
        winrt::Windows::Foundation::Point point = p.Position();
        HipInputOnTouchPressed(p.PointerId()-1, point.X, point.Y);
    }
    void OnPointerMoved(IInspectable const &, PointerEventArgs const & args)
    {
        winrt::Windows::UI::Input::PointerPoint p = args.CurrentPoint();
        winrt::Windows::Foundation::Point point = p.Position();
        HipInputOnTouchMoved(p.PointerId()-1, point.X, point.Y);
    }
    void OnPointerReleased(IInspectable const&, PointerEventArgs const& args)
    {
        winrt::Windows::UI::Input::PointerPoint p = args.CurrentPoint();
        winrt::Windows::Foundation::Point point = p.Position();
        HipInputOnTouchReleased(p.PointerId() - 1, point.X, point.Y);
    }

    void OnPointerWheelChanged(IInspectable const&, PointerEventArgs const& args)
    {
        winrt::Windows::UI::Input::PointerPoint p = args.CurrentPoint();
        winrt::Windows::UI::Input::PointerPointProperties prop = p.Properties();

        float val = (float)prop.MouseWheelDelta();

        if (prop.IsHorizontalMouseWheel())
            HipInputOnTouchScroll(val, 0, 0);
        else
            HipInputOnTouchScroll(0, val, 0);
    }

    void OnKeyDown(IInspectable const&, KeyEventArgs const& args)
    {
        HipInputOnKeyDown((uint32_t)args.VirtualKey());
    }
    void OnKeyUp(IInspectable const&, KeyEventArgs const& args)
    {
        HipInputOnKeyUp((uint32_t)args.VirtualKey());
    }

    void OnGamepadAdded(IInspectable const& obj, Gamepad const & gamepad)
    {
        (void)obj;
        ubyte id = GetGamepadID(gamepad);
        if (id == 255)
            AddGamepad(gamepad);

        HipInputOnGamepadConnected(GetGamepadID(gamepad));
    }
    void OnGamepadRemoved(IInspectable const& obj, Gamepad const & gamepad)
    {
        (void)obj;
        ubyte id = GetGamepadID(gamepad);
        RemoveGamepad(gamepad);
        HipInputOnGamepadDisconnected(id);
    }
};

int __stdcall wWinMain(HINSTANCE, HINSTANCE, PWSTR, int)
{
    CoreApplication::Run(make<App>());
}
