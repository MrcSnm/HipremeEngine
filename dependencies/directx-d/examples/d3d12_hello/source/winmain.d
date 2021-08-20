
import core.runtime;
import core.thread;
import core.sys.windows.windows;
import std.typecons;
import std.string;
import std.datetime;

import d3d12_hello;

alias RefWindow = RefCounted!Window;

static SysTime startTime;


// Our window abstraction layer for sample
struct Window
{
	private enum WndClassName = "DWndClass"w;

	static RefWindow Create(wstring Title="Window", int Width=600 , int Height=400)
	{
		HINSTANCE hInst = GetModuleHandle(null);
		WNDCLASS  wc;

		wc.lpszClassName = WndClassName.ptr;
		wc.style         = CS_OWNDC | CS_HREDRAW | CS_VREDRAW;
		wc.lpfnWndProc   = &WindowProc;
		wc.hInstance     = hInst;
		wc.hIcon         = LoadIcon(cast(HINSTANCE) null, IDI_APPLICATION);
		wc.hCursor       = LoadCursor(cast(HINSTANCE) null, IDC_CROSS);
		wc.hbrBackground = cast(HBRUSH) (COLOR_WINDOW + 1);
		wc.lpszMenuName  = null;
		wc.cbClsExtra    = wc.cbWndExtra = 0;
		const auto wclass = RegisterClass(&wc);
		assert(wclass);

		HWND hWnd;
		hWnd = CreateWindow(WndClassName.ptr, Title.ptr, WS_THICKFRAME |
							WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SYSMENU | WS_VISIBLE,
							CW_USEDEFAULT, CW_USEDEFAULT, Width, Height, HWND_DESKTOP,
							cast(HMENU) null, hInst, null);
		assert(hWnd);

		RefWindow window;
		window.hWnd = hWnd;

		windowMap[hWnd] = window;

		return window;
	}

	// redraw or do other things
	package void onUpdate_() nothrow
	{
	}

	package void onResize_(int width, int height) nothrow
	{
		try
		{
			demoInstance.OnResize(width, height);
		}
		catch(Exception e)
		{
			//TODO: show message 
		}
	}

	HWND hWnd;

	// running sample instance associated with window
	D3D12Hello demoInstance;

	// associates hwnd and window object for later use
	package static RefWindow[HWND] windowMap;

} // struct Window



version(Windows)
{
	extern (Windows)
	LRESULT WindowProc(HWND hWnd, uint uMsg, WPARAM wParam, LPARAM lParam) nothrow
	{
		auto window = hWnd in Window.windowMap;
				

		switch (uMsg)
		{
			case WM_COMMAND:
				break;
				
			case WM_SIZE:
				UINT width = LOWORD(lParam);
				UINT height = HIWORD(lParam);
				if (window)
					(window).onResize_(width, height);
				break;

			case WM_PAINT:
				if (window)
					(window).onUpdate_();
				break;

			case WM_DESTROY:
				PostQuitMessage(0);
				break;

			default:
				break;
		}

		return DefWindowProc(hWnd, uMsg, wParam, lParam);
	}
}



extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	int result;

	try
	{
		Runtime.initialize();
		result = myWinMain();
		Runtime.terminate();
	}
	catch (Exception e)
	{
		import std.conv : to;
		import std.utf : toUTF16z;
		MessageBox(null, to!wstring(e.msg).toUTF16z(), "Error", MB_OK | MB_ICONEXCLAMATION);
		result = 0; // failed
	}

	return result;
}



int myWinMain()
{
	startTime = Clock.currTime();
	auto lastTime = startTime;

	auto window = Window.Create();
	auto example = new D3D12Hello(600,400,window.hWnd);
	window.demoInstance = example;

	MSG msg;
	while(true)
	{
		auto timeNow = Clock.currTime();
		auto deltaTime = (timeNow - lastTime).total!"msecs" / 1000.0f;
		lastTime = timeNow;

		if ( PeekMessage(&msg, cast(HWND) null, 0, 0, PM_REMOVE) )
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);

			if( msg.message == WM_QUIT )
				break;
		}

		example.OnUpdate(deltaTime);

		// too high FPS will cause issues in update logic since a fraction of time will be too small
		Thread.sleep( dur!("msecs")(1) );
	}

	example.OnDestroy();

	return 1;
}