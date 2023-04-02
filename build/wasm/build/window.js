const __windowSize = {width: 800, height: 600};

function getWindowSize(){return Object.assign(__windowSize);}
function setWindowSize(width, height)
{
    const canvas = document.getElementById("glcanvas");
    canvas.style.width = `${width/devicePixelRatio}px`;
    canvas.style.height = `${height/devicePixelRatio}px`;
    Object.assign(__windowSize, {width, height});
    canvas.width  = Math.floor(width);
    canvas.height = Math.floor(height);
}
function initializeWindowing()
{
    /**
     * @type {HTMLCanvasElement}
     */
    const canvas = document.getElementById("glcanvas");
    return {
        WasmSetWindowSize(width, height)
        {
            setWindowSize(width, height);
        },
        WasmGetWindowSize()
        {
            return WasmUtils.toDArray([innerWidth, innerHeight]);
        },
        WasmSetFullscreen(shouldSet)
        {
            if(shouldSet)
                canvas.requestFullscreen();
            else
                document.exitFullscreen();
        },
        WasmSetPointerLocked(shouldLock)
        {
            if(shouldLock)
                canvas.requestPointerLock();
            else
                document.exitPointerLock();
        }
    };
}