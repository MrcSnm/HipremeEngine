#include "pch.h"
#include "input.hpp"


using namespace winrt;
using namespace Windows;
using namespace Windows::Gaming::Input;


ubyte _gamepadCount = 0;
Gamepad** gamepads = nullptr;

void HipInputGamepadSetXboxGamepadVibration(
    ubyte id,
    double leftMotor,
    double rightMotor,
    double leftTrigger,
    double rightTrigger
)
{
    Gamepad gp = *gamepads[id];
    GamepadVibration vib;
    vib.LeftMotor = leftMotor;
    vib.RightMotor = rightMotor;
    vib.LeftTrigger = leftTrigger;
    vib.RightTrigger = rightTrigger;
    gp.Vibration(vib);
}

ubyte HipInputGamepadQueryConnectedGamepadsCount()
{
    return (ubyte)Gamepad::Gamepads().Size();
}

bool HipInputGamepadIsWireless(ubyte id) { return gamepads[id]->IsWireless(); }
HipInputGamepadBatteryStatus HipInputGamepadGetBatteryStatus(ubyte id)
{
    HipInputGamepadBatteryStatus ret;
    Windows::Devices::Power::BatteryReport bat = gamepads[id]->TryGetBatteryReport();

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
HipInputXboxGamepadState HipInputGetXboxGamepadState(uint8_t id)
{
    HipInputXboxGamepadState ret;
    Gamepad gp = *gamepads[id];
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

void AddGamepad(Gamepad* gamepad)
{
    if (gamepads == nullptr)
    {
        gamepads = (Gamepad**)malloc(++_gamepadCount * sizeof(Gamepad**));
        gamepads[0] = gamepad;
    }
    for (int i = 0; i < _gamepadCount; i++)
    {
        if (gamepads[i] == nullptr)
        {
            gamepads[i] = gamepad;
            return;
        }
    }
    gamepads = (Gamepad**)realloc(gamepads, ++_gamepadCount * sizeof(Gamepad**));
}

ubyte GetGamepadID(Gamepad* gamepad)
{
    for (int i = 0; i < _gamepadCount; i++)
        if (gamepads[i] == gamepad)
            return (ubyte)i;
    return 255;
}

void RemoveGamepad(Gamepad* gamepad)
{
    for (int i = 0; i < _gamepadCount; i++)
    {
        if (gamepads[i] == gamepad)
        {
            gamepads[i] = nullptr;
            return;
        }
    }
}

void DestroyGamepads()
{
    if(gamepads != nullptr)
        free(gamepads);
}