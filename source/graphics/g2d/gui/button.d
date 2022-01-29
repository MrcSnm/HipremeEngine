module graphics.g2d.gui.button;
import graphics.g2d.gui.inputarea;
import math.collision;

/**
*   Responsible for controlling the input
*/
class HipButtonController
{
    int x, y, w, h;

    enum State{up,down,hovered}
    State state;

    void delegate() onClick;
    void delegate() onHover;
    void delegate() onUp;
    void delegate() onDown;

    void updateState(State forState, int x, int y)
    {
        if(isPointInsideRect(x, y, this.x, this.y, w, h))
            state = forState;
    }
}