// D import file generated from 'source\app.d'
import console.log;
import console.console;
import bind.external;
import data.hipfs;
import error.handler;
import global.consts;
import hipaudio.audio;
version (Android)
{
	import jni.helper.androidlog;
	import jni.jni;
	import jni.helper.jnicall;
	alias HipAndroid = javaGetPackage!"com.hipremeengine.app.HipremeEngine";
}
version (Windows)
{
	import hiprenderer.backend.d3d.renderer;
}
version (dll)
{
	import core.runtime;
}
import hiprenderer.renderer;
import view;
import systems.game;
import debugging.gui;
static void initEngine(bool audio3D = false);
__gshared GameSystem sys;
__gshared float g_deltaTime = 0;
enum float FRAME_TIME = 1000 / 60;
extern (C) int SDL_main();
static void destroyEngine();
version (Android)
{
	import systems.input;
	extern (C) void Java_com_hipremeengine_app_HipremeEngine_HipremeInit(JNIEnv* env, jclass clazz);
	extern (C) jint Java_com_hipremeengine_app_HipremeEngine_HipremeMain(JNIEnv* env, jclass clazz);
	extern (C) jboolean Java_com_hipremeengine_app_HipremeEngine_HipremeUpdate(JNIEnv* env, jclass clazz);
	extern (C) void Java_com_hipremeengine_app_HipremeEngine_HipremeRender(JNIEnv* env, jclass clazz);
	extern (C) void Java_com_hipremeengine_app_HipremeEngine_HipremeDestroy(JNIEnv* env, jclass clazz);
}
export extern (C) void HipremeInit();
export extern (C) int HipremeMain();
version (dll)
{
}
else
{
	void main();
}
export extern (C) bool HipremeUpdate();
export extern (C) void HipremeRender();
export extern (C) void HipremeDestroy();
