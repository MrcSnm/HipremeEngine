/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.api.renderer.var_packing;
import hip.api.renderer.shadervar:UniformType;

pragma(LDC_no_typeinfo)
struct VarPosition
{
    size_t startPos;
    size_t endPos;
    size_t size;
}

/**
*   Uses the OpenGL's GLSL Std 140 for getting the variable position.
*   This function must return what is the end position given the last variable size.
*/
VarPosition glSTD140(size_t varSize, size_t lastAlignment = 0, bool isLast, UniformType type)
{
    size_t varAlignment = varSize;
    // if(type == UniformType.floating_array || type == UniformType.integer_array || type == UniformType.uinteger_array)
    //     varSize = 16;
    
    if(varSize > 8)
        varAlignment = 16;

    if(lastAlignment == 0)
        return VarPosition(0,varSize,varSize);
    size_t padding = (varAlignment % lastAlignment) % varAlignment;

    // if(isLast)
    // {
    //     sizeOffset+= 16 - (varSize % 16);
    // }
    //TODO: Also send 
    return VarPosition(lastAlignment+padding, lastAlignment + padding + varSize, varSize);
}

/**
*   Uses the OpenGL's GLSL Std 140 for getting the variable position.
*   This function must return what is the end position given the last variable size.
*/
VarPosition dxHLSL4(size_t varSize, size_t lastAlignment = 0, bool isLast, UniformType type)
{
    size_t newN = varSize;
    if(isLast)
    {
        size_t startPos = lastAlignment;
        if(startPos % 16 != 0) startPos = startPos + (16 - (startPos % 16));
        size_t endPos = startPos+newN;
        if(endPos % 16 != 0) endPos = endPos + (16 - (endPos % 16));
        return VarPosition(startPos, endPos, newN);
    }
    if(lastAlignment == 0)
        return VarPosition(0,newN,newN);


    size_t n4 = newN*4;

    //((8 % 16) > (8+8) % 16  || 8 % 16 == 0) && (8+8 % 16 != 0)
    // 8 + (8 % 16) + 8
    
    if((lastAlignment % n4 > (lastAlignment+newN) % n4 || newN % n4 == 0) && (lastAlignment+newN) % n4 != 0)
    {
        size_t startPos = lastAlignment+ (lastAlignment % n4);
        return VarPosition(startPos, startPos+newN, newN);
    }
    
    return VarPosition(lastAlignment, lastAlignment + newN, newN);
}

VarPosition nonePack(size_t varSize, size_t lastAlignment = 0, bool isLast, UniformType type)
{
    return VarPosition(0,0,0);
}