module core.stdc.config;

version(PSVita) version = UseCustomRuntime;
else version(WebAssembly) version = UseCustomRuntime;
version(CustomRuntimeTest) version = UseCustomRuntime;

version(UseCustomRuntime)
{
    alias c_long = ptrdiff_t;
    alias c_ulong = size_t;
}
