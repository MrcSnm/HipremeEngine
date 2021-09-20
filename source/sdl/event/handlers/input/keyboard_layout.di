// D import file generated from 'D:\HipremeEngine\source\sdl\event\handlers\input\keyboard_layout.d'
module sdl.event.handlers.input.keyboard_layout;
import sdl.event.handlers.keyboard;
import util.data_structures;
abstract class KeyboardLayout
{
	enum KeyState 
	{
		NONE = 0,
		ALT = 1 << 0,
		CTRL = 1 << 1,
		SHIFT = 1 << 2,
	}
	abstract void initialize();
	this()
	{
		initialize();
	}
	protected string[Pair!(char, int)] kb;
	static alias KeyStroke = Pair!(char, int);
	pragma (inline, true)final void addKey(char key, string output, KeyState ks = KeyState.NONE);
	final string getKey(char key, KeyState ks);
	pragma (inline, true)final void addKeyAnyState(char key, string output);
	final void generateDefaults();
}
class KeyboardLayoutABNT2 : KeyboardLayout
{
	override void initialize();
}
