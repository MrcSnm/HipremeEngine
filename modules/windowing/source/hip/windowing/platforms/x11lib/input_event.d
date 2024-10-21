module hip.windowing.platforms.x11lib.input_event;

//Currently unused
enum LinuxKeys
{
    KEY_RESERVED = 0,
    KEY_ESC = 1,
    KEY_1 = 2,
    KEY_2 = 3,
    KEY_3 = 4,
    KEY_4 = 5,
    KEY_5 = 6,
    KEY_6 = 7,
    KEY_7 = 8,
    KEY_8 = 9,
    KEY_9 = 10,
    KEY_0 = 11,
    KEY_MINUS = 12,
    KEY_EQUAL = 13,
    KEY_BACKSPACE = 14,
    KEY_TAB = 15,
    KEY_Q = 16,
    KEY_W = 17,
    KEY_E = 18,
    KEY_R = 19,
    KEY_T = 20,
    KEY_Y = 21,
    KEY_U = 22,
    KEY_I = 23,
    KEY_O = 24,
    KEY_P = 25,
    KEY_LEFTBRACE = 26,
    KEY_RIGHTBRACE = 27,
    KEY_ENTER = 28,
    KEY_LEFTCTRL = 29,
    KEY_A = 30,
    KEY_S = 31,
    KEY_D = 32,
    KEY_F = 33,
    KEY_G = 34,
    KEY_H = 35,
    KEY_J = 36,
    KEY_K = 37,
    KEY_L = 38,
    KEY_SEMICOLON = 39,
    KEY_APOSTROPHE = 40,
    KEY_GRAVE = 41,
    KEY_LEFTSHIFT = 42,
    KEY_BACKSLASH = 43,
    KEY_Z = 44,
    KEY_X = 45,
    KEY_C = 46,
    KEY_V = 47,
    KEY_B = 48,
    KEY_N = 49,
    KEY_M = 50,
    KEY_COMMA = 51,
    KEY_DOT = 52,
    KEY_SLASH = 53,
    KEY_RIGHTSHIFT = 54,
    KEY_KPASTERISK = 55,
    KEY_LEFTALT = 56,
    KEY_SPACE = 57,
    KEY_CAPSLOCK = 58,
    KEY_F1 = 59,
    KEY_F2 = 60,
    KEY_F3 = 61,
    KEY_F4 = 62,
    KEY_F5 = 63,
    KEY_F6 = 64,
    KEY_F7 = 65,
    KEY_F8 = 66,
    KEY_F9 = 67,
    KEY_F10 = 68,
    KEY_NUMLOCK = 69,
    KEY_SCROLLLOCK = 70,
    KEY_KP7 = 71,
    KEY_KP8 = 72,
    KEY_KP9 = 73,
    KEY_KPMINUS = 74,
    KEY_KP4 = 75,
    KEY_KP5 = 76,
    KEY_KP6 = 77,
    KEY_KPPLUS = 78,
    KEY_KP1 = 79,
    KEY_KP2 = 80,
    KEY_KP3 = 81,
    KEY_KP0 = 82,
    KEY_KPDOT = 83,

    KEY_ZENKAKUHANKAKU = 85,
    KEY_102ND = 86,
    KEY_F11 = 87,
    KEY_F12 = 88,
    KEY_RO = 89,
    KEY_KATAKANA = 90,
    KEY_HIRAGANA = 91,
    KEY_HENKAN = 92,
    KEY_KATAKANAHIRAGANA = 93,
    KEY_MUHENKAN = 94,
    KEY_KPJPCOMMA = 95,
    KEY_KPENTER = 96,
    KEY_RIGHTCTRL = 97,
    KEY_KPSLASH = 98,
    KEY_SYSRQ = 99,
    KEY_RIGHTALT = 100,
    KEY_LINEFEED = 101,
    KEY_HOME = 102,
    KEY_UP = 103,
    KEY_PAGEUP = 104,
    KEY_LEFT = 105,
    KEY_RIGHT = 106,
    KEY_END = 107,
    KEY_DOWN = 108,
    KEY_PAGEDOWN = 109,
    KEY_INSERT = 110,
    KEY_DELETE = 111,
    KEY_MACRO = 112,
    KEY_MUTE = 113,
    KEY_VOLUMEDOWN = 114,
    KEY_VOLUMEUP = 115,
    KEY_POWER = 116	/* SC System Power Down */,
    KEY_KPEQUAL = 117,
    KEY_KPPLUSMINUS = 118,
    KEY_PAUSE = 119,
    KEY_SCALE = 120	/* AL Compiz Scale (Expose) */,
    KEY_KPCOMMA = 121,
    KEY_HANGEUL = 122,
    KEY_HANGUEL = KEY_HANGEUL,
    KEY_HANJA = 123,
    KEY_YEN = 124,
    KEY_LEFTMETA = 125,
    KEY_RIGHTMETA = 126,
    KEY_COMPOSE = 127
}

/**
private HipKey getHipKeyFromSystem(uint key)
    {
        import hip.windowing.platforms.x11lib.input_event;
        ushort k = cast(ushort)(key);
        assert(k > 0 && k < ubyte.max, "Key out of range");
        switch(k) with(X11Keys)
        {
            case KEY_BACKSPACE: return HipKey.BACKSPACE;
            case KEY_TAB: return HipKey.TAB;
            case KEY_ENTER: return HipKey.ENTER;
            case KEY_LEFTSHIFT: return HipKey.SHIFT;
            case KEY_RIGHTSHIFT: return HipKey.SHIFT;
            case KEY_LEFTCTRL: return HipKey.CTRL;
            case KEY_RIGHTCTRL: return HipKey.CTRL;
            case KEY_LEFTALT: return HipKey.ALT;
            case KEY_RIGHTALT: return HipKey.ALT;
            case KEY_PAUSE: return HipKey.PAUSE_BREAK;
            case KEY_CAPSLOCK: return HipKey.CAPSLOCK;
            case KEY_ESC: return HipKey.ESCAPE;
            case KEY_SPACE: return HipKey.SPACE;
            case KEY_PAGEUP: return HipKey.PAGE_UP;
            case KEY_PAGEDOWN: return HipKey.PAGE_DOWN;
            case KEY_END: return HipKey.END;
            case KEY_HOME: return HipKey.HOME;
            case KEY_LEFT: return HipKey.ARROW_LEFT;
            case KEY_UP: return HipKey.ARROW_UP;
            case KEY_RIGHT: return HipKey.ARROW_RIGHT;
            case KEY_DOWN: return HipKey.ARROW_DOWN;
            case KEY_INSERT: return HipKey.INSERT;
            case KEY_DELETE: return HipKey.DELETE;
            case KEY_0: return HipKey._0;
            case KEY_1: return HipKey._1;
            case KEY_2: return HipKey._2;
            case KEY_3: return HipKey._3;
            case KEY_4: return HipKey._4;
            case KEY_5: return HipKey._5;
            case KEY_6: return HipKey._6;
            case KEY_7: return HipKey._7;
            case KEY_8: return HipKey._8;
            case KEY_9: return HipKey._9;
            case KEY_A: return HipKey.A;
            case KEY_B: return HipKey.B;
            case KEY_C: return HipKey.C;
            case KEY_D: return HipKey.D;
            case KEY_E: return HipKey.E;
            case KEY_F: return HipKey.F;
            case KEY_G: return HipKey.G;
            case KEY_H: return HipKey.H;
            case KEY_I: return HipKey.I;
            case KEY_J: return HipKey.J;
            case KEY_K: return HipKey.K;
            case KEY_L: return HipKey.L;
            case KEY_M: return HipKey.M;
            case KEY_N: return HipKey.N;
            case KEY_O: return HipKey.O;
            case KEY_P: return HipKey.P;
            case KEY_Q: return HipKey.Q;
            case KEY_R: return HipKey.R;
            case KEY_S: return HipKey.S;
            case KEY_T: return HipKey.T;
            case KEY_U: return HipKey.U;
            case KEY_V: return HipKey.V;
            case KEY_W: return HipKey.W;
            case KEY_X: return HipKey.X;
            case KEY_Y: return HipKey.Y;
            case KEY_Z: return HipKey.Z;
            case KEY_LEFTMETA: return HipKey.META_LEFT;
            case KEY_RIGHTMETA: return HipKey.META_RIGHT;
            case KEY_F1: return HipKey.F1;
            case KEY_F2: return HipKey.F2;
            case KEY_F3: return HipKey.F3;
            case KEY_F4: return HipKey.F4;
            case KEY_F5: return HipKey.F5;
            case KEY_F6: return HipKey.F6;
            case KEY_F7: return HipKey.F7;
            case KEY_F8: return HipKey.F8;
            case KEY_F9: return HipKey.F9;
            case KEY_F10: return HipKey.F10;
            case KEY_F11: return HipKey.F11;
            case KEY_F12: return HipKey.F12;
            case KEY_SEMICOLON: return HipKey.SEMICOLON;
            case KEY_EQUAL: return HipKey.EQUAL;
            case KEY_COMMA: return HipKey.COMMA;
            case KEY_MINUS: return HipKey.MINUS;
            case KEY_DOT: return HipKey.PERIOD;
            case KEY_SLASH: return HipKey.SLASH;
            case KEY_LEFTBRACE: return HipKey.BRACKET_LEFT;
            case KEY_BACKSLASH: return HipKey.BACKSLASH;
            case KEY_RIGHTBRACE: return HipKey.BRACKET_RIGHT;
            case KEY_APOSTROPHE: return HipKey.QUOTE;
            default:
            {
                version(HipCheckUnknownKeycode)
                {
                    import hip.util.conv:to;
                    assert(false, "Unknown key received ("~to!string(k)~")");
                }
                else
                    return cast(HipKey)k;
            }
        }
    }
**/