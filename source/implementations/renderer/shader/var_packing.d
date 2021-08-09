module implementations.renderer.shader.var_packing;
import implementations.renderer.shader;
import implementations.renderer.shader.shadervar;

struct VarPosition
{
    uint startPos;
    uint endPos;
    uint size;
}

private uint getVarSize(ref ShaderVar* v, uint n)
{
    final switch(v.type) with(UniformType)
    {
        case floating:
        case uinteger:
        case integer:
        case boolean:
            return n;
        case floating2:
            return n*2;
        case floating3:
        case floating4:
        case floating2x2:
            return n*4;
        case floating3x3:
            return n*12;
        case floating4x4:
            return n*16;
        case none:
            assert(false, "Can't use none uniform type on ShaderVariablesLayout");
    }
}


/**
*   Uses the OpenGL's GLSL Std 140 for getting the variable position.
*   This function must return what is the end position given the last variable size.
*/
VarPosition glSTD140(ref ShaderVar* v, uint lastAlignment = 0, bool isLast = false, uint n = float.sizeof)
{
    uint newN = getVarSize(v, n);
    
    if(lastAlignment == 0)
        return VarPosition(0,newN,newN);

    uint n4 = n*4;

    //((8 % 16) > (8+8) % 16  || 8 % 16 == 0) && (8+8 % 16 != 0)
    // 8 + (8 % 16) + 8 
    
    if((lastAlignment % n4 > (lastAlignment+newN) % n4 || newN % n4 == 0) && (lastAlignment+newN) % n4 != 0)
    {
        uint startPos = lastAlignment;
        if(startPos % n4 != 0) startPos = startPos + (n4 - (startPos % n4));

        return VarPosition(startPos, startPos+newN, newN);
    }
    
    return VarPosition(lastAlignment, lastAlignment + newN, newN);
}

/**
*   Uses the OpenGL's GLSL Std 140 for getting the variable position.
*   This function must return what is the end position given the last variable size.
*/
VarPosition dxHLSL4(ref ShaderVar* v, uint lastAlignment = 0, bool isLast = false, uint n = float.sizeof)
{
    uint newN = getVarSize(v,n);
    if(isLast)
    {
        uint startPos = lastAlignment;
        if(startPos % 16 != 0) startPos = startPos + (16 - (startPos % 16));
        uint endPos = startPos+newN;
        if(endPos % 16 != 0) endPos = endPos + (16 - (endPos % 16));
        return VarPosition(startPos, endPos, newN);
    }
    if(lastAlignment == 0)
        return VarPosition(0,newN,newN);

   
    uint n4 = n*4;

    //((8 % 16) > (8+8) % 16  || 8 % 16 == 0) && (8+8 % 16 != 0)
    // 8 + (8 % 16) + 8 
    
    if((lastAlignment % n4 > (lastAlignment+newN) % n4 || newN % n4 == 0) && (lastAlignment+newN) % n4 != 0)
    {
        uint startPos = lastAlignment+ (lastAlignment % n4);
        return VarPosition(startPos, startPos+newN, newN);
    }
    
    return VarPosition(lastAlignment, lastAlignment + newN, newN);
}

VarPosition nonePack(ref ShaderVar* v, uint lastAlignment = 0, bool isLast = false, uint n = float.sizeof)
{
    return VarPosition(0,0,0);
}