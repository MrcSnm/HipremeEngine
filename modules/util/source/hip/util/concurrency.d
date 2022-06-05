/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.util.concurrency;

/**
*   Creates a function definition for shared an unshared.
*/
mixin template concurrent(string func)
{
    mixin(func);
    mixin("shared "~func);
}

/**
*   Test for wrapping atomic operations in a structure
*/
struct Atomic(T)
{
    import core.atomic;
    private T value;

    auto opAssign(T)(T value)
    {       
        atomicStore(this.value, value);
        return value;
    }
    private @property T v(){return atomicLoad(value);}
    alias v this;

}

///Tries to implement a `volatile` java style
struct Volatile(T)
{
    import core.volatile;
    private T value;

    auto synchronized opAssign(T)(T value)
    {    
        volatileStore(&this.value, value);
        return value;
    }
    private @property synchronized T v(){return volatileLoad(value);}
    alias v this;   
}