package com.hipremeengine.app;

import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.util.Log;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class Hip_GLES30_Renderer implements GLSurfaceView.Renderer
{

    @Override
    public void onSurfaceCreated(GL10 gl, EGLConfig config)
    {
        HipremeEngine.HipremeMain();
        HipremeEngine.gameThread = new Thread(new Runnable() {
            @Override
            public void run()
            {
                long initialTime, deltaTime;
                while(HipremeEngine.isRunning)
                {
                    try{ Thread.sleep(16); }
                    catch(InterruptedException e) { e.printStackTrace();}

                    initialTime =  System.nanoTime();
                    HipremeEngine.HipremeUpdate();
                    deltaTime = System.nanoTime() - initialTime;
                    //System.out.println(deltaTime/1000);
                }
            }
        });
        HipremeEngine.gameThread.start();
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
        //By doing that, it is possible to save little battery when the renderer
        //is not dirty
        HipremeEngine.HipremeRender();
    }
}
