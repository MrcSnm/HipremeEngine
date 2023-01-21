module hip.wasm;
version(WebAssembly):

///WebAssembly.Table replacement for HipremeEngine
private __gshared ubyte* function(ubyte* args)[] _annonymousFunctionTable;
///JSFunctions are represented opaquely right now.
alias JSFunction(T) = ubyte*;

///Gets a unique function index for usage in the table
extern(C) size_t _getFuncAddress(ubyte* fn);

///Javascript function to call a D callback.
export extern(C) ubyte* __callDFunction(size_t addr, ubyte* args)
{
	return _annonymousFunctionTable[addr](args);
}

///Checks if function has been called with required arguments.
private ubyte* validateArguments(alias fn)(ubyte* args)
{
	import std.traits;
	//Only checking the count of 
	assert(Parameters!(fn).length <= *cast(size_t*)args, 
	fn.stringof~"Expected "~Parameters!(fn).length.stringof~" parameters");
	return args + size_t.sizeof; //Only uses 1 size_t to determine arguments validity
}


struct Arguments(alias Func)
{
	import std.traits;
	Parameters!Func params;
}

Struct loadMemoryInStruct(Struct)(ubyte* arg)
{
	Struct ret;
	size_t last = 0;
	foreach(ref v; ret.tupleof)
	{
		static if(is(typeof(v) : string))
		{
			{
				ubyte* data = arg+last;
				size_t length = *cast(size_t*)data;
				v = cast(string)data[size_t.sizeof..length+size_t.sizeof];
			}
		}
		else static if(is(typeof(v) : ubyte[]))
		{
			{
				ubyte* data = arg+last;
				size_t length = *cast(size_t*)data;
				v = cast(ubyte[])data[size_t.sizeof..length+size_t.sizeof];
			}
		}
		else
			memcpy(&v, arg+last, v.sizeof);
		last+= v.sizeof;
	}
	return ret;
}

Arguments!fn wasmParametersFromUbyte(alias fn)(ubyte* arg)
{
	return loadMemoryInStruct!(Arguments!fn)(arg);
}

/**
*	Whenever wanting to pass a callback to Javascript, call this function instead.
*	This function is not expected to meet usercode. But it will stay here nevertheless. 
*/
ubyte* sendJSFunction(alias fn)()
{
	import std.traits;
	static ubyte* function(ubyte* arg) convertedFunc  = (ubyte* arg)
	{
		Arguments!fn params = wasmParametersFromUbyte!fn(validateArguments!fn(arg));
		static if(!is(ReturnType!fn == void))
			return fn(params.tupleof);
		else
		{
			fn(params.tupleof);
			return null;
		}
	};
	size_t addr = _getFuncAddress(cast(ubyte*)fn);
	if(addr >= _annonymousFunctionTable.length) _annonymousFunctionTable.length = addr+1;
	_annonymousFunctionTable[addr] = convertedFunc;

	return cast(ubyte*)fn;
}


struct JSDelegate
{
	ubyte* funcHandle;
	ubyte* funcptr;
	ubyte* ctx;
}

alias JSStringType = AliasSeq!(size_t, void*);

struct JSString
{
	size_t length;
	void* ptr;
	this(string str)
	{
		length = str.length;
		ptr = cast(void*)str.ptr;
	}
}

alias JSDelegateType(T) = AliasSeq!(ubyte*, ubyte*, ubyte*);

JSDelegate sendJSDelegate(alias dg)()
{
	import std.traits;
	auto convertedFunc = toFunc!dg;
	size_t addr = _getFuncAddress(cast(ubyte*)convertedFunc);
	if(addr >= _annonymousFunctionTable.length) _annonymousFunctionTable.length = addr+1;
	_annonymousFunctionTable[addr] = convertedFunc;


	return JSDelegate(cast(ubyte*)addr, cast(ubyte*)dg.funcptr, cast(ubyte*)dg.ptr);
}



///Generates a delegate which adds the `this` context from the arguments.
ubyte* function(ubyte* args) toFunc(alias dg)()
{
	import std.traits;
	import hip.wasm;
	alias Params = Parameters!dg;
	alias DgArgs = Arguments!dg;
	enum Length = DgArgs.tupleof.length;
	alias Ret = ReturnType!dg;

	static ubyte* function(ubyte* arg) ret = (ubyte* arg)
	{
		size_t argsCount = *cast(size_t*)arg;
		assert(argsCount >= 2, "D delegates expects at least 2 arguments [Function Pointer, Function Context]");
		assert(argsCount - 2 <= Length, "Expected "~Length.stringof~" parameters.");
		size_t[3] baseArgs = (cast(size_t*)arg)[0..3];

		static DgArgs delegateArguments;
		static if(Length > 0)
			delegateArguments = loadMemoryInStruct!DgArgs(arg + size_t.sizeof*3);
		
		static if(Length > 0) 
		{
			static if(is(Ret == void))
				void delegate(Params) dg;
			else
				ubyte* delegate(Params) dg;
		}
		else
		{
			static if(is(Ret == void))
				void delegate() dg;
			else
				ubyte* delegate() dg;
		}
		
		dg.funcptr = cast(typeof(dg.funcptr))baseArgs[1];
		dg.ptr = cast(void*)baseArgs[2];

		static if(Length > 0)
		{
			static if(is(Ret == void))
			{
				dg(delegateArguments.tupleof);
				return null;
			} else return dg(delegateArguments.tupleof);
		}
		else
		{
			static if(is(Ret == void))
			{
				dg();
				return null;
			} else return dg();
		}
	};
	return ret;
}



ubyte[] getWasmBinary(ubyte* input)
{
	size_t length = *cast(size_t*)input;
	ubyte[] ret = (input+size_t.sizeof)[0..length];
	return ret;
}

void freeWasmBinary(ubyte[] binary)
{
	ubyte* ptr = binary.ptr - size_t.sizeof;
	object.free(ptr);
}