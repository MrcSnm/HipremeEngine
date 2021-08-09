module implementations.renderer.shader.var_packing;
import implementations.renderer.shader;
import implementations.renderer.shader.shadervar;


/**
*   Uses the OpenGL's GLSL Std 140 for getting the variable position.
*   This function must return what is the end position given the last variable size.
*/
uint glSTD140(ref ShaderVar* v, uint lastAlignment = 0, bool isLast = false, uint n = float.sizeof)
{
    uint newN;
    final switch(v.type) with(UniformType)
    {
        case floating:
        case uinteger:
        case integer:
        case boolean:
            newN = n;
            break;
        case floating2:
            newN = n*2;
            break;
        case floating3:
        case floating4:
        case floating2x2:
            newN = n*4;
            break;
        case floating3x3:
            newN = n*12;
            break;
        case floating4x4:
            newN = n*16;
            break;
        case none:
            assert(false, "Can't use none uniform type on ShaderVariablesLayout");
    }
    if(lastAlignment == 0)
        return newN;

    uint n4 = n*4;
    if(lastAlignment % n4 > (lastAlignment+newN) % n4 || newN % n4 == 0)
        return lastAlignment+ (lastAlignment % n4) + newN;
    
    return lastAlignment + newN;
}

/**
*   Uses the OpenGL's GLSL Std 140 for getting the variable position.
*   This function must return what is the end position given the last variable size.
*/
uint dxHLSL4(ref ShaderVar* v, uint lastAlignment = 0, bool isLast = false, uint n = float.sizeof)
{
    uint newN;
    final switch(v.type) with(UniformType)
    {
        case floating:
        case uinteger:
        case integer:
        case boolean:
            newN = n;
            break;
        case floating2:
            newN = n*2;
            break;
        case floating3:
        case floating4:
        case floating2x2:
            newN = n*4;
            break;
        case floating3x3:
            newN = n*12;
            break;
        case floating4x4:
            newN = n*16;
            break;
        case none:
            assert(false, "Can't use none uniform type on ShaderVariablesLayout");
    }
    if(lastAlignment == 0)
        return newN;

    uint n4 = n*4;
    if(lastAlignment % n4 > (lastAlignment+newN) % n4 || newN % n4 == 0)
        return lastAlignment+ (lastAlignment % n4) + newN;
    
    return lastAlignment + newN;
}

uint nonePack(ref ShaderVar* v, uint lastAlignment = 0, bool isLast = false, uint n = float.sizeof){return 0;}