function initializeFS()
{
    return {
        WasmRead(length, ptr, onSuccessHandle, onSuccessFunc, onSuccessCtx, onErrorHandle, onErrorFunc, onErrorCtx) 
        {
            let path = WasmUtils.fromDString(length, ptr);

            const __callDFunction = exports.__callDFunction;
            console.log("Fetching ", path);
            fetch(path)
            .then((val) =>
            {
                val.arrayBuffer().then((buffer) =>
                {
                    console.log(buffer.byteLength);
                    __callDFunction(onSuccessHandle, WasmUtils.toDArguments(onSuccessFunc, onSuccessCtx, new Uint8Array(buffer)));
                });
            })
            .catch((err) =>
            {
                __callDFunction(onErrorHandle, WasmUtils.toDArguments(onErrorFunc, onErrorCtx, err.toString()));
            });
        },

        write(length, ptr) {
            throw new Error("Can't write files " + WasmUtils.fromDString(length, ptr))
        }
    };
}