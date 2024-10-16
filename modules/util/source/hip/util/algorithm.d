module hip.util.algorithm;
import std.traits:ReturnType;


ReturnType!(Range.front)[] array(Range)(Range range)
{
    typeof(return) ret;
    foreach(v; range)
        ret~= v;
    return ret;
}


/**
Copies the content of `source` into `target` and returns the
remaining (unfilled) part of `target`.

Preconditions: `target` shall have enough room to accommodate
the entirety of `source`.

Params:
    source = an $(REF_ALTTEXT input range, isInputRange, std,range,primitives)
    target = an output range

Returns:
    The unfilled part of target
 */
T[] copyInto(T)(T[] source, T[] target)
{
    assert(target.length >= source.length, "Cannot copy source range into a smaller target range.");

    bool overlaps = source.ptr < target.ptr + target.length && target.ptr < source.ptr + source.length;
    if(overlaps)
    {
        if (source.ptr < target.ptr)
            {
                foreach_reverse (idx; 0 .. source.length)
                    target[idx] = source[idx];
            }
            else
            {
                foreach (idx; 0 .. source.length)
                    target[idx] = source[idx];
            }
            return target[source.length .. target.length];
    }
    else
    {
        target[0..source.length] = source[];
        return target[source.length..$];
    }
}

auto map(Range, From, To)(Range range, scope To delegate (From data) func)
{
    struct Return
    {
        Range inputRange;
        To delegate(From data) convert;
        import std.traits :isArray;
        static if(isArray!Range)
        {
            size_t counter = 0;
            void popFront(){counter++;}
            bool empty(){return counter == inputRange.length;}
            To front(){return convert(inputRange[counter]);}
        }
        else
        {
            void popFront(){inputRange.popFront;}
            bool empty(){return inputRange.empty;}
            To front(){return convert(inputRange.front);}
        }

        int opApply(scope int delegate(To) dg)
        {
            foreach(v; inputRange)
            {
                int ret = dg(convert(v));
                if(ret) return ret;
            }
            return 0;
        }
        int opApply(scope int delegate(size_t, To) dg)
        {
            size_t i = 0;
            foreach(v; inputRange)
            {
                int ret = dg(i++, convert(v));
                if(ret) return ret;
            }
            return 0;
        }
    }
    return Return(range, func);
}

void put(Q, T)(Q range, T[] args ...) if(is(T == U*, U))
{
    int i = 0;
    foreach(v; range)
    {
        if(i >= args.length)
            return;
        *args[i] = v;
        i++;
    }
}

void swap(T)(ref T a, ref T b)
{
    T tempA = a;
    a = b;
    b = tempA;
}


int find(T)(in T[] array, scope bool function(T val) pred)
{
    foreach(index, v; array)
        if(pred(v))
            return cast(int)index;
    return -1;
}

int findLast(T)(in T[] array, scope bool function(T val) pred)
{
    foreach_reverse(index, v; array)
        if(pred(v))
            return cast(int)index;
    return -1;
}