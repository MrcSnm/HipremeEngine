// D import file generated from 'source\hip\util\conv.d'
module hip.util.conv;
import hip.util.string;
import std.typecons;
import std.traits : isArray;
pure nothrow @safe string toString(dstring dstr);
pure nothrow @safe string toString(T)(T[] arr)
{
	string ret = "[";
	for (int i = 0;
	 i < arr.length; i++)
	{
		{
			if (i)
				ret ~= ",";
			ret ~= toString(arr[i]);
		}
	}
	return ret ~ "]";
}
void toStringRange(Sink, T)(auto ref Sink sink, T[] arr) if (isOutputRange!(Sink, char) && !is(T[] == string))
{
	put(sink, '[');
	static if (__traits(compiles, sink.preAllocate))
	{
		sink.preAllocate(2 * arr.length);
	}

	for (int i = 0;
	 i < arr.length; i++)
	{
		{
			if (i != 0)
			{
				foreach (character; " ")
				{
					put(sink, character);
				}
			}
			toStringRange(sink, arr[i]);
		}
	}
	put(sink, ']');
}
pure nothrow @safe string toString(T)(T structOrTuple) if (!isArray!T)
{
	static if (isTuple!T)
	{
		alias tupl = structOrTuple;
		string ret;
		foreach (i, v; tupl)
		{
			if (i > 0)
				ret ~= ", ";
			ret ~= to!string(v);
		}
		return T.stringof ~ "(" ~ ret ~ ")";
	}
	else
	{
		static if (is(T == struct))
		{
			alias struct_ = structOrTuple;
			string s = "(";
			static foreach (i, alias m; T.tupleof)
			{
				if (i > 0)
					s ~= ", ";
				s ~= toString(struct_.tupleof[i]);
			}
			return T.stringof ~ s ~ ")";
		}
		else
		{
			static assert(0, "Not implemented for " ~ T.stringof);
		}
	}
}
void toStringRange(Sink, T)(auto ref Sink sink, T structOrTuple) if (!isArray!T && (is(T == struct) || isTuple!T))
{
	static if (isTuple!T)
	{
		alias tupl = structOrTuple;
		put(sink, T.stringof);
		put(sink, '(');
		foreach (i, v; tupl)
		{
			if (i > 0)
				put(sink, ", ");
			toStringRange(sink, v);
		}
		put(sink, ')');
	}
	else
	{
		static if (is(T == struct))
		{
			alias struct_ = structOrTuple;
			put(sink, T.stringof);
			put(sink, '(');
			static foreach (i, alias m; T.tupleof)
			{
				if (i > 0)
					put(sink, ", ");
				toStringRange(sink, struct_.tupleof[i]);
			}
			put(sink, ')');
		}
		else
		{
			static assert(0, "Not implemented for " ~ T.stringof);
		}
	}
}
string dumpStructToString(T)(T struc) if (is(T == struct))
{
	string s = "\n(";
	static foreach (i, alias m; T.tupleof)
	{
		s ~= "\n\t " ~ m.stringof ~ ": ";
		s ~= toString(struc.tupleof[i]);
	}
	return T.stringof ~ s ~ "\n)";
}
pure nothrow T toStruct(T)(string struc)
{
	T ret;
	string[] each;
	string currentArg;
	bool isInsideString = false;
	for (ulong i = 1;
	 i < cast(int)struc.length - 1; i++)
	{
		{
			if (!isInsideString && (struc[i] == ','))
			{
				each ~= currentArg;
				currentArg = null;
				if (struc[i + 1] == ' ')
					i++;
				continue;
			}
			else if (struc[i] == '"')
			{
				isInsideString = !isInsideString;
				continue;
			}
			currentArg ~= struc[i];
		}
	}
	if (currentArg.length != 0)
		each ~= currentArg;
	static foreach (i, m; __traits(allMembers, T))
	{
		{
			alias member = __traits(getMember, ret, m);
			member = to!(typeof(member))(each[i]);
		}
	}
	return ret;
}
pure nothrow @nogc @safe bool toBool(string str);
pure nothrow @nogc @safe string toString(string str);
void toStringRange(Sink)(auto ref Sink sink, string str) if (isOutputRange!(Sink, char))
{
	static if (__traits(compiles, sink.preAllocate))
	{
		sink.preAllocate(str.length);
	}

	foreach (character; str)
	{
		put(sink, character);
	}
}
void toStringRange(Sink)(auto ref Sink sink, const(char)* str) if (isOutputRange!(Sink, char))
{
	import core.stdc.string : strlen;
	size_t length = strlen(str);
	static if (__traits(compiles, sink.preAllocate))
	{
		sink.preAllocate(length);
	}

	for (int i = 0;
	 i < length; i++)
	{
		put(sink, str[i]);
	}
}
void toStringRange(Sink)(auto ref Sink sink, void* ptr) if (isOutputRange!(Sink, char))
{
	toHex(sink, cast(size_t)ptr);
}
pure nothrow @nogc @safe string toString(bool b);
void toStringRange(Sink)(auto ref Sink sink, bool b) if (isOutputRange!(Sink, char))
{
	if (b)
	{
		static if (__traits(compiles, sink.preAllocate))
		{
			sink.preAllocate("true".length);
		}

		put(sink, "true");
	}
	else
	{
		static if (__traits(compiles, sink.preAllocate))
		{
			sink.preAllocate("false".length);
		}

		put(sink, "false");
	}
}
pure nothrow TO to(TO, FROM)(FROM f)
{
	static if (is(TO == string))
	{
		static if (is(FROM == const(char)*) || is(FROM == char*))
		{
			return fromStringz(f);
		}
		else
		{
			return toString(f);
		}
	}
	else
	{
		static if (is(TO == int))
		{
			static if (!is(FROM == string))
			{
				return toInt(f.toString);
			}
			else
			{
				return toInt(f);
			}
		}
		else
		{
			static if (is(TO == uint) || is(TO == ulong) || is(TO == ubyte) || is(TO == ushort))
			{
				static if (!is(FROM == string))
				{
					return cast(TO)toInt(f.toString);
				}
				else
				{
					return cast(TO)toInt(f);
				}
			}
			else
			{
				static if (is(TO == float))
				{
					static if (!is(FROM == string))
					{
						return toFloat(f.toString);
					}
					else
					{
						return toFloat(f);
					}
				}
				else
				{
					static if (is(TO == bool))
					{
						static if (!is(FROM == string))
						{
							return toBool(f.toString);
						}
						else
						{
							return toBool(f);
						}
					}
					else
					{
						static if (!is(FROM == string))
						{
							return toStruct!TO(f.toString);
						}
						else
						{
							return toStruct!TO(f);
						}
					}
				}
			}
		}
	}
}
export pure nothrow @safe string toString(int x);
import std.range.interfaces;
import std.range.primitives;
import std.range : put;
void toStringRange(Sink)(auto ref Sink sink, int x) if (isOutputRange!(Sink, char))
{
	enum numbers = "0123456789";
	int preAllocSize = 0;
	bool isNegative = x < 0;
	if (isNegative)
	{
		x *= -1;
		preAllocSize++;
	}
	ulong div = 10;
	while (div <= x)
	{
		div *= 10;
		preAllocSize++;
	}
	div /= 10;
	static if (__traits(hasMember, sink, "preAllocate"))
	{
		sink.preAllocate(preAllocSize);
	}

	if (isNegative)
		put(sink, '-');
	while (div >= 10)
	{
		put(sink, numbers[x / div % 10]);
		div /= 10;
	}
	put(sink, numbers[x % 10]);
}
export pure nothrow @safe string toString(float f);
void toStringRange(Sink)(auto ref Sink sink, float f)
{
	if (f != f)
	{
		static if (__traits(hasMember, sink, "preAllocate"))
		{
			sink.preAllocate("nan".length);
		}

		foreach (v; "nan")
		{
			put(sink, v);
		}
		return ;
	}
	if (f == (float).infinity)
	{
		static if (__traits(hasMember, sink, "preAllocate"))
		{
			sink.preAllocate("inf".length);
		}

		foreach (v; "inf")
		{
			put(sink, v);
		}
		return ;
	}
	if (f < 0)
	{
		f = -f;
		put(sink, '-');
	}
	float decimal = f - cast(int)f;
	toStringRange(sink, cast(int)f);
	if (decimal == 0)
		return ;
	while (cast(int)decimal != decimal)
	decimal *= 10;
	put(sink, '.');
	toStringRange(sink, cast(int)decimal);
}
void toHex(Sink)(auto ref Sink sink, size_t n) if (isOutputRange!(Sink, char))
{
	enum numbers = "0123456789ABCDEF";
	int preAllocSize = 1;
	size_t div = 16;
	while (div <= n)
	{
		div *= 16;
		preAllocSize++;
	}
	div /= 16;
	static if (__traits(hasMember, sink, "preAllocate"))
	{
		sink.preAllocate(preAllocSize);
	}

	while (div >= 16)
	{
		put(sink, numbers[n / div % 16]);
		div /= 16;
	}
	put(sink, numbers[n % 16]);
}
string toHex(size_t n);
pure nothrow string fromUTF16(wstring str);
pure nothrow @nogc @safe int toInt(string str);
pure nothrow @nogc @safe float toFloat(string str);
