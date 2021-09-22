module event.api;


mixin template ExportInputAPI(alias game) //GameSystem
{
    import hipengine.api.math.vector;
    import hipengine.api.input.mouse;
    import event.dispatcher;
    import systems.game;

    export extern(C) bool isKeyPressed(char key, uint id = 0) 
    {
        return game.dispatcher.isKeyPressed(key, id);
    }
    export extern(C) bool isKeyJustPressed(char key, uint id = 0) 
    {
        return game.dispatcher.isKeyJustPressed(key, id);
    }
    export extern(C) bool isKeyJustReleased(char key, uint id = 0) 
    {
        return game.dispatcher.isKeyJustReleased(key, id);
    }
    export extern(C) float getKeyDownTime(char key, uint id = 0) 
    {
        return game.dispatcher.getKeyDownTime(key, id);
    }
    export extern(C) float getKeyUpTime(char key, uint id = 0) 
    {
        return game.dispatcher.getKeyUpTime(key, id);
    }
    export extern(C) bool isMouseButtonPressed(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) 
    {
        return game.dispatcher.isMouseButtonPressed(btn, id);
    }
    export extern(C) bool isMouseButtonJustPressed(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) 
    {
        return game.dispatcher.isMouseButtonJustPressed(btn, id);
    }
    export extern(C) bool isMouseButtonJustReleased(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) 
    {
        return game.dispatcher.isMouseButtonJustReleased(btn, id);
    }
    export extern(C) immutable(Vector2*) getTouchPosition(uint id=0) 
    {
        return game.dispatcher.getTouchPosition(id);
    }
    export extern(C) Vector2 getTouchDeltaPosition(uint id=0) 
    {
        return game.dispatcher.getTouchDeltaPosition(id);
    }
    export extern(C) Vector3 getScroll() 
    {
        return game.dispatcher.getScroll();
    }
}
