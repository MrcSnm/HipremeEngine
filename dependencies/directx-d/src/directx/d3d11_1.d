module directx.d3d11_1;
/*-------------------------------------------------------------------------------------
 *
 * Copyright (c) Microsoft Corporation
 *
 *-------------------------------------------------------------------------------------*/

version(Windows):

public import directx.dxgi1_2;
public import directx.d3d11;

alias D3D11_COPY_FLAGS = int;
enum : D3D11_COPY_FLAGS
{
	D3D11_COPY_NO_OVERWRITE	= 0x1,
	D3D11_COPY_DISCARD	= 0x2
}

alias D3D11_LOGIC_OP = int;
enum : D3D11_LOGIC_OP
{
	D3D11_LOGIC_OP_CLEAR	= 0,
	D3D11_LOGIC_OP_SET	= ( D3D11_LOGIC_OP_CLEAR + 1 ) ,
	D3D11_LOGIC_OP_COPY	= ( D3D11_LOGIC_OP_SET + 1 ) ,
	D3D11_LOGIC_OP_COPY_INVERTED	= ( D3D11_LOGIC_OP_COPY + 1 ) ,
	D3D11_LOGIC_OP_NOOP	= ( D3D11_LOGIC_OP_COPY_INVERTED + 1 ) ,
	D3D11_LOGIC_OP_INVERT	= ( D3D11_LOGIC_OP_NOOP + 1 ) ,
	D3D11_LOGIC_OP_AND	= ( D3D11_LOGIC_OP_INVERT + 1 ) ,
	D3D11_LOGIC_OP_NAND	= ( D3D11_LOGIC_OP_AND + 1 ) ,
	D3D11_LOGIC_OP_OR	= ( D3D11_LOGIC_OP_NAND + 1 ) ,
	D3D11_LOGIC_OP_NOR	= ( D3D11_LOGIC_OP_OR + 1 ) ,
	D3D11_LOGIC_OP_XOR	= ( D3D11_LOGIC_OP_NOR + 1 ) ,
	D3D11_LOGIC_OP_EQUIV	= ( D3D11_LOGIC_OP_XOR + 1 ) ,
	D3D11_LOGIC_OP_AND_REVERSE	= ( D3D11_LOGIC_OP_EQUIV + 1 ) ,
	D3D11_LOGIC_OP_AND_INVERTED	= ( D3D11_LOGIC_OP_AND_REVERSE + 1 ) ,
	D3D11_LOGIC_OP_OR_REVERSE	= ( D3D11_LOGIC_OP_AND_INVERTED + 1 ) ,
	D3D11_LOGIC_OP_OR_INVERTED	= ( D3D11_LOGIC_OP_OR_REVERSE + 1 ) 
}

struct D3D11_RENDER_TARGET_BLEND_DESC1
{
	BOOL BlendEnable;
	BOOL LogicOpEnable;
	D3D11_BLEND SrcBlend;
	D3D11_BLEND DestBlend;
	D3D11_BLEND_OP BlendOp;
	D3D11_BLEND SrcBlendAlpha;
	D3D11_BLEND DestBlendAlpha;
	D3D11_BLEND_OP BlendOpAlpha;
	D3D11_LOGIC_OP LogicOp;
	UINT8 RenderTargetWriteMask;
}

struct D3D11_BLEND_DESC1
{
	BOOL AlphaToCoverageEnable = FALSE;
	BOOL IndependentBlendEnable = FALSE;
	D3D11_RENDER_TARGET_BLEND_DESC1[8] RenderTarget;

	void Init() @property
	{
			const D3D11_RENDER_TARGET_BLEND_DESC1 defaultRenderTargetBlendDesc =
			{
				FALSE,FALSE,
					D3D11_BLEND_ONE, D3D11_BLEND_ZERO, D3D11_BLEND_OP_ADD,
					D3D11_BLEND_ONE, D3D11_BLEND_ZERO, D3D11_BLEND_OP_ADD,
					D3D11_LOGIC_OP_NOOP,
					D3D11_COLOR_WRITE_ENABLE_ALL,
			};
			for (UINT i = 0; i < D3D11_SIMULTANEOUS_RENDER_TARGET_COUNT; ++i)
				RenderTarget[ i ] = defaultRenderTargetBlendDesc;
	}
}

mixin( uuid!(ID3D11BlendState1, "cc86fabe-da55-401d-85e7-e3c9de2877e9") );
extern (C++) interface ID3D11BlendState1 : ID3D11BlendState
{
	void GetDesc1( 
        /*out*/ D3D11_BLEND_DESC1* pDesc);
}

struct D3D11_RASTERIZER_DESC1
{
	D3D11_FILL_MODE FillMode = D3D11_FILL_SOLID;
	D3D11_CULL_MODE CullMode = D3D11_CULL_BACK;
	BOOL FrontCounterClockwise = FALSE;
	INT DepthBias = D3D11_DEFAULT_DEPTH_BIAS;
	FLOAT DepthBiasClamp = D3D11_DEFAULT_DEPTH_BIAS_CLAMP;
	FLOAT SlopeScaledDepthBias = D3D11_DEFAULT_SLOPE_SCALED_DEPTH_BIAS;
	BOOL DepthClipEnable = TRUE;
	BOOL ScissorEnable = FALSE;
	BOOL MultisampleEnable = FALSE;
	BOOL AntialiasedLineEnable = FALSE;
	UINT ForcedSampleCount = 0;
}

mixin( uuid!(ID3D11RasterizerState1, "1217d7a6-5039-418c-b042-9cbe256afd6e") );
extern (C++) interface ID3D11RasterizerState1 : ID3D11RasterizerState
{
    void GetDesc1( 
            /*out*/ D3D11_RASTERIZER_DESC1* pDesc);
}

alias D3D11_1_CREATE_DEVICE_CONTEXT_STATE_FLAG = int;
enum : D3D11_1_CREATE_DEVICE_CONTEXT_STATE_FLAG
{
	D3D11_1_CREATE_DEVICE_CONTEXT_STATE_SINGLETHREADED	= 0x1
}

mixin( uuid!(ID3DDeviceContextState, "5c1e0d8a-7c23-48f9-8c59-a92958ceff11") );
extern (C++) interface ID3DDeviceContextState : ID3D11DeviceChild
{
}

mixin( uuid!(ID3D11DeviceContext1, "bb2c6faa-b5fb-4082-8e6b-388b8cfa90e1") );
extern (C++) interface ID3D11DeviceContext1 : ID3D11DeviceContext
{
	void CopySubresourceRegion1( 
            ID3D11Resource pDstResource,
            UINT DstSubresource,
            UINT DstX,
            UINT DstY,
            UINT DstZ,
            ID3D11Resource pSrcResource,
            UINT SrcSubresource,
            const(D3D11_BOX)* pSrcBox,
            UINT CopyFlags);
        
	void UpdateSubresource1( 
            ID3D11Resource pDstResource,
            UINT DstSubresource,
            const(D3D11_BOX)* pDstBox,
            const(void*) pSrcData,
            UINT SrcRowPitch,
            UINT SrcDepthPitch,
            UINT CopyFlags);
        
	void DiscardResource( 
            ID3D11Resource pResource);
        
	void DiscardView( 
			ID3D11View pResourceView);
        
	void VSSetConstantBuffers1( 
            UINT StartSlot,
            UINT NumBuffers,
            const(ID3D11Buffer)* ppConstantBuffers,
            const(UINT)* pFirstConstant,
            const(UINT)* pNumConstants);
        
	void HSSetConstantBuffers1( 
			UINT StartSlot,
			UINT NumBuffers,
            const(ID3D11Buffer)* ppConstantBuffers,
            const(UINT)* pFirstConstant,
            const(UINT)* pNumConstants);
        
	void DSSetConstantBuffers1( 
			UINT StartSlot,
			UINT NumBuffers,
            const(ID3D11Buffer)* ppConstantBuffers,
            const(UINT)* pFirstConstant,
            const(UINT)* pNumConstants);
        
	void GSSetConstantBuffers1( 
			UINT StartSlot,
			UINT NumBuffers,
            const(ID3D11Buffer)* ppConstantBuffers,
            const(UINT)* pFirstConstant,
            const(UINT)* pNumConstants);
        
	void PSSetConstantBuffers1( 
			UINT StartSlot,
			UINT NumBuffers,
			const(ID3D11Buffer)* ppConstantBuffers,
			const(UINT)* pFirstConstant,
            const(UINT)* pNumConstants);
        
	void CSSetConstantBuffers1( 
			UINT StartSlot,
			UINT NumBuffers,
			const(ID3D11Buffer)* ppConstantBuffers,
			const(UINT)* pFirstConstant,
			const(UINT)* pNumConstants);
        
	void VSGetConstantBuffers1( 
			UINT StartSlot,
			UINT NumBuffers,
            /*out*/ ID3D11Buffer* ppConstantBuffers,
            /*out*/ UINT* pFirstConstant,
            /*out*/ UINT* pNumConstants);
        
	void HSGetConstantBuffers1( 
			UINT StartSlot,
			UINT NumBuffers,
			/*out*/ ID3D11Buffer* ppConstantBuffers,
			/*out*/ UINT* pFirstConstant,
            /*out*/ UINT* pNumConstants);
        
	void DSGetConstantBuffers1( 
			UINT StartSlot,
			UINT NumBuffers,
			/*out*/ ID3D11Buffer* ppConstantBuffers,
            /*out*/ UINT* pFirstConstant,
            /*out*/ UINT* pNumConstants);
        
	void GSGetConstantBuffers1( 
			UINT StartSlot,
			UINT NumBuffers,
            /*out*/ ID3D11Buffer* ppConstantBuffers,
            /*out*/ UINT* pFirstConstant,
            /*out*/ UINT* pNumConstants);
        
	void PSGetConstantBuffers1( 
			UINT StartSlot,
			UINT NumBuffers,
			/*out*/ ID3D11Buffer* ppConstantBuffers,
			/*out*/ UINT* pFirstConstant,
			/*out*/ UINT* pNumConstants);
        
	void CSGetConstantBuffers1( 
			UINT StartSlot,
			UINT NumBuffers,
			/*out*/ ID3D11Buffer* ppConstantBuffers,
			/*out*/ UINT* pFirstConstant,
			/*out*/ UINT* pNumConstants);
        
	void SwapDeviceContextState( 
			ID3DDeviceContextState pState,
			ID3DDeviceContextState* ppPreviousState) ;
        
	void ClearView( 
            ID3D11View pView,
            const(FLOAT)[4] Color,
			const(D3D11_RECT)* pRect,
            UINT NumRects);
        
	void DiscardView1( 
            ID3D11View pResourceView,
            const(D3D11_RECT)* pRects,
            UINT NumRects);
}

mixin( uuid!(ID3D11Device1, "a04bfb29-08ef-43d6-a49c-a9bdbdcbe686") );
extern (C++) interface ID3D11Device1 : ID3D11Device
{
	void GetImmediateContext1( 
            /*out*/ ID3D11DeviceContext1* ppImmediateContext);
        
	HRESULT CreateDeferredContext1( 
            UINT ContextFlags,
            /*out*/ ID3D11DeviceContext1* ppDeferredContext);
        
	HRESULT CreateBlendState1( 
            const(D3D11_BLEND_DESC1)* pBlendStateDesc,
            /*out*/ ID3D11BlendState1* ppBlendState);
        
	HRESULT CreateRasterizerState1( 
            const(D3D11_RASTERIZER_DESC1)* pRasterizerDesc,
            /*out*/ ID3D11RasterizerState1* ppRasterizerState);
        
	HRESULT CreateDeviceContextState( 
            UINT Flags,
			const(D3D_FEATURE_LEVEL)* pFeatureLevels,
			UINT FeatureLevels,
            UINT SDKVersion,
            REFIID EmulatedInterface,
            /*out*/ D3D_FEATURE_LEVEL* pChosenFeatureLevel,
            /*out*/ ID3DDeviceContextState* ppContextState);
        
	HRESULT OpenSharedResource1( 
            HANDLE hResource,
            REFIID returnedInterface,
            /*out*/ void** ppResource);
        
	HRESULT OpenSharedResourceByName( 
            LPCWSTR lpName,
            DWORD dwDesiredAccess,
            REFIID returnedInterface,
            /*out*/ void** ppResource);
}

mixin( uuid!(ID3DUserDefinedAnnotation, "b2daad8b-03d4-4dbf-95eb-32ab4b63d0ab") );
extern (C++) interface ID3DUserDefinedAnnotation : IUnknown
{
	INT BeginEvent( 
            LPCWSTR Name);
        
	INT EndEvent();
        
	void SetMarker( 
            LPCWSTR Name);
        
	BOOL GetStatus();
}
