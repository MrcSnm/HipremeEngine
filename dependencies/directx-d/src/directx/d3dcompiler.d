module directx.d3dcompiler;
//////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) Microsoft Corporation.  All rights reserved.
//
//  File:       D3DCompiler.h
//  Content:    D3D Compilation Types and APIs
//
//////////////////////////////////////////////////////////////////////////////

version(Windows):

public import directx.d3d11shader;
public import directx.d3d12shader;


// useful enums for shader versions
alias LPCSTR_D3D_SHADER_TARGET_ext = LPCSTR;
enum : LPCSTR_D3D_SHADER_TARGET_ext
{
	// Direct3D 11.0 and 11.1

	cs_5_0 = "cs_5_0",
	ds_5_0 = "ds_5_0",
	gs_5_0 = "gs_5_0",
	hs_5_0 = "hs_5_0",
	ps_5_0 = "ps_5_0",
	vs_5_0 = "vs_5_0",

	// Direct3D 10.1

	cs_4_1 = "cs_4_1",
	gs_4_1 = "gs_4_1",
	ps_4_1 = "ps_4_1",
	vs_4_1 = "vs_4_1",

	// Direct3D 10.0

	cs_4_0 = "cs_4_0",
	gs_4_0 = "gs_4_0",
	ps_4_0 = "ps_4_0",
	vs_4_0 = "vs_4_0",

	// Direct3D 9.1, 9.2, 9.3

	ps_4_0_level_9_1 = "ps_4_0_level_9_1",
	ps_4_0_level_9_3 = "ps_4_0_level_9_3",
	vs_4_0_level_9_1 = "vs_4_0_level_9_1",
	vs_4_0_level_9_3 = "vs_4_0_level_9_3",

	// Legacy Direct3D 9 SM 3.0

	ps_3_0 = "ps_3_0",
	ps_3_sw = "ps_3_sw",
	vs_3_0 = "vs_3_0",
	vs_3_sw = "vs_3_sw",

	// Legacy Direct3D 9 SM 2.0

	ps_2_0 = "ps_2_0",
	ps_2_a = "ps_2_a",
	ps_2_b = "ps_2_b",
	ps_2_sw = "ps_2_sw",
	vs_2_0 = "vs_2_0",
	vs_2_a = "vs_2_a",
	vs_2_sw = "vs_2_sw",

	// Legacy effects

	fx_2_0 = "fx_2_0",
	fx_4_0 = "fx_4_0",
	fx_4_1 = "fx_4_1",
	fx_5_0 = "fx_5_0",

} // enum LPCSTR_D3D_SHADER_TARGET_ext


//////////////////////////////////////////////////////////////////////////////
// APIs //////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////


/// predefined for D3DDisassemble10Effect
interface ID3D10Effect : IUnknown {}

extern(C)
{

//----------------------------------------------------------------------------
// D3DCOMPILE flags:
// -----------------
// D3DCOMPILE_DEBUG
//   Insert debug file/line/type/symbol information.
//
// D3DCOMPILE_SKIP_VALIDATION
//   Do not validate the generated code against known capabilities and
//   constraints.  This option is only recommended when compiling shaders
//   you KNOW will work.  (ie. have compiled before without this option.)
//   Shaders are always validated by D3D before they are set to the device.
//
// D3DCOMPILE_SKIP_OPTIMIZATION 
//   Instructs the compiler to skip optimization steps during code generation.
//   Unless you are trying to isolate a problem in your code using this option 
//   is not recommended.
//
// D3DCOMPILE_PACK_MATRIX_ROW_MAJOR
//   Unless explicitly specified, matrices will be packed in row-major order
//   on input and output from the shader.
//
// D3DCOMPILE_PACK_MATRIX_COLUMN_MAJOR
//   Unless explicitly specified, matrices will be packed in column-major 
//   order on input and output from the shader.  This is generally more 
//   efficient, since it allows vector-matrix multiplication to be performed
//   using a series of dot-products.
//
// D3DCOMPILE_PARTIAL_PRECISION
//   Force all computations in resulting shader to occur at partial precision.
//   This may result in faster evaluation of shaders on some hardware.
//
// D3DCOMPILE_FORCE_VS_SOFTWARE_NO_OPT
//   Force compiler to compile against the next highest available software
//   target for vertex shaders.  This flag also turns optimizations off, 
//   and debugging on.  
//
// D3DCOMPILE_FORCE_PS_SOFTWARE_NO_OPT
//   Force compiler to compile against the next highest available software
//   target for pixel shaders.  This flag also turns optimizations off, 
//   and debugging on.
//
// D3DCOMPILE_NO_PRESHADER
//   Disables Preshaders. Using this flag will cause the compiler to not 
//   pull out static expression for evaluation on the host cpu
//
// D3DCOMPILE_AVOID_FLOW_CONTROL
//   Hint compiler to avoid flow-control constructs where possible.
//
// D3DCOMPILE_PREFER_FLOW_CONTROL
//   Hint compiler to prefer flow-control constructs where possible.
//
// D3DCOMPILE_ENABLE_STRICTNESS
//   By default, the HLSL/Effect compilers are not strict on deprecated syntax.
//   Specifying this flag enables the strict mode. Deprecated syntax may be
//   removed in a future release, and enabling syntax is a good way to make
//   sure your shaders comply to the latest spec.
//
// D3DCOMPILE_ENABLE_BACKWARDS_COMPATIBILITY
//   This enables older shaders to compile to 4_0 targets.
//
//----------------------------------------------------------------------------

enum D3DCOMPILE_DEBUG                          = (1 << 0);
enum D3DCOMPILE_SKIP_VALIDATION                = (1 << 1);
enum D3DCOMPILE_SKIP_OPTIMIZATION              = (1 << 2);
enum D3DCOMPILE_PACK_MATRIX_ROW_MAJOR          = (1 << 3);
enum D3DCOMPILE_PACK_MATRIX_COLUMN_MAJOR       = (1 << 4);
enum D3DCOMPILE_PARTIAL_PRECISION              = (1 << 5);
enum D3DCOMPILE_FORCE_VS_SOFTWARE_NO_OPT       = (1 << 6);
enum D3DCOMPILE_FORCE_PS_SOFTWARE_NO_OPT       = (1 << 7);
enum D3DCOMPILE_NO_PRESHADER                   = (1 << 8);
enum D3DCOMPILE_AVOID_FLOW_CONTROL             = (1 << 9);
enum D3DCOMPILE_PREFER_FLOW_CONTROL            = (1 << 10);
enum D3DCOMPILE_ENABLE_STRICTNESS              = (1 << 11);
enum D3DCOMPILE_ENABLE_BACKWARDS_COMPATIBILITY = (1 << 12);
enum D3DCOMPILE_IEEE_STRICTNESS                = (1 << 13);
enum D3DCOMPILE_OPTIMIZATION_LEVEL0            = (1 << 14);
enum D3DCOMPILE_OPTIMIZATION_LEVEL1            = 0;
enum D3DCOMPILE_OPTIMIZATION_LEVEL2            = ((1 << 14) | (1 << 15));
enum D3DCOMPILE_OPTIMIZATION_LEVEL3            = (1 << 15);
enum D3DCOMPILE_RESERVED16                     = (1 << 16);
enum D3DCOMPILE_RESERVED17                     = (1 << 17);
enum D3DCOMPILE_WARNINGS_ARE_ERRORS            = (1 << 18);

//----------------------------------------------------------------------------
// D3DCOMPILE_EFFECT flags:
// -------------------------------------
// These flags are passed in when creating an effect, and affect
// either compilation behavior or runtime effect behavior
//
// D3DCOMPILE_EFFECT_CHILD_EFFECT
//   Compile this .fx file to a child effect. Child effects have no
//   initializers for any shared values as these are initialied in the
//   master effect (pool).
//
// D3DCOMPILE_EFFECT_ALLOW_SLOW_OPS
//   By default, performance mode is enabled.  Performance mode
//   disallows mutable state objects by preventing non-literal
//   expressions from appearing in state object definitions.
//   Specifying this flag will disable the mode and allow for mutable
//   state objects.
//
//----------------------------------------------------------------------------

enum D3DCOMPILE_EFFECT_CHILD_EFFECT              = (1 << 0);
enum D3DCOMPILE_EFFECT_ALLOW_SLOW_OPS            = (1 << 1);

//----------------------------------------------------------------------------
// D3DCompile:
// ----------
// Compile source text into bytecode appropriate for the given target.
//----------------------------------------------------------------------------
extern(Windows) nothrow
HRESULT D3DCompile(
				LPCVOID pSrcData,
				SIZE_T SrcDataSize,
				LPCSTR pSourceName,
				const(D3D_SHADER_MACRO)* pDefines,
				ID3DInclude pInclude,
				LPCSTR pEntrypoint,
				LPCSTR pTarget,
				UINT Flags1,
				UINT Flags2,
				ID3DBlob* ppCode,
				ID3DBlob* ppErrorMsgs);

alias pD3DCompile = extern(Windows) nothrow HRESULT function(
     LPCVOID                         pSrcData,
     SIZE_T                          SrcDataSize,
     LPCSTR                          pFileName,
     const(D3D_SHADER_MACRO)*        pDefines,
     ID3DInclude                     pInclude,
     LPCSTR                          pEntrypoint,
     LPCSTR_D3D_SHADER_TARGET_ext    pTarget,
     UINT                            Flags1,
     UINT                            Flags2,
     ID3DBlob*                       ppCode,
     ID3DBlob*                       ppErrorMsgs);
	 
	 
// NOTE: Since D3DCompiler_44 D3DCompileFromFile is now part of the DirectX rather than Windows
extern(Windows) nothrow
HRESULT D3DCompileFromFile(
				LPCWSTR pFileName,
				const(D3D_SHADER_MACRO)* pDefines,
				ID3DInclude pInclude,
				LPCSTR pEntrypoint,
				LPCSTR pTarget,
				UINT Flags1,
				UINT Flags2,
				ID3DBlob* ppCode,
				ID3DBlob* ppErrorMsgs);
     
//----------------------------------------------------------------------------
// D3DPreprocess:
// ----------
// Process source text with the compiler's preprocessor and return
// the resulting text.
//----------------------------------------------------------------------------

extern(Windows) nothrow
HRESULT D3DPreprocess(
				LPCVOID pSrcData,
				SIZE_T SrcDataSize,
				LPCSTR pSourceName,
				const(D3D_SHADER_MACRO)* pDefines,
				ID3DInclude pInclude,
				ID3DBlob* ppCodeText,
				ID3DBlob* ppErrorMsgs);

alias pD3DPreprocess = extern(Windows) nothrow HRESULT function(
     LPCVOID                      pSrcData,
     SIZE_T                       SrcDataSize,
     LPCSTR                       pFileName,
     const(D3D_SHADER_MACRO)*     pDefines,
     ID3DInclude                  pInclude,
     ID3DBlob*                    ppCodeText,
     ID3DBlob*                    ppErrorMsgs);

//----------------------------------------------------------------------------
// D3DGetDebugInfo:
// -----------------------
// Gets shader debug info.  Debug info is generated by D3DCompile and is
// embedded in the body of the shader.
//----------------------------------------------------------------------------

extern(Windows) nothrow
HRESULT D3DGetDebugInfo(
				LPCVOID pSrcData,
				SIZE_T SrcDataSize,
				ID3DBlob* ppDebugInfo);

//----------------------------------------------------------------------------
// D3DReflect:
// ----------
// Shader code contains metadata that can be inspected via the
// reflection APIs.
//----------------------------------------------------------------------------

extern(Windows) nothrow
HRESULT D3DReflect(
				LPCVOID pSrcData,
				SIZE_T SrcDataSize,
				REFIID pInterface,
				void** ppReflector);

//----------------------------------------------------------------------------
// D3DDisassemble:
// ----------------------
// Takes a binary shader and returns a buffer containing text assembly.
//----------------------------------------------------------------------------

enum D3D_DISASM_ENABLE_COLOR_CODE            = 0x00000001;
enum D3D_DISASM_ENABLE_DEFAULT_VALUE_PRINTS  = 0x00000002;
enum D3D_DISASM_ENABLE_INSTRUCTION_NUMBERING = 0x00000004;
enum D3D_DISASM_ENABLE_INSTRUCTION_CYCLE     = 0x00000008;
enum D3D_DISASM_DISABLE_DEBUG_INFO           = 0x00000010;

extern(Windows) nothrow
HRESULT D3DDisassemble(
				LPCVOID pSrcData,
				SIZE_T SrcDataSize,
				UINT Flags,
				LPCSTR szComments,
				ID3DBlob* ppDisassembly);

alias pD3DDisassemble = extern(Windows) nothrow HRESULT function(
     LPCVOID pSrcData,
     SIZE_T SrcDataSize,
     UINT Flags,
     LPCSTR szComments,
     ID3DBlob* ppDisassembly);

//----------------------------------------------------------------------------
// D3DDisassemble10Effect:
// -----------------------
// Takes a D3D10 effect interface and returns a
// buffer containing text assembly.
//----------------------------------------------------------------------------

extern(Windows) nothrow
HRESULT D3DDisassemble10Effect(
				ID3D10Effect pEffect,
				UINT Flags,
                ID3DBlob* ppDisassembly);

//----------------------------------------------------------------------------
// D3DGetInputSignatureBlob:
// -----------------------
// Retrieve the input signature from a compilation result.
//----------------------------------------------------------------------------

extern(Windows) nothrow
HRESULT D3DGetInputSignatureBlob(
				LPCVOID pSrcData,
				SIZE_T SrcDataSize,
				ID3DBlob* ppSignatureBlob);

//----------------------------------------------------------------------------
// D3DGetOutputSignatureBlob:
// -----------------------
// Retrieve the output signature from a compilation result.
//----------------------------------------------------------------------------

extern(Windows) nothrow
HRESULT D3DGetOutputSignatureBlob(
				LPCVOID pSrcData,
				SIZE_T SrcDataSize,
				ID3DBlob* ppSignatureBlob);

//----------------------------------------------------------------------------
// D3DGetInputAndOutputSignatureBlob:
// -----------------------
// Retrieve the input and output signatures from a compilation result.
//----------------------------------------------------------------------------

extern(Windows) nothrow
HRESULT D3DGetInputAndOutputSignatureBlob(
				LPCVOID pSrcData,
				SIZE_T SrcDataSize,
				ID3DBlob* ppSignatureBlob);

//----------------------------------------------------------------------------
// D3DStripShader:
// -----------------------
// Removes unwanted blobs from a compilation result
//----------------------------------------------------------------------------

enum D3DCOMPILER_STRIP_FLAGS
{
    D3DCOMPILER_STRIP_REFLECTION_DATA = 1,
    D3DCOMPILER_STRIP_DEBUG_INFO      = 2,
    D3DCOMPILER_STRIP_TEST_BLOBS      = 4,
    D3DCOMPILER_STRIP_FORCE_DWORD     = 0x7fffffff,
}

extern(Windows) nothrow
HRESULT D3DStripShader(
				LPCVOID pShaderBytecode,
				SIZE_T BytecodeLength,
				UINT uStripFlags,
				ID3DBlob* ppStrippedBlob);

//----------------------------------------------------------------------------
// D3DGetBlobPart:
// -----------------------
// Extracts information from a compilation result.
//----------------------------------------------------------------------------
alias D3D_BLOB_PART = int;
enum : D3D_BLOB_PART
{
    D3D_BLOB_INPUT_SIGNATURE_BLOB,
    D3D_BLOB_OUTPUT_SIGNATURE_BLOB,
    D3D_BLOB_INPUT_AND_OUTPUT_SIGNATURE_BLOB,
    D3D_BLOB_PATCH_CONSTANT_SIGNATURE_BLOB,
    D3D_BLOB_ALL_SIGNATURE_BLOB,
    D3D_BLOB_DEBUG_INFO,
    D3D_BLOB_LEGACY_SHADER,
    D3D_BLOB_XNA_PREPASS_SHADER,
    D3D_BLOB_XNA_SHADER,

    // Test parts are only produced by special compiler versions and so
    // are usually not present in shaders.
    D3D_BLOB_TEST_ALTERNATE_SHADER = 0x8000,
    D3D_BLOB_TEST_COMPILE_DETAILS,
    D3D_BLOB_TEST_COMPILE_PERF,
}

extern(Windows) nothrow
HRESULT D3DGetBlobPart(
				LPCVOID pSrcData,
				SIZE_T SrcDataSize,
				D3D_BLOB_PART Part,
				UINT Flags,
				ID3DBlob* ppPart);

//----------------------------------------------------------------------------
// D3DCompressShaders:
// -----------------------
// Compresses a set of shaders into a more compact form.
//----------------------------------------------------------------------------

struct _D3D_SHADER_DATA
{
    LPCVOID pBytecode;
    SIZE_T BytecodeLength;
}
alias _D3D_SHADER_DATA D3D_SHADER_DATA;

enum D3D_COMPRESS_SHADER_KEEP_ALL_PARTS = 0x00000001;

extern(Windows) nothrow
HRESULT D3DCompressShaders(
				UINT uNumShaders,
				D3D_SHADER_DATA* pShaderData,
				UINT uFlags,
				ID3DBlob* ppCompressedData);

//----------------------------------------------------------------------------
// D3DDecompressShaders:
// -----------------------
// Decompresses one or more shaders from a compressed set.
//----------------------------------------------------------------------------

extern(Windows) nothrow
HRESULT D3DDecompressShaders(
				LPCVOID pSrcData,
				SIZE_T SrcDataSize,
				UINT uNumShaders,
				UINT uStartIndex,
				UINT* pIndices,
				UINT uFlags,
				ID3DBlob* ppShaders,
				UINT* pTotalShaders);

//----------------------------------------------------------------------------
// D3DCreateBlob:
// -----------------------
// Create an ID3DBlob instance.
//----------------------------------------------------------------------------

extern(Windows) nothrow
HRESULT D3DCreateBlob(
				SIZE_T Size,
				ID3DBlob* ppBlob);


}
