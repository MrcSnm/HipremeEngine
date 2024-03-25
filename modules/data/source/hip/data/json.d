module hip.data.json;

JSONValue parseJSON(string jsonData)
{
    return JSONValue.parse(jsonData);
}
struct JSONArray
{
	private JSONValue[] value;
	size_t length;

	this(JSONValue[] v)
	{
		this.value = v;
		this.length = v.length;
	}

	ref JSONArray append(JSONValue v)
	{
		if(length >= value.length)
			value~= v;
		else
			value[length] = v;
		length++;
		return this;
	}
	static JSONArray* createNew()
	{
		import std.array;
		JSONArray* ret = new JSONArray([]);
		ret.value = uninitializedArray!(JSONValue[])(8);
		return ret;
	}

	JSONValue[] getArray(){return value[0..length];}
}
struct JSONObject
{
	JSONValue[string] value;

	alias value this;
}
private enum JSONState
{
	key,
	lookingAssignment,
	lookingForNext,
	value
}

enum JSONType
{
	bool_,
	float_,
	int_, integer = int_, uinteger = int_,
	string_, string = string_,
	array,
	object,
	null_
}

pragma(inline, true)
bool isWhitespace(char ch)
{
	switch(ch)
	{
		case ' ', '\t', '\n', '\r': return true;
		default: return false;
	}
}

pragma(inline, true) bool isNumber(char ch){return ch >= '0' && ch <= '9';}
pragma(inline, true) bool isNumeric(char ch){return (ch >= '0' && ch <= '9') || ch == '-' || ch == '.';}

struct JSONValue
{
	union JSONData{

		double _float;
		long _int;
		bool _bool;
		string _string;
		JSONObject* object;
		JSONArray* array;
	}
	JSONData data;
	string key;
	string error;
	JSONType type = JSONType.object;

	this(T)(T value)
	{
		import std.traits;
		static if(isIntegral!T)
		{
			type = JSONType.int_;
			data._int = value;
		}
		else static if(isFloatingPoint!T)
		{
			type = JSONType.float_;
			data._float = value;
		}
		else static if(is(T == bool))
		{
			type = JSONType.bool_;
			data._bool = value;
		}
		else static if(is(T == string))
		{
			type = JSONType.string_;
			data._string = value;
		}
		else static if(is(T == JSONObject*))
		{
			type = JSONType.object;
			data.object = value;
		}
		else static if(is(T == JSONArray*))
		{
			type = JSONType.array;
			data.array = value;
		}
		else static if(is(T == JSONValue[]))
		{
			data.array = new JSONArray(value);
			type = JSONType.array;
		}
		else static if(is(T == JSONValue))
		{
			type = value.type;
			data = value.data;
		}
		else static if(is(T == typeof(null)))
		{
			data.object = null;
			type = JSONType.null_;
		}
		else static assert(false, "Unsupported type ", T);
	}

    int integer() const {return get!int;}
    bool boolean() const {return get!bool;}
    string str() const {return get!string;}
    ///Returns an array range.
    auto array() const
    {
        assert(type == JSONType.array, "Tried to iterate a non array object of type "~getTypeName);
        struct JSONValueArrayIterator
        {
            private const(JSONArray*) arr;
            private size_t idx = 0;
            size_t length(){return arr.length;}
            bool empty(){return idx == arr.length;}
            void popFront(){idx++;}
            JSONValue front(){return arr.value[idx];}
            JSONValue opIndex(size_t num){return arr.value[num];}
        }
        return JSONValueArrayIterator(data.array);
    }

	JSONValue[] array()
	{
		assert(type == JSONType.array, "Tried to iterate a non array object of type "~getTypeName);
		return data.array.getArray;
	}

    JSONValue object()
    {
        assert(type == JSONType.object, "Tried to get type object but value is of type "~getTypeName); 
		JSONValue ret;
		ret.data = data;
		ret.error = error;
		ret.key = key;
		ret.type = JSONType.object;
        return ret;
    }

	string getTypeName() const
	{
		final switch(type) with(JSONType)
		{
			case int_: return "int";
			case bool_: return "bool";
			case float_: return "float";
			case string_: return "string";
			case object: return "object";
			case array: return "array";
			case null_: return "null";
		}
	}

	T get(T)() const
	{
		import std.traits;

		static if(isIntegral!T)
		{
			assert(type == JSONType.int_, "Tried to get type "~T.stringof~" but value is of type "~getTypeName);
			return cast(Unqual!T)data._int;
		}
		else static if(isFloatingPoint!T)
		{
			assert(type == JSONType.float_, "Tried to get type "~T.stringof~" but value is of type "~getTypeName);
			return cast(Unqual!T)data._float;
		}
		else static if(is(T == bool))
		{
			assert(type == JSONType.bool_, "Tried to get type "~T.stringof~" but value is of type "~getTypeName);
			return cast(Unqual!T)data._bool;
		}
		else static if(is(T == string))
		{
			assert(type == JSONType.string_, "Tried to get type "~T.stringof~" but value is of type "~getTypeName);
			return data._string;
		}
		else static if(is(T == JSONObject))
		{
			assert(type == JSONType.object, "Tried to get type "~T.stringof~" but value is of type "~getTypeName);
			return *data.object;
		}
		else static if(is(T == JSONArray))
		{
			assert(type == JSONType.array, "Tried to get type "~T.stringof~" but value is of type "~getTypeName);
			return *data.array;
		}
	}
	bool isNull()
	{
		with(JSONType)
		{
			if(type == null_) return true;
			if(type == JSONType.object) return data.object == null;
			if(type == JSONType.array) return data.array == null;
		}
		return false;
	}

	static JSONValue emptyObject()
	{
		JSONValue ret;
		ret.type = JSONType.object;
		ret.data.object = new JSONObject();
		return ret;
	}

	private static JSONValue create(T)(T data, string key)
	{
		JSONValue ret = JSONValue(data);
		ret.key = key;
		return ret;
	}
	private static JSONValue errorObj(string message)
	{
		JSONValue ret;
		ret.error = message;
		return ret;
	}


	private static JSONValue parse(string data)
	{
		import core.memory;
		
		import hip.util.conv:to;
		if(!data.length)
		{
			return JSONValue.errorObj("No data provided");
		}
		ptrdiff_t index = 0;
		while(index < data.length && data[index++] != '{'){}
		if(index == data.length)
		{
			return JSONValue.errorObj("Valid JSON starts with a '{'.");
		}

		bool getNextString(string data, ptrdiff_t currentIndex, out ptrdiff_t newIndex, out string theString)
		{
			import std.array;
			assert(data[currentIndex] == '"');
			ptrdiff_t i = currentIndex + 1;
			size_t returnLength = 0;
			char[] ret = uninitializedArray!(char[])(128);
			char ch;
			
			LOOP: while(i < data.length)
			{
				ch = data[i];
				switch(ch)
				{
					case '"': break LOOP;
					case '\\': i++; goto default;
					default:
						if(returnLength >= ret.length)
							ret.length*= 2;
						ret[returnLength++] = ch;
						break;
				}
				i++;
			}
			ret.length = returnLength;
			newIndex = i;
			if(newIndex == data.length) //Not found
				return false;
			theString = cast(string)ret;
			return true;
		}


		bool getNextNumber(string data, ptrdiff_t currentIndex, out ptrdiff_t newIndex, out JSONData theData, out JSONType type)
		{
			assert(data[currentIndex].isNumeric);
			bool hasDecimal = false;
			newIndex = currentIndex;
			if(data[currentIndex] == '-')
				newIndex++;
			if(data[newIndex] == '.')
			{
				hasDecimal = true;
				newIndex++;
			}

			while(newIndex < data.length)
			{
				if(!hasDecimal && data[newIndex] == '.')
				{
					if(!hasDecimal) hasDecimal = true;
					if(newIndex+1 < data.length) newIndex++;
				}
				if(isNumber(data[newIndex]))
					newIndex++;
				else 
					break;
			}
			if(hasDecimal)
			{
				theData._float = to!double(data[currentIndex..newIndex]);
				type = JSONType.float_;
			}
			else
			{
				theData._int = to!long(data[currentIndex..newIndex]);
				type = JSONType.int_;
			}
			//Stopped on a non number. Revert 1 step.
			newIndex--;
			return newIndex < data.length;
		}
		JSONValue ret;
		ret.data.object = new JSONObject();
		JSONValue* current = &ret;
		JSONState state = JSONState.lookingForNext;
		JSONValue lastValue = ret;

		import std.array;
		scope JSONValue[] stack = uninitializedArray!(JSONValue[])(128);
		stack[0] = ret;
		scope ptrdiff_t stackLength = 1;

		void pushNewScope(JSONValue val)
		{
			assert(val.type == JSONType.object || val.type == JSONType.array, "Unexpected push.");
			JSONValue* currTemp = current;

			stackLength++;
			if(stackLength > stack.length)
				stack~= val;
			else
				stack[stackLength-1] = val;

			current = &stack[stackLength-1];

			if(currTemp.type == JSONType.object)
				currTemp.data.object.value[val.key] = *current;
			else
				currTemp.data.array.append(*current);

		}
		void popScope()
		{
			assert(stackLength > 0, "Unexpected pop.");
			
			stackLength--;
			if(stackLength > 0)
			{
				current = &stack[stackLength-1];
				assert(current.type == JSONType.object || current.type == JSONType.array, "Unexpected value in stack. (Typed "~(cast(size_t)(current.type)).to!string);
			}
		}

		void pushToStack(JSONValue val)
		{
			switch(current.type) with(JSONType)
			{
				case object:
					current.data.object.value[val.key] = val;
					break;
				case array:
					current.data.array.append(val);
					break;
				default: assert(false, "Unexpected stack type: "~current.getTypeName);
			}
			lastValue = val;
		}

		size_t line = 0;
		string getErr(string err="", string f = __FILE_FULL_PATH__, size_t l = __LINE__)
		{
			return "Error at line "~line.to!string~" "~err~" on index '"~index.to!string~"' last parsed: "~lastValue.toString~" [Internal: "~f~":"~l.to!string~"]";
		}

		string lastKey;
		do
		{
			char ch = data[index];
			switch(ch)
			{
				case '\n': 
					line++;
					break;
				case '{':
				{
					if(state != JSONState.value)
						return JSONValue.errorObj(getErr());
					JSONValue obj = JSONValue.create(new JSONObject(), lastKey);
					pushNewScope(obj);

					state = JSONState.key;
					break;
				}
				case '}':
					popScope();
					state = JSONState.lookingForNext;
					break;
				case ':':
					if(state != JSONState.lookingAssignment)
						return JSONValue.errorObj(getErr("expected key before ':'"));
					state = JSONState.value;
					break;
				case '"':
				{

					switch(state)
					{
						case JSONState.lookingForNext:
							if(current.type == JSONType.object)
								goto case JSONState.key;
							else if(current.type == JSONType.array)
								goto case JSONState.value;
							goto default;
						case JSONState.key:
						{
							assert(current.type == JSONType.object, getErr("only object can receive a key."));
							if(!getNextString(data, index, index, lastKey))
								return JSONValue.errorObj(getErr("unclosed quotes."));
							JSONValue keyJson;
							keyJson.key = lastKey;
							pushToStack(keyJson);
							state = JSONState.lookingAssignment;
							break;
						}
						case JSONState.value:
						{
							string val;
							if(!getNextString(data, index, index, val))
								return JSONValue.errorObj(getErr("unclosed quotes."));
							pushToStack(JSONValue.create!string(val, lastKey));
							state = JSONState.lookingForNext;
							break;
						}
						default:
							return JSONValue.errorObj(getErr("comma expected before key "~lastValue.key));
					}
					break;
				}
				case '[':
				{
					if(state != JSONState.lookingForNext && state != JSONState.value)
						return JSONValue.errorObj(getErr(" expected to be a value. "));
					pushNewScope(JSONValue.create(JSONArray.createNew(), lastKey));
					state = JSONState.value;
					break;
				}
				case ']':
					if(state != JSONState.lookingForNext && state != JSONState.value)
						return JSONValue.errorObj(getErr("expected to be a value. "));
					popScope();
					state = JSONState.lookingForNext;
					break;
				case ',':
					if(state != JSONState.lookingForNext)
						return JSONValue.errorObj(getErr("unexpected comma. "));
					if(current.type != JSONType.object && current.type != JSONType.array)
						return JSONValue.errorObj(getErr("unexpected comma. "));

					switch(current.type) with(JSONType)
					{
						case object: state = JSONState.key; break;
						case array: state = JSONState.value; break;
						default: assert(false, "Error?");
					}
					break;
				default:
					switch(state)
					{
						case JSONState.value: //Any value
							if(ch.isNumeric)
							{
								if(!getNextNumber(data, index, index, lastValue.data, lastValue.type))
									return JSONValue.errorObj(getErr("unexpected end of file."));
								pushToStack(lastValue);
								state = JSONState.lookingForNext;
							}
							else if(index + "true".length < data.length && data[index.."true".length + index] == "true")
							{
								pushToStack(JSONValue.create!bool(true, lastKey));
								state = JSONState.lookingForNext;
							}
							else if(index + "false".length < data.length && data[index.."false".length + index] == "false")
							{
								pushToStack(JSONValue.create!bool(false, lastKey));
								state = JSONState.lookingForNext;
							}
							else if(index + "null".length < data.length && data[index.."null".length + index] == "null")
							{
								pushToStack(JSONValue.create(null, lastKey));
								state = JSONState.lookingForNext;
							}
							break;
						case JSONState.lookingForNext: //Array
							if(ch.isNumeric)
							{
								if(current.type != JSONType.array)
									return JSONValue.errorObj(getErr("unexpected number."));
								if(!getNextNumber(data, index, index, lastValue.data, lastValue.type))
									return JSONValue.errorObj(getErr("unexpected end of file."));
								pushToStack(lastValue);
								state = JSONState.lookingForNext;
							}
							else if(index + "true".length < data.length && data[index.."true".length + index] == "true")
							{
								if(current.type != JSONType.array)
									return JSONValue.errorObj(getErr("unexpected number."));
								pushToStack(JSONValue.create!bool(true, lastKey));
								state = JSONState.lookingForNext;
							}
							else if(index + "false".length < data.length && data[index.."false".length + index] == "false")
							{
								if(current.type != JSONType.array)
									return JSONValue.errorObj(getErr("unexpected number."));
								pushToStack(JSONValue.create!bool(false, lastKey));
								state = JSONState.lookingForNext;
							}
							break;
						default:break;
					}
					break;
			}
			index++;
		}
		while(index < data.length && stack.length > 0);
		return ret;
	}

	JSONValue opIndex(string key) const
	{
		assert(type == JSONType.object, "Can't get a member from a non object.");
		return (*data.object)[key];
	}
	JSONValue opIndexAssign(JSONValue v, string key)
	{
		assert(type == JSONType.object, "Can't get a member from a non object.");
		assert(data.object !is null, "Can't access a null object");
		(*data.object)[key] = v;
		v.key = key;
		return (*data.object)[key];
	}

	const(JSONValue)* opBinaryRight(string op)(string key) const
	if(op == "in")
	{
		if(type != JSONType.object)	return null;
		return key in *(data.object).value;
	}
    JSONValue* opBinaryRight(string op)(string key)
	if(op == "in")
	{
		if(type != JSONType.object)	return null;
		return key in (*data.object).value;
	}

    int opApply(scope int delegate(string key, JSONValue v) dg)
    {
        if(type != JSONType.object)
        {
            assert(false, "Can't iterate with key[string] and value[JSONValue] an object of type "~getTypeName);
        }
        int result = 0;
        foreach (k, v ; data.object.value)
        {
            result = dg(k, v);
            if (result)
                break;
        }
    
        return result;
    }
	bool hasErrorOccurred(){ return error.length != 0; }

	//selfPrintKey is only used for object.
	string toString(bool selfPrintkey = false)
	{
		if(hasErrorOccurred)
			return error;
		import hip.util.conv:to;
		string ret;

		static string escapeBackSlashes(string input)
		{
			size_t length = input.length;
			foreach(ch; input)
				if(ch == '\\') length++;
			if(length == input.length) return input;
			char[] escaped = new char[](length);
			length = 0;
			foreach(i; 0..input.length)
			{
				if(input[i] == '\\')
				{
					escaped[length] = '\\';
					escaped[++length] = '\\';
				}
				else
					escaped[length] = input[i];
				length++;
			}
			return cast(string)escaped;
		}

		final switch ( type )
		{
			case JSONType.int_:
				ret = data._int.to!(string);
				break;
			case JSONType.float_:
				ret = data._float.to!string;
				break;
			case JSONType.bool_:
				ret = data._bool ? "true" : "false";
				break;
			case JSONType.string_:
				ret = '"'~escapeBackSlashes(data._string)~'"';
				break;
			case JSONType.null_:
				ret = "null";
				break;
			case JSONType.array:
			{
				ret = "[";
				bool isFirst = true;
				foreach(v; data.array.getArray)
				{
					if(!isFirst)
						ret~=", ";
					isFirst = false;
					ret~= v.toString(false);
				}
				ret~= "]";
				break;
			}
			case JSONType.object:
			{
				if(selfPrintkey)
				{
					ret = '"'~escapeBackSlashes(key)~"\": ";
				}
				ret~= '{';
				bool isFirst = true;
				foreach(k, v; data.object.value)
				{
					if(!isFirst)
						ret~= ", ";
					isFirst = false;
					ret~= '"'~escapeBackSlashes(k)~"\" : "~v.toString(false);
				}
				ret~= '}';
				break;

			}
		}
		return ret;
	}

    void dispose()
    {
        if(type == JSONType.object)
        {
            foreach(v; data.object.value)
                v.dispose();
        }
        else if(type == JSONType.array)
        {
            foreach(v; data.array.value)
                v.dispose();
        }
        
    }
}