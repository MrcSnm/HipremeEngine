package com.hipremeengine.app;

import android.opengl.GLES20;
import android.opengl.GLSurfaceView;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class Hip_GLES30_Renderer implements GLSurfaceView.Renderer
{

    @Override
    public void onSurfaceCreated(GL10 gl, EGLConfig config)
    {
        HipremeEngine.HipremeMain();
        GLES20.glClearColor(0, 0, 0, 1);

    }

    @Override
    public void onSurfaceChanged(GL10 gl, int width, int height)
    {
        GLES20.glViewport(0, 0, width, height);
    }

    @Override
    public void onDrawFrame(GL10 gl)
    {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT);
        HipremeEngine.HipremeUpdate();
    }
}
