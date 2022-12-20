/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.util.string;
public import hip.util.conv:to;

/** 
 *  RefCounted, @nogc string, OutputRange compatible, 
 */
struct String
{
    @nogc:
    import core.stdc.string;
    import core.stdc.stdlib;
    char* chars;
    size_t length;
    private size_t _capacity;
    private int* countPtr;

    this(this)
    {
        if(countPtr !is null)
            *countPtr = *countPtr + 1;
    }

    private void initialize(size_t length)
    {
        this.chars = cast(char*)malloc(length);
        this.countPtr = cast(int*)malloc(int.sizeof);
        this._capacity = length;
        this.chars[0..length] = '\0';
        *countPtr = 1;
    }

    static auto opCall(const(char)* str)
    {
        String s;
        size_t l = strlen(str);
        s.initialize(l);
        s.length = l;
        memcpy(s.chars, str, l);
        return s;
    }
    static auto opCall(String str){return str;}
    static auto opCall(string str)
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
        import hip.util.conv:toStringRange;
        String s;
        s.initialize(128);
        static foreach(a; args)
        {
            static if(isAppendable!(typeof(a)))
                s~= a;
            else static if(__traits(hasMember, a, "toString"))
                s~= a.toString;
            else
                toStringRange(s, a);
        }
        return s;
    }
    alias _opApplyFn = int delegate(char c) @nogc;
    int opApply(scope _opApplyFn dg)
    {
        int result = 0;
        for(int i = 0; i < length && result; i++)
            result = dg(chars[i]);
        return result;
    }

    bool updateBorrowed(size_t length)
    {
        if(countPtr == null) //Not initialized
        {  
            initialize(length);
            return true;
        }
        else if(*countPtr != 1) //If it is borrowed
        {
            //Remove that old reference and initialize itself (something like when slices shares a common array)
            char* oldChars = chars;
            *countPtr = *countPtr - 1;
            initialize(length+this.length);
            memcpy(chars, oldChars, this.length);
            return true;
        }
        return false;
    }

    auto ref opOpAssign(string op, T)(T value)
    if(op == "~")
    {
        size_t l = 0;
        immutable (char)* chs;
        static if(is(T == String))
        {
            l = value.length;
            chs = cast(immutable(char)*)value.chars;
        }
        else static if (is(T == string)) 
        {
            l = cast(size_t)value.length;
            chs = value.ptr;
        }
        else static if(is(T == immutable(char)*))
        {
            l = cast(size_t)strlen(value);
            chs = value;
        }
        else static if(is(T == char))
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
        if(!updateBorrowed(l) && l + this.length >= this._capacity) //New size is greater than capacity
            resize(cast(uint)((l + this.length)*1.5));
        memcpy(chars+length, chs, l);
        length+= l;
        return this;
    }

    auto ref opAssign(string value)
    {
        bool resized = updateBorrowed(value.length);
        if(!resized)
        {
            if(chars == null)
            {
                chars = cast(char*)malloc(value.length);
                _capacity = value.length;
            }
            else if(value.length > _capacity)
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
        if(!resized)
        {
            if(chars == null)
            {
                chars = cast(char*)malloc(l);
                _capacity = l;
            }
            else if(l > _capacity)
                resize(l);
        }
        length = l;
        memcpy(chars, value, l);
        return this;
    }

    string opCast() const
    {
        return cast(string)chars[0..length];
    }
    string toString() const {return cast(string)chars[0..length];}

    pragma(inline, true) private void resize(size_t newSize)
    {
        chars = cast(char*)realloc(chars, newSize);
        _capacity = newSize;
    }
    ///Make this struct OutputRange compatible
    void put(char c)
    {
        if(this.length + 1 >= this._capacity)
            resize(cast(uint)((this.length+1)*1.5));
        chars[length] = c;
        length++;
    }
    bool opEquals(R)(const R other) const
    {
        static if(is(R == typeof(null)))
            return chars == null;
        else static if(is(R == string))
            return toString == other;
        else static if(is(R == String))
            return toString == other.toString;
        else static assert(false, "Invalid comparison between String and "~R.stringof);
    }
    
    /**
    *   This function serves to allocate before put. This will make less allocations occur while iterating
    * this struct as an OutputRange.
    */
    void preAllocate(uint howMuch)
    {
        if(length + howMuch > _capacity)
        {
            this._capacity+= howMuch;
            chars = cast(char*)realloc(chars, this._capacity);
        }
    }
    void preAllocate(ulong howMuch){preAllocate(cast(uint)howMuch);}

    ref auto opIndex(size_t index)
    {
        assert(index < length, "Index out of bounds");
        return chars[index];
    }

    ~this()
    {
        if(countPtr != null)
        {

            *countPtr = *countPtr - 1;
            assert(*countPtr >= 0);
            if(*countPtr == 0 && chars != null)
            {
                free(chars);
                free(countPtr);
            }
            countPtr = null;
            chars = null;
        }
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
        if(stringsPtr == strings.length)
        {
            if(strings.length == 0x10000) //65K (This will guarantee a reasonable amount of allocations)
                toString();
            else
            {
                //128 is a reasonable start, this way, no really small operation should matter on performance
                strings.length = strings.length == 0 ? 128 : strings.length * 2;
            }
        }
        strings[stringsPtr++] = value;
    }
    string toString()
    {
        import core.stdc.string:memcpy;
        if(stringsPtr == 0) return cast(string)builtString[0..builtLength];
        uint count = builtLength;
        uint i = builtLength;
        foreach(s;strings[0..stringsPtr])
            count+= s.length;
        builtString.length = count;
        
        foreach(s; strings[0..stringsPtr])
        {
            memcpy(builtString.ptr+i, s.ptr, s.length);
            i+= s.length;
        }
        builtLength = count;
        stringsPtr = 0;
        return cast(string)builtString[0..builtLength];
    }
    auto ref opAssign(T)(T value) if(is(T == string))
    {
        builtString.length = value.length;
        foreach(i, c; s)
            builtString[i] = c;
        stringsPtr = 0;
        builtLength = cast(typeof(builtLength))value.length;

        return this;
    }
    auto ref opOpAssign(string op, T)(T value) if(op == "~")
    {
        import std.traits:isArray;
        static if(isArray!T && !is(T == string))
            foreach(v; value) append(v);
        else
            append(value);
        return this;
    }
    ref auto opIndex(size_t index){return toString()[index];}
    uint length(){return builtLength;}
    ~this(){strings.length = 0;}

    ///Interface for OutputRange
    alias put = append;
}



pure TString replaceAll(TChar, TString = TChar[])(TString str, TChar what, TString replaceWith = "")
{
    string ret;
    for(int i = 0; i < str.length; i++)
    {
        if(str[i] != what) ret~= str[i];
        else if(replaceWith != "") ret~=replaceWith;
    }
    return ret;
}

pure TString replaceAll(TString)(TString str, TString what, TString replaceWith = "")
{
    TString ret;
    uint z = 0;
    for(uint i = 0; i < str.length; i++)
    {
        while(z < what.length && str[i+z] == what[z])
            z++;
        if(z == what.length)
        {
            ret~= replaceWith;
            i+=z;
        }
        z = 0;
        ret~= str[i];
    }
    return ret;
}

pure int indexOf (TString)(in TString str,in TString toFind, int startIndex = 0) nothrow @nogc @safe
{
    if(!toFind.length)
        return -1;
    int left = 0;

    for(int i = startIndex; i < str.length; i++)
    {
        if(str[i] == toFind[left])
        {
            left++;
            if(left == toFind.length)
                return (i+1) - left; //Remember that left is already out of bounds
        }
        else if(left > 0)
            left--;
    }
    return -1;
}

pure bool startsWith(TString)(in TString str, in TString withWhat) nothrow @nogc @safe
{
    if(withWhat.length > str.length)
        return false;
    int index = 0;
    while(index < withWhat.length && str[index] == withWhat[index])
        index++;
    return index == withWhat.length;
}

/**
*   Same thing as startsWith, but returns the part after the afterWhat
*/
pure string after(TString)(in TString str, in TString afterWhat) nothrow @nogc @safe
{
    bool has = str.startsWith(afterWhat);
    if(!has)
        return null;
    return str[afterWhat.length..$];
}

pure string findAfter(TString)(in TString str, in TString afterWhat, int startIndex = 0) nothrow @nogc @safe
{
    int afterWhatIndex = str.indexOf(afterWhat, startIndex);
    if(afterWhatIndex == -1)
        return null;
    return str[afterWhatIndex+afterWhat.length..$];
}

/**
*   Returns the content that is between `left` and `right`:
```d
string test = `string containing a "thing"`;
writeln(test.between(`"`, `"`)); //thing
```
*/
pure string between(TString)(in TString str, in TString left, in TString right, int start = 0) nothrow @nogc @safe
{
    int leftIndex = str.indexOf(left, start);
    if(leftIndex == -1) return null;
    int rightIndex = str.indexOf(right, leftIndex+1);
    if(rightIndex == -1) return null;

    return str[leftIndex+1..rightIndex];
}

pure int indexOf(TChar)(in TChar[] str, in TChar ch, int startIndex = 0) nothrow @nogc @trusted
{
    char[1] temp = [ch];
    return indexOf(str, cast(TChar[])temp, startIndex);
}


TString repeat(TString)(TString str, size_t repeatQuant)
{
    TString ret;
    for(int i = 0; i < repeatQuant; i++)
        ret~= str;
    return ret;
}

pure int count(TString)(in TString str, in TString countWhat) nothrow @nogc @safe
{
    int ret = 0;
    int index = 0;

    //Navigates using indexOf
    while((index = str.indexOf(countWhat, index)) != -1)
    {
        index+= countWhat.length;
        ret++;
    }
    return ret;
}

alias countUntil = indexOf;

int lastIndexOf(TString)(in TString str,in TString toFind, int startIndex = -1) pure nothrow @nogc @safe
{
    if(startIndex == -1) startIndex = cast(int)(str.length)-1;

    int maxToFind = cast(int)toFind.length - 1;
    int right = maxToFind;
    if(right < 0) return -1; //Empty string case 
    
    
    for(int i = startIndex; i >= 0; i--)
    {
        if(str[i] == toFind[right])
        {
            right--;
            if(right == -1)
                return i;
        }
        else if(right < maxToFind)
            right++;
    }
    return -1;
}
int lastIndexOf(TChar)(TChar[] str, TChar ch, int startIndex = -1) pure nothrow @nogc @trusted
{
    TChar[1] temp = [ch];
    return lastIndexOf(str, cast(TChar[])temp, startIndex);
}

T toDefault(T)(string s, T defaultValue = T.init)
{
    if(s == "")
        return defaultValue;
    T v = defaultValue;
    try{v = to!(T)(s);}
    catch(Exception e){}
    return v;
}

string fromStringz(const char* cstr) pure nothrow @nogc
{
    import core.stdc.string:strlen;
    size_t len = strlen(cstr);
    return (len) ? cast(string)cstr[0..len] : null;
}

const(char)* toStringz(string str) pure nothrow
{
    return (str~"\0").ptr;
}
pragma(inline, true) char toLowerCase(char c) pure nothrow @safe @nogc 
{
    if(c < 'A' || c > 'Z')
        return c;
    return cast(char)(c + ('a' - 'A'));
}

string toLowerCase(string str)
{
    char[] ret = new char[](str.length);
    for(uint i = 0; i < str.length; i++)
        ret[i] = str[i].toLowerCase;
    return cast(string)ret;
}

pragma(inline, true) enum toUpper(char c)
{
    if(c < 'a' || c > 'z')
        return c;
    return cast(char)(c - ('a' - 'A'));
}

string toUpper(string str) pure nothrow @safe
{
    char[] ret = new char[](str.length);
    for(uint i = 0; i < str.length; i++)
        ret[i] = str[i].toUpper;
    return ret;
}

TChar[][] split(TChar)(TChar[] str, TChar separator) pure nothrow
{
    TChar[1] sep = [separator];
    return split(str, cast(TChar[])sep);
}

TString[] split(TString)(TString str, TString separator) pure nothrow @safe
{
    TString[] ret;
    int last = 0;
    int index = 0;
    do
    {
        index = str.indexOf(separator, index);
        if(index != -1)
        {
            ret~= str[last..index];
        	last = index+= separator.length;
        }
    }
    while(index != -1);
    if(last != 0)
        ret~= str[last..$];
    return ret;
}

auto splitRange(TString)(TString str, TString separator) pure nothrow @safe @nogc
{
    struct SplitRange
    {
        TString strToSplit;
        TString sep;
        TString frontStr;
        int lastFound, index;

        bool empty(){return frontStr == "" && index == -1 && lastFound == -1;}
        TString front()
        {
            if(frontStr == "") popFront();
            return frontStr;
        }
        void popFront()
        {
            if(index == -1 && lastFound == -1)
            {
                frontStr = "";
                return;
            }
            index = strToSplit.indexOf(sep, index);
            //When finding, take the string[lastFound..index]
            if(index != -1)
            {
                frontStr = strToSplit[lastFound..index];
                lastFound = index+= sep.length;
            }
            //If index not found and there was a last, take the string[lastFound..$]
            else if(lastFound != 0)
            {
                frontStr = strToSplit[lastFound..$];
                lastFound = -1;
            }
            //Just say there is no string
            else
                lastFound = -1;
        }
    }

    return SplitRange(str, separator);
}


bool isNumber(TString)(in TString str) pure nothrow @nogc
{
    if(!str)
        return false;
    bool isFirst = true;
    bool hasDecimalSeparator = false;
    foreach(c; str)
    {
        //Check for negative
        if(isFirst)
        {
            isFirst = false;
            if(c == '-')
                continue;
        }
        //Can only check for '.' once.
        if(!hasDecimalSeparator && c == '.')
            hasDecimalSeparator = true;
        else if(c < '0' || c > '9')
            return false;

    }
    return true;
}

/**
This function will get the number at the end of the string. Used when you have numbered items such as frames:
walk_01, walk_02, etc
```d
"test123".getNumericEnding == "123"
"123abc".getNumericEnding == ""
"123".getNumericEnding == "123"
```
*/
string getNumericEnding(string s)
{
    if(!s)
        return "";
    long i = cast(long)s.length - 1;
    while(i >= 0)
    {
        if(!isNumeric(s[i]))
            return s[i+1..$];
        i--;
    }
    return "";
}


pragma(inline, true) bool isUpperCase(TChar)(TChar c) @nogc nothrow pure @safe
{
    return c >= 'A' && c <= 'Z';
}
pragma(inline, true) bool isLowercase(TChar)(TChar c) @nogc nothrow pure @safe
{
    return c >= 'a' && c <= 'z';
}

pragma(inline, true) bool isAlpha(TChar)(TChar c) @nogc nothrow pure @safe
{
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
}

pragma(inline, true) bool isEndOfLine(TChar)(TChar c) @nogc nothrow pure @safe
{
    return c == '\n' || c == '\r';
}

pragma(inline, true) bool isNumeric(TChar)(TChar c) @nogc nothrow pure @safe
{
    return (c >= '0' && c <= '9') || (c == '-');
}
pragma(inline, true) bool isWhitespace(TChar)(TChar c) @nogc nothrow pure @safe
{
    return (c == ' ' || c == '\t' || c.isEndOfLine);
}

TString[] pathSplliter(TString)(TString str)
{
    TString[] ret;

    TString curr;
    for(uint i = 0; i < str.length; i++)
        if(str[i] == '/' || str[i] == '\\')
        {
            ret~= curr;
            curr = null;
        }
        else
            curr~= str[i];
    ret~= curr;
    return ret;
}


TString trim(TString)(TString str) pure nothrow @safe @nogc
{
    if(str.length == 0)
        return str;
    
    size_t start = 0;
    size_t end = str.length - 1;
    while(start < str.length && str[start].isWhitespace)
        start++;
   
    while(end > 0 && str[end].isWhitespace)
        end--;
    
    return str[start..end+1];
}

TString join(TString)(TString[] args, TString separator = "")
{
	if(args.length == 0) return "";
	TString ret = args[0];
	for(int i = 1; i < args.length; i++)
		ret~=separator~args[i];
	return ret;
}

unittest
{
    assert(baseName("a/b/test.txt") == "test.txt");
    assert(join(["hello", "world"], ", ") == "hello, world");
    assert(split("hello world", " ").length == 2);
    assert(toDefault!int("hello") == 0);
    assert(lastIndexOf("hello, hello", "hello") == 7);
    assert(indexOf("hello, hello", "hello") == 0);
    assert(replaceAll("\nTest\n", '\n') == "Test");

    assert(trim(" \n  \thello there  \n \t") == "hello there");
    assert(between(`string containing a "thing"`, `"`, `"`) == "thing");

    assert("test123".getNumericEnding == "123");
    assert("123abc".getNumericEnding == "");
    assert("123".getNumericEnding == "123");
}
