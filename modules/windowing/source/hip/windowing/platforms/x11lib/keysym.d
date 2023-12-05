module hip.windowing.platforms.x11lib.keysym;

version(Android){}
else version(linux) version = X11;
version(X11):
enum {

    /*
    * TTY function keys, cleverly chosen to map to ASCII, for convenience of
    * programming, but could have been arbitrary (at the cost of lookup
    * tables in client code).
    */

    XK_BackSpace                    = 0xff08,  /* Back space, back char */
    XK_Tab                          = 0xff09,
    XK_Linefeed                     = 0xff0a,  /* Linefeed, LF */
    XK_Clear                        = 0xff0b,
    XK_Return                       = 0xff0d,  /* Return, enter */
    XK_Pause                        = 0xff13,  /* Pause, hold */
    XK_Scroll_Lock                  = 0xff14,
    XK_Sys_Req                      = 0xff15,
    XK_Escape                       = 0xff1b,
    XK_Delete                       = 0xffff,  /* Delete, rubout */
    /* Cursor control & motion */

    XK_Home                        = 0xff50,
    XK_Left                        = 0xff51,  /* Move left, left arrow */
    XK_Up                          = 0xff52,  /* Move up, up arrow */
    XK_Right                       = 0xff53,  /* Move right, right arrow */
    XK_Down                        = 0xff54,  /* Move down, down arrow */
    XK_Prior                       = 0xff55,  /* Prior, previous */
    XK_Page_Up                     = 0xff55,
    XK_Next                        = 0xff56,  /* Next */
    XK_Page_Down                   = 0xff56,
    XK_End                         = 0xff57,  /* EOL */
    XK_Begin                       = 0xff58,  /* BOL */

    XK_space = 0x0020,  /* U+0020 SPACE */
    XK_exclam = 0x0021,  /* U+0021 EXCLAMATION MARK */
    XK_quotedbl = 0x0022,  /* U+0022 QUOTATION MARK */
    XK_numbersign = 0x0023,  /* U+0023 NUMBER SIGN */
    XK_dollar = 0x0024,  /* U+0024 DOLLAR SIGN */
    XK_percent = 0x0025,  /* U+0025 PERCENT SIGN */
    XK_ampersand = 0x0026,  /* U+0026 AMPERSAND */
    XK_apostrophe = 0x0027,  /* U+0027 APOSTROPHE */
    XK_quoteright = 0x0027,  /* deprecated */
    XK_parenleft = 0x0028,  /* U+0028 LEFT PARENTHESIS */
    XK_parenright = 0x0029,  /* U+0029 RIGHT PARENTHESIS */
    XK_asterisk = 0x002a,  /* U+002A ASTERISK */
    XK_plus = 0x002b,  /* U+002B PLUS SIGN */
    XK_comma = 0x002c,  /* U+002C COMMA */
    XK_minus = 0x002d,  /* U+002D HYPHEN-MINUS */
    XK_period = 0x002e,  /* U+002E FULL STOP */
    XK_slash = 0x002f,  /* U+002F SOLIDUS */
    XK_0 = 0x0030,  /* U+0030 DIGIT ZERO */
    XK_1 = 0x0031,  /* U+0031 DIGIT ONE */
    XK_2 = 0x0032,  /* U+0032 DIGIT TWO */
    XK_3 = 0x0033,  /* U+0033 DIGIT THREE */
    XK_4 = 0x0034,  /* U+0034 DIGIT FOUR */
    XK_5 = 0x0035,  /* U+0035 DIGIT FIVE */
    XK_6 = 0x0036,  /* U+0036 DIGIT SIX */
    XK_7 = 0x0037,  /* U+0037 DIGIT SEVEN */
    XK_8 = 0x0038,  /* U+0038 DIGIT EIGHT */
    XK_9 = 0x0039,  /* U+0039 DIGIT NINE */
    XK_colon = 0x003a,  /* U+003A COLON */
    XK_semicolon = 0x003b,  /* U+003B SEMICOLON */
    XK_less = 0x003c,  /* U+003C LESS-THAN SIGN */
    XK_equal = 0x003d,  /* U+003D EQUALS SIGN */
    XK_greater = 0x003e,  /* U+003E GREATER-THAN SIGN */
    XK_question = 0x003f,  /* U+003F QUESTION MARK */
    XK_at = 0x0040,  /* U+0040 COMMERCIAL AT */
    XK_A = 0x0041,  /* U+0041 LATIN CAPITAL LETTER A */
    XK_B = 0x0042,  /* U+0042 LATIN CAPITAL LETTER B */
    XK_C = 0x0043,  /* U+0043 LATIN CAPITAL LETTER C */
    XK_D = 0x0044,  /* U+0044 LATIN CAPITAL LETTER D */
    XK_E = 0x0045,  /* U+0045 LATIN CAPITAL LETTER E */
    XK_F = 0x0046,  /* U+0046 LATIN CAPITAL LETTER F */
    XK_G = 0x0047,  /* U+0047 LATIN CAPITAL LETTER G */
    XK_H = 0x0048,  /* U+0048 LATIN CAPITAL LETTER H */
    XK_I = 0x0049,  /* U+0049 LATIN CAPITAL LETTER I */
    XK_J = 0x004a,  /* U+004A LATIN CAPITAL LETTER J */
    XK_K = 0x004b,  /* U+004B LATIN CAPITAL LETTER K */
    XK_L = 0x004c,  /* U+004C LATIN CAPITAL LETTER L */
    XK_M = 0x004d,  /* U+004D LATIN CAPITAL LETTER M */
    XK_N = 0x004e,  /* U+004E LATIN CAPITAL LETTER N */
    XK_O = 0x004f,  /* U+004F LATIN CAPITAL LETTER O */
    XK_P = 0x0050,  /* U+0050 LATIN CAPITAL LETTER P */
    XK_Q = 0x0051,  /* U+0051 LATIN CAPITAL LETTER Q */
    XK_R = 0x0052,  /* U+0052 LATIN CAPITAL LETTER R */
    XK_S = 0x0053,  /* U+0053 LATIN CAPITAL LETTER S */
    XK_T = 0x0054,  /* U+0054 LATIN CAPITAL LETTER T */
    XK_U = 0x0055,  /* U+0055 LATIN CAPITAL LETTER U */
    XK_V = 0x0056,  /* U+0056 LATIN CAPITAL LETTER V */
    XK_W = 0x0057,  /* U+0057 LATIN CAPITAL LETTER W */
    XK_X = 0x0058,  /* U+0058 LATIN CAPITAL LETTER X */
    XK_Y = 0x0059,  /* U+0059 LATIN CAPITAL LETTER Y */
    XK_Z = 0x005a,  /* U+005A LATIN CAPITAL LETTER Z */
    XK_bracketleft = 0x005b,  /* U+005B LEFT SQUARE BRACKET */
    XK_backslash = 0x005c,  /* U+005C REVERSE SOLIDUS */
    XK_bracketright = 0x005d,  /* U+005D RIGHT SQUARE BRACKET */
    XK_asciicircum = 0x005e,  /* U+005E CIRCUMFLEX ACCENT */
    XK_underscore = 0x005f,  /* U+005F LOW LINE */
    XK_grave = 0x0060,  /* U+0060 GRAVE ACCENT */
    XK_quoteleft = 0x0060,  /* deprecated */
    XK_a = 0x0061,  /* U+0061 LATIN SMALL LETTER A */
    XK_b = 0x0062,  /* U+0062 LATIN SMALL LETTER B */
    XK_c = 0x0063,  /* U+0063 LATIN SMALL LETTER C */
    XK_d = 0x0064,  /* U+0064 LATIN SMALL LETTER D */
    XK_e = 0x0065,  /* U+0065 LATIN SMALL LETTER E */
    XK_f = 0x0066,  /* U+0066 LATIN SMALL LETTER F */
    XK_g = 0x0067,  /* U+0067 LATIN SMALL LETTER G */
    XK_h = 0x0068,  /* U+0068 LATIN SMALL LETTER H */
    XK_i = 0x0069,  /* U+0069 LATIN SMALL LETTER I */
    XK_j = 0x006a,  /* U+006A LATIN SMALL LETTER J */
    XK_k = 0x006b,  /* U+006B LATIN SMALL LETTER K */
    XK_l = 0x006c,  /* U+006C LATIN SMALL LETTER L */
    XK_m = 0x006d,  /* U+006D LATIN SMALL LETTER M */
    XK_n = 0x006e,  /* U+006E LATIN SMALL LETTER N */
    XK_o = 0x006f,  /* U+006F LATIN SMALL LETTER O */
    XK_p = 0x0070,  /* U+0070 LATIN SMALL LETTER P */
    XK_q = 0x0071,  /* U+0071 LATIN SMALL LETTER Q */
    XK_r = 0x0072,  /* U+0072 LATIN SMALL LETTER R */
    XK_s = 0x0073,  /* U+0073 LATIN SMALL LETTER S */
    XK_t = 0x0074,  /* U+0074 LATIN SMALL LETTER T */
    XK_u = 0x0075,  /* U+0075 LATIN SMALL LETTER U */
    XK_v = 0x0076,  /* U+0076 LATIN SMALL LETTER V */
    XK_w = 0x0077,  /* U+0077 LATIN SMALL LETTER W */
    XK_x = 0x0078,  /* U+0078 LATIN SMALL LETTER X */
    XK_y = 0x0079,  /* U+0079 LATIN SMALL LETTER Y */
    XK_z = 0x007a,  /* U+007A LATIN SMALL LETTER Z */
    XK_braceleft = 0x007b,  /* U+007B LEFT CURLY BRACKET */
    XK_bar = 0x007c,  /* U+007C VERTICAL LINE */
    XK_braceright = 0x007d,  /* U+007D RIGHT CURLY BRACKET */
    XK_asciitilde = 0x007e,  /* U+007E TILDE */

    XK_F1 = 0xffbe,
    XK_F2 = 0xffbf,
    XK_F3 = 0xffc0,
    XK_F4 = 0xffc1,
    XK_F5 = 0xffc2,
    XK_F6 = 0xffc3,
    XK_F7 = 0xffc4,
    XK_F8 = 0xffc5,
    XK_F9 = 0xffc6,
    XK_F10 = 0xffc7,
    XK_F11 = 0xffc8,
    XK_F12 = 0xffc9,

    /* Modifiers */

    XK_Shift_L = 0xffe1,  /* Left shift */
    XK_Shift_R = 0xffe2,  /* Right shift */
    XK_Control_L = 0xffe3,  /* Left control */
    XK_Control_R = 0xffe4,  /* Right control */
    XK_Caps_Lock = 0xffe5,  /* Caps lock */
    XK_Shift_Lock = 0xffe6,  /* Shift lock */
    XK_Meta_L = 0xffe7,  /* Left meta */
    XK_Meta_R = 0xffe8,  /* Right meta */
    XK_Alt_L = 0xffe9,  /* Left alt */
    XK_Alt_R = 0xffea,  /* Right alt */

    XK_Select                        = 0xff60,  /* Select, mark */
    XK_Print                         = 0xff61,
    XK_Execute                       = 0xff62,  /* Execute, run, do */
    XK_Insert                        = 0xff63,  /* Insert, insert here */
    XK_Undo                          = 0xff65,
    XK_Redo                          = 0xff66,  /* Redo, again */
    XK_Menu                          = 0xff67,
    XK_Find                          = 0xff68,  /* Find, search */
    XK_Cancel                        = 0xff69,  /* Cancel, stop, abort, exit */
    XK_Help                          = 0xff6a,  /* Help */
    XK_Break                         = 0xff6b,
    XK_Mode_switch                   = 0xff7e,  /* Character set switch */
    XK_script_switch                 = 0xff7e,  /* Alias for mode_switch */
    XK_Num_Lock                      = 0xff7f,

    XK_KP_Space                      = 0xff80,  /* Space */
    XK_KP_Tab                        = 0xff89,
    XK_KP_Enter                      = 0xff8d,  /* Enter */
    XK_KP_F1                         = 0xff91,  /* PF1, KP_A, ... */
    XK_KP_F2                         = 0xff92,
    XK_KP_F3                         = 0xff93,
    XK_KP_F4                         = 0xff94,
    XK_KP_Home                       = 0xff95,
    XK_KP_Left                       = 0xff96,
    XK_KP_Up                         = 0xff97,
    XK_KP_Right                      = 0xff98,
    XK_KP_Down                       = 0xff99,
    XK_KP_Prior                      = 0xff9a,
    XK_KP_Page_Up                    = 0xff9a,
    XK_KP_Next                       = 0xff9b,
    XK_KP_Page_Down                  = 0xff9b,
    XK_KP_End                        = 0xff9c,
    XK_KP_Begin                      = 0xff9d,
    XK_KP_Insert                     = 0xff9e,
    XK_KP_Delete                     = 0xff9f,
    XK_KP_Equal                      = 0xffbd,  /* Equals */
    XK_KP_Multiply                   = 0xffaa,
    XK_KP_Add                        = 0xffab,
    XK_KP_Separator                  = 0xffac,  /* Separator, often comma */
    XK_KP_Subtract                   = 0xffad,
    XK_KP_Decimal                    = 0xffae,
    XK_KP_Divide                     = 0xffaf,

    XK_KP_0                          = 0xffb0,
    XK_KP_1                          = 0xffb1,
    XK_KP_2                          = 0xffb2,
    XK_KP_3                          = 0xffb3,
    XK_KP_4                          = 0xffb4,
    XK_KP_5                          = 0xffb5,
    XK_KP_6                          = 0xffb6,
    XK_KP_7                          = 0xffb7,
    XK_KP_8                          = 0xffb8,
    XK_KP_9                          = 0xffb9,
}