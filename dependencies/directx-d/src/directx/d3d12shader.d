module directx.d3d12shader;
//////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) Microsoft Corporation.  All rights reserved.
//
//  File:       D3D12Shader.h
//  Content:    D3D12 Shader Types and APIs
//
//////////////////////////////////////////////////////////////////////////////

version(Windows):

public import directx.d3dcommon;

alias DWORD D3D12_SHADER_VERSION_TYPE;
enum : D3D12_SHADER_VERSION_TYPE
{
    D3D12_SHVER_PIXEL_SHADER    = 0,
    D3D12_SHVER_VERTEX_SHADER   = 1,
    D3D12_SHVER_GEOMETRY_SHADER = 2,

    // D3D11 Shaders
    D3D12_SHVER_HULL_SHADER     = 3,
    D3D12_SHVER_DOMAIN_SHADER   = 4,
    D3D12_SHVER_COMPUTE_SHADER  = 5,

    D3D12_SHVER_RESERVED0       = 0xFFF0,
}

pure nothrow @safe @nogc {
    DWORD D3D12_SHVER_GET_TYPE(DWORD _Version) {
        return (_Version >> 16) & 0xffff;
    }
    DWORD D3D12_SHVER_GET_MAJOR(DWORD _Version) {
        return (_Version >> 4) & 0xf;
    }
    DWORD D3D12_SHVER_GET_MINOR(DWORD _Version) {
        return (_Version >> 0) & 0xf;
    }
}

// Slot ID for library function return
enum D3D_RETURN_PARAMETER_INDEX = (-1);

alias D3D_RESOURCE_RETURN_TYPE D3D12_RESOURCE_RETURN_TYPE;

alias D3D_CBUFFER_TYPE D3D12_CBUFFER_TYPE;

struct D3D12_SIGNATURE_PARAMETER_DESC
{
    LPCSTR                      SemanticName;   // Name of the semantic
    UINT                        SemanticIndex;  // Index of the semantic
    UINT                        Register;       // Number of member variables
    D3D_NAME                    SystemValueType;// A predefined system value, or D3D_NAME_UNDEFINED if not applicable
    D3D_REGISTER_COMPONENT_TYPE ComponentType;  // Scalar type (e.g. uint, float, etc.)
    BYTE                        Mask;           // Mask to indicate which components of the register
    // are used (combination of D3D10_COMPONENT_MASK values)
    BYTE                        ReadWriteMask;  // Mask to indicate whether a given component is
    // never written (if this is an output signature) or
    // always read (if this is an input signature).
    // (combination of D3D_MASK_* values)
    UINT                        Stream;         // Stream index
    D3D_MIN_PRECISION           MinPrecision;   // Minimum desired interpolation precision
}

struct D3D12_SHADER_BUFFER_DESC
{
    LPCSTR                  Name;           // Name of the constant buffer
    D3D_CBUFFER_TYPE        Type;           // Indicates type of buffer content
    UINT                    Variables;      // Number of member variables
    UINT                    Size;           // Size of CB (in bytes)
    UINT                    uFlags;         // Buffer description flags
}

struct D3D12_SHADER_VARIABLE_DESC
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

struct D3D12_SHADER_TYPE_DESC
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

alias D3D12_TESSELLATOR_DOMAIN = D3D_TESSELLATOR_DOMAIN;

alias D3D12_TESSELLATOR_PARTITIONING = D3D_TESSELLATOR_PARTITIONING;

alias D3D12_TESSELLATOR_OUTPUT_PRIMITIVE = D3D_TESSELLATOR_OUTPUT_PRIMITIVE;

struct D3D12_SHADER_DESC
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
    D3D_PRIMITIVE_TOPOLOGY  GSOutputTopology;            // Geometry shader output topology
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

struct D3D12_SHADER_INPUT_BIND_DESC
{
    LPCSTR                      Name;           // Name of the resource
    D3D_SHADER_INPUT_TYPE       Type;           // Type of resource (e.g. texture, cbuffer, etc.)
    UINT                        BindPoint;      // Starting bind point
    UINT                        BindCount;      // Number of contiguous bind points (for arrays)

    UINT                        uFlags;         // Input binding flags
    D3D_RESOURCE_RETURN_TYPE    ReturnType;     // Return type (if texture)
    D3D_SRV_DIMENSION           Dimension;      // Dimension (if texture)
    UINT                        NumSamples;     // Number of samples (0 if not MS texture)
    UINT                        Space;          // Register space
    UINT uID;                                   // Range ID in the bytecode
}

enum D3D_SHADER_REQUIRES_DOUBLES = 0x00000001;
enum D3D_SHADER_REQUIRES_EARLY_DEPTH_STENCIL = 0x00000002;
enum D3D_SHADER_REQUIRES_UAVS_AT_EVERY_STAGE = 0x00000004;
enum D3D_SHADER_REQUIRES_64_UAVS = 0x00000008;
enum D3D_SHADER_REQUIRES_MINIMUM_PRECISION = 0x00000010;
enum D3D_SHADER_REQUIRES_11_1_DOUBLE_EXTENSIONS = 0x00000020;
enum D3D_SHADER_REQUIRES_11_1_SHADER_EXTENSIONS = 0x00000040;
enum D3D_SHADER_REQUIRES_LEVEL_9_COMPARISON_FILTERING = 0x00000080;
enum D3D_SHADER_REQUIRES_TILED_RESOURCES = 0x00000100;
enum D3D_SHADER_REQUIRES_STENCIL_REF = 0x00000200;
enum D3D_SHADER_REQUIRES_INNER_COVERAGE = 0x00000400;
enum D3D_SHADER_REQUIRES_TYPED_UAV_LOAD_ADDITIONAL_FORMATS = 0x00000800;
enum D3D_SHADER_REQUIRES_ROVS = 0x00001000;
enum D3D_SHADER_REQUIRES_VIEWPORT_AND_RT_ARRAY_INDEX_FROM_ANY_SHADER_FEEDING_RASTERIZER = 0x00002000;

struct D3D12_LIBRARY_DESC
{
    LPCSTR    Creator;           // The name of the originator of the library.
    UINT      Flags;             // Compilation flags.
    UINT      FunctionCount;     // Number of functions exported from the library.
}

struct D3D12_FUNCTION_DESC
{
    UINT                    Version;                     // Shader version
    LPCSTR                  Creator;                     // Creator string
    UINT                    Flags;                       // Shader compilation/parse flags

    UINT                    ConstantBuffers;             // Number of constant buffers
    UINT                    BoundResources;              // Number of bound resources

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
    UINT                    MovInstructionCount;         // Number of mov instructions used
    UINT                    MovcInstructionCount;        // Number of movc instructions used
    UINT                    ConversionInstructionCount;  // Number of type conversion instructions used
    UINT                    BitwiseInstructionCount;     // Number of bitwise arithmetic instructions used
    D3D_FEATURE_LEVEL       MinFeatureLevel;             // Min target of the function byte code
    UINT64                  RequiredFeatureFlags;        // Required feature flags

    LPCSTR                  Name;                        // Function name
    INT                     FunctionParameterCount;      // Number of logical parameters in the function signature (not including return)
    BOOL                    HasReturn;                   // TRUE, if function returns a value, false - it is a subroutine
    BOOL                    Has10Level9VertexShader;     // TRUE, if there is a 10L9 VS blob
    BOOL                    Has10Level9PixelShader;      // TRUE, if there is a 10L9 PS blob
}

struct D3D12_PARAMETER_DESC
{
    LPCSTR                      Name;               // Parameter name.
    LPCSTR                      SemanticName;       // Parameter semantic name (+index).
    D3D_SHADER_VARIABLE_TYPE    Type;               // Element type.
    D3D_SHADER_VARIABLE_CLASS   Class;              // Scalar/Vector/Matrix.
    UINT                        Rows;               // Rows are for matrix parameters.
    UINT                        Columns;            // Components or Columns in matrix.
    D3D_INTERPOLATION_MODE      InterpolationMode;  // Interpolation mode.
    D3D_PARAMETER_FLAGS         Flags;              // Parameter modifiers.

    UINT                        FirstInRegister;    // The first input register for this parameter.
    UINT                        FirstInComponent;   // The first input register component for this parameter.
    UINT                        FirstOutRegister;   // The first output register for this parameter.
    UINT                        FirstOutComponent;  // The first output register component for this parameter.
}

//////////////////////////////////////////////////////////////////////////////
// Interfaces ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

mixin( uuid!(ID3D12ShaderReflectionType, "e913c351-783d-48ca-a1d1-4f306284ad56") );
extern (C++) interface ID3D12ShaderReflectionType : IUnknown
{
    HRESULT GetDesc(D3D12_SHADER_TYPE_DESC* pDesc);

    ID3D12ShaderReflectionType GetMemberTypeByIndex(UINT Index);
    ID3D12ShaderReflectionType GetMemberTypeByName(LPCSTR Name);
    LPCSTR GetMemberTypeName(UINT Index);

    HRESULT IsEqual(ID3D12ShaderReflectionType pType);
    ID3D12ShaderReflectionType GetSubType();
    ID3D12ShaderReflectionType GetBaseClass();
    UINT GetNumInterfaces();
    ID3D12ShaderReflectionType GetInterfaceByIndex(UINT uIndex);
    HRESULT IsOfType(ID3D12ShaderReflectionType pType);
    HRESULT ImplementsInterface(ID3D12ShaderReflectionType pBase);
}

mixin( uuid!(ID3D12ShaderReflectionVariable, "8337a8a6-a216-444a-b2f4-314733a73aea") );
extern (C++) interface ID3D12ShaderReflectionVariable : IUnknown
{
    HRESULT GetDesc(D3D12_SHADER_VARIABLE_DESC* pDesc);

    ID3D12ShaderReflectionType GetType();
    ID3D12ShaderReflectionConstantBuffer GetBuffer();

    UINT GetInterfaceSlot(UINT uArrayIndex);
}

mixin( uuid!(ID3D12ShaderReflectionConstantBuffer, "c59598b4-48b3-4869-b9b1-b1618b14a8b7") );
extern (C++) interface ID3D12ShaderReflectionConstantBuffer : IUnknown
{
    HRESULT GetDesc(D3D12_SHADER_BUFFER_DESC* pDesc);

    ID3D12ShaderReflectionVariable GetVariableByIndex(UINT Index);
    ID3D12ShaderReflectionVariable GetVariableByName(LPCSTR Name);
}

mixin( uuid!(ID3D12ShaderReflection, "5a58797d-a72c-478d-8ba2-efc6b0efe88e") );
extern (C++) interface ID3D12ShaderReflection : IUnknown
{
    HRESULT GetDesc(D3D12_SHADER_DESC* pDesc);

    ID3D12ShaderReflectionConstantBuffer GetConstantBufferByIndex(UINT Index);
    ID3D12ShaderReflectionConstantBuffer GetConstantBufferByName(LPCSTR Name);

    HRESULT GetResourceBindingDesc(UINT ResourceIndex,
                                   D3D12_SHADER_INPUT_BIND_DESC* pDesc);

    HRESULT GetInputParameterDesc(UINT ParameterIndex,
                                  D3D12_SIGNATURE_PARAMETER_DESC* pDesc);
    HRESULT GetOutputParameterDesc(UINT ParameterIndex,
                                   D3D12_SIGNATURE_PARAMETER_DESC* pDesc);
    HRESULT GetPatchConstantParameterDesc(UINT ParameterIndex,
                                          D3D12_SIGNATURE_PARAMETER_DESC* pDesc);

    ID3D12ShaderReflectionVariable GetVariableByName(LPCSTR Name);

    HRESULT GetResourceBindingDescByName(LPCSTR Name,
                                         D3D12_SHADER_INPUT_BIND_DESC* pDesc);

    UINT GetMovInstructionCount();
    UINT GetMovcInstructionCount();
    UINT GetConversionInstructionCount();
    UINT GetBitwiseInstructionCount();

    D3D_PRIMITIVE GetGSInputPrimitive();
    BOOL IsSampleFrequencyShader();

    UINT GetNumInterfaceSlots();
    HRESULT GetMinFeatureLevel(D3D_FEATURE_LEVEL* pLevel);

    UINT GetThreadGroupSize(
        UINT* pSizeX,
        UINT* pSizeY,
        UINT* pSizeZ);

    UINT64 GetRequiresFlags();
}

mixin( uuid!(ID3D12LibraryReflection, "8e349d19-54db-4a56-9dc9-119d87bdb804") );
extern (C++) interface ID3D12LibraryReflection : IUnknown
{
    HRESULT GetDesc(D3D12_LIBRARY_DESC* pDesc);

    ID3D12FunctionReflection GetFunctionByIndex(INT FunctionIndex);
}

mixin( uuid!(ID3D12FunctionReflection, "1108795c-2772-4ba9-b2a8-d464dc7e2799") );
extern (C++) interface ID3D12FunctionReflection : IUnknown
{
    HRESULT GetDesc(D3D12_FUNCTION_DESC * pDesc);

    ID3D12ShaderReflectionConstantBuffer GetConstantBufferByIndex(UINT BufferIndex);
    ID3D12ShaderReflectionConstantBuffer GetConstantBufferByName(LPCSTR Name);

    HRESULT GetResourceBindingDesc(UINT ResourceIndex,
                                   D3D12_SHADER_INPUT_BIND_DESC* pDesc);

    ID3D12ShaderReflectionVariable GetVariableByName(LPCSTR Name);

    HRESULT GetResourceBindingDescByName(LPCSTR Name,
                                         D3D12_SHADER_INPUT_BIND_DESC* pDesc);

    // Use D3D_RETURN_PARAMETER_INDEX to get description of the return value.
    ID3D12FunctionParameterReflection GetFunctionParameter(INT ParameterIndex);
};

mixin( uuid!(ID3D12FunctionParameterReflection, "ec25f42d-7006-4f2b-b33e-02cc3375733f") );
extern (C++) interface ID3D12FunctionParameterReflection : IUnknown
{
    HRESULT GetDesc(D3D12_PARAMETER_DESC* pDesc);
}
