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

    this()
    {
        view = Matrix4.identity;
        proj = Matrix4.identity;
        viewProj = Matrix4.identity;
        updateFromViewport();
    }
    void updateFromViewport()
    {
        Viewport v = HipRenderer.getCurrentViewport();
        proj = Matrix4.orthoLH(v.x, v.width, v.height, v.y, znear, zfar);
    }
    void setSize(uint width, uint height)
    {
        proj = Matrix4.orthoLH(0, width, height, 0, znear, zfar);
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