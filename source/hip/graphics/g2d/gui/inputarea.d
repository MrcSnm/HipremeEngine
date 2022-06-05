module hip.graphics.g2d.gui.inputarea;

struct HipInputAreaHandler
{
    string name;
    int x, y, w, h;
    bool delegate(int x, int y) onInput;
}

class HipInputArea
{
    HipInputAreaHandler[] handlers;
    void addArea(HipInputAreaHandler handler){handlers~=handler;}
}