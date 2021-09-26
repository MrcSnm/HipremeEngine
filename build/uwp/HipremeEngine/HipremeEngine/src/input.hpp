#pragma once
#include "Def.h"

using namespace winrt;
using namespace Windows;
using namespace Windows::Gaming::Input;

struct HipInputXboxGamepadState
{
    int buttons;
    double leftAnalogX;
    double leftAnalogY;
    double rightAnalogX;
    double rightAnalogY;
    double leftTrigger;
    double rightTrigger;
};

///Based on https://docs.microsoft.com/en-us/uwp/api/windows.system.power.batterystatus?view=winrt-20348
enum HipInputGamepadBatteryState
{
    notPresent = 0,
    discharging,
    idle,
    charging
};

///Struct based on winrt::Windows::Devices::Power::BatteryReport
struct HipGamepadBatteryStatus
{
    int chargeRateInMilliwatts;
    int remainingCapacityInMilliwattHours;
    int fullChargeCapacityInMilliwattHours;
    ubyte state;
};


d_import HipInputXboxGamepadState HipGamepadGetXboxGamepadState(uint8_t id);
d_import bool HipGamepadIsWireless(ubyte id);
d_import HipGamepadBatteryStatus HipGamepadGetBatteryStatus(ubyte id);
d_import ubyte HipGamepadQueryConnectedGamepadsCount();
d_import void HipGamepadSetXboxGamepadVibration(
    ubyte id,
    double leftMotor,
    double rightMotor,
    double leftTrigger,
    double rightTrigger
);


/// <summary>
/// Adds a gamepad to the internal managed list. If there is an empty slot in the list,
/// that slot will be populated with the gamepad
/// </summary>
/// <param name="gamepad"></param>
void AddGamepad(Gamepad gamepad);

/// <summary>
/// Returns 255 if no gamepad is found
/// </summary>
/// <param name="gamepad"></param>
/// <returns></returns>
ubyte GetGamepadID(Gamepad gamepad);

/// <summary>
/// Remove gamepad from the internal managed list. It won't change the list order.
/// It will set it to null and reassign to that slot on the next gamepad added.
/// </summary>
/// <param name="gamepad"></param>
void RemoveGamepad(Gamepad gamepad);
void DestroyGamepads();
