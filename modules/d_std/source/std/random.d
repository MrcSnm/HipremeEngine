module std.random;

version(WebAssembly)
{
    private extern(C) float JS_Math_random() @nogc nothrow;

    int uniform(int low, int high) 
    {
        return cast(int)(low + JS_Math_random() * (high - low));
    }

}