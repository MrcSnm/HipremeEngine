/*
XAudio2 tutorial ported to D
http://www.win32developer.com/tutorial/xaudio/xaudio_tutorial_1.shtm
*/

import core.sys.windows.com;
import core.sys.windows.windows;
import std.stdio;
import std.string;

import directx.xaudio2;

import wave;

int xaudio_tutorial()
{
	IXAudio2 g_engine;
	IXAudio2SourceVoice g_source;
	IXAudio2MasteringVoice g_master;

	//must call this for COM
	auto hr = CoInitializeEx( null, COINIT_MULTITHREADED );
	
	if ( FAILED(hr) )
		return -5;

	//create the engine
	if( FAILED( XAudio2Create( g_engine ) ) )
	{
		CoUninitialize();
		return -1;
	}

	//create the mastering voice
	if( FAILED( g_engine.CreateMasteringVoice( &g_master ) ) )
	{
		g_engine.Release();
		CoUninitialize();
		return -2;
	}

	//helper class to load wave files; trust me, this makes it MUCH easier
	Wave buffer;
	if ( !buffer.load("sfx.wav") )
	{
		g_engine.Release();
		CoUninitialize();
		return -3;
	}

	//create the source voice, based on loaded wave format
	if( FAILED( g_engine.CreateSourceVoice( &g_source, buffer.wf() ) ) )
	{
		g_engine.Release();
		CoUninitialize();
		return -4;
	}

	//start consuming audio in the source voice
	g_source.Start();
	
	//simple message loop
	while( MessageBoxA( null, toStringz("Do you want to play the sound?"), toStringz("ABLAX: PAS"), MB_YESNO ) == IDYES )
	{
		g_source.SubmitSourceBuffer( buffer.xaBuffer() );
	}

	//release the engine, NOT the voices!
	g_engine.Release();

	//again, for COM
	CoUninitialize();

	return 0;
}

extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	import core.runtime;
	int result;
	
	try
	{
		Runtime.initialize();
		result = xaudio_tutorial();
		Runtime.terminate();
	}

    catch (Exception e)            // catch any uncaught exceptions
    {
		MessageBoxA(null, toStringz(e.msg), "Error", MB_OK | MB_ICONEXCLAMATION);
		result = 0;             // failed
    }

	return cast(int)result;
}


