module hip.util.algorithm;
public import std.algorithm.iteration : map;
import std.algorithm.mutation : copy;
import std.traits:ReturnType;

///An alias made of std.algorithm.mutation.copy for the intention to be clearer since the `from` is the first argument
alias copyInto = copy;

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