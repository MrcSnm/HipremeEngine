function initializeFS()
{
    const _dir = {};
    return {
        read(length, ptr) {
            fetch(WasmUtils.fromDString(length, ptr))
        },
        write(length, ptr) {
            throw new Error("Can't write files " + WasmUtils.fromDString(length, ptr))
        },
        exists(length, ptr){
            return Boolean(_dir[WasmUtils.fromDString(length, ptr)]);
        }
    };
}