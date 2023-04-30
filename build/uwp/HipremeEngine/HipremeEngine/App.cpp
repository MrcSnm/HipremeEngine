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

enum HipGamepadTypes
{
    HipGamepadTypes_xbox,
    HipGamepadTypes_psvita
};

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
    }

    float ConvertDipsToPixels(float dips)
    {
        static const float dipsPerInch = 96.0f;
        return floorf(dips * dpi / dipsPerInch + 0.5f); //Round to nearest integer
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
            if (!HipremeUpdate())
                break;
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
        dprint("Loaded Hipreme Engine at address %p\n", lib);
        if (d_game_LoadDLL(lib) != 0)
        {
            OutputDebugString(L"Error ocurred when loading D libs");
            exit(EXIT_FAILURE);
        }
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

        HipInputOnGamepadConnected(GetGamepadID(gamepad), HipGamepadTypes_xbox);
    }
    void OnGamepadRemoved(IInspectable const& obj, Gamepad const & gamepad)
    {
        (void)obj;
        ubyte id = GetGamepadID(gamepad);
        RemoveGamepad(gamepad);
        HipInputOnGamepadDisconnected(id, HipGamepadTypes_xbox);
    }
};

int __stdcall wWinMain(HINSTANCE, HINSTANCE, PWSTR, int)
{
    CoreApplication::Run(make<App>());
}
