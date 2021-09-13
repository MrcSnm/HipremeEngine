/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module util.array;
private import std.conv : to;

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
*  Returns if swap was succesful
*/
bool swapElementsFromArray(T)(T[] arr, T element1, T element2)
{
    import std.algorithm : countUntil, swapAt;

    long index1 = arr.indexOf(element1);
    long index2 = arr.indexOf(element2);

    if(index1 != -1 && index2 != 1)
    {
        swapAt(arr, index1, index2);
        return true;
    }
    return false;
}


bool popFront(T)(ref T[] arr, out T val)
{
    import util.memory;
    if(arr.length == 0)
        return false;
    val = arr[0];
    memcpy(arr.ptr, arr.ptr+1, (arr.length-1)*T.sizeof);
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
    import util.memory;
    if(arr.length == 0)
        return false;
    
    for(ulong i = 0; i < arr.length; i++)
        if(arr[i] == val)
        {
            for(ulong z = 0; z+i < arr.length-1; z++)
                arr[z+i] = arr[z+i+1];
            arr.length--;
            return true;
        }
    return false;
}
pragma(inline, true)
bool contains(T)(ref T[] arr, T val){return arr.indexOf(val) != -1;} 


/**
*   Compare a array of structures member with a target value
*/
pragma(inline, true) bool contains(string accessor, T, Q)(ref T[] arr, Q val)
{
    for(ulong i = 0; i < arr.length; i++)
        mixin("if(arr[i]."~accessor~" == val) return true;");
    return false;
}

/**
*   Compare two different structures accessing different members
*/
pragma(inline, true) bool contains(string accessorA, string accessorB, T, Q)(ref T[] arr, Q val)
{
    for(ulong i = 0; i < arr.length; i++)
        mixin("if(arr[i]."~accessorA~" == val."~accessorB~") return true;");
    return false;
}

pragma(inline, true)
bool isEmpty(T)(ref T[] arr){return arr.length == 0;}



void printArrayWithoutValues(T)(const T[] arr, T[] ignoreValues...)
{
    import console.log;
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
    assert(lastIndexOf([2, 3, 3, 4], 4) == 2);
}