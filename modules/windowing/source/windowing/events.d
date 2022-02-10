module windowing.events;
import windowing.input;

nothrow
{
    void function() onWindowClosed;
    void function(uint width, uint height) onWindowResize;
    void function(int moveY, int moveX) onMouseWheel;
    void function(int x, int y) onMouseMove;
    void function(ubyte btn, int x, int y) onMouseDown;
    void function(ubyte btn, int x, int y) onMouseUp;
    void function(wchar k) onKeyDown;
    void function(wchar k) onTextInput;
    void function(wchar k) onKeyUp;   
}
