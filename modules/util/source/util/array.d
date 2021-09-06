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
* Returns index of element if it finds or returns -1 if not
*/
int indexOf(T)(T[] arr, T element, int startIndex = 0)
{
    const size_t len = arr.length;
    if(len ==0)return-1;
    for(int i = startIndex; i < len; i++)
        if(arr[i] == element)
            return i;
    return -1;
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