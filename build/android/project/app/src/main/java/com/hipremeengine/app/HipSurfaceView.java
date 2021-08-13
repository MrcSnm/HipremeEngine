package com.hipremeengine.app;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Bundle;

public class HipSurfaceView extends GLSurfaceView
{
    Hip_GLES30_Renderer renderer;
    public HipSurfaceView(Context ctx)
    {
        super(ctx);
        setEGLContextClientVersion(3);
        renderer = new Hip_GLES30_Renderer();
        //Save battery
        setRenderer(renderer);
        setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);
    }
}
