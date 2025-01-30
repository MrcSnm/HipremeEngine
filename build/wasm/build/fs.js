function initializeFS()
{
    const fileCache = {};
    globalThis.fileCache = fileCache;

    return {
        WasmRead(length, ptr, onSuccessHandle, onSuccessFunc, onSuccessCtx, onErrorHandle, onErrorFunc, onErrorCtx) 
        {
            const __callDFunction = exports.__callDFunction;

            let path = WasmUtils.fromDString(length, ptr);
            if(path in fileCache)
            {
                __callDFunction(onSuccessHandle, WasmUtils.toDArguments(onSuccessFunc, onSuccessCtx, fileCache[path]));
                return;
            }

            console.log("Fetching ", path);
            fetch(path)
            .then((val) =>
            {
                val.arrayBuffer().then((buffer) =>
                {
                    fileCache[path] = new Uint8Array(buffer);
                    __callDFunction(onSuccessHandle, WasmUtils.toDArguments(onSuccessFunc, onSuccessCtx, fileCache[path]));
                });
            })
            .catch((err) =>
            {
                __callDFunction(onErrorHandle, WasmUtils.toDArguments(onErrorFunc, onErrorCtx, err.toString()));
            });
        },

        WasmReadCache(pathLength, pathPtr)
        {
            const cachePath = WasmUtils.fromDString(pathLength, pathPtr);
            const ret = localStorage.getItem(cachePath);
            console.log("Cache from ", cachePath, ret);
            return WasmUtils.toDString(ret);
        },

        WasmWriteCache(pathLength, pathPtr, writeLength, writePtr)
        {
            const path = WasmUtils.fromDString(pathLength, pathPtr);
            const toWrite = WasmUtils.fromDString(writeLength, writePtr);
            localStorage.setItem(path, toWrite);
            console.log("Saved in", path, toWrite);
        }
    };
}