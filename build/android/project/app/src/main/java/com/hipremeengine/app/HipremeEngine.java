package com.hipremeengine.app;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.content.res.Resources;
import android.os.Bundle;

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
    ///Initializes the D runtime
    public static AssetManager assetManager;
    public static native void HipremeInit();
    public static native int HipremeMain();
    public static native boolean HipremeUpdate();
    public static native void HipremeRender();
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

        view = new HipSurfaceView((this));
        setContentView(view);
    }
    @Override
    protected void onDestroy()
    {
        super.onDestroy();
        HipremeDestroy();
        HipremeEngine.instance = null;
    }

    public static int[] getWindowSize ()
    {
        DisplayMetrics m = Resources.getSystem().getDisplayMetrics();
        return new int[]{m.widthPixels, m.heightPixels};
    }
    public static Object getAssetManager()
    {
        System.out.println("OPA AMIGAO");
        return assetManager;
    }

    public static String getApplicationDir() throws PackageManager.NameNotFoundException
    {
        if(instance != null)
            return instance.getPackageManager().getPackageInfo(instance.getPackageName(), 0).applicationInfo.dataDir;
        return "/";
    }
    public static float getPixelsDensity()
    {
        return Resources.getSystem().getDisplayMetrics().density;
    }
}