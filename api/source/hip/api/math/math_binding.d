module hip.api.math.math_binding;

version(HipMathAPI):
import hip.api.math.random;


version(Script) void initMath()
{
    initRandom();
    import hip.api.console;
    log("HipengineAPI: Initialized Math");
}