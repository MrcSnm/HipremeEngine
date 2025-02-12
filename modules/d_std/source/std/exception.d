module std.exception;
import std.traits;

void enforce(bool cond, lazy string onThrow, string file = __FILE__, size_t line = __LINE__) pure @trusted
{
    if(cond)
        throw new Exception(onThrow, null, file, line);
}

void enforce(bool cond, lazy Exception onThrow, string file = __FILE__, size_t line = __LINE__) pure @trusted
{
    if(cond)
        throw onThrow;
}
void enforce(T)(bool cond, lazy string onThrow, string file = __FILE__, size_t line = __LINE__) pure @trusted
{
    if(cond)
        throw new T(onThrow, file, line);
}





CommonType!(T[], U[]) overlap(T, U)(T[] a, U[] b) @trusted
if (is(typeof(a.ptr < b.ptr) == bool))
{
    import std.algorithm.comparison : min;

    auto end = min(a.ptr + a.length, b.ptr + b.length);
    // CTFE requires pairing pointer comparisons, which forces a
    // slightly inefficient implementation.
    if (a.ptr <= b.ptr && b.ptr < a.ptr + a.length)
    {
        return b.ptr[0 .. end - b.ptr];
    }

    if (b.ptr <= a.ptr && a.ptr < b.ptr + b.length)
    {
        return a.ptr[0 .. end - a.ptr];
    }

    return null;
}

package enum isUnionAliased(T, size_t i) = isUnionAliasedImpl!T(T.tupleof[i].offsetof);
private bool isUnionAliasedImpl(T)(size_t offset)
{
    int count = 0;
    foreach (i, U; typeof(T.tupleof))
        if (T.tupleof[i].offsetof == offset)
            ++count;
    return count >= 2;
}


/**
Checks whether a given source object contains pointers or references to a given
target object.

Params:
    source = The source object
    target = The target object

Bugs:
    The function is explicitly annotated `@nogc` because inference could fail,
    see $(LINK2 https://issues.dlang.org/show_bug.cgi?id=17084, Bugzilla issue 17084).

Returns: `true` if `source`'s representation embeds a pointer
that points to `target`'s representation or somewhere inside
it.

If `source` is or contains a dynamic array, then, then these functions will check
if there is overlap between the dynamic array and `target`'s representation.

If `source` is a class, then it will be handled as a pointer.

If `target` is a pointer, a dynamic array or a class, then these functions will only
check if `source` points to `target`, $(I not) what `target` references.

If `source` is or contains a union or `void[n]`, then there may be either false positives or
false negatives:

`doesPointTo` will return `true` if it is absolutely certain
`source` points to `target`. It may produce false negatives, but never
false positives. This function should be prefered when trying to validate
input data.

`mayPointTo` will return `false` if it is absolutely certain
`source` does not point to `target`. It may produce false positives, but never
false negatives. This function should be prefered for defensively choosing a
code path.

Note: Evaluating $(D doesPointTo(x, x)) checks whether `x` has
internal pointers. This should only be done as an assertive test,
as the language is free to assume objects don't have internal pointers
(TDPL 7.1.3.5).
*/
bool doesPointTo(S, T, Tdummy=void)(auto ref const S source, ref const T target) @nogc @trusted pure nothrow
if (__traits(isRef, source) || isDynamicArray!S ||
    is(S == U*, U) || is(S == class))
{
    static if (is(S == U*, U) || is(S == class) || is(S == interface))
    {
        const m = *cast(void**) &source;
        const b = cast(void*) &target;
        const e = b + target.sizeof;
        return b <= m && m < e;
    }
    else static if (is(S == struct) || is(S == union))
    {
        foreach (i, Subobj; typeof(source.tupleof))
            static if (!isUnionAliased!(S, i))
                if (doesPointTo(source.tupleof[i], target)) return true;
        return false;
    }
    else static if (isStaticArray!S)
    {
        static if (!is(S == void[n], size_t n))
        {
            foreach (ref s; source)
                if (doesPointTo(s, target)) return true;
        }
        return false;
    }
    else static if (isDynamicArray!S)
    {
        import std.array : overlap;
        return overlap(cast(void[]) source, cast(void[])(&target)[0 .. 1]).length != 0;
    }
    else
    {
        return false;
    }
}

// for shared objects
/// ditto
bool doesPointTo(S, T)(auto ref const shared S source, ref const shared T target) @trusted pure nothrow
{
    return doesPointTo!(shared S, shared T, void)(source, target);
}

mixin template basicExceptionCtors()
{
    /++
        Params:
            msg  = The message for the exception.
            file = The file where the exception occurred.
            line = The line number where the exception occurred.
            next = The previous exception in the chain of exceptions, if any.
    +/
    this(string msg, string file = __FILE__, size_t line = __LINE__,
         Throwable next = null) @nogc @safe pure nothrow
    {
        super(msg, file, line, next);
    }

    /++
        Params:
            msg  = The message for the exception.
            next = The previous exception in the chain of exceptions.
            file = The file where the exception occurred.
            line = The line number where the exception occurred.
    +/
    this(string msg, Throwable next, string file = __FILE__,
         size_t line = __LINE__) @nogc @safe pure nothrow
    {
        super(msg, file, line, next);
    }
}

immutable(T)[] assumeUnique(T)(T[] array) pure nothrow
{
    return .assumeUnique(array);    // call ref version
}
/// ditto
immutable(T)[] assumeUnique(T)(ref T[] array) pure nothrow
{
    auto result = cast(immutable(T)[]) array;
    array = null;
    return result;
}
/// ditto
immutable(T[U]) assumeUnique(T, U)(ref T[U] array) pure nothrow
{
    auto result = cast(immutable(T[U])) array;
    array = null;
    return result;
}