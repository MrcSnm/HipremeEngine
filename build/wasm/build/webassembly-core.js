
// can webassembly's main be async?
// I might be able to make a semaphore out of
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Atomics/wait

// stores { object: o, refcount: n }
var bridgeObjects = [{}]; // the first one is a null object; ignored
// placeholder to be filled in by the loader
var memory;
var printBlockDebugInfo;
var bridge_malloc;
var exports;

function memdump(address, length) {
	var a = new Uint32Array(memory.buffer, address, length);
	console.log(a);
}

function meminfo() {
	document.getElementById("stdout").innerHTML = "";
	printBlockDebugInfo(0);
}


var dModules = {};
var savedFunctions = {};
const utf8Encoder = new TextEncoder("utf-8");
const utf8Decoder = new TextDecoder();
var WasmUtils = {
	toDString(str)
	{
		const s = utf8Encoder.encode(str);
		const ptr = bridge_malloc(s.byteLength + 4);
		let view = new Uint32Array(memory.buffer, ptr, 1);
		view[0] = s.byteLength;
		let view2 = new Uint8Array(memory.buffer, ptr + 4, s.length);
		view2.set(s);
		return ptr;
	},
	fromDString(length, ptr)
	{
		return utf8Decoder.decode(new DataView(memory.buffer, ptr, length));
	}
}

var importObject = {
env: {
	acquire: function(returnType, modlen, modptr, javascriptCodeStringLength, javascriptCodeStringPointer, argsLength, argsPtr) {
		var td = new TextDecoder();
		var md = td.decode(new Uint8Array(memory.buffer, modptr, modlen));
		var s = td.decode(new Uint8Array(memory.buffer, javascriptCodeStringPointer, javascriptCodeStringLength));

		var jsArgs = [];
		var argIdx = 0;

		var jsArgsNames = "";

		var a = new Uint32Array(memory.buffer, argsPtr, argsLength * 3);
		var aidx = 0;

		for(var argIdx = 0; argIdx < argsLength; argIdx++) {
			var type = a[aidx];
			aidx++;
			var ptr = a[aidx];
			aidx++;
			var length = a[aidx];
			aidx++;

			if(jsArgsNames.length)
				jsArgsNames += ", ";
			jsArgsNames += "$" + argIdx;

			var value;

			switch(type) {
				case 0:
					// an integer was casted to the pointer
					if(ptr & 0x80000000)
						value = - (~ptr + 1); // signed 2's complement
					else
						value = ptr;
				break;
				case 1:
					// pointer+length is a string
					value = td.decode(new Uint8Array(memory.buffer, ptr, length));
				break;
				case 2:
					// a handle
					value = bridgeObjects[ptr].object;
				break;
				case 3:
					// float passed by ref cuz idk how else to reinterpret cast in js
					value = (new Float32Array(memory.buffer, ptr, 1))[0];
				break;
				case 4:
					// float passed by ref cuz idk how else to reinterpret cast in js
					value = (new Uint8Array(memory.buffer, ptr, length));
				break;
				/*
				case 5:
					// a pointer to a delegate
					let p1 = a[ptr];
					let p2 = a[ptr + 1];
					value = function()
				break;
				*/
			}

			jsArgs.push(value);
		}

		///*
		var func = savedFunctions[s];
		if(!func) {
			func = new Function(jsArgsNames, s);
			savedFunctions[s] = func;
		}
		//*/
		//var func = new Function(jsArgsNames, s);
		var ret = func.apply(dModules[md] ? dModules[md] : (dModules[md] = {}), jsArgs);

		switch(returnType) {
			case 0: // void
				return 0;
			case 1:
				// int
				return ret;
			case 2:
				// float
				var view = new Float32Array(memory.buffer, 0, 1);
				view[0] = ret;
				return 0;
			case 3:
				// boxed object
				var handle = bridgeObjects.length;
				bridgeObjects.push({ refcount: 1, object: ret });
				return handle;
			case 4:
				// ubyte[] into given buffer
			case 5:
				// malloc'd ubyte[]
			case 6:
				// string into given buffer
			case 7:
				// malloc'd string. it puts the length as an int before the string, then returns the pointer.
				var te = new TextEncoder();
				var s = te.encode(ret);
				var ptr = bridge_malloc(s.byteLength + 4);
				var view = new Uint32Array(memory.buffer, ptr, 1);
				view[0] = s.byteLength;
				var view2 = new Uint8Array(memory.buffer, ptr + 4, s.length);
				view2.set(s);
				return ptr;
			case 8:
				// return the function itself, so box it up but do not actually call it
		}
		return -1;
	},

	retain: function(handle) {
		bridgeObjects[handle].refcount++;
	},
	release: function(handle) {
		bridgeObjects[handle].refcount--;
		if(bridgeObjects[handle].refcount <= 0) {
			//console.log("freeing " + handle);
			bridgeObjects[handle] = null;
			if(handle + 1 == bridgeObjects.length)
				bridgeObjects.pop();
		}
	},
	abort: function() {
		if(druntimeAbortHook) druntimeAbortHook();
		throw new Error("DRuntime Aborted Wasm");
	},
	_Unwind_Resume: function() {},

	monotimeNow: function() {
		return performance.now()|0;
	},

	executeCanvasCommands: function(handle, start, len) {
		var context = bridgeObjects[handle].object;

		var commands = new Float64Array(memory.buffer, start, len);

		context.save();

		len = 0;

		while(len < commands.length) {
			switch(commands[len++]) {
				case 0: break; // intentionally blank
				case 1: // clear
					context.clearRect(0, 0, context.canvas.width, context.canvas.height);
				break;
				case 2: // strokeStyle
					var s = "";
					var slen = commands[len++];
					for(var i = 0; i < slen; i++)
						s += String.fromCharCode(commands[len++]);
					context.strokeStyle = s;
				break;
				case 3: // fillStyle
					var s = "";
					var slen = commands[len++];
					for(var i = 0; i < slen; i++)
						s += String.fromCharCode(commands[len++]);
					context.fillStyle = s;
				break;
				case 4: // drawRectangle
					context.beginPath();
					context.rect(commands[len++] + 0.5, commands[len++] + 0.5, commands[len++] - 1, commands[len++] - 1);
					context.closePath();

					context.stroke();
					context.fill();
				break;
				case 5: // drawText
					// FIXME
					var x = commands[len++];
					var y = commands[len++];
					var s = "";
					var slen = commands[len++];
					for(var i = 0; i < slen; i++)
						s += String.fromCharCode(commands[len++]);

					context.font = "18px sans-serif";
					context.strokeText(s, x, y);
				break;
				case 6: // drawCircle
					context.beginPath();
					context.arc(commands[len++], commands[len++], commands[len++], 0, 2 * Math.PI, false);
					context.closePath();
					context.fill();
					context.stroke();
				break;
				case 7: // drawLine
					context.beginPath();
					context.moveTo(commands[len++] + 0.5, commands[len++] + 0.5);
					context.lineTo(commands[len++] + 0.5, commands[len++] + 0.5);
					context.closePath();

					context.stroke();
				break;
				case 8: // drawPolygon
					context.beginPath();
					var count = commands[len++];

					context.moveTo(commands[len++] + 0.5,
						commands[len++] + 0.5);
					for(var i = 1; i < count; i++)
						context.lineTo(commands[len++] + 0.5,
							commands[len++] + 0.5);

					context.closePath();
					context.fill();
					context.stroke();
				break;
				default: throw new Error("unknown command from sdpy bridge");
			}
		}

		context.restore();

	},
	JS_Math_random : Math.random,
	atan2f: Math.atan2,
	tanf: Math.tan,
	log2: Math.log2,
	cosf: Math.cos,
	acosf: Math.acos,
	sinf: Math.sin,
	sqrtf: Math.sqrt,
}};

(function()
{
	const glEnv = initializeWebglContext();
	for (const functionName in glEnv) 
	{
		importObject.env[functionName] = glEnv[functionName];
	}
}());