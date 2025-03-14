package com.hipremeengine.app;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.content.res.Resources;
import android.media.AudioManager;
import android.os.Bundle;

import android.os.Looper;
import android.os.MessageQueue;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;

import java.io.IOException;

public class HipremeEngine extends Activity
{
    static
    {
        try{ System.loadLibrary("hipreme_engine"); }
        catch (Exception e) { Log.e("HipremeEngine", "Could not load libhipreme_engine.so"); }
    }
    public static boolean isRunning = true;
    public static Thread gameThread;
    public static HipremeEngine instance;
    public static AssetManager assetManager;
    ///Initializes the D runtime
    public static native void HipremeInit();
    ///Initializes the engine modules
    public static native int HipremeMain();
    public static native boolean HipremeUpdate();
    public static native void HipremeRender();
    public static native void HipremeReinitialize();
    public static native void HipremeDestroy();

    HipSurfaceView view;
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        try {
            for(String s : getApplicationContext().getResources().getAssets().list(""))
                System.out.println(s);
        } catch (IOException e) {
            e.printStackTrace();
        }

        assetManager = getApplicationContext().getResources().getAssets();
        instance = this;
        view = new HipSurfaceView(this);
        setContentView(view);
    }
    @Override
    protected void onDestroy()
    {
        super.onDestroy();
        //HipremeDestroy();
        HipremeEngine.instance = null;
    }


    //--------------------------------------------------------------------------------------------//
    // Public API called by the native code
    //--------------------------------------------------------------------------------------------//

    //--------------------------------------------------------------------------------------------//
    // Window section
    //--------------------------------------------------------------------------------------------//
    public static int[] getWindowSize ()
    {
        DisplayMetrics m = Resources.getSystem().getDisplayMetrics();
        return new int[]{m.widthPixels, m.heightPixels};
    }
    public static float getPixelsDensity(){return Resources.getSystem().getDisplayMetrics().density;}

    //--------------------------------------------------------------------------------------------//
    // Asset manager (file loading related)
    //--------------------------------------------------------------------------------------------//

    public static Object getAssetManager(){return assetManager;}
    public static String getApplicationDir() throws PackageManager.NameNotFoundException
    {
        if(instance != null)
            return instance.getPackageManager().getPackageInfo(instance.getPackageName(), 0).applicationInfo.dataDir;
        return "/";
    }

    //--------------------------------------------------------------------------------------------//
    // Audio manger (low latency config)
    //--------------------------------------------------------------------------------------------//

    public static boolean hasLowLatencyFeature()
    {
        if(instance != null)
            return instance.getPackageManager().hasSystemFeature(PackageManager.FEATURE_AUDIO_LOW_LATENCY);
        return false;
    }
    public static boolean hasProFeature()
    {
        if(instance != null)
            return instance.getPackageManager().hasSystemFeature(PackageManager.FEATURE_AUDIO_PRO);
        return false;
    }

    public static int getOptimalSampleRate()
    {
        if(instance != null)
            return Integer.parseInt(((AudioManager)instance.getSystemService(Context.AUDIO_SERVICE)).getProperty(AudioManager.PROPERTY_OUTPUT_SAMPLE_RATE));
        return 44100;
    }
    public static int getOptimalAudioBufferSize()
    {
        if(instance != null)
            return Integer.parseInt(((AudioManager)instance.getSystemService(Context.AUDIO_SERVICE)).getProperty(AudioManager.PROPERTY_OUTPUT_FRAMES_PER_BUFFER));
        return 256;
    }
}