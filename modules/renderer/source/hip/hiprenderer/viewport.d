/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.viewport;
import hip.math.vector;
import hip.math.scaling;
import hip.hiprenderer.renderer;
import hip.math.rect;
public import hip.api.renderer.viewport;

package void sanityCheck(in Viewport v)
{
    assert(v.width > 0, "Can't have viewport with width less than 0");
    assert(v.height > 0, "Can't have viewport with height less than 0");
}

void setFitViewport(ref Viewport v, int windowWidth, int windowHeight)
{
    Vector2 size = Scaling.fit(v.worldWidth, v.worldHeight,windowWidth, windowHeight);
    v.setBounds(
        (windowWidth - cast(int)size.x)/2,
        (windowHeight - cast(int)size.y)/2,
        cast(int)size.x, cast(int)size.y
    );
}

void setType(ref Viewport v, ViewportType type, int windowWidth, int windowHeight)
{
    v.type = type;
    updateForWindowSize(v, windowWidth, windowHeight);
}

void updateForWindowSize(ref Viewport v, int windowWidth, int windowHeight)
{
    final switch(v.type)
    {
        case ViewportType.default_:
            v.width = windowWidth;
            v.height = windowHeight;
            break;
        case ViewportType.fit:
            v.setFitViewport(windowWidth, windowHeight);
            break;
    }   
    v.sanityCheck();
}