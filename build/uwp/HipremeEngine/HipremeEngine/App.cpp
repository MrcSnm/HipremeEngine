#include "pch.h"
#include <CoreWindow.h>
#include "d_game.h"
#include "input.hpp"
#include "Def.h"

using namespace winrt;
using namespace Windows;
using namespace Windows::ApplicationModel::Core;
using namespace Windows::Foundation::Numerics;
using namespace Windows::UI;
using namespace Windows::UI::Core;
using namespace Windows::UI::Composition;
using namespace Windows::Gaming::Input;

ID3D11Device* g_D3D11Device;
HWND g_CoreWindowHWND;


struct __declspec(uuid("45D64A29-A63E-4CB6-B498-5781D298CB4F")) __declspec(novtable)
    ICoreWindowInterop : IUnknown
{
    virtual HRESULT __stdcall get_WindowHandle(HWND* hwnd) = 0;
    virtual HRESULT __stdcall put_MessageHandled(unsigned char) = 0;
};

d_import void(*GetOutputUWP)(LPCWSTR) = &OutputDebugStringW;
d_import void OutputUWP(LPCWSTR str)
{
    OutputDebugString(str);
}
d_import ID3D11Device* getD3D11Device() { return g_D3D11Device; }
d_import HWND getCoreWindowHWND() { return g_CoreWindowHWND; }

void assertOk(HRESULT res, const char* err)
{
    if (res != S_OK)
        std::exception(err);
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
        OutputDebugString(L"OI\n");
        com_ptr<ICoreWindowInterop> interop;
        assertOk(window.as<::IUnknown>()->QueryInterface(interop.put()), "Could not get window Interop interface");
        interop->get_WindowHandle(&g_CoreWindowHWND);
        HipremeInit();
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
        ID3D11RenderTargetView* nullView[] = { nullptr };
        m_context->OMSetRenderTargets(ARRAYSIZE(nullView), nullView, nullptr);
        m_context->Flush();
        width = (std::max)(1.0f, ConvertDipsToPixels(logicalWidth));
        height= (std::max)(1.0f, ConvertDipsToPixels(logicalHeight));

        if (m_swapChain == nullptr)
        {
            DXGI_SWAP_CHAIN_DESC1 desc = { 0 };
            desc.Width = width;
            desc.Height = height;
            desc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
            desc.SampleDesc.Count = 1;
            desc.SampleDesc.Quality = 0;
            desc.SwapEffect = DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL;
            desc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
            desc.BufferCount = 2;
            
            com_ptr<IDXGIDevice3> dxgi;
            m_device.try_as(dxgi);
            com_ptr<IDXGIAdapter> adapter;
            assertOk(dxgi->GetAdapter(adapter.put()), "Could not get DXGI adapter");

            com_ptr<IDXGIFactory4>factory;
            com_ptr<IDXGISwapChain1> swapChain;


            assertOk(adapter->GetParent(__uuidof(IDXGIFactory4), factory.put_void()), "Could not get factory");
            assertOk(factory->CreateSwapChainForCoreWindow (m_device.get(),
                window.as<IUnknown>().get(),
                &desc,
                nullptr,
                swapChain.put()
            ), "Could not create swap chain");
            
            swapChain.try_as(m_swapChain);
        }
    }

    void CreateD3D11Device()
    {
        static const D3D_FEATURE_LEVEL featureLevels[] =
        {
            D3D_FEATURE_LEVEL_11_1,
            D3D_FEATURE_LEVEL_11_0,
            D3D_FEATURE_LEVEL_10_1,
            D3D_FEATURE_LEVEL_10_0,
            D3D_FEATURE_LEVEL_9_3,
            D3D_FEATURE_LEVEL_9_2,
            D3D_FEATURE_LEVEL_9_1
        };
        UINT creationFlags = 0;

#ifdef DEBUG_BUILD
        creationFlags |= D3D11_CREATE_DEVICE_DEBUG;
#endif
        D3D_FEATURE_LEVEL featureLevel;

        com_ptr<ID3D11Device> device;
        com_ptr<ID3D11DeviceContext> context;
        HRESULT hres = D3D11CreateDevice(nullptr,
            D3D_DRIVER_TYPE_HARDWARE,
            0, creationFlags,
            featureLevels,
            ARRAYSIZE(featureLevels),
            D3D11_SDK_VERSION,
            device.put(),
            &featureLevel,
            context.put()
        );

        if (FAILED(hres))
        {
            // Initialization failed, fall back to the WARP device.
            assertOk(D3D11CreateDevice(
                nullptr,
                D3D_DRIVER_TYPE_WARP,
                0,
                creationFlags,
                featureLevels,
                ARRAYSIZE(featureLevels),
                D3D11_SDK_VERSION,
                device.put(),
                &featureLevel,
                context.put()), "Could not create D3D11 device"
            );
        }
        device.as(m_device);
        context.as(m_context);

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
    void OnWindowClosed(const CoreWindow& sender, const CoreWindowEventArgs& args){m_windowClosed = true;}

    void SetWindow(CoreWindow const& wnd)
    {
        window = wnd;
        Compositor compositor;
        ContainerVisual root = compositor.CreateContainerVisual();
        m_target = compositor.CreateTargetForCurrentView();
        m_target.Root(root);
        m_visuals = root.Children();

        window.PointerPressed({ this, &App::OnPointerPressed });
        window.PointerMoved({ this, &App::OnPointerMoved });
        window.PointerReleased({ this , &App::OnPointerReleased });
        window.PointerWheelChanged({ this , &App::OnPointerWheelChanged});
        
        Gamepad::GamepadAdded({ this, &App::OnGamepadAdded });
        Gamepad::GamepadRemoved({ this, &App::OnGamepadRemoved });
        

        window.KeyDown({ this, &App::OnKeyDown });
        window.KeyUp({ this, &App::OnKeyUp });
        window.Closed({ this, &App::OnWindowClosed });


        HMODULE lib = LoadDLL(L"hipreme_engine.dll");
        if (d_game_LoadDLL(lib) != 0)
            OutputDebugString(L"Error ocurred when loading D libs");

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

    void OnGamepadAdded(IInspectable const& obj, Windows::Gaming::Input::Gamepad const & gamepad)
    {
        ubyte id = GetGamepadID(&gamepad);
        if (id == 255)
            AddGamepad(&gamepad);

        HipInputOnGamepadConnected(GetGamepadID(&gamepad));
    }
    void OnGamepadRemoved(IInspectable const& obj, Windows::Gaming::Input::Gamepad const & gamepad)
    {
        ubyte id = GetGamepadID(&gamepad);
        if (id == 255)
        {
            OutputDebugString(L"Something really wrong has happenned.");
            return;
        }
        HipInputOnGamepadDisconnected(GetGamepadID(&gamepad));
    }
};

int __stdcall wWinMain(HINSTANCE, HINSTANCE, PWSTR, int)
{
    CoreApplication::Run(make<App>());
}
