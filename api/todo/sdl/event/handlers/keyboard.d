
module sdl.event.handlers.keyboard;
import sdl.event.handlers.input.keyboard_layout;
import util.data_structures;
import bindbc.sdl;
import std.algorithm;
import std.conv;
import std.datetime.stopwatch;
import error.handler;
import util.time;
import util.array;
enum KeyCodes 
{
	BACKSPACE = 8,
	TAB,
	ENTER = 13,
	SHIFT = 16,
	CTRL,
	ALT,
	PAUSE_BREAK,
	CAPSLOCK,
	ESCAPE = 27,
	SPACE = 32,
	PAGE_UP,
	PAGE_DOWN,
	END,
	HOME,
	ARROW_LEFT,
	ARROW_UP,
	ARROW_RIGHT,
	ARROW_DOWN,
	INSERT = 45,
	DELETE,
	_0 = 48,
	_1,
	_2,
	_3,
	_4,
	_5,
	_6,
	_7,
	_8,
	_9,
	A = 65,
	B,
	C,
	D,
	E,
	F,
	G,
	H,
	I,
	J,
	K,
	L,
	M,
	N,
	O,
	P,
	Q,
	R,
	S,
	T,
	U,
	V,
	W,
	X,
	Y,
	Z,
	META_LEFT = 91,
	META_RIGHT,
	F1 = 112,
	F2,
	F3,
	F4,
	F5,
	F6,
	F7,
	F8,
	F9,
	F10,
	F11,
	F12,
	SEMICOLON = 186,
	EQUAL,
	COMMA,
	MINUS,
	PERIOD = 190,
	SLASH,
	BACKQUOTE,
	BRACKET_LEFT = 219,
	BACKSLASH,
	BRACKET_RIGHT,
	QUOTE,
}
private char toUppercase(char a);
abstract class Key
{
	KeyboardHandler* keyboard;
	KeyMetadata meta;
	int keyCode;
	abstract void onDown();
	abstract void onUp();
	final void rebind(SDL_Keycode newKeycode);
}
final private class KeyMetadata
{
	float lastDownTime;
	float downTimeStamp;
	float lastUpTime;
	float upTimeStamp;
	ubyte keyCode;
	bool isPressed = false;
	bool justPressed = false;
	this(int key)
	{
		this.keyCode = cast(ubyte)key;
	}
	this(SDL_Keycode key)
	{
		this.keyCode = cast(ubyte)key;
	}
	private void stampDownTime();
	private void stampUpTime();
	public float getDowntimeDuration();
	public float getUpTimeDuration();
	private void setPressed(bool press);
}
class KeyboardHandler
{
	private Key[][int] listeners;
	private int[int] listenersCount;
	private static int[256] pressedKeys;
	private static KeyMetadata[256] metadatas;
	private static string frameText;
	private static bool altPressed;
	private static bool shiftPressed;
	private static bool ctrlPressed;
	private static float keyRepeatDelay = 0.5;
	static this();
	bool rebind(Key k, SDL_Keycode kCode);
	void addKeyListener(SDL_Keycode key, Key k);
	private void setPressed(SDL_Keycode key, bool press);
	void handleKeyUp(SDL_Keycode key);
	pragma (inline, true)bool isKeyPressed(char key);
	void handleKeyDown(SDL_Keycode key);
	static string getInputText(KeyboardLayout layout);
	void update();
	void postUpdate();
}
