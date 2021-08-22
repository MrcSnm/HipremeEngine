/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module sdl.event.handlers.input.keyboard_layout;
import sdl.event.handlers.keyboard;
import util.data_structures;

/**
*   This class is used for getting user text input based on the keyboard layout implementation
*/
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
    this(){initialize();}

    protected string[Pair!(char, int)] kb;
    static alias KeyStroke = Pair!(char, int);
    
    pragma(inline, true)
    final void addKey(char key, string output, KeyState ks = KeyState.NONE)
    {
        kb[KeyStroke(key, ks)] = output;
    }

    final string getKey(char key, KeyState ks)
    {
        import std.stdio;
        string* str = (KeyStroke(key, ks) in kb);
        if(str == null)
        {
            return "";
        }
        return *str; 
    }

    pragma(inline, true)
    final void addKeyAnyState(char key, string output)
    {
        import std.traits:EnumMembers;
        int[] members = cast(int[])[EnumMembers!KeyState];

        for(int i = 0; i < members.length; i++)
            addKey(key, output, cast(KeyState)members[i]);

    }


    final void generateDefaults()
    {
        with(KeyCodes)
        {
            addKeyAnyState(SPACE, " ");
            addKeyAnyState(ENTER, "\n");
            addKey(_0, "0");
            addKey(_1, "1");
            addKey(_2, "2");
            addKey(_3, "3");
            addKey(_4, "4");
            addKey(_5, "5");
            addKey(_6, "6");
            addKey(_7, "7");
            addKey(_8, "8");
            addKey(_9, "9");
            
        }
    }
}


class KeyboardLayoutABNT2 : KeyboardLayout
{
    override void initialize()
    {
        generateDefaults();
        with(KeyCodes)
        {
            addKey(A, "a");
            addKey(B, "b");
            addKey(C, "c");
            addKey(D, "d");
            addKey(E, "e");
            addKey(F, "f");
            addKey(G, "g");
            addKey(H, "h");
            addKey(I, "i");
            addKey(J, "j");
            addKey(K, "k");
            addKey(L, "l");
            addKey(M, "m");
            addKey(N, "n");
            addKey(O, "o");
            addKey(P, "p");
            addKey(Q, "q");
            addKey(R, "r");
            addKey(S, "s");
            addKey(T, "t");
            addKey(U, "u");
            addKey(V, "v");
            addKey(W, "w");
            addKey(X, "x");
            addKey(Y, "y");
            addKey(Z, "z");
            addKey(MINUS, "-");
            addKey(EQUAL, "=");
            addKey(BRACKET_LEFT, "");//Not supported
            addKey(BRACKET_RIGHT, "[");
            addKey(BACKSLASH, "]");
            addKey(SLASH, ";");
            addKey(PERIOD, ".");
            addKey(COMMA, ",");
            addKey(QUOTE, "~");
            addKey(BACKQUOTE, "'");

            //Shift
            addKey(A, "A", KeyState.SHIFT);
            addKey(B, "B", KeyState.SHIFT);
            addKey(C, "C", KeyState.SHIFT);
            addKey(D, "D", KeyState.SHIFT);
            addKey(E, "E", KeyState.SHIFT);
            addKey(F, "F", KeyState.SHIFT);
            addKey(G, "G", KeyState.SHIFT);
            addKey(H, "H", KeyState.SHIFT);
            addKey(I, "I", KeyState.SHIFT);
            addKey(J, "J", KeyState.SHIFT);
            addKey(K, "K", KeyState.SHIFT);
            addKey(L, "L", KeyState.SHIFT);
            addKey(M, "M", KeyState.SHIFT);
            addKey(N, "N", KeyState.SHIFT);
            addKey(O, "O", KeyState.SHIFT);
            addKey(P, "P", KeyState.SHIFT);
            addKey(Q, "Q", KeyState.SHIFT);
            addKey(R, "R", KeyState.SHIFT);
            addKey(S, "S", KeyState.SHIFT);
            addKey(T, "T", KeyState.SHIFT);
            addKey(U, "U", KeyState.SHIFT);
            addKey(V, "V", KeyState.SHIFT);
            addKey(W, "W", KeyState.SHIFT);
            addKey(X, "X", KeyState.SHIFT);
            addKey(Y, "Y", KeyState.SHIFT);
            addKey(Z, "Z", KeyState.SHIFT);

            addKey(_1, "!", KeyState.SHIFT);
            addKey(_2, "@", KeyState.SHIFT);
            addKey(_3, "#", KeyState.SHIFT);
            addKey(_4, "$", KeyState.SHIFT);
            addKey(_5, "%", KeyState.SHIFT);
            addKey(_6, "¨", KeyState.SHIFT);
            addKey(_7, "&", KeyState.SHIFT);
            addKey(_8, "*", KeyState.SHIFT);
            addKey(_9, "(", KeyState.SHIFT);
            addKey(_0, ")", KeyState.SHIFT);

            addKey(MINUS, "_", KeyState.SHIFT);
            addKey(EQUAL, "+", KeyState.SHIFT);
            addKey(BRACKET_LEFT, "`", KeyState.SHIFT);
            addKey(BRACKET_RIGHT, "{", KeyState.SHIFT);
            addKey(BACKSLASH, "}", KeyState.SHIFT);
            addKey(SLASH, ":", KeyState.SHIFT);
            addKey(PERIOD, ">", KeyState.SHIFT);
            addKey(COMMA, "<", KeyState.SHIFT);
            addKey(BACKQUOTE, "\"", KeyState.SHIFT);

            import def.debugging.log;

            rawlog(kb[KeyStroke('A', KeyState.NONE)]);
            
        }
    }
}