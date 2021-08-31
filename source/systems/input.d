module systems.input;
import jni.helper.androidlog;
import jni.jni;
import jni.helper.jnicall;
import std.traits : hasUDA;
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
        import console.log;
        rawlog(x, " ", y);
	}
    mixin javaGenerateModuleMethodsForPackage!(HipAndroidInput, systems.input, true);
}
else
{
    
} 