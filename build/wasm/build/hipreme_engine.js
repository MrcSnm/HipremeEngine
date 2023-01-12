function lookupForFunction(exports, funcName)
{
    if(!exports[funcName])
        throw new Error("HipremeEngine function '"+funcName+"' is required.");
}
function initializeHipremeEngine(exports)
{
    lookupForFunction(exports, "HipremeUpdate"); //(float dt)
    lookupForFunction(exports, "HipremeRender"); 
    lookupForFunction(exports, "HipInputOnTouchPressed");       //(uint id, float x, float y)
    lookupForFunction(exports, "HipInputOnTouchMoved");         //(uint id, float x, float y)
    lookupForFunction(exports, "HipInputOnTouchReleased");      //(uint id, float x, float y)
    lookupForFunction(exports, "HipInputOnTouchScroll");        //(float x, float y, float z)
    lookupForFunction(exports, "HipInputOnKeyDown");            //(uint virtualKey)
    lookupForFunction(exports, "HipInputOnKeyUp");              //(uint virtualKey)
    lookupForFunction(exports, "HipInputOnGamepadConnected");   //(ubyte id)
    lookupForFunction(exports, "HipInputOnGamepadDisconnected");//(ubyte id)
    lookupForFunction(exports, "HipOnRendererResize");          //(int x, int y)

    
    const HipInputOnKeyDown = (ev) =>
    {
        exports.HipInputOnKeyDown(ev.keyCode); //Use that for now. WILL be updated later.
    };
    const HipInputOnKeyUp = (ev) =>
    {
        exports.HipInputOnKeyUp(ev.keyCode); //Use that for now. WILL be updated later.
    };
    const HipInputOnTouchPressed = (ev) =>
    {
        exports.HipInputOnTouchPressed(0, ev.x, ev.y);
    };
    const HipInputOnTouchReleased = (ev) =>
    {
        exports.HipInputOnTouchReleased(0, ev.x, ev.y);
    };
    const HipInputOnTouchMoved = (ev) =>
    {
        exports.HipInputOnTouchMoved(0, ev.x, ev.y);
    };
    const HipInputOnTouchScroll = (ev) =>
    {
        exports.HipInputOnTouchScroll(ev.deltaX, ev.deltaY, ev.deltaZ);
    };
    const HipInputOnGamepadConnected = (ev) =>
    {
        exports.HipInputOnGamepadConnected(ev.gamepad.id);
    };
    const HipInputOnGamepadDisconnected = (ev) =>
    {
        exports.HipInputOnGamepadDisconnected(ev.gamepad.id);
    };
    const HipOnRendererResize = (ev) =>
    {
        exports.HipOnRendererResize(800, 600);//Currently maintain it as that.
    };
    window.addEventListener("keydown", HipInputOnKeyDown);
    window.addEventListener("keyup", HipInputOnKeyUp);
    window.addEventListener("mousedown", HipInputOnTouchPressed);
    window.addEventListener("mouseup", HipInputOnTouchReleased);
    window.addEventListener("mousemove", HipInputOnTouchMoved);
    window.addEventListener("wheel", HipInputOnTouchScroll);
    window.addEventListener("gamepadconnected", HipInputOnGamepadConnected);
    window.addEventListener("gamepaddisconnected", HipInputOnGamepadDisconnected);
    window.addEventListener("resize", HipOnRendererResize);

    const destroyEngine = () =>
    {
        window.removeEventListener("keydown", HipInputOnKeyDown);
        window.removeEventListener("keyup", HipInputOnKeyUp);
        window.removeEventListener("mousedown", HipInputOnTouchPressed);
        window.removeEventListener("mouseup", HipInputOnTouchReleased);
        window.removeEventListener("mousemove", HipInputOnTouchMoved);
        window.removeEventListener("wheel", HipInputOnTouchScroll);
        window.removeEventListener("gamepadconnected", HipInputOnGamepadConnected);
        window.removeEventListener("gamepaddisconnected", HipInputOnGamepadDisconnected);
        window.removeEventListener("resize", HipOnRendererResize);
    };
    window.druntimeAbortHook = destroyEngine;


    let lastTime = performance.now();
    function nextFrame(step)
    {
        try
        {
            if(exports.HipremeUpdate(performance.now() - lastTime))
            {
                finished = true;
                destroyEngine();
            }
            else
            {
                exports.HipremeRender();
                gameLoop();
            }
            lastTime = performance.now();
        }
        catch(err)
        {
            finished = true;
            destroyEngine();
            throw err;
        }
    }
    const gameLoop = () =>
    {
        requestAnimationFrame(nextFrame);
    }
    requestAnimationFrame(gameLoop);
}