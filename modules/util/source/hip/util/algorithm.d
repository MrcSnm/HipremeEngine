module hip.util.algorithm;
public import std.algorithm:map;
import std.traits:ReturnType;

ReturnType!(Range.front)[] array(Range)(Range range)
{
    typeof(return) ret;
    foreach(v; range)
        ret~= v;
    return ret;
}

auto map(Range, From, To)(Range range, scope To delegate (From data) func)
{
    struct Return
    {
        Range inputRange;
        To delegate(From data) convert;
        void popFront(){inputRange.popFront;}
        bool empty(){return inputRange.empty;}
        To front(){return convert(inputRange.front);}
    }
    return Return(range, func);
}

void put(Q, T)(Q range, T[] args ...)
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