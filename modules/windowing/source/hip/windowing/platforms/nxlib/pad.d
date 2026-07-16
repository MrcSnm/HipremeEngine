module hip.windowing.platforms.nxlib.pad;
public import hip.windowing.platforms.nxlib.types;
public import hip.windowing.platforms.nxlib.hid;
/**
 * @file pad.h
 * @brief Simple wrapper for the HID Npad API.
 * @author fincs
 * @copyright libnx Authors
 */

/// Mask including all existing controller IDs.
enum PAD_ANY_ID_MASK = 0x1000100FFUL;

extern(System) nothrow @nogc:

/// Pad state object.
struct PadState{
    u8 id_mask;
    u8 active_id_mask;
    bool read_handheld;
    bool active_handheld;
    u32 style_set;
    u32 attributes;
    u64 buttons_cur;
    u64 buttons_old;
    HidAnalogStickState[2] sticks;
    u32[2] gc_triggers;
}

/// Pad button repeater state object.
struct PadRepeater {
    u64 button_mask;
    s32 counter;
    u16 delay;
    u16 repeat;
}

/**
 * @brief Configures the input layout supported by the application.
 * @param[in] max_players The maximum supported number of players (1 to 8).
 * @param[in] style_set Bitfield of supported controller styles (see \ref HidNpadStyleTag).
 */
void padConfigureInput(u32 max_players, u32 style_set);

/**
 * @brief Initializes a \ref PadState object to read input from one or more controller input sources.
 * @param[in] _pad Pointer to \ref PadState.
 * @remarks This is a variadic macro, pass the \ref HidNpadIdType value of each controller to add to the set.
 */

void padInitialize(PadState* _pad, const scope HidNpadIdType[] _pad_ids...)
{
    u64 _pad_mask = 0;
    for (ubyte _pad_i = 0; _pad_i < _pad_ids.length; ++_pad_i)
        _pad_mask |= 1UL << _pad_ids[_pad_i];
    padInitializeWithMask(_pad, _pad_mask);
}

/**
 * @brief Same as \ref padInitialize, but taking a bitfield of controller IDs directly.
 * @param[in] pad Pointer to \ref PadState.
 * @param[in] mask Bitfield of controller IDs (each bit's position indicates a different \ref HidNpadIdType value).
 */
void padInitializeWithMask(PadState* pad, u64 mask);

/**
 * @brief Same as \ref padInitialize, but including every single controller input source.
 * @param[in] pad Pointer to \ref PadState.
 * @remark Use this function if you want to accept input from any controller.
 */
pragma(inline, true) void padInitializeAny(PadState* pad) {
    padInitializeWithMask(pad, PAD_ANY_ID_MASK);
}

/**
 * @brief Same as \ref padInitialize, but including \ref HidNpadIdType.No1 and \ref HidNpadIdType.Handheld.
 * @param[in] pad Pointer to \ref PadState.
 * @remark Use this function if you just want to accept input for a single-player application.
 */
pragma(inline, true) void padInitializeDefault(PadState* pad) {
    padInitialize(pad, HidNpadIdType.No1, HidNpadIdType.Handheld);
}

/**
 * @brief Updates pad state by reading from the controller input sources specified during initialization.
 * @param[in] pad Pointer to \ref PadState.
 */
void padUpdate(PadState* pad);

/**
 * @brief Retrieves whether \ref HidNpadIdType.Handheld is an active input source (i.e. it was possible to read from it).
 * @param[in] pad Pointer to \ref PadState.
 * @return Boolean value.
 * @remark \ref padUpdate must have been previously called.
 */
bool padIsHandheld(const PadState* pad) {
    return pad.active_handheld;
}

/**
 * @brief Retrieves whether the specified controller is an active input source (i.e. it was possible to read from it).
 * @param[in] pad Pointer to \ref PadState.
 * @param[in] id ID of the controller input source (see \ref HidNpadIdType)
 * @return Boolean value.
 * @remark \ref padUpdate must have been previously called.
 */
bool padIsNpadActive(const PadState* pad, HidNpadIdType id) {
    if (id <= HidNpadIdType.No8)
        return (pad.active_id_mask & BIT(id)) != 0;
    else if (id == HidNpadIdType.Handheld)
        return pad.active_handheld;
    else
        return false;
}

/**
 * @brief Retrieves the set of input styles supported by the selected controller input sources.
 * @param[in] pad Pointer to \ref PadState.
 * @return Bitfield of \ref HidNpadStyleTag.
 * @remark \ref padUpdate must have been previously called.
 */
u32 padGetStyleSet(const PadState* pad) {
    return pad.style_set;
}

/**
 * @brief Retrieves the set of attributes reported by the system for the selected controller input sources.
 * @param[in] pad Pointer to \ref PadState.
 * @return Bitfield of \ref HidNpadAttribute.
 * @remark \ref padUpdate must have been previously called.
 */
u32 padGetAttributes(const PadState* pad) {
    return pad.attributes;
}

/**
 * @brief Retrieves whether any of the selected controller input sources is connected.
 * @param[in] pad Pointer to \ref PadState.
 * @return Boolean value.
 * @remark \ref padUpdate must have been previously called.
 */
bool padIsConnected(const PadState* pad) {
    return pad.attributes & HidNpadAttribute.IsConnected;
}

/**
 * @brief Retrieves the current set of pressed buttons across all selected controller input sources.
 * @param[in] pad Pointer to \ref PadState.
 * @return Bitfield of \ref HidNpadButton.
 * @remark \ref padUpdate must have been previously called.
 */
u64 padGetButtons(const PadState* pad) {
    return pad.buttons_cur;
}

/**
 * @brief Retrieves the set of buttons that are newly pressed.
 * @param[in] pad Pointer to \ref PadState.
 * @return Bitfield of \ref HidNpadButton.
 * @remark \ref padUpdate must have been previously called.
 */
u64 padGetButtonsDown(const PadState* pad) {
    return ~pad.buttons_old & pad.buttons_cur;
}

/**
 * @brief Retrieves the set of buttons that are newly released.
 * @param[in] pad Pointer to \ref PadState.
 * @return Bitfield of \ref HidNpadButton.
 * @remark \ref padUpdate must have been previously called.
 */
u64 padGetButtonsUp(const PadState* pad) {
    return pad.buttons_old & ~pad.buttons_cur;
}

/**
 * @brief Retrieves the position of an analog stick in a controller.
 * @param[in] pad Pointer to \ref PadState.
 * @param[in] i ID of the analog stick to read (0=left, 1=right).
 * @return \ref HidAnalogStickState.
 * @remark \ref padUpdate must have been previously called.
 */
HidAnalogStickState padGetStickPos(const PadState* pad, uint i) {
    return pad.sticks[i];
}

/**
 * @brief Retrieves the position of an analog trigger in a GameCube controller.
 * @param[in] pad Pointer to \ref PadState.
 * @param[in] i ID of the analog trigger to read (0=left, 1=right).
 * @return Analog trigger position (range is 0 to 0x7fff).
 * @remark \ref padUpdate must have been previously called.
 * @remark \ref HidNpadStyleTag_NpadGc must have been previously configured as a supported style in \ref padConfigureInput for GC trigger data to be readable.
 */
u32 padGetGcTriggerPos(const PadState* pad, uint i) {
    return pad.gc_triggers[i];
}

/**
 * @brief Initializes a \ref PadRepeater object with the specified settings.
 * @param[in] r Pointer to \ref PadRepeater.
 * @param[in] delay Number of input updates between button presses being first detected and them being considered for repeat.
 * @param[in] repeat Number of input updates between autogenerated repeat button presses.
 */
void padRepeaterInitialize(PadRepeater* r, u16 delay, u16 repeat) {
    r.button_mask = 0;
    r.counter = 0;
    r.delay = delay;
    r.repeat = repeat;
}

/**
 * @brief Updates pad repeat state.
 * @param[in] r Pointer to \ref PadRepeater.
 * @param[in] button_mask Bitfield of currently pressed \ref HidNpadButton that will be considered for repeat.
 */
void padRepeaterUpdate(PadRepeater* r, u64 button_mask);

/**
 * @brief Retrieves the set of buttons that are being repeated according to the parameters specified in \ref padRepeaterInitialize.
 * @param[in] r Pointer to \ref PadRepeater.
 * @return Bitfield of \ref HidNpadButton.
 * @remark It is suggested to bitwise-OR the return value of this function with that of \ref padGetButtonsDown.
 */
u64 padRepeaterGetButtons(const PadRepeater* r) {
    return r.counter == 0 ? r.button_mask : 0;
}
