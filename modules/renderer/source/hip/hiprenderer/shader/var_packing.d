/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.shader.var_packing;
import hip.hiprenderer.shader;
import hip.hiprenderer.shader.shadervar;
import hip.error.handler;

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
VarPosition glSTD140(ref ShaderVar* v, size_t lastAlignment = 0, bool isLast = false)
{
    size_t size = v.varSize;
    
    if(lastAlignment == 0)
        return VarPosition(0,size,size);

    size_t size4 = size*4;

    //((8 % 16) > (8+8) % 16  || 8 % 16 == 0) && (8+8 % 16 != 0)
    // 8 + (8 % 16) + 8 
    
    if((lastAlignment % size4 > (lastAlignment+size) % size4 || size % size4 == 0) && (lastAlignment+size) % size4 != 0)
    {
        size_t startPos = lastAlignment;
        if(startPos % size4 != 0) startPos = startPos + (size4 - (startPos % size4));

        return VarPosition(startPos, startPos+size, size);
    }
    
    return VarPosition(lastAlignment, lastAlignment + size, size);
}

/**
*   Uses the OpenGL's GLSL Std 140 for getting the variable position.
*   This function must return what is the end position given the last variable size.
*/
VarPosition dxHLSL4(ref ShaderVar* v, size_t lastAlignment = 0, bool isLast = false)
{
    size_t newN = v.varSize;
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

VarPosition nonePack(ref ShaderVar* v, size_t lastAlignment = 0, bool isLast = false)
{
    return VarPosition(0,0,0);
}