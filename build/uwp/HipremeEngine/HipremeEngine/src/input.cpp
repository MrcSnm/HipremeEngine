#include "pch.h"
#include "input.hpp"


using namespace winrt;
using namespace Windows;
using namespace Windows::Gaming::Input;


std::vector<Gamepad> gamepads;
std::deque<ubyte> emptySlots;

void HipGamepadSetXboxGamepadVibration(
    ubyte id,
    double leftMotor,
    double rightMotor,
    double leftTrigger,
    double rightTrigger
)
{
    Gamepad gp = gamepads[id];
    GamepadVibration vib;
    vib.LeftMotor = leftMotor;
    vib.RightMotor = rightMotor;
    vib.LeftTrigger = leftTrigger;
    vib.RightTrigger = rightTrigger;
    gp.Vibration(vib);
}

ubyte HipGamepadQueryConnectedGamepadsCount()
{
    return (ubyte)Gamepad::Gamepads().Size();
}

bool HipGamepadIsWireless(ubyte id) { return gamepads[id].IsWireless(); }
HipGamepadBatteryStatus HipGamepadGetBatteryStatus(ubyte id)
{
    HipGamepadBatteryStatus ret;
    Windows::Devices::Power::BatteryReport bat = gamepads[id].TryGetBatteryReport();

    Windows::Foundation::IReference<int32_t> temp = bat.ChargeRateInMilliwatts();
    if (temp != nullptr)
        ret.chargeRateInMilliwatts = temp.GetInt32();
    else
        ret.chargeRateInMilliwatts = -1;

    temp = bat.FullChargeCapacityInMilliwattHours();
    if (temp != nullptr)
        ret.fullChargeCapacityInMilliwattHours = temp.GetInt32();
    else
        ret.chargeRateInMilliwatts = -1;

    temp = bat.RemainingCapacityInMilliwattHours();
    if (temp != nullptr)
        ret.remainingCapacityInMilliwattHours = temp.GetInt32();
    else
        ret.remainingCapacityInMilliwattHours = -1;

    ret.state = (ubyte)bat.Status();
    
    return ret;
}


/// <summary>
/// Bounds aren't check inside that function. HipInput should manage it
/// </summary>
/// <param name="id"></param>
/// <returns></returns>
HipInputXboxGamepadState HipGamepadGetXboxGamepadState(uint8_t id)
{
    HipInputXboxGamepadState ret;
    Gamepad gp = gamepads[id];
    GamepadReading read = gp.GetCurrentReading();
    ret.buttons = (int)read.Buttons;
    ret.leftAnalogX = read.LeftThumbstickX;
    ret.leftAnalogY = read.LeftThumbstickY;
    ret.rightAnalogX = read.RightThumbstickX;
    ret.rightAnalogY = read.RightThumbstickY;
    ret.leftTrigger = read.LeftTrigger;
    ret.rightTrigger = read.RightTrigger;
    return ret;
}

void AddGamepad(Gamepad gamepad)
{
    if (emptySlots.size() > 0)
    {
        gamepads[emptySlots[0]] = gamepad;
        emptySlots.pop_front();
    }
    else
        gamepads.push_back(gamepad);
}

ubyte GetGamepadID(Gamepad gamepad)
{
    for (int i = 0; i < gamepads.size(); i++)
        if (gamepads[i] == gamepad)
            return (ubyte)i;
    return 255;
}

void RemoveGamepad(Gamepad gamepad)
{
    ubyte id = GetGamepadID(gamepad);
    if (id != 255)
        emptySlots.push_back(id);

}

void DestroyGamepads()
{
    gamepads.clear();
    emptySlots.clear();
}