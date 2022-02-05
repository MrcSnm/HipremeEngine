module windowing.events;
import windowing.input;

nothrow void function() onWindowClosed;
nothrow void function(uint width, uint height) onWindowResize;
nothrow void function(int moveY, int moveX) onMouseWheel;
nothrow void function(int x, int y) onMouseMove;
nothrow void function(ubyte btn, int x, int y) onMouseDown;
nothrow void function(ubyte btn, int x, int y) onMouseUp;
nothrow void function(wchar k) onKeyDown;
nothrow void function(wchar k) onTextInput;
nothrow void function(wchar k) onKeyUp;
