/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module util.data_structures;

struct Pair(A, B)
{
    A first;
    B second;

    alias a = first;
    alias b = second;
}

struct RingBuffer(T)
{
    import core.stdc.stdlib:malloc, free;

    T* data;
    uint length;
    uint cursor;

    this(uint length)
    {
        data = cast(T*)malloc(T.sizeof*length);
        this.length = length;
        this.cursor = 0;
    }

    void push(T data)
    {
        this.data[cursor] = data;
        cursor++;
        if(cursor == length)
            cursor = 0;
    }
    immutable T[] read(uint length = this.length, uint start = 0)
    {
        return data[start .. length];
    }

    void dispose()
    {
        if(data != null)
            free(data);
        data = null;
        length = 0;
        cursor = 0;
    }

    ~this(){dispose();}
}