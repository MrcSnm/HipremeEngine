module directx.xinput;
/***************************************************************************
 *                                                                          *
 *   XInput.h -- This module defines XBOX controller APIs                   *
 *               and constansts for the Windows platform.                   *
 *                                                                          *
 *   Copyright (c) Microsoft Corp. All rights reserved.                     *
 *                                                                          *
 ***************************************************************************/

version(Windows):

import directx.win32;

// note: 9.1.0 is reduced multi-platform(winxp-win8, +xbox?) subset of XInput
//      that only provides most basic stuff. For advanced functionality 
//      use 1.3 or 1.4.
//      9.1.0 has its own enum values.
version = XINPUT_USE_1_3;

// Current name of the DLL shipped in the same SDK as this header.
// The name reflects the current version
version(XINPUT_USE_9_1_0)
{
	enum XINPUT_DLL_A = "xinput9_1_0.dll";
	enum XINPUT_DLL_W = "xinput9_1_0.dll"w;
}
else
{
	enum XINPUT_DLL_A = "xinput1_3.dll";
	enum XINPUT_DLL_W = "xinput1_3.dll"w;
}

alias XINPUT_DLL_W XINPUT_DLL;

//
// Device types available in XINPUT_CAPABILITIES
//
enum XINPUT_DEVTYPE_GAMEPAD         = 0x01;

//
// Device subtypes available in XINPUT_CAPABILITIES
//
enum XINPUT_DEVSUBTYPE_GAMEPAD        = 0x01;


version(XINPUT_USE_9_1_0) 
{
}
else
{
	enum XINPUT_DEVSUBTYPE_WHEEL          = 0x02;
	enum XINPUT_DEVSUBTYPE_ARCADE_STICK   = 0x03;
	enum XINPUT_DEVSUBTYPE_FLIGHT_SICK    = 0x04;
	enum XINPUT_DEVSUBTYPE_DANCE_PAD      = 0x05;
	enum XINPUT_DEVSUBTYPE_GUITAR         = 0x06;
	enum XINPUT_DEVSUBTYPE_DRUM_KIT       = 0x08;
}



//
// Flags for XINPUT_CAPABILITIES
//
enum XINPUT_CAPS_VOICE_SUPPORTED      = 0x0004;

//
// Constants for gamepad buttons
//
enum XINPUT_GAMEPAD_DPAD_UP           = 0x0001;
enum XINPUT_GAMEPAD_DPAD_DOWN         = 0x0002;
enum XINPUT_GAMEPAD_DPAD_LEFT         = 0x0004;
enum XINPUT_GAMEPAD_DPAD_RIGHT        = 0x0008;
enum XINPUT_GAMEPAD_START             = 0x0010;
enum XINPUT_GAMEPAD_BACK              = 0x0020;
enum XINPUT_GAMEPAD_LEFT_THUMB        = 0x0040;
enum XINPUT_GAMEPAD_RIGHT_THUMB       = 0x0080;
enum XINPUT_GAMEPAD_LEFT_SHOULDER     = 0x0100;
enum XINPUT_GAMEPAD_RIGHT_SHOULDER    = 0x0200;
enum XINPUT_GAMEPAD_A                 = 0x1000;
enum XINPUT_GAMEPAD_B                 = 0x2000;
enum XINPUT_GAMEPAD_X                 = 0x4000;
enum XINPUT_GAMEPAD_Y                 = 0x8000;


//
// Gamepad thresholds
//
enum XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE   = 7849;
enum XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE  = 8689;
enum XINPUT_GAMEPAD_TRIGGER_THRESHOLD     = 30;

//
// Flags to pass to XInputGetCapabilities
//
enum XINPUT_FLAG_GAMEPAD              = 0x00000001;


version(XINPUT_USE_9_1_0)
{
}
else
{
//
// Devices that support batteries
//
enum BATTERY_DEVTYPE_GAMEPAD          = 0x00;
enum BATTERY_DEVTYPE_HEADSET          = 0x01;

//
// Flags for battery status level
//
enum BATTERY_TYPE_DISCONNECTED        = 0x00;    // This device is not connected
enum BATTERY_TYPE_WIRED               = 0x01;    // Wired device, no battery
enum BATTERY_TYPE_ALKALINE            = 0x02;    // Alkaline battery source
enum BATTERY_TYPE_NIMH                = 0x03;    // Nickel Metal Hydride battery source
enum BATTERY_TYPE_UNKNOWN             = 0xFF;    // Cannot determine the battery type

// These are only valid for wireless, connected devices, with known battery types
// The amount of use time remaining depends on the type of device.
enum BATTERY_LEVEL_EMPTY              = 0x00;
enum BATTERY_LEVEL_LOW                = 0x01;
enum BATTERY_LEVEL_MEDIUM             = 0x02;
enum BATTERY_LEVEL_FULL               = 0x03;

// User index definitions
enum XUSER_MAX_COUNT                  = 4;

enum XUSER_INDEX_ANY                  = 0x000000FF;


//
// Codes returned for the gamepad keystroke
//

enum VK_PAD_A                         = 0x5800;
enum VK_PAD_B                         = 0x5801;
enum VK_PAD_X                         = 0x5802;
enum VK_PAD_Y                         = 0x5803;
enum VK_PAD_RSHOULDER                 = 0x5804;
enum VK_PAD_LSHOULDER                 = 0x5805;
enum VK_PAD_LTRIGGER                  = 0x5806;
enum VK_PAD_RTRIGGER                  = 0x5807;

enum VK_PAD_DPAD_UP                   = 0x5810;
enum VK_PAD_DPAD_DOWN                 = 0x5811;
enum VK_PAD_DPAD_LEFT                 = 0x5812;
enum VK_PAD_DPAD_RIGHT                = 0x5813;
enum VK_PAD_START                     = 0x5814;
enum VK_PAD_BACK                      = 0x5815;
enum VK_PAD_LTHUMB_PRESS              = 0x5816;
enum VK_PAD_RTHUMB_PRESS              = 0x5817;

enum VK_PAD_LTHUMB_UP                 = 0x5820;
enum VK_PAD_LTHUMB_DOWN               = 0x5821;
enum VK_PAD_LTHUMB_RIGHT              = 0x5822;
enum VK_PAD_LTHUMB_LEFT               = 0x5823;
enum VK_PAD_LTHUMB_UPLEFT             = 0x5824;
enum VK_PAD_LTHUMB_UPRIGHT            = 0x5825;
enum VK_PAD_LTHUMB_DOWNRIGHT          = 0x5826;
enum VK_PAD_LTHUMB_DOWNLEFT           = 0x5827;

enum VK_PAD_RTHUMB_UP                 = 0x5830;
enum VK_PAD_RTHUMB_DOWN               = 0x5831;
enum VK_PAD_RTHUMB_RIGHT              = 0x5832;
enum VK_PAD_RTHUMB_LEFT               = 0x5833;
enum VK_PAD_RTHUMB_UPLEFT             = 0x5834;
enum VK_PAD_RTHUMB_UPRIGHT            = 0x5835;
enum VK_PAD_RTHUMB_DOWNRIGHT          = 0x5836;
enum VK_PAD_RTHUMB_DOWNLEFT           = 0x5837;

//
// Flags used in XINPUT_KEYSTROKE
//
enum XINPUT_KEYSTROKE_KEYDOWN         = 0x0001;
enum XINPUT_KEYSTROKE_KEYUP           = 0x0002;
enum XINPUT_KEYSTROKE_REPEAT          = 0x0004;

}

//
// Structures used by XInput APIs
//
struct _XINPUT_GAMEPAD
{
    WORD                                wButtons;
    BYTE                                bLeftTrigger;
    BYTE                                bRightTrigger;
    SHORT                               sThumbLX;
    SHORT                               sThumbLY;
    SHORT                               sThumbRX;
    SHORT                               sThumbRY;
} 
alias _XINPUT_GAMEPAD XINPUT_GAMEPAD;
alias _XINPUT_GAMEPAD* PXINPUT_GAMEPAD;

struct _XINPUT_STATE
{
    DWORD                               dwPacketNumber;
    XINPUT_GAMEPAD                      Gamepad;
} 
alias _XINPUT_STATE XINPUT_STATE;
alias _XINPUT_STATE* PXINPUT_STATE;

struct _XINPUT_VIBRATION
{
    WORD                                wLeftMotorSpeed;
    WORD                                wRightMotorSpeed;
}
alias _XINPUT_VIBRATION XINPUT_VIBRATION;
alias _XINPUT_VIBRATION* PXINPUT_VIBRATION;

struct _XINPUT_CAPABILITIES
{
    BYTE                                Type;
    BYTE                                SubType;
    WORD                                Flags;
    XINPUT_GAMEPAD                      Gamepad;
    XINPUT_VIBRATION                    Vibration;
} 
alias _XINPUT_CAPABILITIES XINPUT_CAPABILITIES;
alias _XINPUT_CAPABILITIES* PXINPUT_CAPABILITIES;

version(XINPUT_USE_9_1_0)
{
}
else
{
struct _XINPUT_BATTERY_INFORMATION
{
    BYTE BatteryType;
    BYTE BatteryLevel;
}
alias _XINPUT_BATTERY_INFORMATION XINPUT_BATTERY_INFORMATION;
alias _XINPUT_BATTERY_INFORMATION* PXINPUT_BATTERY_INFORMATION;

struct _XINPUT_KEYSTROKE
{
    WORD    VirtualKey;
    WCHAR   Unicode;
    WORD    Flags;
    BYTE    UserIndex;
    BYTE    HidCode;
}
alias _XINPUT_KEYSTROKE XINPUT_KEYSTROKE;
alias _XINPUT_KEYSTROKE* PXINPUT_KEYSTROKE;

}

//
// XInput APIs
//
extern (Windows) 
{

DWORD XInputGetState
(
    in  DWORD         dwUserIndex,  // Index of the gamer associated with the device
    /*out*/ XINPUT_STATE* pState        // Receives the current state
);

DWORD XInputSetState
(
    in DWORD             dwUserIndex,  // Index of the gamer associated with the device
    in XINPUT_VIBRATION* pVibration    // The vibration information to send to the controller
);

DWORD XInputGetCapabilities
(
    in  DWORD                dwUserIndex,   // Index of the gamer associated with the device
    in  DWORD                dwFlags,       // Input flags that identify the device type
    /*out*/ XINPUT_CAPABILITIES* pCapabilities  // Receives the capabilities
);

void XInputEnable
(
    in BOOL enable     // [in] Indicates whether xinput is enabled or disabled. 
);

DWORD XInputGetDSoundAudioDeviceGuids
(
    in  DWORD dwUserIndex,          // Index of the gamer associated with the device
    /*out*/ GUID* pDSoundRenderGuid,    // DSound device ID for render
    /*out*/ GUID* pDSoundCaptureGuid    // DSound device ID for capture
);

version(XINPUT_USE_9_1_0)
{
}
else
{

DWORD XInputGetBatteryInformation
(
    in  DWORD                       dwUserIndex,        // Index of the gamer associated with the device
    in  BYTE                        devType,            // Which device on this user index
    /*out*/ XINPUT_BATTERY_INFORMATION* pBatteryInformation // Contains the level and types of batteries
);

DWORD XInputGetKeystroke
(
    in       DWORD dwUserIndex,              // Index of the gamer associated with the device
             DWORD dwReserved,               // Reserved for future use
    /*out*/  PXINPUT_KEYSTROKE pKeystroke    // Pointer to an XINPUT_KEYSTROKE structure that receives an input event.
);

}

}

