module hip.config.input;


version(PSVita) 
{
    ///Converts default keyboard mappings to gamepad (hip.api.config.mapToGamepad)
    enum InputConvertKeyboardToGamepad = true;
    ///Converts analog to common keyboard directionals (hip.api.config.keyIsDirectinal)
    enum InputConvertAnalogToArrowsAndWASD = true;
}
else version(UWP)
{
    enum InputConvertKeyboardToGamepad = true;
    enum InputConvertAnalogToArrowsAndWASD = true;
}
else
{
    enum InputConvertKeyboardToGamepad = false;
    enum InputConvertAnalogToArrowsAndWASD = false;
}