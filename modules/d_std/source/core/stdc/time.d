module core.stdc.time;

version(PSVita) version = CustomRuntime;
version(CustomRuntimeTest) version = CustomRuntime;

version(CustomRuntime)
{
    import core.stdc.config;
    alias time_t = c_long;
    extern(C) time_t  time(scope time_t* timer) nothrow;
}
