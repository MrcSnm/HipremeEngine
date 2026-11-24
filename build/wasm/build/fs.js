function initializeFS()
{
    const fileCache = {};
    globalThis.fileCache = fileCache;

    const storagePaths = new Set();
    const Backend =
    {
        opfs: 0,
        indexedDB: 1,
        localStorage: 2
    };
    let storageBackend = -1;
    let storageReadyPromise = null;

    function normalizeStoragePath(path)
    {
        const parts = [];
        for(const part of path.replaceAll("\\", "/").split("/"))
        {
            if(part.length === 0 || part === ".")
                continue;
            if(part === "..")
                parts.pop();
            else
                parts.push(part);
        }
        return parts.join("/");
    }

    function hasOpfs()
    {
        return !!(navigator.storage && navigator.storage.getDirectory);
    }

    function hasIndexedDB()
    {
        return typeof indexedDB !== "undefined" && indexedDB !== null;
    }

    function hasLocalStorage()
    {
        try
        {
            return typeof localStorage !== "undefined" && localStorage !== null;
        }
        catch(err)
        {
            return false;
        }
    }

    let opfsRootPromise = null;

    async function initOpfs()
    {
        const root = await navigator.storage.getDirectory();
        const stack = [["", root]];
        while(stack.length)
        {
            const [prefix, dir] = stack.pop();
            for await (const [name, handle] of dir.entries())
            {
                if(handle.kind === "directory")
                    stack.push([prefix + name + "/", handle]);
                else
                    storagePaths.add(prefix + name);
            }
        }
        opfsRootPromise = Promise.resolve(root);
    }

    async function getOpfsFileHandle(path, create)
    {
        const cleanPath = normalizeStoragePath(path);
        if(cleanPath.length === 0)
            throw new Error("Invalid storage path: '" + path + "'");
        const parts = cleanPath.split("/");
        let dir = await opfsRootPromise;
        for(let i = 0; i < parts.length - 1; i++)
            dir = await dir.getDirectoryHandle(parts[i], {create});
        return dir.getFileHandle(parts[parts.length - 1], {create});
    }

    async function readOpfsFile(path)
    {
        const handle = await getOpfsFileHandle(path, false);
        const file = await handle.getFile();
        return new Uint8Array(await file.arrayBuffer());
    }

    async function writeOpfsFile(path, data)
    {
        const handle = await getOpfsFileHandle(path, true);
        const writable = await handle.createWritable();
        await writable.write(data);
        await writable.close();
        storagePaths.add(normalizeStoragePath(path));
    }

    async function removeOpfsFile(path)
    {
        const cleanPath = normalizeStoragePath(path);
        const parts = cleanPath.split("/");
        const name = parts.pop();
        let dir = await opfsRootPromise;
        for(const part of parts)
            dir = await dir.getDirectoryHandle(part, {create: false});
        await dir.removeEntry(name);
        storagePaths.delete(cleanPath);
    }

    const INDEXED_DB_NAME = "hipreme_engine_fs";
    const INDEXED_DB_STORE = "files";
    let indexedDBPromise = null;

    function openIndexedDB()
    {
        if(indexedDBPromise === null)
        {
            indexedDBPromise = new Promise((resolve, reject) =>
            {
                const request = indexedDB.open(INDEXED_DB_NAME, 1);
                request.onupgradeneeded = () =>
                {
                    const db = request.result;
                    if(!db.objectStoreNames.contains(INDEXED_DB_STORE))
                        db.createObjectStore(INDEXED_DB_STORE);
                };
                request.onsuccess = () => resolve(request.result);
                request.onerror = () => reject(request.error || new Error("Could not open IndexedDB."));
                request.onblocked = () => reject(new Error("IndexedDB open blocked."));
            });
        }
        return indexedDBPromise;
    }

    async function initIndexedDB()
    {
        const db = await openIndexedDB();
        await new Promise((resolve, reject) =>
        {
            const request = db.transaction(INDEXED_DB_STORE, "readonly").objectStore(INDEXED_DB_STORE).getAllKeys();
            request.onsuccess = () =>
            {
                for(const key of request.result)
                    storagePaths.add(key);
                resolve();
            };
            request.onerror = () => reject(request.error || new Error("Could not enumerate IndexedDB."));
        });
    }

    async function readIndexedDB(path)
    {
        const db = await openIndexedDB();
        return new Promise((resolve, reject) =>
        {
            const request = db.transaction(INDEXED_DB_STORE, "readonly").objectStore(INDEXED_DB_STORE).get(path);
            request.onsuccess = () =>
            {
                if(request.result === undefined)
                {
                    reject(new Error("NotFoundError: " + path));
                    return;
                }
                const value = request.result;
                resolve(value instanceof Uint8Array ? value : new Uint8Array(value));
            };
            request.onerror = () => reject(request.error || new Error("IndexedDB read failed."));
        });
    }

    async function writeIndexedDB(path, data)
    {
        const db = await openIndexedDB();
        await new Promise((resolve, reject) =>
        {
            const transaction = db.transaction(INDEXED_DB_STORE, "readwrite");
            transaction.objectStore(INDEXED_DB_STORE).put(data, path);
            transaction.oncomplete = () => resolve();
            transaction.onerror = () => reject(transaction.error || new Error("IndexedDB write failed."));
            transaction.onabort = () => reject(transaction.error || new Error("IndexedDB write aborted."));
        });
        storagePaths.add(normalizeStoragePath(path));
    }

    async function removeIndexedDB(path)
    {
        const db = await openIndexedDB();
        await new Promise((resolve, reject) =>
        {
            const transaction = db.transaction(INDEXED_DB_STORE, "readwrite");
            transaction.objectStore(INDEXED_DB_STORE).delete(path);
            transaction.oncomplete = () => resolve();
            transaction.onerror = () => reject(transaction.error || new Error("IndexedDB remove failed."));
            transaction.onabort = () => reject(transaction.error || new Error("IndexedDB remove aborted."));
        });
        storagePaths.delete(normalizeStoragePath(path));
    }

    const LOCAL_STORAGE_PREFIX = "hipreme_fs:";

    function initLocalStorage()
    {
        for(let i = 0; i < localStorage.length; i++)
        {
            const key = localStorage.key(i);
            if(key && key.startsWith(LOCAL_STORAGE_PREFIX))
                storagePaths.add(key.substring(LOCAL_STORAGE_PREFIX.length));
        }
    }

    function readLocalStorage(path)
    {
        const encoded = localStorage.getItem(LOCAL_STORAGE_PREFIX + path);
        if(encoded === null)
            throw new Error("NotFoundError: " + path);
        const binary = atob(encoded);
        const ret = new Uint8Array(binary.length);
        for(let i = 0; i < binary.length; i++)
            ret[i] = binary.charCodeAt(i);
        return ret;
    }

    function writeLocalStorage(path, data)
    {
        const chunkSize = 0x8000;
        let binary = "";
        for(let i = 0; i < data.length; i += chunkSize)
            binary += String.fromCharCode.apply(null, data.subarray(i, i + chunkSize));
        localStorage.setItem(LOCAL_STORAGE_PREFIX + path, btoa(binary));
        storagePaths.add(normalizeStoragePath(path));
    }

    function removeLocalStorage(path)
    {
        localStorage.removeItem(LOCAL_STORAGE_PREFIX + path);
        storagePaths.delete(normalizeStoragePath(path));
    }

    async function initStorage()
    {
        if(hasOpfs())
        {
            try
            {
                await initOpfs();
                storageBackend = Backend.opfs;
                return;
            }
            catch(err)
            {
                console.warn("OPFS unavailable, falling back to IndexedDB:", err);
            }
        }
        if(hasIndexedDB())
        {
            try
            {
                await initIndexedDB();
                storageBackend = Backend.indexedDB;
                return;
            }
            catch(err)
            {
                console.warn("IndexedDB unavailable, falling back to localStorage:", err);
            }
        }
        if(hasLocalStorage())
        {
            initLocalStorage();
            storageBackend = Backend.localStorage;
            return;
        }
        throw new Error("No supported persistent storage backend (OPFS, IndexedDB or localStorage).");
    }

    function getStorageReady()
    {
        if(storageReadyPromise === null)
            storageReadyPromise = initStorage();
        return storageReadyPromise;
    }

    function hasStorage()
    {
        return hasOpfs() || hasIndexedDB() || hasLocalStorage();
    }

    async function readStorage(path)
    {
        await getStorageReady();
        switch(storageBackend)
        {
            case Backend.opfs:
                return readOpfsFile(path);
            case Backend.indexedDB:
                return readIndexedDB(path);
            case Backend.localStorage:
                return readLocalStorage(path);
            default:
                throw new Error("No persistent storage backend available.");
        }
    }

    async function writeStorage(path, data)
    {
        await getStorageReady();
        switch(storageBackend)
        {
            case Backend.opfs:
                return writeOpfsFile(path, data);
            case Backend.indexedDB:
                return writeIndexedDB(path, data);
            case Backend.localStorage:
                return writeLocalStorage(path, data);
            default:
                throw new Error("No persistent storage backend available.");
        }
    }

    async function removeStorage(path)
    {
        await getStorageReady();
        switch(storageBackend)
        {
            case Backend.opfs:
                return removeOpfsFile(path);
            case Backend.indexedDB:
                return removeIndexedDB(path);
            case Backend.localStorage:
                return removeLocalStorage(path);
            default:
                throw new Error("No persistent storage backend available.");
        }
    }

    if(!hasOpfs() && !hasIndexedDB() && hasLocalStorage())
    {
        initLocalStorage();
        storageBackend = Backend.localStorage;
        storageReadyPromise = Promise.resolve();
    }
    else
    {
        getStorageReady().catch((err) =>
        {
            console.warn("Persistent storage unavailable:", err);
        });
    }

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
        },

        WasmOPFSRead(pathLength, pathPtr, onSuccessHandle, onSuccessFunc, onSuccessCtx, onErrorHandle, onErrorFunc, onErrorCtx)
        {
            const path = normalizeStoragePath(WasmUtils.fromDString(pathLength, pathPtr));
            readStorage(path)
            .then((data) =>
            {
                exports.__callDFunction(onSuccessHandle, WasmUtils.toDArguments(onSuccessFunc, onSuccessCtx, data));
            })
            .catch((err) =>
            {
                exports.__callDFunction(onErrorHandle, WasmUtils.toDArguments(onErrorFunc, onErrorCtx, path + ": " + err.toString()));
            });
        },

        WasmOPFSWrite(pathLength, pathPtr, dataLength, dataPtr)
        {
            if(!hasStorage())
                return false;
            const path = normalizeStoragePath(WasmUtils.fromDString(pathLength, pathPtr));
            const data = WasmUtils.copyFromDBinary(dataLength, dataPtr);
            storagePaths.add(path);
            writeStorage(path, data).catch((err) =>
            {
                storagePaths.delete(path);
                console.error("Persistent storage write failed for '" + path + "':", err);
            });
            return true;
        },

        WasmOPFSRemove(pathLength, pathPtr)
        {
            if(!hasStorage())
                return false;
            const path = normalizeStoragePath(WasmUtils.fromDString(pathLength, pathPtr));
            storagePaths.delete(path);
            removeStorage(path).catch((err) =>
            {
                storagePaths.add(path);
                console.error("Persistent storage remove failed for '" + path + "':", err);
            });
            return true;
        },

        WasmOPFSExists(pathLength, pathPtr)
        {
            const path = normalizeStoragePath(WasmUtils.fromDString(pathLength, pathPtr));
            return storagePaths.has(path);
        },

        WasmDebugWriteFile(pathLength, pathPtr, contentLength, contentPtr)
        {
            let path = WasmUtils.fromDString(pathLength, pathPtr);
            let content = WasmUtils.fromDString(contentLength, contentPtr);
eval(`
/*
${content.replaceAll("*/", "*\\/")}
*/
//#sourceURL=${path}`);
        }
    };
}
