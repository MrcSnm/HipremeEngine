module hip.data.json;


JSONValue parseJSON(string jsonData)
{
    return JSONValue.parse(jsonData);
}
struct JSONArray
{
	JSONValue[] value;
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
	int_,
	string_,
	array,
	object
}

bool isWhitespace(char ch){return ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r';}
bool isNumber(char ch){return ch >= '0' && ch <= '9';}
bool isNumeric(char ch){return (ch >= '0' && ch <= '9') || ch == '-' || ch == '.';}

struct JSONValue
{
	union JSONData{

		float _float;
		int _int;
		bool _bool;
		string _string;
		JSONObject* object;
		JSONArray* array;
	}
	JSONData data;
	string key;
	string error;
	JSONType type = JSONType.object;

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
            size_t length(){return arr.value.length;}
            bool empty(){return idx == arr.value.length;}
            void popFront(){idx++;}
            JSONValue front(){return arr.value[idx];}
        }
        return JSONValueArrayIterator(data.array);
    }

    JSONValue object()
    {
        assert(type == JSONType.object, "Tried to get type object but value is of type "~getTypeName);
        return JSONValue(data, key, error, JSONType.object);
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
		}
	}

	T get(T)() const
	{
		static if(is(T == int))
		{
			assert(type == JSONType.int_, "Tried to get type "~T.stringof~" but value is of type "~getTypeName);
			return data._int;
		}
		else static if(is(T == float))
		{
			assert(type == JSONType.float_, "Tried to get type "~T.stringof~" but value is of type "~getTypeName);
			return data._float;
		}
		else static if(is(T == bool))
		{
			assert(type == JSONType.bool_, "Tried to get type "~T.stringof~" but value is of type "~getTypeName);
			return data._bool;
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
	private static JSONValue create(T)(T data, string key)
	{
		JSONValue ret;
		ret.key = key;
		static if(is(T == int))
		{
			ret.type = JSONType.int_;
			ret.data._int = data;
		}
		else static if(is(T == float))
		{
			ret.type = JSONType.float_;
			ret.data._float = data;
		}
		else static if(is(T == bool))
		{
			ret.type = JSONType.bool_;
			ret.data._bool = data;
		}
		else static if(is(T == string))
		{
			ret.type = JSONType.string_;
			ret.data._string = data;
		}
		else static if(is(T == JSONObject*))
		{
			ret.type = JSONType.object;
			ret.data.object = data;
		}
		else static if(is(T == JSONArray*))
		{
			ret.type = JSONType.array;
			ret.data.array = data;
		}
		else static assert(false, "Unsupported type "~T.stringof);
		return ret;
	}


	private static JSONValue parse(string data)
	{
		import hip.util.conv:to;
		if(!data.length)
		{
			return JSONValue(JSONData.init, "", "No data provided");
		}
		ptrdiff_t index = 0;
		while(index < data.length && data[index++] != '{'){}
		if(index == data.length)
		{
			return JSONValue(JSONData.init, "", "Valid JSON starts with a '{'.");
		}

		bool getNextString(string data, ptrdiff_t currentIndex, out ptrdiff_t newIndex, out string theString)
		{
			assert(data[currentIndex] == '"');
			newIndex = currentIndex+1;
			while(newIndex < data.length && data[newIndex] != '"')
			{
				if(data[newIndex] == '\\')
					newIndex++;
				newIndex++;
			}
			if(newIndex == data.length) //Not found
				return false;
			theString = data[currentIndex+1..newIndex]; //Assign output
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
				theData._float = to!float(data[currentIndex..newIndex]);
				type = JSONType.float_;
			}
			else
			{
				theData._int = to!int(data[currentIndex..newIndex]);
				type = JSONType.int_;
			}
			//Stopped on a non number. Revert 1 step.
			newIndex--;
			return newIndex < data.length;
		}

		data = data[1..$];
		JSONValue ret;
		ret.data.object = new JSONObject();
		JSONValue* current = &ret;
		JSONState state = JSONState.lookingForNext;
		JSONValue lastValue = ret;

		scope JSONValue[] stack = [ret];
		void pushNewScope(JSONValue val)
		{
			assert(val.type == JSONType.object || val.type == JSONType.array, "Unexpected push.");
			JSONValue* currTemp = current;
			stack~= val;
			current = &stack[$-1];
			if(currTemp.type == JSONType.object)
				currTemp.data.object.value[val.key] = *current;
			else
				currTemp.data.array.value~= *current;
		}
		void popScope()
		{
			assert(stack.length > 0, "Unexpected pop.");
			stack = stack[0..$-1];
			if(stack.length > 0)
				current = &stack[$-1];
		}

		void pushToStack(JSONValue val)
		{
			switch(current.type) with(JSONType)
			{
				case object:
					current.data.object.value[val.key] = val;
					break;
				case array:
					current.data.array.value~= val;
					break;
				default: assert(false, "Unexpected stack type: "~current.getTypeName);
			}
			lastValue = val;
		}

		size_t line = 0;

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
						return JSONValue(JSONData.init, "", "Error at line "~line.to!string);
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
						return JSONValue(JSONData.init, "", "Error at line "~line.to!string~" expected key before ':'");
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
							assert(current.type == JSONType.object, "Error at line "~line.to!string~" only object can receive a key.");
							if(!getNextString(data, index, index, lastKey))
								return JSONValue(JSONData.init, "", "Error at line"~line.to!string~" unclosed quotes.");
							pushToStack(JSONValue(JSONData.init, lastKey));
							state = JSONState.lookingAssignment;
							break;
						}
						case JSONState.value:
						{
							string val;
							if(!getNextString(data, index, index, val))
								return JSONValue(JSONData.init, "", "Error at line"~line.to!string~" unclosed quotes.");
							pushToStack(JSONValue.create!string(val, lastKey));
							state = JSONState.lookingForNext;
							break;
						}
						default:
							return JSONValue(JSONData.init, "", "Error at line "~line.to!string~" comma expected before key "~lastValue.toString);
					}
					break;
				}
				case '[':
				{
					if(state != JSONState.lookingForNext && state != JSONState.value)
						return JSONValue(JSONData.init, "", "Error at line "~line.to!string~" expected to be a value. "~lastValue.toString);
					pushNewScope(JSONValue.create(new JSONArray(), lastKey));
					state = JSONState.value;
					break;
				}
				case ']':
					if(state != JSONState.lookingForNext && state != JSONState.value)
						return JSONValue(JSONData.init, "", "Error at line "~line.to!string~" expected to be a value. "~lastValue.toString);
					popScope();
					state = JSONState.lookingForNext;
					break;
				case ',':
					if(state != JSONState.lookingForNext)
						return JSONValue(JSONData.init, "", "Error at line "~line.to!string~" unexpected comma.");
					if(current.type != JSONType.object && current.type != JSONType.array)
						return JSONValue(JSONData.init, "", "Error at line "~line.to!string~" unexpected comma.");

					switch(current.type) with(JSONType)
					{
						case object: state = JSONState.key; break;
						case array: state = JSONState.lookingForNext; break;
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
									return JSONValue(JSONData.init, "", "Error at line "~line.to!string~" unexpected end of file.");
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

							break;
						case JSONState.lookingForNext: //Array
							if(ch.isNumeric)
							{
								if(current.type != JSONType.array)
									return JSONValue(JSONData.init, "", "Error at line "~line.to!string~" unexpected number.");
								if(!getNextNumber(data, index, index, lastValue.data, lastValue.type))
									return JSONValue(JSONData.init, "", "Error at line "~line.to!string~" unexpected end of file.");
								pushToStack(lastValue);
								state = JSONState.lookingForNext;
							}
							else if(index + "true".length < data.length && data[index.."true".length + index] == "true")
							{
								if(current.type != JSONType.array)
									return JSONValue(JSONData.init, "", "Error at line "~line.to!string~" unexpected number.");
								pushToStack(JSONValue.create!bool(true, lastKey));
								state = JSONState.lookingForNext;
							}
							else if(index + "false".length < data.length && data[index.."false".length + index] == "false")
							{
								if(current.type != JSONType.array)
									return JSONValue(JSONData.init, "", "Error at line "~line.to!string~" unexpected number.");
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
	const(JSONValue)* opBinaryRight(string op)(string key) const
	if(op == "in")
	{
		if(type != JSONType.object)	return null;
		return key in data.object.value;
	}
    JSONValue* opBinaryRight(string op)(string key)
	if(op == "in")
	{
		if(type != JSONType.object)	return null;
		return key in data.object.value;
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
	string toString(bool selfPrintkey = true)
	{
		import hip.util.conv:to;
		string ret ;
		final switch ( type ) with(JSONType)
		{
			case int_:
				ret = data._int.to!string;
				break;
			case float_:
				ret = data._float.to!string;
				break;
			case bool_:
				ret = data._bool ? "true" : "false";
				break;
			case string_:
				ret = '"'~data._string~'"';
				break;
			case array:
			{
				ret = "[";
				bool isFirst = true;
				foreach(v; data.array.value)
				{
					if(!isFirst)
						ret~=", ";
					isFirst = false;
					ret~= v.toString;
				}
				ret~= "]";
				break;
			}
			case object:
			{
				if(selfPrintkey)
				{
					ret = '"'~key~"\": ";
				}
				ret~= '{';
				bool isFirst = true;
				foreach(k, v; data.object.value)
				{
					if(!isFirst)
						ret~= ", ";
					isFirst = false;
					ret~= '"'~k~"\" : "~v.toString(false);
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