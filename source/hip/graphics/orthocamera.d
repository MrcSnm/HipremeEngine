/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.graphics.orthocamera;
import hip.hiprenderer.viewport;
import hip.hiprenderer;
import hip.math.matrix;
import hip.math.utils;
import hip.math.vector;

enum CameraType : ubyte
{
    orthographic,
    perspective
}

/**
*   Orthographic Projection camera. 
*   A good resource to understand how orthographic projection works follows on:
*   http://learnwebgl.brown37.net/08_projections/projections_ortho.html
*
*   But basically:
*   1. Translate the center to the origin of the screen(top left)
*   2. Scale the screen size by 2 (remember that we lost the -1..0 range)
*   3. Alternate the handeness if necessary
*/
class HipOrthoCamera
{
    Matrix4 view;
    Matrix4 proj;
    Matrix4 viewProj;
    float znear = 0.001f;
    float zfar  = 100.0f;
    float fov = PI_2;

    CameraType type = CameraType.orthographic;

    bool dirty = false;

    this()
    {
        view = Matrix4.identity;
        proj = Matrix4.identity;
        viewProj = Matrix4.identity;
        updateFromViewport();
    }

    void setType(CameraType type)
    {
        this.type = type;
        updateFromViewport();
    }
    private void updateProjection(uint x, uint y, uint width, uint height)
    {
        if(type == CameraType.orthographic)
            proj = Matrix4.orthoLH(x, width, height, y, znear, zfar);
        else
            proj = Matrix4.perspective(fov, width, height, znear, zfar);
    }
    void updateFromViewport()
    {
        Viewport v = HipRenderer.getCurrentViewport();
        updateProjection(v.x, v.y, v.width, v.height);
        dirty = true;
    }
    void setSize(uint width, uint height)
    {
        updateProjection(cast(uint)x, cast(uint)y, width, height);
        dirty = true;
    }
    void translate(float x, float y, float z)
    {
        view = view.translate(x, y, z);
        dirty = true;
    }
    void setScale(float x, float y, float z = 1)
    {
        view = view.scale((1/view[0])*x, (1/view[5])*y, (1/view[10])*z);
        dirty = true;
    }
    void scale(float x, float y, float z = 0)
    {
        view = view.scale(x,y,z);
        dirty = true;
    }

    void lookAt(Vector3 origin, Vector3 lookPoint, Vector3 up = Vector3(0, 1, 0))
    {
        Vector3 cameraDir = (lookPoint - origin).normalize;
        Vector3 cameraRight = up.cross(cameraDir).normalize;
        Vector3 cameraUp = cameraDir.cross(cameraRight);

        view = Matrix4([
            cameraRight.x, cameraUp.x, cameraDir.x, 0,
            cameraRight.y, cameraUp.y, cameraDir.y, 0,
            cameraRight.z, cameraUp.z, cameraDir.z, 0,
            -Vector3.Dot(cameraRight, origin), -Vector3.Dot(cameraUp, origin), -Vector3.Dot(cameraDir, origin), 1
        ]);
        dirty = true;

    }

    Matrix4 getMVP()
    {
        if(dirty)update();
        return viewProj;
    }

    void setPosition(float x, float y, float z = 0)
    {
        view = view.translate(-view[12]+x, -view[13]+y, -view[14]+z);
        dirty = true;
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
        dirty = false;
    }
}