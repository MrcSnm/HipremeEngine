// D import file generated from 'source\hiprenderer\shader\var_packing.d'
module hiprenderer.shader.var_packing;
import hiprenderer.shader;
import hiprenderer.shader.shadervar;
import error.handler;
struct VarPosition
{
	uint startPos;
	uint endPos;
	uint size;
}
private uint getVarSize(ref ShaderVar* v, uint n);
VarPosition glSTD140(ref ShaderVar* v, uint lastAlignment = 0, bool isLast = false, uint n = (float).sizeof);
VarPosition dxHLSL4(ref ShaderVar* v, uint lastAlignment = 0, bool isLast = false, uint n = (float).sizeof);
VarPosition nonePack(ref ShaderVar* v, uint lastAlignment = 0, bool isLast = false, uint n = (float).sizeof);
