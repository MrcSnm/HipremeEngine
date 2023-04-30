/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.api.input.keyboard;

interface IHipKeyboard
{
    bool isKeyPressed(char key);
    bool isKeyJustPressed(char key);
    bool isKeyJustReleased(char key);
    float getKeyDownTime(char key);
    float getKeyUpTime(char key);
}

enum HipKey : ushort
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
    PAGE_UP, PAGE_DOWN, END, HOME,
    ARROW_LEFT, ARROW_UP, ARROW_RIGHT, ARROW_DOWN,
    PRINT = 44, INSERT = 45, DELETE,
    _0 = 48, _1, _2, _3, _4, _5, _6, _7, _8, _9,
    A = 65, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,

    META_LEFT = 91, META_RIGHT,

    F1 = 112, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, 
    SEMICOLON = 186, EQUAL, COMMA, MINUS, PERIOD = 190, SLASH, BACKQUOTE, BRACKET_LEFT = 219, BACKSLASH, BRACKET_RIGHT, QUOTE,

    NONE = 255
}
