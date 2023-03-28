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


    const canvas = document.getElementById("glcanvas");
    
    const HipInputOnKeyDown = (ev) =>
    {
        exports.HipInputOnKeyDown(ev.keyCode); //Use that for now. WILL be updated later.
    };
    const HipInputOnKeyUp = (ev) =>
    {
        exports.HipInputOnKeyUp(ev.keyCode); //Use that for now. WILL be updated later.
    };

    function convertToHipremeEngineCoordinates(xy)
    {
        const rec = canvas.getBoundingClientRect();
        xy[0] = Math.floor((xy[0] - rec.left) * devicePixelRatio) | 0;
        xy[1] = Math.floor((xy[1] - rec.top)* devicePixelRatio) | 0;
        return xy;
    }

    const HipInputOnTouchPressed = (ev) =>
    {
        const [x, y] = convertToHipremeEngineCoordinates([ev.x, ev.y]);
        exports.HipInputOnTouchPressed(0, x, y);
    };
    const HipInputOnTouchReleased = (ev) =>
    {
        const [x, y] = convertToHipremeEngineCoordinates([ev.x, ev.y]);
        exports.HipInputOnTouchReleased(0, x, y);
    };
    const HipInputOnTouchMoved = (ev) =>
    {
        const [x, y] = convertToHipremeEngineCoordinates([ev.x, ev.y]);
        exports.HipInputOnTouchMoved(0, x, y);
    };
    const HipInputOnTouchScroll = (ev) =>
    {
        exports.HipInputOnTouchScroll(ev.deltaX, ev.deltaY, ev.deltaZ);
    };
    const HipInputOnGamepadConnected = (ev) =>
    {
        exports.HipInputOnGamepadConnected(ev.gamepad.id, -1);
    };
    const HipInputOnGamepadDisconnected = (ev) =>
    {
        exports.HipInputOnGamepadDisconnected(ev.gamepad.id, -1);
    };
    const HipOnRendererResize = (ev) =>
    {
        // let {width, height} = getWindowSize();
        width = window.innerWidth
        height = window.innerHeight
        setWindowSize(width, height);

        exports.HipOnRendererResize(width, height);//Currently maintain it as that.
    };
    canvas.addEventListener("mousedown", HipInputOnTouchPressed);
    canvas.addEventListener("mouseup", HipInputOnTouchReleased);
    canvas.addEventListener("mousemove", HipInputOnTouchMoved);
    canvas.addEventListener("wheel", HipInputOnTouchScroll);
    window.addEventListener("keydown", HipInputOnKeyDown);
    window.addEventListener("keyup", HipInputOnKeyUp);
    window.addEventListener("gamepadconnected", HipInputOnGamepadConnected);
    window.addEventListener("gamepaddisconnected", HipInputOnGamepadDisconnected);
    window.addEventListener("resize", HipOnRendererResize);

    const destroyEngine = () =>
    {
        canvas.removeEventListener("mousedown", HipInputOnTouchPressed);
        canvas.removeEventListener("mouseup", HipInputOnTouchReleased);
        canvas.removeEventListener("mousemove", HipInputOnTouchMoved);
        canvas.removeEventListener("wheel", HipInputOnTouchScroll);
        window.removeEventListener("keydown", HipInputOnKeyDown);
        window.removeEventListener("keyup", HipInputOnKeyUp);
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
            //To seconds. Javascript gives in MS.
            if(!exports.HipremeUpdate((performance.now() - lastTime)/1000))
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