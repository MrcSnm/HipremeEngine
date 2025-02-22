module std.math;
public import core.stdc.math;
import std.traits:Unqual, isFloatingPoint;


Unqual!F pow(F, G)(F x, G n) @nogc @trusted pure nothrow
{
    static if(is(F == float)) return powf(cast(float)x, cast(int)n);
    else return cast(F)core.stdc.math.pow(cast(double)x, cast(int)n);
}


pragma(inline, true)
Number abs(Number)(Number n)
{
    static if(isFloatingPoint!Number)
        return (n != n) ? n : (n < 0 ? -n : n);
    else
        return n < 0 ? -n : n;
}



N exp(N)(N input)
{
    static if(is(N == float)) return expf(input);
    else return core.stdc.math.exp(input);
}