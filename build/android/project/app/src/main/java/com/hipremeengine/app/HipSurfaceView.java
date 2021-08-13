package com.hipremeengine.app;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Bundle;

public class HipSurfaceView extends GLSurfaceView
{
    HipremeGL20Renderer renderer;
    public HipremeSurfaceView(Context ctx)
    {
        super(ctx);
        setEGLContextClientVersion(2);
        renderer = new
        //Save battery
        setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);
    }
}
