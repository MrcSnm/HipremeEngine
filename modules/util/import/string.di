// D import file generated from 'source\hip\util\string.d'
module hip.util.string;
public import hip.util.conv : to;
struct String
{
	@nogc
	{
		import core.stdc.string;
		import core.stdc.stdlib;
		char* chars;
		size_t length;
		private size_t _capacity;
		private int* countPtr;
		import std.stdio;
		this(this);
		private void initialize(size_t length);
		auto static opCall(const(char)* str)
		{
			String s;
			size_t l = strlen(str);
			s.initialize(l);
			s.length = l;
			memcpy(s.chars, str, l);
			return s;
		}
		auto static opCall(String str)
		{
			return str;
		}
		auto static opCall(string str)
		{
			String s;
			s.initialize(str.length);
			s.length = str.length;
			memcpy(s.chars, str.ptr, s.length);
			return s;
		}
		private enum isAppendable(T) = is(T == String) || is(T == string) || is(T == immutable(char)*) || is(T == char);
		static auto opCall(Args...)(Args args)
		{
			import hip.util.conv : toStringRange;
			String s;
			s.initialize(128);
			static foreach (a; args)
			{
				static if (isAppendable!(typeof(a)))
				{
					s ~= a;
				}
				else
				{
					static if (__traits(hasMember, a, "toString"))
					{
						s ~= a.toString;
					}
					else
					{
						toStringRange(s, a);
					}
				}
			}
			return s;
		}
		alias _opApplyFn = int delegate(char c) @nogc;
		int opApply(scope _opApplyFn dg);
		bool updateBorrowed(size_t length);
		auto ref opOpAssign(string op, T)(T value) if (op == "~")
		{
			size_t l = 0;
			immutable(char)* chs;
			static if (is(T == String))
			{
				l = value.length;
				chs = cast(immutable(char)*)value.chars;
			}
			else
			{
				static if (is(T == string))
				{
					l = cast(size_t)value.length;
					chs = value.ptr;
				}
				else
				{
					static if (is(T == immutable(char)*))
					{
						l = cast(size_t)strlen(value);
						chs = value;
					}
					else
					{
						static if (is(T == char))
						{
							l = 1;
							chs = cast(immutable(char*))&value;
						}
						else
						{
							string temp = to!string(value);
							l = temp.length;
							chs = temp.ptr;
						}
					}
				}
			}
			if (!updateBorrowed(l) && (l + this.length >= this._capacity))
				resize(cast(uint)((l + this.length) * 1.5));
			memcpy(chars + length, chs, l);
			length += l;
			return this;
		}
		auto ref opAssign(string value)
		{
			bool resized = updateBorrowed(value.length);
			if (!resized)
			{
				if (chars == null)
				{
					chars = cast(char*)malloc(value.length);
					_capacity = value.length;
				}
				else if (value.length > _capacity)
					resize(value.length);
			}
			memcpy(chars, value.ptr, value.length);
			length = value.length;
			return this;
		}
		auto ref opAssign(immutable(char)* value)
		{
			size_t l = cast(size_t)strlen(value);
			bool resized = updateBorrowed(l);
			if (!resized)
			{
				if (chars == null)
				{
					chars = cast(char*)malloc(l);
					_capacity = l;
				}
				else if (l > _capacity)
					resize(l);
			}
			length = l;
			memcpy(chars, value, l);
			return this;
		}
		const string opCast();
		const string toString();
		pragma (inline, true)private void resize(size_t newSize);
		void put(char c);
		const bool opEquals(R)(const R other)
		{
			static if (is(R == typeof(null)))
			{
				return chars == null;
			}
			else
			{
				static if (is(R == string))
				{
					return toString == other;
				}
				else
				{
					static if (is(R == String))
					{
						return toString == other.toString;
					}
					else
					{
						static assert(false, "Invalid comparison between String and " ~ R.stringof);
					}
				}
			}
		}
		void preAllocate(uint howMuch);
		void preAllocate(ulong howMuch);
		auto ref opIndex(size_t index)
		{
			assert(index < length, "Index out of bounds");
			return chars[index];
		}
		~this();
	}
}
struct StringBuilder
{
	private char[] builtString;
	private uint builtLength;
	string[] strings;
	private uint stringsPtr = 0;
	void append(T)(T value)
	{
		if (stringsPtr == strings.length)
		{
			if (strings.length == 65536)
				toString();
			else
			{
				strings.length = strings.length == 0 ? 128 : strings.length * 2;
			}
		}
		strings[stringsPtr++] = value;
	}
	string toString();
	auto ref opAssign(T)(T value) if (is(T == string))
	{
		builtString.length = value.length;
		foreach (i, c; s)
		{
			builtString[i] = c;
		}
		stringsPtr = 0;
		builtLength = cast(typeof(builtLength))value.length;
		return this;
	}
	auto ref opOpAssign(string op, T)(T value) if (op == "~")
	{
		import std.traits : isArray;
		static if (isArray!T && !is(T == string))
		{
			foreach (v; value)
			{
				append(v);
			}
		}
		else
		{
			append(value);
		}
		return this;
	}
	auto ref opIndex(size_t index)
	{
		return toString()[index];
	}
	uint length();
	~this();
	alias put = append;
}
pure TString replaceAll(TChar, TString = TChar[])(TString str, TChar what, TString replaceWith = "")
{
	string ret;
	for (int i = 0;
	 i < str.length; i++)
	{
		{
			if (str[i] != what)
				ret ~= str[i];
			else if (replaceWith != "")
				ret ~= replaceWith;
		}
	}
	return ret;
}
pure TString replaceAll(TString)(TString str, TString what, TString replaceWith = "")
{
	TString ret;
	uint z = 0;
	for (uint i = 0;
	 i < str.length; i++)
	{
		{
			while (z < what.length && (str[i + z] == what[z]))
			z++;
			if (z == what.length)
			{
				ret ~= replaceWith;
				i += z;
			}
			z = 0;
			ret ~= str[i];
		}
	}
	return ret;
}
pure nothrow @nogc @safe int indexOf(TString)(in TString str, in TString toFind, int startIndex = 0)
{
	int left = 0;
	if (!toFind.length)
		return -1;
	for (int i = startIndex;
	 i < str.length; i++)
	{
		{
			if (str[i] == toFind[left])
			{
				left++;
				if (left == toFind.length)
					return i + 1 - left;
			}
			else if (left > 0)
				left--;
		}
	}
	return -1;
}
pure nothrow @nogc @trusted int indexOf(TChar)(in TChar[] str, TChar ch, int startIndex = 0)
{
	char[1] temp = [ch];
	return indexOf(str, cast(TChar[])temp, startIndex);
}
TString repeat(TString)(TString str, size_t repeatQuant)
{
	TString ret;
	for (int i = 0;
	 i < repeatQuant; i++)
	{
		ret ~= str;
	}
	return ret;
}
pure nothrow @nogc @safe int count(TString)(in TString str, in TString countWhat)
{
	int ret = 0;
	int index = 0;
	while ((index = str.indexOf(countWhat, index)) != -1)
	{
		index += countWhat.length;
		ret++;
	}
	return ret;
}
alias countUntil = indexOf;
pure nothrow @nogc @safe int lastIndexOf(TString)(in TString str, in TString toFind, int startIndex = -1)
{
	if (startIndex == -1)
		startIndex = cast(int)str.length - 1;
	int maxToFind = cast(int)toFind.length - 1;
	int right = maxToFind;
	if (right < 0)
		return -1;
	for (int i = startIndex;
	 i >= 0; i--)
	{
		{
			if (str[i] == toFind[right])
			{
				right--;
				if (right == -1)
					return i;
			}
			else if (right < maxToFind)
				right++;
		}
	}
	return -1;
}
pure nothrow @nogc @trusted int lastIndexOf(TChar)(TChar[] str, TChar ch, int startIndex = -1)
{
	TChar[1] temp = [ch];
	return lastIndexOf(str, cast(TChar[])temp, startIndex);
}
T toDefault(T)(string s, T defaultValue = T.init)
{
	if (s == "")
		return defaultValue;
	T v = defaultValue;
	try
	{
		v = to!T(s);
	}
	catch(Exception e)
	{
	}
	return v;
}
pure nothrow @nogc string fromStringz(const char* cstr);
pure nothrow const(char*) toStringz(string str);
pragma (inline, true)pure nothrow @nogc @safe char toLowerCase(char c);
string toLowerCase(string str);
pragma (inline, true)enum toUpper(char c)
{
	if (c < 'a' || c > 'z')
		return c;
	return cast(char)(c - ('a' - 'A'));
}
pure nothrow @safe string toUpper(string str);
pure nothrow TChar[][] split(TChar)(TChar[] str, TChar separator)
{
	TChar[1] sep = [separator];
	return split(str, cast(TChar[])sep);
}
pure nothrow @safe TString[] split(TString)(TString str, TString separator)
{
	TString[] ret;
	int last = 0;
	int index = 0;
	do
	{
		index = str.indexOf(separator, index);
		if (index != -1)
		{
			ret ~= str[last..index];
			last = (index += separator.length);
		}
	}
	while (index != -1);
	if (last != 0)
		ret ~= str[last..$];
	return ret;
}
auto pure nothrow @nogc @safe splitRange(TString)(TString str, TString separator)
{
	struct SplitRange
	{
		TString strToSplit;
		TString sep;
		TString frontStr;
		int last;
		int index;
		bool empty();
		TString front();
		void popFront();
	}
	return SplitRange(str, separator);
}
pragma (inline, true)enum isUpperCase(TChar)(TChar c)
{
	return c >= 'A' && (c <= 'Z');
}
pragma (inline, true)enum isLowercase(TChar)(TChar c)
{
	return c >= 'a' && (c <= 'z');
}
pragma (inline, true)enum isAlpha(TChar)(TChar c)
{
	return c >= 'a' && (c <= 'z') || c >= 'A' && (c <= 'Z');
}
pragma (inline, true)enum isEndOfLine(TChar)(TChar c)
{
	return c == '\n' || c == '\r';
}
pragma (inline, true)enum isNumeric(TChar)(TChar c)
{
	return c >= '0' && (c <= '9') || c == '-';
}
pragma (inline, true)enum isWhitespace(TChar)(TChar c)
{
	return c == ' ' || c == '\t' || c.isEndOfLine;
}
TString[] pathSplliter(TString)(TString str)
{
	TString[] ret;
	TString curr;
	for (uint i = 0;
	 i < str.length; i++)
	{
		if (str[i] == '/' || str[i] == '\\')
		{
			ret ~= curr;
			curr = null;
		}
		else
			curr ~= str[i];
	}
	ret ~= curr;
	return ret;
}
pure nothrow @nogc @safe TString trim(TString)(TString str)
{
	if (str.length == 0)
		return str;
	size_t start = 0;
	size_t end = str.length - 1;
	while (start < str.length && str[start].isWhitespace)
	start++;
	while (end > 0 && str[end].isWhitespace)
	end--;
	return str[start..end + 1];
}
TString join(TString)(TString[] args, TString separator)
{
	if (args.length == 0)
		return "";
	TString ret = args[0];
	for (int i = 1;
	 i < args.length; i++)
	{
		ret ~= separator ~ args[i];
	}
	return ret;
}
