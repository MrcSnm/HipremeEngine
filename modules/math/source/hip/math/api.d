module hip.math.api;

mixin template ExportMathAPI()
{
    import hip.math.vector;
    import hip.math.random;

    mixin ExportDFunctions!(hip.math.random);
}