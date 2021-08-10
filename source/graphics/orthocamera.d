module graphics.orthocamera;
import graphics.g2d.viewport;
import implementations.renderer;
import math.matrix;

class HipOrthoCamera
{
    Matrix4 view;
    Matrix4 proj;
    Matrix4 viewProj;
    float znear = 0.001f;
    float zfar  = 100.0f;

    this()
    {
        view = Matrix4.identity;
        Viewport v = HipRenderer.getCurrentViewport();
        proj = Matrix4.orthoLH(v.x, v.w, v.h, v.y, znear, zfar);
    }
    void translate(float x, float y, float z)
    {
        view = view.translate(x, y, z);
    }
    void setScale(float x, float y, float z = 1)
    {
        view = view.scale((1/view[0])*x, (1/view[5])*y, (1/view[10])*z);
    }
    void scale(float x, float y, float z = 0)
    {
        view = view.scale(x,y,z);
    }

    void setPosition(float x, float y, float z = 0)
    {
        view = view.translate(-view[12]+x, -view[13]+y, -view[14]+z);
    }
    pragma(inline, true)
    @property float x(){return view[12];}
    pragma(inline, true)
    @property float y(){return view[13];}
    pragma(inline, true)
    @property float z(){return view[14];}

    void update()
    {
        viewProj = view*proj;
    }
}