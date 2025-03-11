/**
 * 
 * @param {string} url The URL to fetch
 * @param {RequestInit?} init The request init object
 * @param {(total: number, current: number)} onProgress A function for monitoring the progress
 * @returns 
 */
async function fetchWithProgress(url, init, onProgress) 
{
    const response = await fetch(url, init);

    if (!response.ok) {
        throw new Error('Network response was not ok');
    }
    const contentLength = response.headers.get('Content-Length');
    if (!contentLength) {
        throw new Error('Content-Length response header unavailable');
    }

    const total = parseInt(contentLength, 10);
    let loaded = 0;

    const reader = response.body.getReader();
    const stream = new ReadableStream({
        start(controller) {
            function read() {
                reader.read().then(({ done, value }) => {
                    if (done) {
                        controller.close();
                        return;
                    }
                    loaded += value.byteLength;
                    onProgress(loaded, total);
                    controller.enqueue(value);
                    read();
                }).catch(error => {
                    console.error('Stream reading error', error);
                    controller.error(error);
                });
            }
            read();
        }
    });

    const newResponse = new Response(stream, {
        headers: {
            'Content-Type': response.headers.get("Content-Type")
        }
    });
    return newResponse;
}


function lookupForFunction(exports, funcName)
{
    if(!exports[funcName])
        throw new Error("HipremeEngine function '"+funcName+"' is required.");
}
function initializeHipremeEngine(exports)
{
    lookupForFunction(exports, "HipremeEngineLoop"); //(float dt)
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
        let id = 0;
        if(ev.id) id = ev.id;
        exports.HipInputOnTouchPressed(id, x, y);
    };
    const HipInputOnTouchReleased = (ev) =>
    {
        const [x, y] = convertToHipremeEngineCoordinates([ev.x, ev.y]);
        let id = 0;
        if(ev.id) id = ev.id;
        exports.HipInputOnTouchReleased(id, x, y);
    };
    const HipInputOnTouchMoved = (ev) =>
    {
        const [x, y] = convertToHipremeEngineCoordinates([ev.x, ev.y]);
        let id = 0;
        if(ev.id) id = ev.id;
        exports.HipInputOnTouchMoved(id, x, y);
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

    canvas.addEventListener("touchstart", (ev) =>
    {
        for(let i = 0; i < ev.touches.length; i++)
            HipInputOnTouchPressed({x: ev.touches[i].clientX, y: ev.touches[i].clientY, id:i});
    });
    canvas.addEventListener("touchmove", (ev) =>
    {
        for(let i = 0; i < ev.touches.length; i++)
            HipInputOnTouchMoved({x: ev.touches[i].clientX, y: ev.touches[i].clientY, id:i});
    });
    canvas.addEventListener("touchend", (ev) =>
    {
        for(let i = 0; i < ev.touches.length; i++)
            HipInputOnTouchReleased({x: ev.touches[i].clientX, y: ev.touches[i].clientY, id:i});
    });
    canvas.addEventListener("mousedown", HipInputOnTouchPressed);
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
    const nextFrame = (step) =>
    {
        if(__shouldReloadGame)
        {
            __reloadGame();
            return;
        }
        try
        {
            //To seconds. Javascript gives in MS.
            if(!exports.HipremeEngineLoop((performance.now() - lastTime)/1000))
            {
                finished = true;
                destroyEngine();
            }
            else
            {
                lastTime = performance.now();
                requestAnimationFrame(nextFrame);
            }
        }
        catch(err)
        {
            finished = true;
            destroyEngine();
            throw err;
        }
    }
    requestAnimationFrame(nextFrame);
}