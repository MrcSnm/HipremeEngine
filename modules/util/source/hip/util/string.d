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
public import hip.util.to_string_range;

version(WebAssembly) version = UseDRuntimeDecoder;
version(CustomRuntimeTest) version = UseDRuntimeDecoder;
version(PSVita) version = UseDRuntimeDecoder;

/** 
 *  RefCounted, @nogc string, OutputRange compatible, 
 */
struct String
{
    @nogc:
    import core.stdc.string;
    import core.stdc.stdlib;
    import core.int128;
    char[] chars;
    private size_t _capacity;
    private int* countPtr;
    size_t length() const {return chars.length;}

    this(this)
    {
        if(countPtr !is null)
            *countPtr = *countPtr + 1;
    }

    private void initialize(size_t length)
    {
        if(length == 0)
            length = 128;
        this.chars = (cast(char*)malloc(length))[0..0];
        this.countPtr = cast(int*)malloc(int.sizeof);
        this._capacity = length;
        this.chars.ptr[0.._capacity] = '\0';
        *countPtr = 1;
    }

    static auto opCall(string str)
    {
        String s;
        s.initialize(str.length);
        s.chars = s.chars.ptr[0..str.length];
        s.chars[] = str[];
        return s;
    }
    static auto opCall(const(char)* str){return opCall(str[0..strlen(str)]);}
    static auto opCall(String str){return str;}

    private enum isAppendable(T) = is(T == String) || is(T == string) || is(T == immutable(char)*) || is(T == char);
    
    static auto opCall(Args...)(Args args)
    {
        import hip.util.conv:toStringRange;
        String s;
        s.initialize(128);
        static foreach(a; args)
        {
            static if(isAppendable!(typeof(a)) )
                s~= a;
            else static if(is(typeof(a) == struct) || __traits(compiles, toStringRange(s, a)))
            {
                toStringRange(s, a);
            }
            else static if(__traits(hasMember, a, "toString"))
                s~= a.toString;
            else static assert(false, "No conversion found");
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

    /**
    *   If it was borrowed, allocate new memory.
    */
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
            char[] oldChars = chars;
            *countPtr = *countPtr - 1;
            initialize(length+this.length);
            chars = chars.ptr[0..oldChars.length];
            chars[0..oldChars.length] = oldChars[0..$];
            return true;
        }
        return false;
    }

    auto ref opOpAssign(string op, T)(T value)
    if(op == "~")
    {
        String temp;
        char[] chs;
        static if(is(T == String))
            chs = value.chars;
        else static if (is(T == string) || is(T == char[]))
            chs = cast(char[])value;
        else static if(is(T == immutable(char)*))
            chs = value[0..strlen(value)];
        else static if(is(T == char))
        {
            char[1] _chContainer;
            _chContainer[0] = value;
            chs = _chContainer;
        }
        else
        {
            temp = String(value);
            chs = temp.chars;
        }
        if(!updateBorrowed(chs.length) && chs.length + this.length >= this._capacity) //New size is greater than capacity
            resize(cast(uint)((chs.length + this.length)*1.5));
        memcpy(chars.ptr+length, chs.ptr, chs.length);
        chars = chars.ptr[0..chars.length+chs.length];
        return this;
    }

    auto ref opAssign(string value)
    {
        if(countPtr is null)
            chars = cast(char[])value; //Don't allocate memory for the string literal.
        else
        {
            bool resized = updateBorrowed(value.length);
            if(!resized)
            {
                if(chars == null)
                    initialize(value.length);
                else if(value.length > _capacity)
                    resize(value.length);
            }
            chars.ptr[0..value.length] = value[];
        }
        return this;
    }

    auto ref opAssign(immutable(char)* value)
    {
        opAssign(value[0..strlen(value)]);
        return this;
    }

    string opCast() const
    {
        return cast(string)chars[0..length];
    }
    string toString() const {return cast(string)chars;}

    pragma(inline, true) private void resize(size_t newSize)
    {
        chars = (cast(char*)realloc(chars.ptr, newSize))[0..chars.length];
        _capacity = newSize;
    }
    ///Make this struct OutputRange compatible
    void put(char c)
    {
        if(this.length + 1 >= this._capacity)
            resize(cast(uint)((this.length+1)*1.5));
        chars.ptr[length] = c;
        chars = chars.ptr[0..length+1];
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
            resize(_capacity + howMuch);
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
                free(chars.ptr);
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


pure dstring toUTF32(string encoded)
{
    dstring decoded;
    version(UseDRuntimeDecoder)
    {
        foreach(dchar ch; encoded) decoded~= ch;
    }
    else
    {
        static import std.utf;
        decoded = std.utf.toUTF32(encoded);
    }
    return decoded;
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
    char[] ret;
    int last;
    int i;
    do
    {
        i = indexOf(str, what, i);
        if(i != -1)
        {
            int copyLength = i - last;
            int currLength = cast(int)ret.length;
            ret.length+= copyLength+replaceWith.length;
            //Copy old content
            ret[currLength..currLength+copyLength] = str[last..i];
            //Copy replace
            ret[currLength+copyLength..$] = replaceWith[];
            //Skip what
            i+= what.length;
            last = i;
        }
    } while(i != -1);

    int copyLength = cast(int)(str.length - last);
    int currLength = cast(int)ret.length;
    ret.length+= copyLength;
    ret[currLength..$] = str[last..$];

    return cast(TString)ret;
}

pure int indexOf (TString)(inout TString str,inout TString toFind, int startIndex = 0) nothrow @nogc @safe
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

pure bool startsWith(TString)(inout TString str, inout TString withWhat) nothrow @nogc @safe
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
pure string after(TString)(TString str, immutable TString afterWhat) nothrow @nogc @safe
{
    bool has = str.startsWith(afterWhat);
    if(!has)
        return null;
    return str[afterWhat.length..$];
}

pure inout(TString) findAfter(TString)(inout TString str, inout TString afterWhat, int startIndex = 0) nothrow @nogc @safe
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
pure inout(TString) between(TString)(inout TString str, inout TString left, inout TString right, int start = 0) nothrow @nogc @safe
{
    int leftIndex = str.indexOf(left, start);
    if(leftIndex == -1) return null;
    int rightIndex = str.indexOf(right, leftIndex+1);
    if(rightIndex == -1) return null;

    return str[leftIndex+1..rightIndex];
}

pure int indexOf(TChar)(inout TChar[] str, inout TChar ch, int startIndex = 0) nothrow @nogc @trusted
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

pure int count(TString)(inout TString str, inout TString countWhat) nothrow @nogc @safe
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

int lastIndexOf(TString)(inout TString str,inout TString toFind, int startIndex = -1) pure nothrow @nogc @safe
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

pragma(inline, true) char toUpper(char c) pure nothrow @nogc @safe
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
    if(last != index)
        ret~= str[last..$];
    return ret;
}

auto splitRange(TString, TStrSep)(TString str, TStrSep separator) pure nothrow @safe @nogc
{
    struct SplitRange
    {
        TString strToSplit;
        TStrSep sep;
        TString frontStr;
        int lastFound, index;

        bool empty(){return frontStr == null && index == -1 && lastFound == -1;}
        TString front()
        {
            if(frontStr == "") popFront();
            return frontStr;
        }
        void popFront()
        {
            if(index == -1 && lastFound == -1)
            {
                frontStr = null;
                return;
            }
            index = indexOf(cast(TString)strToSplit, cast(TString)sep, index);
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
    ptrdiff_t i = cast(ptrdiff_t)s.length - 1;
    while(i >= 0)
    {
        if(!isNumeric(s[i]))
            return s[i+1..$];
        i--;
    }
    return s;
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
