module hip.api.math.math_binding;

version(HipMathAPI):
import hip.api.math.random;


void initMath()
{
    version(Script)
    {
        import std.stdio;
        initRandom();
        writeln("Initialized random module");
    }
}