/*
This example shows basic usage of Direct2D in D.
It has safety and style problems and full of bad practice, but simply works.
Be careful, API chages may break it in any moment(hopefully for good).
*/

import std.utf;
import std.stdio;
import std.math;

import directx.com;
import directx.win32;
import directx.d2d1;
import directx.d2d1helper;
import directx.dwrite;

// some predefinitions as usual, moslty due to missing decls in std.c.windows.windows
enum GWLP_USERDATA = -21;
enum GWLP_HINSTANCE = -6;
extern(Windows) LONG SetWindowLongA( HWND hWnd, int nIndex, LONG dwNewLong ) nothrow;
extern(Windows) LONG GetWindowLongA( HWND hWnd, int nIndex ) nothrow;

struct tagCREATESTRUCT {
	LPVOID    lpCreateParams;
	HINSTANCE hInstance;
	HMENU     hMenu;
	HWND      hwndParent;
	int       cy;
	int       cx;
	int       y;
	int       x;
	LONG      style;
	LPCTSTR   lpszName;
	LPCTSTR   lpszClass;
	DWORD     dwExStyle;
}
alias CREATESTRUCT = tagCREATESTRUCT;
alias LPCREATESTRUCT = tagCREATESTRUCT*;


void SafeRelease(T : IUnknown)(ref T ppInterfaceToRelease)
{
	if (ppInterfaceToRelease !is null)
	{
		ppInterfaceToRelease.Release();

		ppInterfaceToRelease = null;
	}
}

class DemoApp
{
public:
	~this()
	{
		SafeRelease(m_pDirect2dFactory);
		SafeRelease(m_pRenderTarget);
		SafeRelease(m_pLightSlateGrayBrush);
		SafeRelease(m_pCornflowerBlueBrush);
	}

	// Register the window class and call methods for instantiating drawing resources
	HRESULT Initialize()
	{
		HRESULT hr;
		HINSTANCE hinst = GetModuleHandle(null);

		// Initialize device-indpendent resources, such
		// as the Direct2D factory.
		hr = CreateDeviceIndependentResources();

		if (SUCCEEDED(hr))
		{

			HINSTANCE hInst = GetModuleHandle(null);
			WNDCLASS  wc;

			wc.lpszClassName = "D2DDemoApp";
			wc.style         = CS_HREDRAW | CS_VREDRAW;
			wc.lpfnWndProc   = &DemoApp.WndProc;
			wc.hInstance     = hinst;
			wc.hIcon         = LoadIcon(null, IDI_APPLICATION);
			wc.hCursor       = LoadCursor(null, IDC_CROSS);
			wc.hbrBackground = null;
			wc.lpszMenuName  = null;
			wc.cbClsExtra    = wc.cbWndExtra = LONG_PTR.sizeof;
			
			auto wca = RegisterClass(&wc);
			assert(wca);

			// Because the CreateWindow function takes its size in pixels,
			// obtain the system DPI and use it to scale the window size.
			FLOAT dpiX, dpiY;

			m_pDirect2dFactory.ReloadSystemMetrics();
			// The factory returns the current system DPI. This is also the value it will use
			// to create its own windows.
			m_pDirect2dFactory.GetDesktopDpi(&dpiX, &dpiY);

			m_hwnd = CreateWindow("D2DDemoApp", 
								 "Direct2D Demo App", 
								 WS_OVERLAPPEDWINDOW,
								 CW_USEDEFAULT, 
								 CW_USEDEFAULT, 
								 cast(UINT)(ceil(640.0f * dpiX / 96.0f)), 
								 cast(UINT)(ceil(480.0f * dpiY / 96.0f)), 
								 null,
								 null, 
								 hinst,
								 cast(void*)this
								 );
			
			hr = m_hwnd ? S_OK : E_FAIL;
			
			if (SUCCEEDED(hr))
			{
				ShowWindow(m_hwnd, SW_SHOWNORMAL);
				UpdateWindow(m_hwnd);
			}
			else
			{
			}
		}

		return hr;
	}

	// Process and dispatch messages
	void RunMessageLoop()
	{
		MSG msg;

		while (GetMessage(&msg, null, 0, 0))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}

private:
	// Initialize device-independent resources.
	HRESULT CreateDeviceIndependentResources()
	{
		HRESULT hr = S_OK;

		// Create a Direct2D factory.
		hr = D2D1CreateFactory(D2D1_FACTORY_TYPE_SINGLE_THREADED, &IID_ID2D1Factory, null, cast(void**)&m_pDirect2dFactory);
		return hr;
	}

	// Initialize device-dependent resources.
	HRESULT CreateDeviceResources()
	{
		HRESULT hr = S_OK;

		if (!m_pRenderTarget)
		{
			RECT rc;
			GetClientRect(m_hwnd, &rc);

			D2D1_SIZE_U size = D2D1.SizeU(
				rc.right - rc.left,
				rc.bottom - rc.top
				);

			// Create a Direct2D render target.
			hr = m_pDirect2dFactory.CreateHwndRenderTarget(
				D2D1.RenderTargetPropertiesPtr(), // note this is D extension method suffixed with "Ptr"
				D2D1.HwndRenderTargetPropertiesPtr(m_hwnd, size), // ditto
				&m_pRenderTarget
				);


			if (SUCCEEDED(hr))
			{
				// Create a gray brush.
				hr = CreateSolidColorBrush(
					m_pRenderTarget,
					D2D1.ColorF(D2D1.ColorF.LightSlateGray),
					&m_pLightSlateGrayBrush
					);
			}
			if (SUCCEEDED(hr))
			{
				// Create a blue brush.
				hr = CreateSolidColorBrush(
					m_pRenderTarget,
					D2D1.ColorF(D2D1.ColorF.CornflowerBlue),
					&m_pCornflowerBlueBrush
					);
			}
		}

		return hr;
	}

	// Release device-dependent resource.
	void DiscardDeviceResources()
	{
		SafeRelease(m_pRenderTarget);
		SafeRelease(m_pLightSlateGrayBrush);
		SafeRelease(m_pCornflowerBlueBrush);
	}

	// Draw content.
	HRESULT OnRender()
	{
		HRESULT hr = S_OK;

		hr = CreateDeviceResources();
	
		if (SUCCEEDED(hr))
		{
			auto mat = D2D1.Matrix3x2F.Identity;

			m_pRenderTarget.BeginDraw();

			m_pRenderTarget.SetTransform(&mat.matrix);

			m_pRenderTarget.Clear(&D2D1.ColorF(D2D1.ColorF.White).color); // ugh...

			D2D1_SIZE_F rtSize = m_pRenderTarget.GetSize();
			

			// Draw a grid background.
			int width = cast(int)rtSize.width;
			int height = cast(int)rtSize.height;

			for (int x = 0; x < width; x += 10)
			{
				m_pRenderTarget.DrawLine( D2D1.Point2F(cast(FLOAT)x, 0.0f), D2D1.Point2F(cast(FLOAT)x, rtSize.height), m_pLightSlateGrayBrush, 0.5f );
			}

			for (int y = 0; y < height; y += 10)
			{
				m_pRenderTarget.DrawLine( D2D1.Point2F(0.0f, cast(FLOAT)y), D2D1.Point2F(rtSize.width, cast(FLOAT)y), m_pLightSlateGrayBrush, 0.5f );
			}

			// Draw two rectangles.
			D2D1_RECT_F rectangle1 = D2D1.RectF(
				rtSize.width / 2 - 50.0f,
				rtSize.height / 2 - 50.0f,
				rtSize.width / 2 + 50.0f,
				rtSize.height / 2 + 50.0f
				);

			D2D1_RECT_F rectangle2 = D2D1.RectF(
				rtSize.width / 2 - 100.0f,
				rtSize.height / 2 - 100.0f,
				rtSize.width / 2 + 100.0f,
				rtSize.height / 2 + 100.0f
				);

			// Draw a filled rectangle.
			m_pRenderTarget.FillRectangle(&rectangle1, m_pLightSlateGrayBrush);

			// Draw the outline of a rectangle.
			m_pRenderTarget.DrawRectangle(&rectangle2, m_pCornflowerBlueBrush);

			hr = m_pRenderTarget.EndDraw();
		}

		if (hr == D2DERR_RECREATE_TARGET)
		{
			hr = S_OK;
			DiscardDeviceResources();
		}

		return hr;
	}

	// Resize the render target.
	nothrow void OnResize (
		UINT width,
		UINT height
		)	
	{
		auto size = D2D1_SIZE_U(width, height); // should be argument in Resize function
		try 
		{
			if (m_pRenderTarget)
			{
				// Note: This method can fail, but it's okay to ignore the
				// error here, because the error will be returned again
				// the next time EndDraw is called.
				if ( !SUCCEEDED(m_pRenderTarget.Resize(&size)) )
				{
					int err = GetLastError();
				}
			}
		}
		catch (Exception e)
		{
		}
	}

	// The windows procedure.
	nothrow extern(Windows) static LRESULT WndProc(
		HWND hWnd,
		UINT message,
		WPARAM wParam,
		LPARAM lParam
		)
	{
		LRESULT result = 0;

		if (message == WM_CREATE)
		{
			LPCREATESTRUCT pcs = cast(LPCREATESTRUCT)lParam;
			DemoApp pDemoApp = cast(DemoApp)pcs.lpCreateParams;

			SetWindowLong(
				hWnd,
				GWLP_USERDATA,
				cast(int)cast(void*)pDemoApp
				);

			result = 1;
		}
		else
		{
			DemoApp pDemoApp = cast(DemoApp)cast(void*)(
					GetWindowLong(
					hWnd,
					GWLP_USERDATA
				));

			bool wasHandled = false;

			if (pDemoApp)
			{
				switch (message)
				{
					case WM_SIZE:
						{
							UINT width = LOWORD(lParam);
							UINT height = HIWORD(lParam);
							pDemoApp.OnResize(width, height);
						}
						result = 0;
						wasHandled = true;
						break;

					case WM_DISPLAYCHANGE:
						{
							InvalidateRect(hWnd, null, FALSE);
						}
						result = 0;
						wasHandled = true;
						break;

					case WM_PAINT:
						{
							try {
							 pDemoApp.OnRender();
							 ValidateRect(hWnd, null);
							}
							catch( Exception e )
							{
							}
						}
						result = 0;
						wasHandled = true;
						break;

					case WM_DESTROY:
						{
							PostQuitMessage(0);
						}
						result = 1;
						wasHandled = true;
						break;
						
					default:
						break;
				}
			}

			if (!wasHandled)
			{
				result = DefWindowProc(hWnd, message, wParam, lParam);
			}
		}

		return result;
	}

private:
	__gshared HWND m_hwnd;
	__gshared ID2D1Factory m_pDirect2dFactory;
	__gshared ID2D1HwndRenderTarget m_pRenderTarget;
	__gshared ID2D1SolidColorBrush m_pLightSlateGrayBrush;
	__gshared ID2D1SolidColorBrush m_pCornflowerBlueBrush;
}


extern(Windows)
int WinMain(
	HINSTANCE /* hInstance */,
	HINSTANCE /* hPrevInstance */,
	LPSTR /* lpCmdLine */,
	int /* nCmdShow */
	)
{
	import core.runtime;
	
	Runtime.initialize();

	if (SUCCEEDED(CoInitialize(null)))
	{
		{
			DemoApp app = new DemoApp();

			if (SUCCEEDED(app.Initialize()))
			{
				app.RunMessageLoop();
			}
		}
		CoUninitialize();
	}
	
	Runtime.terminate();

	return 0;
}