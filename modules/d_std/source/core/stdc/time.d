module core.stdc.time;

version(PSVita)
{
    import core.stdc.config;
    alias time_t = c_long;
    extern(C) time_t  time(scope time_t* timer) nothrow;
}
