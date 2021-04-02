module directx.d3d11_2;
/*-------------------------------------------------------------------------------------
 *
 * Copyright (c) Microsoft Corporation
 *
 *-------------------------------------------------------------------------------------*/

version(Windows):

public import directx.dxgi1_3;
public import directx.d3d11_1;

struct D3D11_TILED_RESOURCE_COORDINATE
{
	UINT X;
	UINT Y;
	UINT Z;
	UINT Subresource;
}

struct D3D11_TILE_REGION_SIZE
{
	UINT NumTiles;
	BOOL bUseBox;
	UINT Width;
	UINT16 Height;
	UINT16 Depth;
}

alias D3D11_TILE_MAPPING_FLAG = int;
enum : D3D11_TILE_MAPPING_FLAG
{
	D3D11_TILE_MAPPING_NO_OVERWRITE	= 0x1
}

alias D3D11_TILE_RANGE_FLAG = int;
enum : D3D11_TILE_RANGE_FLAG
{
	D3D11_TILE_RANGE_NULL	= 0x1,
	D3D11_TILE_RANGE_SKIP	= 0x2,
	D3D11_TILE_RANGE_REUSE_SINGLE_TILE	= 0x4
}

struct D3D11_SUBRESOURCE_TILING
{
	UINT WidthInTiles;
	UINT16 HeightInTiles;
	UINT16 DepthInTiles;
	UINT StartTileIndexInOverallResource;
}

enum D3D11_PACKED_TILE	= ( 0xffffffff );

struct D3D11_TILE_SHAPE
{
	UINT WidthInTexels;
	UINT HeightInTexels;
	UINT DepthInTexels;
}

struct D3D11_PACKED_MIP_DESC
{
	UINT8 NumStandardMips;
	UINT8 NumPackedMips;
	UINT NumTilesForPackedMips;
	UINT StartTileIndexInOverallResource;
}

alias D3D11_CHECK_MULTISAMPLE_QUALITY_LEVELS_FLAG = int;
enum : D3D11_CHECK_MULTISAMPLE_QUALITY_LEVELS_FLAG
{
	D3D11_CHECK_MULTISAMPLE_QUALITY_LEVELS_TILED_RESOURCE	= 0x1
}

alias D3D11_TILE_COPY_FLAG = int;
enum : D3D11_TILE_COPY_FLAG
{
	D3D11_TILE_COPY_NO_OVERWRITE	= 0x1,
	D3D11_TILE_COPY_LINEAR_BUFFER_TO_SWIZZLED_TILED_RESOURCE	= 0x2,
	D3D11_TILE_COPY_SWIZZLED_TILED_RESOURCE_TO_LINEAR_BUFFER	= 0x4
}

mixin( uuid!(ID3D11DeviceContext2, "420d5b32-b90c-4da4-bef0-359f6a24a83a") );
extern (C++) interface ID3D11DeviceContext2 : ID3D11DeviceContext1
{
	HRESULT UpdateTileMappings( 
		ID3D11Resource pTiledResource,
		UINT NumTiledResourceRegions,
		const(D3D11_TILED_RESOURCE_COORDINATE)* pTiledResourceRegionStartCoordinates,
		const(D3D11_TILE_REGION_SIZE)* pTiledResourceRegionSizes,
		ID3D11Buffer pTilePool,
		UINT NumRanges,
		const(UINT)* pRangeFlags,
		const(UINT)* pTilePoolStartOffsets,
		const(UINT)* pRangeTileCounts,
		UINT Flags);
        
	HRESULT CopyTileMappings( 
		ID3D11Resource pDestTiledResource,
		const(D3D11_TILED_RESOURCE_COORDINATE)* pDestRegionStartCoordinate,
		ID3D11Resource pSourceTiledResource,
		const(D3D11_TILED_RESOURCE_COORDINATE)* pSourceRegionStartCoordinate,
		const(D3D11_TILE_REGION_SIZE)* pTileRegionSize,
		UINT Flags);
        
	void CopyTiles( 
		ID3D11Resource pTiledResource,
		const(D3D11_TILED_RESOURCE_COORDINATE)* pTileRegionStartCoordinate,
		const(D3D11_TILE_REGION_SIZE)* pTileRegionSize,
		ID3D11Buffer pBuffer,
		UINT64 BufferStartOffsetInBytes,
		UINT Flags);
        
    void UpdateTiles( 
		ID3D11Resource pDestTiledResource,
		const(D3D11_TILED_RESOURCE_COORDINATE)* pDestTileRegionStartCoordinate,
		const(D3D11_TILE_REGION_SIZE)* pDestTileRegionSize,
		const(void*) pSourceTileData,
		UINT Flags);
        
	HRESULT ResizeTilePool( 
		ID3D11Buffer pTilePool,
		UINT64 NewSizeInBytes);
        
	void TiledResourceBarrier( 
		ID3D11DeviceChild pTiledResourceOrViewAccessBeforeBarrier,
		ID3D11DeviceChild pTiledResourceOrViewAccessAfterBarrier);
        
	BOOL IsAnnotationEnabled();
        
	void SetMarkerInt( 
		LPCWSTR pLabel,
		INT Data);
        
	void BeginEventInt( 
		LPCWSTR pLabel,
		INT Data);
        
	void EndEvent();
}

mixin( uuid!(ID3D11Device2, "9d06dffa-d1e5-4d07-83a8-1bb123f2f841") );
extern (C++) interface ID3D11Device2 : ID3D11Device1
{
	void GetImmediateContext2( 
		/*out*/ ID3D11DeviceContext2* ppImmediateContext);
        
	HRESULT CreateDeferredContext2( 
		UINT ContextFlags,
		/*out*/ ID3D11DeviceContext2* ppDeferredContext);
        
	void GetResourceTiling( 
		ID3D11Resource pTiledResource,
		/*out*/ UINT* pNumTilesForEntireResource,
		/*out*/ D3D11_PACKED_MIP_DESC* pPackedMipDesc,
		/*out*/ D3D11_TILE_SHAPE* pStandardTileShapeForNonPackedMips,
		/*inout*/ UINT *pNumSubresourceTilings,
		UINT FirstSubresourceTilingToGet,
		/*out*/ D3D11_SUBRESOURCE_TILING* pSubresourceTilingsForNonPackedMips);
        
	HRESULT CheckMultisampleQualityLevels1(
        DXGI_FORMAT Format,
        UINT SampleCount,
        UINT Flags,
        /*out*/ UINT* pNumQualityLevels);
}
