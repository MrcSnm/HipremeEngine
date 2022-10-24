/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.util.array;
private import hip.util.conv : to;

/**
* Uses accessor on the array to find an element
*/
int indexOf(string accessor, T, Q)(T[] arr, Q element, int startIndex = 0)
{
    static if(accessor != "")
        enum op = "."~accessor;
    else
        enum op = accessor;
    const size_t len = arr.length;
    for(ulong i = startIndex; i < len; i++)
        mixin("if(arr[i]"~op~" == element)return cast(int)i;");
    return -1;
}
/**
* Returns index of element if it finds or returns -1 if not
*/
int indexOf(T)(T[] arr, T element, int startIndex = 0)
{
    return indexOf!""(arr, element, startIndex);
}

int lastIndexOf(T)(T[] arr, T element, int startIndex = -1)
{
    const size_t len = arr.length;
    if(len==0)return-1;
    if(startIndex < 0) startIndex = (cast(int)len - 1);
    for(int i = startIndex; i >= 0; i--)
        if(arr[i] == element)
            return i;
    return -1;
}

/**
*   Should work only for numerics
*/
int binarySearch(T)(in T[] arr, T element) @nogc @safe nothrow
{
    uint l = 0;
    uint r = arr.length;
    uint m;
    while(l <= r)
    {
        m = cast(uint)((l+r)/2);
        if(arr[m] < element)
            l = m + 1;
        else if(arr[m] > element)
            r = m - 1;
        else if(arr[m] == element)
            return m;
    }

    return -1;
}

bool swapAt(T)(T[] arr, int index1, int index2) @nogc @safe nothrow
{
    if(index1 == index2 || index1 < 0 || index1 >= arr.length || index2 < 0 || index2 >= arr.length)
        return false;
    T temp  = arr[index1];
    arr[index1] = arr[index2];
    arr[index2] = temp;
    return true;
}

/**
*  Returns if swap was succesful
*/
bool swapElementsFromArray(T)(T[] arr, T element1, T element2) @nogc @safe nothrow
{
    long index1 = arr.indexOf(element1);
    long index2 = arr.indexOf(element2);

    if(index1 != -1 && index2 != 1)
    {
        T temp = arr[index1];
        arr[index1] = arr[index2];
        arr[index2] = temp;
        return true;
    }
    return false;
}


bool popFront(T)(ref T[] arr, out T val)
{
    import hip.util.memory;
    if(arr.length == 0)
        return false;
    val = arr[0];
    memcpy(arr.ptr, arr.ptr+1, (cast(int)arr.length-1)*T.sizeof);
    arr.length--;
    return true;
}
bool popFront(T)(ref T[] arr)
{
    T val;
    return popFront(arr, val);
}
bool remove(T)(ref T[] arr, T val)
{
    import hip.util.memory;
    if(arr.length == 0)
        return false;
    
    for(ulong i = 0; i < arr.length; i++)
        if(arr[i] == val)
        {
            for(ulong z = 0; z+i < cast(int)arr.length-1; z++)
                arr[z+i] = arr[z+i+1];
            arr.length--;
            return true;
        }
    return false;
}
pragma(inline)
bool contains(T)(ref T[] arr, T val){return arr.indexOf(val) != -1;} 


/**
*   Compare a array of structures member with a target value
*/
pragma(inline, true) bool contains(string accessor, T, Q)(ref T[] arr, Q val)
{
    for(ulong i = 0; i < arr.length; i++)
    {
        if(__traits(getMember, arr[i], accessor) == val)
            return true;
    }
    return false;
}

/**
*   Compare two different structures accessing different members
*/
pragma(inline, true) bool contains(string accessorA, string accessorB, T, Q)(ref T[] arr, Q val)
{
    for(ulong i = 0; i < arr.length; i++)
    {
        if(__traits(getMember, arr[i], accessorA) == __traits(getMember, val, accessorB))
            return true;
    }
    return false;
}

pragma(inline) bool isEmpty(T)(in T[] arr){return arr.length == 0;}


import std.traits:ForeachType;
ForeachType!(T)[] array(T)(T range)
{
    typeof(return) ret;
    foreach(r;range)
        ret~= r;
    return ret;
}

string join(T)(T[] arr, string separator = "")
{
    import hip.util.conv;
    string ret;
    if(arr.length == 0) return "";

    ret = toString(arr[0]);
    for(int i = 1; i < arr.length; i++)
    {
        ret~= separator;
        ret~= arr[i];
    }
    return ret;
}

string join(T)(T[] arr, char separator)
{
    char[1] temp = separator;
    return join(arr, cast(string)temp);
}


void printArrayWithoutValues(T)(const T[] arr, T[] ignoreValues...)
{
    import hip.console.log;
    string str = "[";
    MainLoop: foreach (val; arr)
    {
        foreach (arg; ignoreValues)
            if(val == arg) //Ignore if value is in the loop list
                continue MainLoop;
        str~= to!string(val) ~", ";
    }
    str~= "]";
    const int index = lastIndexOf(str, ',');
    if(index == -1)
        logln("[]");
    else
        logln(str[0..index] ~ str[index+2..$]);
}

unittest
{
    assert(indexOf([2, 3, 4], 3) == 1);
    assert(swapElementsFromArray([5, 10, 9], 10, 9));
    assert(lastIndexOf([2, 3, 3, 4], 4) == 3);
}