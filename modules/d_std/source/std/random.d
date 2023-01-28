module std.random;

version(WebAssembly)
{
    import arsd.webassembly;
    int uniform(int low, int high) 
    {
        int max = high - low;
        return low + eval!int(q{ return Math.floor(Math.random() * $0); }, max);
    }

}