package com.hipremeengine.app;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.view.MotionEvent;

public class HipSurfaceView extends GLSurfaceView
{
    Hip_GLES30_Renderer renderer;
    public HipSurfaceView(Context ctx)
    {
        super(ctx);
        setEGLContextClientVersion(3);
        renderer = new Hip_GLES30_Renderer();
        setRenderer(renderer);
        //Save battery
        setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);
    }

    @Override
    public boolean onTouchEvent(MotionEvent e)
    {
        super.onTouchEvent(e);
        int i = 0;
        int ID = 0;
        int pointerCount = e.getPointerCount();
        switch(e.getAction())
        {
            case MotionEvent.ACTION_MOVE:
                for(; i < pointerCount;i++)
                {
                    ID = e.getPointerId(i);
                    HipInput.onMotionEventActionMove(ID, e.getX(ID), e.getY(ID));
                }
                break;
            case MotionEvent.ACTION_DOWN:
            case MotionEvent.ACTION_POINTER_DOWN:
                for(; i < pointerCount;i++)
                {
                    ID = e.getPointerId(i);
                    HipInput.onMotionEventActionPointerDown(ID, e.getX(ID), e.getY(ID));
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL: //Sometimes it is cancelled instead of "up"
            case MotionEvent.ACTION_POINTER_UP:
                for(; i < pointerCount;i++)
                {
                    ID = e.getPointerId(i);
                    HipInput.onMotionEventActionPointerUp(ID, e.getX(ID), e.getY(ID));
                }
                break;
            case MotionEvent.ACTION_SCROLL:
                HipInput.onMotionEventActionScroll(e.getAxisValue(MotionEvent.AXIS_HSCROLL), e.getAxisValue(MotionEvent.AXIS_VSCROLL));
                break;
            default:break;
        }
        return true;
    }

}
