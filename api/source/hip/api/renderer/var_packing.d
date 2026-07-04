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
VarPosition glSTD140(size_t varSize, size_t lastAlignment = 0, bool isLast, UniformType type, size_t biggestMember)
{
    size_t varAlignment = varSize;
    // if(type == UniformType.floating_array || type == UniformType.integer_array || type == UniformType.uinteger_array)
    //     varSize = 16;
    
    if(varSize > 8)
        varAlignment = 16;

    if(lastAlignment == 0)
        return VarPosition(0,varSize,varSize);
    size_t padding = (varAlignment % lastAlignment) % varAlignment;

    size_t alignment = 0;
    if(isLast)
    {
        import hip.math.utils;
        alignment = alignTo(cast(int)(lastAlignment+padding+varSize), cast(int)biggestMember);
        return VarPosition(lastAlignment+padding, alignment, varSize);
    }
    //TODO: Also send 
    return VarPosition(lastAlignment+padding, lastAlignment + padding + varSize+alignment, varSize);
}

/**
*   Uses the OpenGL's GLSL Std 140 for getting the variable position.
*   This function must return what is the end position given the last variable size.
*/
VarPosition dxHLSL4(size_t varSize, size_t lastAlignment = 0, bool isLast, UniformType type, size_t biggestMember)
{
    size_t offset = 0;
    int remainingBytes = 16 - lastAlignment % 16;
    if(isLast)
    {
        size_t endPosPadding = 16 - (lastAlignment + varSize) % 16;
        return VarPosition(lastAlignment, lastAlignment + varSize + endPosPadding, varSize);
    }

    if(varSize > remainingBytes)
        offset+= remainingBytes;

    return VarPosition(lastAlignment, lastAlignment+varSize+offset, varSize);
}

VarPosition nonePack(size_t varSize, size_t lastAlignment = 0, bool isLast, UniformType type, size_t biggestMember)
{
    return VarPosition(0,0,0);
}