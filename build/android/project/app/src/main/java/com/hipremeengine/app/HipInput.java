package com.hipremeengine.app;

public class HipInput
{
    public static native void onMotionEventActionMove(int pointerId, float x, float y);
    public static native void onMotionEventActionPointerDown(int pointerId, float x, float y);
    public static native void onMotionEventActionPointerUp(int pointerId, float x, float y);
    public static native void onMotionEventActionScroll(float x, float y);
}
