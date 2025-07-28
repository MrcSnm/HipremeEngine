module hip.api.input.binding;

version(DirectCall)
{
    public import hip.global.gamedef : HipInput, HipInputListener;
}
else version(ScriptAPI)
{
    public import hip.api.input.core: HipInput, HipInputListener;
    void initInput()
    {
        import hip.api.internal;
        import hip.api.input.core;
        alias inputFn = extern(System) IHipInput function();
        alias inputListenerFn = extern(System) IHipInputListener function();
        setHipInput((cast(inputFn)_loadSymbol(_dll, "HipInputAPI"))());
        setHipInputListener((cast(inputListenerFn)_loadSymbol(_dll, "HipInputListenerAPI"))());
        import hip.api.console;
        log("HipengineAPI: Initialized Input");
    }
}