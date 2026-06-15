function setWindowSize(width, height)
{
    const canvas = document.getElementById("glcanvas");
    canvas.style.width = `${width}px`;
    canvas.style.height = `${height}px`;
    canvas.width  = Math.floor(width*devicePixelRatio);
    canvas.height = Math.floor(height*devicePixelRatio);
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
        WasmSetWindowTitle(length, ptr)
        {
            document.title = WasmUtils.fromDString(length, ptr)
        },
        hipGetWindowScaleFactor()
        {
            return devicePixelRatio;
        },
        WasmGetWindowSize()
        {
            const canvas = document.getElementById("glcanvas");
            return WasmUtils.toDArray([canvas.clientWidth, canvas.clientHeight]);
        },
        WasmGetMaxScreenSize()
        {
            return WasmUtils.toDArray([screen.width, screen.height]);
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