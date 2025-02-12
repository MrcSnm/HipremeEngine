function initializeWebsocketsContext()
{
    globalThis.ConnectedWebsockets = [];
    const addObject = WasmUtils.addObject;
    const removeObject = WasmUtils.removeObject;
    const objects = WasmUtils._objects;

    const msgQueue = {};
    ///Data to be sent once initialized.
    const sendQueue = {};

    /**
     *
     * @param {number} ws Websocket ID
     * @returns {WebSocket}
     */
    const getWebSocket = (ws) =>
    {
        const ret = objects[ws];
        if(!ret)
            throw new Error(`Could not find websocket with id ${websocket}`);
        return ret;
    };

    
    return {
        /**
         *  Receives a (string, void delegate() onConnected, void delegate() onClose)
         * Used for tracking state of websocket
         *
         * @param {number} urlLength Length of the string
         * @param {number} urlPtr String pointer init
         *
         * @param {number} connHadle Which function to call
         * @param {number} connFunc Internal detail of handle
         * @param {number} connCtx Internal detail of conn
         *
         * @param {number} closeHandle Which function to call
         * @param {number} closeFunc Internal of close
         * @param {number} closeCtx Internal of close
         *
         * @param {number} idMsgHandle Which function to call
         * @param {number} idMsgFunc Internal of close
         * @param {number} idMsgCtx Internal of close
         * @returns Websocket handle
         */
        connectWebsocket(
            urlLength, urlPtr,
            connHandle, connFunc, connCtx,
            closeHandle, closeFunc, closeCtx,
            idMsgHandle, idMsgFunc, idMsgCtx
        )
        {
            const ws = new WebSocket(WasmUtils.fromDString(urlLength, urlPtr));
            globalThis.ConnectedWebsockets.push(ws);
            ws.binaryType = "arraybuffer";
            const ret = addObject(ws);
            msgQueue[ret] = [];
            sendQueue[ret] = [];
            let isFirstMessage = true;

            ws.onmessage = (event) =>
            {
                if(isFirstMessage)
                {
                    isFirstMessage = false;
                    exports.__callDFunction(idMsgHandle, WasmUtils.toDArguments(idMsgFunc, idMsgCtx, new Uint32Array(event.data)[0]));
                }
                else
                {
                    let data = event.data instanceof ArrayBuffer ? new Uint8Array(event.data) : event.data;
                    msgQueue[ret].push(data);
                }
            }
            ws.onopen = (event) =>
            {
                exports.__callDFunction(connHandle, WasmUtils.toDArguments(connFunc, connCtx));
                sendQueue[ret].forEach(element => {
                    ws.send(element);
                });

                delete sendQueue[ret];
            };

            globalThis.ws = ws;
            ws.onclose = (event) =>
            {
                exports.__callDFunction(closeHandle, WasmUtils.toDArguments(closeFunc, closeCtx));
                console.warn("Hip Websockets: Closed.");
            }
            return ret;
        },

        /**
         *
         * @param {number} websocket WebSocket handle
         * @param {number} from From socket ID
         * @param {number} to To Socket ID
         * @param {number} bufferLen Data Length
         * @param {number} ptr Data pointer
         */
        websocketSendData(websocket, from, to, bufferLen, ptr)
        {
            const ws = getWebSocket(websocket);
            let data = new ArrayBuffer(8 + bufferLen);
            const view = new DataView(data);
            const uint8View = new Uint8Array(data);

            view.setUint32(0, from, true);
            view.setUint32(4, to, true);
            uint8View.set(new Uint8Array(memory.buffer, ptr, bufferLen), 8);


            switch(ws.readyState)
            {
                case WebSocket.CONNECTING:
                    sendQueue[websocket].push(view);
                    break;
                case WebSocket.OPEN:
                    ws.send(view);
                    break;
                default:
                    throw new Error(`Tried to send websocket ${websocket} message while it is closed or closing.`);
            }

        },
        websocketGetData(websocket)
        {
            getWebSocket(websocket); //Force check existence
            const q = msgQueue[websocket];
            if(q.length > 0)
                return WasmUtils.toDBinary(q.splice(0, 1)[0]);
            return null;
        },
        closeWebsocket(websocket)
        {
            const ws = getWebSocket(websocket);
            const sockets = globalThis.ConnectedWebsockets;
            sockets.splice(sockets.indexOf(ws), 1);
            ws.close();
        }
    }
}