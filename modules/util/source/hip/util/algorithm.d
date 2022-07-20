module hip.util.algorithm;
public import std.algorithm;

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
