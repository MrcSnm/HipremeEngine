function setWindowSize(width, height)
{
    const dpr = window.devicePixelRatio || 1;
    const canvas = document.getElementById("glcanvas");
    canvas.style.width = `${width}px`;
    canvas.style.height = `${height}px`;
    canvas.width  = Math.round(width*dpr);
    canvas.height = Math.round(height*dpr);
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
            return WasmUtils.toDArray([innerWidth, innerHeight]);
        },
        WasmGetMaxScreenSize()
        {
            return WasmUtils.toDArray([screen.availWidth, screen.availHeight]);
        },
        WasmSetFullscreen(shouldSet)
        {
            if(shouldSet == !!document.fullscreenElement)
                return;
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