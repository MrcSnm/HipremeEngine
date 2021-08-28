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

struct RingBuffer(T, uint Length)
{
    import core.stdc.stdlib:malloc, free;
    import util.concurrency:Volatile;

    T[Length] data;
    private Volatile!uint writeCursor;
    private Volatile!uint readCursor;

    this()
    {
        this.writeCursor = 0;
        this.readCursor = 0;
    }

    void push(T data)
    {
        this.data[writeCursor] = data;
        writeCursor = (writeCursor+1) % Length;
    }
    ///It may read less than count if it is out of bounds
    immutable T[] read(uint count)
    {
        uint temp = readCursor;
        if(temp + count > Length)
        {
            readCursor = 0;
            return data[temp..Length];
        }
        readCursor = (temp+count)%Length;
        return data[temp .. count];
    }

    immutable T read()
    {
        uint temp = readCursor;
        immutable T ret = data[temp];
        readCursor = (temp+1)%Length;
        return ret;
    }

    void dispose()
    {
        data = null;
        length = 0;
        writeCursor = 0;
        readCursor = 0;
    }

    ~this(){dispose();}
}