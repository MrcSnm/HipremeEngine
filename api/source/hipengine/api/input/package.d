module hipengine.api.input;
// public import hipengine.api.math.vector;
// public import hipengine.api.input.mouse;

// version(HipremeEngineDef)
// {

// }
// else
// {

//     extern(C) bool function(char key, uint id = 0) isKeyPressed;
//     extern(C) bool function(char key, uint id = 0) isKeyJustPressed;
//     extern(C) bool function(char key, uint id = 0) isKeyJustReleased;
//     extern(C) float function(char key, uint id = 0) getKeyDownTime;
//     extern(C) float function(char key, uint id = 0) getKeyUpTime;
//     extern(C) bool function(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) isMouseButtonPressed;
//     extern(C) bool function(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) isMouseButtonJustPressed;
//     extern(C) bool function(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) isMouseButtonJustReleased;
//     extern(C) Vector2 function(uint id=0) getTouchPosition;
//     extern(C) Vector2 function(uint id=0) getTouchDeltaPosition;
//     extern(C) Vector3 function(uint id=0) getScroll;
//     void initInput()
//     {
//         import hipengine.internal;
//         loadSymbol!isKeyPressed;
//         loadSymbol!isKeyJustPressed;
//         loadSymbol!isKeyJustReleased;
//         loadSymbol!getKeyDownTime;
//         loadSymbol!getKeyUpTime;
//         loadSymbol!isMouseButtonPressed;
//         loadSymbol!isMouseButtonJustPressed;
//         loadSymbol!isMouseButtonJustReleased;
//         loadSymbol!getTouchPosition;
//         loadSymbol!getTouchDeltaPosition;
//         loadSymbol!getScroll;
//     }
// }