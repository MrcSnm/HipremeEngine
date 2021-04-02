module directx.d3d11shader;
//////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) Microsoft Corporation.  All rights reserved.
//
//  File:       D3D11Shader.h
//  Content:    D3D11 Shader Types and APIs
//
//////////////////////////////////////////////////////////////////////////////

version(Windows):

public import directx.d3dcommon;

alias D3D11_SHADER_VERSION_TYPE = int;
enum : D3D11_SHADER_VERSION_TYPE
{
    D3D11_SHVER_PIXEL_SHADER    = 0,
    D3D11_SHVER_VERTEX_SHADER   = 1,
    D3D11_SHVER_GEOMETRY_SHADER = 2,
    
    // D3D11 Shaders
    D3D11_SHVER_HULL_SHADER     = 3,
    D3D11_SHVER_DOMAIN_SHADER   = 4,
    D3D11_SHVER_COMPUTE_SHADER  = 5,
}

int D3D11_SHVER_GET_TYPE(T)(_Version) {
    return (((_Version) >> 16) & 0xffff);
}

int D3D11_SHVER_GET_MAJOR(T)(_Version) {
    return (((_Version) >> 4) & 0xf);
}

int D3D11_SHVER_GET_MINOR(T)(_Version) {
    return (((_Version) >> 0) & 0xf);
}

alias D3D_RESOURCE_RETURN_TYPE D3D11_RESOURCE_RETURN_TYPE;

alias D3D_CBUFFER_TYPE D3D11_CBUFFER_TYPE;

struct _D3D11_SIGNATURE_PARAMETER_DESC
{
    LPCSTR                      SemanticName;   // Name of the semantic
    UINT                        SemanticIndex;  // Index of the semantic
    UINT                        Register;       // Number of member variables
    D3D_NAME                    SystemValueType;// A predefined system value, or D3D_NAME_UNDEFINED if not applicable
    D3D_REGISTER_COMPONENT_TYPE ComponentType;// Scalar type (e.g. uint, float, etc.)
    BYTE                        Mask;           // Mask to indicate which components of the register
                                                // are used (combination of D3D10_COMPONENT_MASK values)
    BYTE                        ReadWriteMask;  // Mask to indicate whether a given component is 
                                                // never written (if this is an output signature) or
                                                // always read (if this is an input signature).
                                                // (combination of D3D10_COMPONENT_MASK values)
    UINT Stream;                                // Stream index
}
alias _D3D11_SIGNATURE_PARAMETER_DESC D3D11_SIGNATURE_PARAMETER_DESC;

struct _D3D11_SHADER_BUFFER_DESC
{
    LPCSTR                  Name;           // Name of the constant buffer
    D3D_CBUFFER_TYPE        Type;           // Indicates type of buffer content
    UINT                    Variables;      // Number of member variables
    UINT                    Size;           // Size of CB (in bytes)
    UINT                    uFlags;         // Buffer description flags
}
alias _D3D11_SHADER_BUFFER_DESC D3D11_SHADER_BUFFER_DESC;

struct _D3D11_SHADER_VARIABLE_DESC
{
    LPCSTR                  Name;           // Name of the variable
    UINT                    StartOffset;    // Offset in constant buffer's backing store
    UINT                    Size;           // Size of variable (in bytes)
    UINT                    uFlags;         // Variable flags
    LPVOID                  DefaultValue;   // Raw pointer to default value
    UINT                    StartTexture;   // First texture index (or -1 if no textures used)
    UINT                    TextureSize;    // Number of texture slots possibly used.
    UINT                    StartSampler;   // First sampler index (or -1 if no textures used)
    UINT                    SamplerSize;    // Number of sampler slots possibly used.
}
alias _D3D11_SHADER_VARIABLE_DESC D3D11_SHADER_VARIABLE_DESC;

struct _D3D11_SHADER_TYPE_DESC
{
    D3D_SHADER_VARIABLE_CLASS   Class;          // Variable class (e.g. object, matrix, etc.)
    D3D_SHADER_VARIABLE_TYPE    Type;           // Variable type (e.g. float, sampler, etc.)
    UINT                        Rows;           // Number of rows (for matrices, 1 for other numeric, 0 if not applicable)
    UINT                        Columns;        // Number of columns (for vectors & matrices, 1 for other numeric, 0 if not applicable)
    UINT                        Elements;       // Number of elements (0 if not an array)
    UINT                        Members;        // Number of members (0 if not a structure)
    UINT                        Offset;         // Offset from the start of structure (0 if not a structure member)
    LPCSTR                      Name;           // Name of type, can be NULL
}
alias _D3D11_SHADER_TYPE_DESC D3D11_SHADER_TYPE_DESC;

alias D3D_TESSELLATOR_DOMAIN D3D11_TESSELLATOR_DOMAIN;

alias D3D_TESSELLATOR_PARTITIONING D3D11_TESSELLATOR_PARTITIONING;

alias D3D_TESSELLATOR_OUTPUT_PRIMITIVE D3D11_TESSELLATOR_OUTPUT_PRIMITIVE;

struct _D3D11_SHADER_DESC
{
    UINT                    Version;                     // Shader version
    LPCSTR                  Creator;                     // Creator string
    UINT                    Flags;                       // Shader compilation/parse flags
    
    UINT                    ConstantBuffers;             // Number of constant buffers
    UINT                    BoundResources;              // Number of bound resources
    UINT                    InputParameters;             // Number of parameters in the input signature
    UINT                    OutputParameters;            // Number of parameters in the output signature

    UINT                    InstructionCount;            // Number of emitted instructions
    UINT                    TempRegisterCount;           // Number of temporary registers used 
    UINT                    TempArrayCount;              // Number of temporary arrays used
    UINT                    DefCount;                    // Number of constant defines 
    UINT                    DclCount;                    // Number of declarations (input + output)
    UINT                    TextureNormalInstructions;   // Number of non-categorized texture instructions
    UINT                    TextureLoadInstructions;     // Number of texture load instructions
    UINT                    TextureCompInstructions;     // Number of texture comparison instructions
    UINT                    TextureBiasInstructions;     // Number of texture bias instructions
    UINT                    TextureGradientInstructions; // Number of texture gradient instructions
    UINT                    FloatInstructionCount;       // Number of floating point arithmetic instructions used
    UINT                    IntInstructionCount;         // Number of signed integer arithmetic instructions used
    UINT                    UintInstructionCount;        // Number of unsigned integer arithmetic instructions used
    UINT                    StaticFlowControlCount;      // Number of static flow control instructions used
    UINT                    DynamicFlowControlCount;     // Number of dynamic flow control instructions used
    UINT                    MacroInstructionCount;       // Number of macro instructions used
    UINT                    ArrayInstructionCount;       // Number of array instructions used
    UINT                    CutInstructionCount;         // Number of cut instructions used
    UINT                    EmitInstructionCount;        // Number of emit instructions used
    D3D_PRIMITIVE_TOPOLOGY   GSOutputTopology;           // Geometry shader output topology
    UINT                    GSMaxOutputVertexCount;      // Geometry shader maximum output vertex count
    D3D_PRIMITIVE           InputPrimitive;              // GS/HS input primitive
    UINT                    PatchConstantParameters;     // Number of parameters in the patch constant signature
    UINT                    cGSInstanceCount;            // Number of Geometry shader instances
    UINT                    cControlPoints;              // Number of control points in the HS->DS stage
    D3D_TESSELLATOR_OUTPUT_PRIMITIVE HSOutputPrimitive;  // Primitive output by the tessellator
    D3D_TESSELLATOR_PARTITIONING HSPartitioning;         // Partitioning mode of the tessellator
    D3D_TESSELLATOR_DOMAIN  TessellatorDomain;           // Domain of the tessellator (quad, tri, isoline)
    // instruction counts
    UINT cBarrierInstructions;                           // Number of barrier instructions in a compute shader
    UINT cInterlockedInstructions;                       // Number of interlocked instructions
    UINT cTextureStoreInstructions;                      // Number of texture writes
}
alias _D3D11_SHADER_DESC D3D11_SHADER_DESC;

struct _D3D11_SHADER_INPUT_BIND_DESC
{
    LPCSTR                      Name;           // Name of the resource
    D3D_SHADER_INPUT_TYPE       Type;           // Type of resource (e.g. texture, cbuffer, etc.)
    UINT                        BindPoint;      // Starting bind point
    UINT                        BindCount;      // Number of contiguous bind points (for arrays)
    
    UINT                        uFlags;         // Input binding flags
    D3D_RESOURCE_RETURN_TYPE    ReturnType;     // Return type (if texture)
    D3D_SRV_DIMENSION           Dimension;      // Dimension (if texture)
    UINT                        NumSamples;     // Number of samples (0 if not MS texture)
}
alias _D3D11_SHADER_INPUT_BIND_DESC D3D11_SHADER_INPUT_BIND_DESC;


//////////////////////////////////////////////////////////////////////////////
// Interfaces ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

mixin( uuid!(ID3D11ShaderReflectionType, "6E6FFA6A-9BAE-4613-A51E-91652D508C21") );
interface ID3D11ShaderReflectionType
{
	extern(Windows):
	HRESULT GetDesc(
				D3D11_SHADER_TYPE_DESC* pDesc);
    
    ID3D11ShaderReflectionType GetMemberTypeByIndex(
				UINT Index);
	
    ID3D11ShaderReflectionType GetMemberTypeByName(
				LPCSTR Name);
	
    LPCSTR GetMemberTypeName(
				UINT Index);

    HRESULT IsEqual(
				ID3D11ShaderReflectionType pType);

    ID3D11ShaderReflectionType GetSubType();
	
    ID3D11ShaderReflectionType GetBaseClass();
	
    UINT GetNumInterfaces();
	
    ID3D11ShaderReflectionType GetInterfaceByIndex(
				UINT uIndex);
	
    HRESULT IsOfType(
				ID3D11ShaderReflectionType pType);
				
    HRESULT ImplementsInterface(
				ID3D11ShaderReflectionType pBase);
}
alias ID3D11ShaderReflectionType LPD3D11SHADERREFLECTIONTYPE;



mixin( uuid!(ID3D11ShaderReflectionVariable, "51F23923-F3E5-4BD1-91CB-606177D8DB4C") );
interface ID3D11ShaderReflectionVariable
{
	extern(Windows):
	HRESULT GetDesc(
				D3D11_SHADER_VARIABLE_DESC* pDesc);
    
    ID3D11ShaderReflectionType GetType();

    ID3D11ShaderReflectionConstantBuffer GetBuffer();

    UINT GetInterfaceSlot(
				UINT uArrayIndex);
}
alias ID3D11ShaderReflectionVariable LPD3D11SHADERREFLECTIONVARIABLE;




mixin( uuid!(ID3D11ShaderReflectionConstantBuffer, "EB62D63D-93DD-4318-8AE8-C6F83AD371B8") );
interface ID3D11ShaderReflectionConstantBuffer
{
	extern(Windows):
	HRESULT GetDesc(
				D3D11_SHADER_BUFFER_DESC* pDesc);
    
    ID3D11ShaderReflectionVariable GetVariableByIndex(
				UINT Index);
				
    ID3D11ShaderReflectionVariable GetVariableByName(
				LPCSTR Name);
	
}
alias ID3D11ShaderReflectionConstantBuffer LPD3D11SHADERREFLECTIONCONSTANTBUFFER;



// The ID3D11ShaderReflection IID may change from SDK version to SDK version
// if the reflection API changes.  This prevents new code with the new API
// from working with an old binary.  Recompiling with the new header
// will pick up the new IID.

mixin( uuid!(ID3D11ShaderReflection, "0a233719-3960-4578-9d7c-203b8b1d9cc1") );
interface ID3D11ShaderReflection : IUnknown
{
	extern(Windows):
    HRESULT GetDesc(
				D3D11_SHADER_DESC* pDesc);
    
    ID3D11ShaderReflectionConstantBuffer GetConstantBufferByIndex(
				UINT Index);

    ID3D11ShaderReflectionConstantBuffer GetConstantBufferByName(
				LPCSTR Name);
    
    HRESULT GetResourceBindingDesc(
				UINT ResourceIndex,
				D3D11_SHADER_INPUT_BIND_DESC* pDesc);
    
    HRESULT GetInputParameterDesc(
				UINT ParameterIndex,
				D3D11_SIGNATURE_PARAMETER_DESC* pDesc);
				
    HRESULT GetOutputParameterDesc(
				UINT ParameterIndex,
				D3D11_SIGNATURE_PARAMETER_DESC* pDesc);
				
    HRESULT GetPatchConstantParameterDesc(
				UINT ParameterIndex,
				D3D11_SIGNATURE_PARAMETER_DESC* pDesc);

    ID3D11ShaderReflectionVariable GetVariableByName(
				LPCSTR Name);

    HRESULT GetResourceBindingDescByName(
				LPCSTR Name,
				D3D11_SHADER_INPUT_BIND_DESC* pDesc);

    UINT GetMovInstructionCount();

    UINT GetMovcInstructionCount();

    UINT GetConversionInstructionCount();

    UINT GetBitwiseInstructionCount();
    
    D3D_PRIMITIVE GetGSInputPrimitive();
	
    BOOL IsSampleFrequencyShader();

    UINT GetNumInterfaceSlots();
	
    HRESULT GetMinFeatureLevel(
				D3D_FEATURE_LEVEL* pLevel) ;

    UINT GetThreadGroupSize(
				UINT* pSizeX,
				UINT* pSizeY,
				UINT* pSizeZ);
	
}
alias ID3D11ShaderReflection LPD3D11SHADERREFLECTION;