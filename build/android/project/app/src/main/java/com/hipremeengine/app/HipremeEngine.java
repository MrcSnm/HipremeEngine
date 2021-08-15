package com.hipremeengine.app;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.opengl.GLSurfaceView;
import android.os.Bundle;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.snackbar.Snackbar;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;

import android.view.Menu;
import android.view.MenuItem;
import android.view.Window;
import android.view.WindowInsetsController;
import android.view.WindowManager;

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
        instance = this;
        view = new HipSurfaceView((this));
        setContentView(view);
    }
    @Override
    protected void onDestroy()
    {
        super.onDestroy();
        HipremeEngine.instance = null;
    }

    public static int[] getWindowSize ()
    {
        DisplayMetrics m = Resources.getSystem().getDisplayMetrics();
        return new int[]{m.widthPixels, m.heightPixels};
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