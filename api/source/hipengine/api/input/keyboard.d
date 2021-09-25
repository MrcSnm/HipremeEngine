module hipengine.api.input.keyboard;


interface IHipKeyboard
{
    bool isKeyPressed(char key);
    bool isKeyJustPressed(char key);
    bool isKeyJustReleased(char key);
    float getKeyDownTime(char key);
    float getKeyUpTime(char key);
}