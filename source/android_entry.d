module android_entry;

version(Android):
import app;
import hip.jni.helper.androidlog;
import hip.jni.jni;
import hip.jni.helper.jnicall;
///Setups an Android Package for HipremeEngine
alias HipAndroid = javaGetPackage!("com.hipremeengine.app.HipremeEngine");
import hip.systems.input;
import hip.console.log;


export extern(C)
{
    private __gshared bool _hasExecInit = false;
    void Java_com_hipremeengine_app_HipremeEngine_HipremeInit(JNIEnv* env, jclass clazz)
    {
        if(!_hasExecInit)
        {
            _hasExecInit = true;
            import hip.filesystem.systems.android;
            HipremeInit();
            JNISetEnv(env);
            aaMgr = cast(AAssetManager*)HipAndroid.javaCall!(Object, "getAssetManager");
            aaMgr = AAssetManager_fromJava(env, aaMgr);
        }
    }

    private __gshared bool _hasExecMain;
    private __gshared int  _mainRet;
    jint Java_com_hipremeengine_app_HipremeEngine_HipremeMain(JNIEnv* env, jclass clazz)
    {
        if(!_hasExecMain)
        {
            _hasExecMain = true;
            int[2] wsize = HipAndroid.javaCall!(int[2], "getWindowSize");
            _mainRet = HipremeMain(wsize[0], wsize[1]);
        }
        return _mainRet;
    }
    jboolean Java_com_hipremeengine_app_HipremeEngine_HipremeUpdate(JNIEnv* env, jclass clazz)
    {
        return HipremeUpdate();
    }
    void Java_com_hipremeengine_app_HipremeEngine_HipremeRender(JNIEnv* env, jclass clazz)
    {
        HipremeRender();
    }

    void Java_com_hipremeengine_app_HipremeEngine_HipremeReinitialize(JNIEnv* env, jclass clazz)
    {
        import hip.hiprenderer.renderer;
        HipRenderer.reinitialize();
    }

    void  Java_com_hipremeengine_app_HipremeEngine_HipremeDestroy(JNIEnv* env, jclass clazz)
    {
        JNISetEnv(null);
        HipremeDestroy();
    }
}