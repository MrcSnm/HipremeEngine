module systems.input;
import jni.helper.androidlog;
import jni.jni;
import jni.helper.jnicall;
///Setups an Android Package for HipremeEngine
alias HipAndroidInput = javaGetPackage!("com.hipremeengine.app.HipInput");


version(Android)
{
    @JavaFunc!(HipAndroidInput) void onMotionEvent_ActionMove(float x, float y)
	{
        import console.log;
        rawlog(x, " ", y);
	}

    @JavaFunc!(HipAndroidInput) void onMotionEvent_ActionTouch(float x, float y)
	{
	}
    @JavaFunc!(HipAndroidInput) void onMotionEventActionTalk(string s, float x, float y)
    {
        import console.log;
    }
    // extern(C) void Java_com_hipremeengine_app_HipInput_onMotionEvent_ActionTalk (JNIEnv* env, jclass clazz, jstring s,jfloat x,jfloat y)      
    // {
    //     pragma(inline, true)
    //     import console.log;
    //     rawlog("Comi sua mae, chamada, ", s);
    //     // onMotionEvent_ActionTalk(javaTypeToD!string(env, s),x,y);
    // }


    mixin javaGenerateModuleMethodsForPackage!(HipAndroidInput, systems.input, true);
}
else
{

} 