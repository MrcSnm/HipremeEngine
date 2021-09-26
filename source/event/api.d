module event.api;
public import global.gamedef;

private enum Define(string code)
{
    version(Standalone)
        return "pragma(inline) "~code;
    else
        return "export extern(C) "~code;
}
import hipengine.api.math.vector;
import hipengine.api.input.mouse;
import event.dispatcher;
import systems.game;

mixin(Define(q{bool isKeyPressed(char key, uint id = 0) 
{
    return sys.dispatcher.isKeyPressed(key, id);
}}));
mixin(Define(q{bool isKeyJustPressed(char key, uint id = 0) 
{
    return sys.dispatcher.isKeyJustPressed(key, id);
}}));
mixin(Define(q{bool isKeyJustReleased(char key, uint id = 0) 
{
    return sys.dispatcher.isKeyJustReleased(key, id);
}}));
mixin(Define(q{float getKeyDownTime(char key, uint id = 0) 
{
    return sys.dispatcher.getKeyDownTime(key, id);
}}));
mixin(Define(q{float getKeyUpTime(char key, uint id = 0) 
{
    return sys.dispatcher.getKeyUpTime(key, id);
}}));
mixin(Define(q{bool isMouseButtonPressed(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) 
{
    return sys.dispatcher.isMouseButtonPressed(btn, id);
}}));
mixin(Define(q{bool isMouseButtonJustPressed(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) 
{
    return sys.dispatcher.isMouseButtonJustPressed(btn, id);
}}));
mixin(Define(q{bool isMouseButtonJustReleased(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) 
{
    return sys.dispatcher.isMouseButtonJustReleased(btn, id);
}}));
mixin(Define(q{immutable(Vector2*) getTouchPosition(uint id=0) 
{
    return sys.dispatcher.getTouchPosition(id);
}}));
mixin(Define(q{Vector2 getTouchDeltaPosition(uint id=0) 
{
    return sys.dispatcher.getTouchDeltaPosition(id);
}}));
mixin(Define(q{Vector3 getScroll() 
{
    return sys.dispatcher.getScroll();
}}));

mixin(Define(q{ubyte getGamepadCount()
{
    return sys.dispatcher.getGamepadCount();
}}));