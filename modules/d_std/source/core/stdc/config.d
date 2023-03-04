module core.stdc.config;

version(PSVita) version = UseCustomRuntime;
version(CustomRuntimeTest) version = UseCustomRuntime;

version(UseCustomRuntime)
{
    alias c_long = int;
    alias c_ulong = uint;
}
