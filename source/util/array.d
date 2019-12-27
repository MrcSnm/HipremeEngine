module util.array;

/**
*  Returns if swap was succesful
*/
bool swapElementsFromArray(T)(T[] arr, T element1, T element2)
{
    import std.algorithm : countUntil, swapAt;

    long index1 = countUntil(arr, element1);
    long index2 = countUntil(arr, element2);

    if(index1 != -1 && index2 != 1)
    {
        swapAt(arr, index1, index2);
        return true;
    }
    return false;
}

/**
* Returns index of element if it finds or returns -1 if not
*/
int indexOf(T)(T[] arr, T element)
{
    const ulong len = arr.length;
    for(int i = 0; i < len; i++)
        if(arr[i] == element)
            return i;
    return -1;
}