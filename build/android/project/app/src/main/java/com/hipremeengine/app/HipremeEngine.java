package com.hipremeengine.app;

import android.app.Activity;
import android.opengl.GLSurfaceView;
import android.os.Bundle;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.snackbar.Snackbar;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.util.Log;
import android.view.View;

import android.view.Menu;
import android.view.MenuItem;

public class HipremeEngine extends Activity
{
    static
    {
        try{
            System.loadLibrary("hipreme_engine");
        }
        catch (Exception e)
        {
            Log.e("HipremeEngine", "Could not load libhipreme_engine.so");
        }
    }
    public static native int HipremeMain();
    public static native boolean HipremeUpdate();
    public static native void HipremeDestroy();

    HipSurfaceView view;
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        view = new HipSurfaceView((this));
        setContentView(view);
    }
}