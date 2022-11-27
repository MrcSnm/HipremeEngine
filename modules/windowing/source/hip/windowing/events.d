module hip.windowing.events;
import hip.windowing.input;

nothrow
{
    void function() onWindowClosed;
    void function(uint width, uint height) onWindowResize;
    void function(int moveY, int moveX) onMouseWheel;
    void function(int x, int y) onMouseMove;
    void function(ubyte btn, int x, int y) onMouseDown;
    void function(ubyte btn, int x, int y) onMouseUp;
    void function(uint k) onKeyDown;
    void function(uint k) onKeyUp;   
    void function(wchar k) onTextInput;
}
