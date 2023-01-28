function initializeDecoders()
{
    const gameAssets = {};
    function assertNotExist(key)
    {
        if(gameAssets[key])
            throw new Error("HipremeEngine already loaded asset " + key);
    }
    function substringEquals(input, start, compareWith)
    {
        if(start + compareWith.length >= input.length) return false;
        for(let i = 0; i < compareWith.length; i++)
            if(!compareWith[i] == input[i+start]) return false;
        return true;
    }
    const addObject = WasmUtils.addObject;
    const _objects = WasmUtils._objects;
    const removeObject = WasmUtils.removeObject;
    
    ///__callDFunction always expect toDArguments as its argument.
    const toDArguments = WasmUtils.toDArguments;
    const _canvas = document.createElement("canvas");
    _canvas.style.imageRendering = "pixelated";
    
    const memoryCanvas = _canvas.getContext("2d", {willReadFrequently:true});

    return {
        WasmDecodeImage(imgNameLength, imgNamePtr, ptr, length, dFunction, dgFunc, delegateCtx)
        {
            const imgName = WasmUtils.fromDString(imgNameLength, imgNamePtr);
            assertNotExist(imgName);
            const extIndex = imgName.lastIndexOf(".") + 1;
            if(extIndex == 0) throw new TypeError("Expected extension on imgName: " + imgName);

            const type = imgName.substring(extIndex);
            const img = document.createElement("img");
            const imgHandle = addObject(img);
            img.onload = (ev) =>
            {
                exports.__callDFunction(dFunction, toDArguments(dgFunc, delegateCtx, imgHandle));
            };  
            img.src = 'data:image/'+type+";base64,"+WasmUtils.binToBase64(ptr, length);

            // document.body.appendChild(img); Not needed
            gameAssets[imgName] = img;

            return imgHandle;
        },
        WasmImageGetWidth(img){return _objects[img].width;},
        WasmImageGetHeight(img){return _objects[img].height;},

        ///Always allocates D memory. Should be freed in D code.
        WasmImageGetPixels(img)
        {
            const objImg = _objects[img];
            _canvas.width = objImg.width;
            _canvas.height = objImg.height;

            memoryCanvas.drawImage(objImg, 0, 0);
            const imgData = memoryCanvas.getImageData(0, 0, objImg.width, objImg.height);
            return WasmUtils.toDBinary(imgData.data);
        },
        WasmImageDispose(img){removeObject(img);},

    }
}