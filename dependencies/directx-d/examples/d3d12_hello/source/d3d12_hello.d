/*
THIS IS PORTED VERSION OF MICROSOFT DirectX12 "HelloTriangle"" EXAMPLE
ORIGNAL SOURCES CAN BE FOUND HERE:
https://github.com/Microsoft/DirectX-Graphics-Samples
*/

import core.stdc.string : memcpy;
import std.stdio;
import std.string : toStringz;
import std.conv : to;

import directx.d3d12;
import directx.d3d12sdklayers;
import directx.dxgi1_4;
import directx.d3dcompiler;


class D3D12Hello
{
	this(uint width, uint height, HWND hWnd)
	{
		this.hWnd = hWnd;
		this.width = width;
		this.height = height;

		viewport.MinDepth = 0.0f;
		viewport.MaxDepth = 1.0f;
		OnResize(width, height);

		LoadPipeline();
		LoadAssets();
	}


	void LoadPipeline()
	{
		// Enable the D3D12 debug layer.
		debug
    	{
			ID3D12Debug debugController;

			scope(exit) 
				if (debugController) 
					debugController.Release(); 
			
			if (SUCCEEDED(D3D12GetDebugInterface(&IID_ID3D12Debug, cast(void**)&debugController)))
			{
				debugController.EnableDebugLayer();
			}
		}

		IDXGIFactory4 factory;
		scope(exit)
			if (factory)
				factory.Release();

		if(FAILED(CreateDXGIFactory1(&IID_IDXGIFactory4, cast(void**)&factory)))
		{
			throw new D3D12Exception("Create DXGI Factory failed");
		}

		IDXGIAdapter1 hardwareAdapter;
		scope(exit)
			if (hardwareAdapter)
				hardwareAdapter.Release();

        GetHardwareAdapter(factory, hardwareAdapter);

        if(FAILED(D3D12CreateDevice(
            hardwareAdapter,
            D3D_FEATURE_LEVEL_11_0,
            &IID_ID3D12Device,
			&device,
			)))
		{
			throw new D3D12Exception("Create device failed");
		}

		// Describe and create the command queue.
    	D3D12_COMMAND_QUEUE_DESC queueDesc;
    	queueDesc.Flags = D3D12_COMMAND_QUEUE_FLAG_NONE;
    	queueDesc.Type = D3D12_COMMAND_LIST_TYPE_DIRECT;

		if (FAILED(device.CreateCommandQueue(&queueDesc, &IID_ID3D12CommandQueue, &commandQueue)))
		{
			throw new D3D12Exception("CreateCommandQueue failed");
		}

    	// Describe and create the swap chain.
    	DXGI_SWAP_CHAIN_DESC swapChainDesc;
    	swapChainDesc.BufferCount = frameCount;
    	swapChainDesc.BufferDesc.Width = width;
    	swapChainDesc.BufferDesc.Height = height;
    	swapChainDesc.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
    	swapChainDesc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    	swapChainDesc.SwapEffect = DXGI_SWAP_EFFECT_FLIP_DISCARD;
    	swapChainDesc.OutputWindow = hWnd;
    	swapChainDesc.SampleDesc.Count = 1;
    	swapChainDesc.Windowed = TRUE;

		IDXGISwapChain swapChain;
		scope(exit) if (swapChain) swapChain.Release();

    	if (FAILED(factory.CreateSwapChain(
        	commandQueue,        // Swap chain needs the queue so that it can force a flush on it.
        	&swapChainDesc,
        	&swapChain
			)))
		{
			throw new D3D12Exception("Init swapchain failed");
		}

		this.swapChain = cast(IDXGISwapChain3)swapChain;
		if( !this.swapChain )
		{
			throw new D3D12Exception("failed to assign swap chain");
		}

    	// This sample does not support fullscreen transitions.
		if (FAILED(factory.MakeWindowAssociation(null, DXGI_MWA_NO_ALT_ENTER)))
		{
			throw new D3D12Exception("Window association error");
		}

    	frameIndex = this.swapChain.GetCurrentBackBufferIndex();

		// Create descriptor heaps.
		{
			
			// Describe and create a render target view (RTV) descriptor heap.
			D3D12_DESCRIPTOR_HEAP_DESC rtvHeapDesc;
			rtvHeapDesc.NumDescriptors = frameCount;
			rtvHeapDesc.Type = D3D12_DESCRIPTOR_HEAP_TYPE_RTV;
			rtvHeapDesc.Flags = D3D12_DESCRIPTOR_HEAP_FLAG_NONE;
			auto hr = device.CreateDescriptorHeap(&rtvHeapDesc, &IID_ID3D12DescriptorHeap, &rtvHeap);
			if (FAILED(hr))
			{
				throw new D3D12Exception("failed to create descriptor heap");
			}

			rtvDescriptorSize = device.GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_RTV);
		}

		// Create frame resources.
		{
			D3D12_CPU_DESCRIPTOR_HANDLE rtvHandle = rtvHeap.GetCPUDescriptorHandleForHeapStart();

			// Create a RTV for each frame.
			for (UINT n = 0; n < frameCount; n++)
			{
				if (FAILED(swapChain.GetBuffer(n, &IID_ID3D12Resource, cast(void**)&renderTargets[n])))
				{
					throw new D3D12Exception("failed to create frame resource N=" ~ to!string(n));
				}

				device.CreateRenderTargetView(renderTargets[n], null, rtvHandle);
				rtvHandle.ptr += cast(size_t)(1 * rtvDescriptorSize);
			}
		}

		if (FAILED(device.CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, &IID_ID3D12CommandAllocator, &commandAllocator)))
		{
			throw new D3D12Exception("failed to create command allocators");
		}
	}

    void LoadAssets()
	{
		// Create an empty root signature.
		{
			D3D12_ROOT_SIGNATURE_DESC rootSignatureDesc = {
				0, null, 0, null, D3D12_ROOT_SIGNATURE_FLAG_ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT
			};

			ID3DBlob signature;
			ID3DBlob error;
			scope(exit) { if (signature) signature.Release(); if (error) error.Release(); }
			if (FAILED(D3D12SerializeRootSignature(&rootSignatureDesc, D3D_ROOT_SIGNATURE_VERSION_1, &signature, &error)))
			{
				throw new D3D12Exception("Unable to serialize root signature");
			}
			if (FAILED(device.CreateRootSignature(0, signature.GetBufferPointer(), signature.GetBufferSize(), &IID_ID3D12RootSignature, &rootSignature)))
			{
				throw new D3D12Exception("Unable to create root signature");
			}
		}

		// Create the pipeline state, which includes compiling and loading shaders.
		{
			ID3DBlob vertexShader;
			ID3DBlob pixelShader;
			scope(exit)
			{
				if(vertexShader) vertexShader.Release();
				if(pixelShader) pixelShader.Release();
			}

				// Enable better shader debugging with the graphics debugging tools.
			debug UINT compileFlags = D3DCOMPILE_DEBUG | D3DCOMPILE_SKIP_OPTIMIZATION;
			else UINT compileFlags = 0;

			enum shaderSource = import("d3d12hello.hlsl");

			if (FAILED(D3DCompile(shaderSource.ptr, shaderSource.length, "shaders.hlsl", null, null, "VSMain", vs_5_0, compileFlags, 0, &vertexShader, null)))
			{
				throw new D3D12Exception("unable to compile vertex shader");
			}
			if (FAILED(D3DCompile(shaderSource.ptr, shaderSource.length, "shaders.hlsl", null, null, "PSMain", ps_5_0, compileFlags, 0, &pixelShader, null)))
			{
				throw new D3D12Exception("unable to compile pixel shader");
			}

			// Define the vertex input layout.
			auto inputElementDescs = Vertex.GetVertexLayoutDescr();

			// Describe and create the graphics pipeline state object (PSO).
			D3D12_GRAPHICS_PIPELINE_STATE_DESC psoDesc;
			psoDesc.InputLayout = D3D12_INPUT_LAYOUT_DESC( inputElementDescs.ptr, cast(uint)inputElementDescs.length );
			psoDesc.pRootSignature = rootSignature;
			psoDesc.VS = D3D12_SHADER_BYTECODE ( vertexShader.GetBufferPointer(), vertexShader.GetBufferSize() );
			psoDesc.PS = D3D12_SHADER_BYTECODE ( pixelShader.GetBufferPointer(), pixelShader.GetBufferSize() );
			psoDesc.RasterizerState = D3D12_RASTERIZER_DESC();
			psoDesc.BlendState = D3D12_BLEND_DESC();
			psoDesc.DepthStencilState.DepthEnable = FALSE;
			psoDesc.DepthStencilState.StencilEnable = FALSE;
			psoDesc.SampleMask = UINT.max;
			psoDesc.PrimitiveTopologyType = D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE;
			psoDesc.NumRenderTargets = 1;
			psoDesc.RTVFormats[0] = DXGI_FORMAT_R8G8B8A8_UNORM;
			psoDesc.SampleDesc.Count = 1;

			if (FAILED(device.CreateGraphicsPipelineState(&psoDesc, &IID_ID3D12PipelineState, &pipelineState)))
			{
				throw new D3D12Exception("unable to create pipeline state");
			}
		}


		 // Create the command list.
		if (FAILED(device.CreateCommandList(0u, D3D12_COMMAND_LIST_TYPE_DIRECT, commandAllocator, pipelineState, &IID_ID3D12GraphicsCommandList, cast(ID3D12CommandList*)&commandList)))
		{
			throw new D3D12Exception("failed to create command lists");
		}

    	// Command lists are created in the recording state, but there is nothing
    	// to record yet. The main loop expects it to be closed, so close it now.
		if (FAILED(commandList.Close()))
		{
			throw new D3D12Exception("failed to close command list");
		}


		// Create the vertex buffer.
		{
			if ( height < 1) height = 1;
			auto aspectRatio = width / height;

			// Define the geometry for a triangle.
			Vertex[] triangleVertices =
			[
				{ [ 0.0f, 0.25f * aspectRatio, 0.0f ], [ 1.0f, 0.0f, 0.0f, 1.0f ] },
				{ [ 0.25f, -0.25f * aspectRatio, 0.0f ], [ 0.0f, 1.0f, 0.0f, 1.0f ] },
				{ [ -0.25f, -0.25f * aspectRatio, 0.0f ], [ 0.0f, 0.0f, 1.0f, 1.0f ] }
			];

			const UINT vertexBufferSize = cast(UINT)(triangleVertices.length * Vertex.sizeof);

			auto heapProperties = D3D12_HEAP_PROPERTIES(D3D12_HEAP_TYPE_UPLOAD, D3D12_CPU_PAGE_PROPERTY_UNKNOWN, D3D12_MEMORY_POOL_UNKNOWN, 1, 1);
			auto resourceDesc = D3D12_RESOURCE_DESC(D3D12_RESOURCE_DIMENSION_BUFFER, 0, vertexBufferSize, 1, 1, 1,DXGI_FORMAT_UNKNOWN, DXGI_SAMPLE_DESC(1,0), D3D12_TEXTURE_LAYOUT_ROW_MAJOR, D3D12_RESOURCE_FLAG_NONE);
			// Note: using upload heaps to transfer static data like vert buffers is not 
			// recommended. Every time the GPU needs it, the upload heap will be marshalled 
			// over. Please read up on Default Heap usage. An upload heap is used here for 
			// code simplicity and because there are very few verts to actually transfer.
			if (FAILED(device.CreateCommittedResource(
					&heapProperties,
					D3D12_HEAP_FLAG_NONE,
					&resourceDesc,
					D3D12_RESOURCE_STATE_GENERIC_READ,
					null,
					&IID_ID3D12Resource,
					&vertexBuffer)))
			{
				throw new D3D12Exception("failed to vertex buffer resource");
			}

			// Copy the triangle data to the vertex buffer.
			ubyte* pVertexDataBegin;
			auto readRange = D3D12_RANGE(0, 0);        // We do not intend to read from this resource on the CPU.
			if (FAILED(vertexBuffer.Map(0, &readRange, cast(void**)&pVertexDataBegin)))
			{
				throw new D3D12Exception("failed to map vertex buffer");
			}

			memcpy(pVertexDataBegin, triangleVertices.ptr, vertexBufferSize);
			vertexBuffer.Unmap(0, null);

			// Initialize the vertex buffer view.
			vertexBufferView.BufferLocation = vertexBuffer.GetGPUVirtualAddress();
			vertexBufferView.StrideInBytes = Vertex.sizeof;
			vertexBufferView.SizeInBytes = vertexBufferSize;
		}


		// Create synchronization objects and wait until assets have been uploaded to the GPU.
		{
			if (FAILED(device.CreateFence(0, D3D12_FENCE_FLAG_NONE, &IID_ID3D12Fence, &fence)))
			{
				throw new D3D12Exception("failed to create fence");
			}
			fenceValue = 1;

			// Create an event handle to use for frame synchronization.
			fenceEvent = CreateEvent(null, FALSE, FALSE, null);
			if (fenceEvent == null)
			{
				if (FAILED(HRESULT_FROM_WIN32(GetLastError())))
				{
					throw new D3D12Exception("failed to fence event");
				}
			}

			// Wait for the command list to execute; we are reusing the same command 
			// list in our main loop but for now, we just want to wait for setup to 
			// complete before continuing.
			WaitForPreviousFrame();
		}

	}


    void WaitForPreviousFrame()
	{
		// WAITING FOR THE FRAME TO COMPLETE BEFORE CONTINUING IS NOT BEST PRACTICE.
		// This is code implemented as such for simplicity. More advanced samples 
		// illustrate how to use fences for efficient resource usage.

		// Signal and increment the fence value.
		const UINT64 lfence = fenceValue;
		if (FAILED(commandQueue.Signal(fence, lfence)))
		{
			throw new D3D12Exception("command queue signal fail");
		}
		fenceValue++;

		// Wait until the previous frame is finished.
		if (fence.GetCompletedValue() < lfence)
		{
			if (FAILED(fence.SetEventOnCompletion(lfence, fenceEvent)))
			{
				throw new D3D12Exception("failed to set fence completion event");
			}
			WaitForSingleObject(fenceEvent, INFINITE);
		}

		frameIndex = swapChain.GetCurrentBackBufferIndex();
	}


	void PopulateCommandList()
	{
		// Command list allocators can only be reset when the associated 
		// command lists have finished execution on the GPU; apps should use 
		// fences to determine GPU execution progress.
		if (FAILED(commandAllocator.Reset()))
		{
			throw new D3D12Exception("failed to reset command allocators");
		}

		// However, when ExecuteCommandList() is called on a particular command 
		// list, that command list can then be reset at any time and must be before 
		// re-recording.
		if (FAILED(commandList.Reset(commandAllocator, pipelineState)))
		{
			throw new D3D12Exception("failed to reset command list");
		}

		// Set necessary state.
		commandList.SetGraphicsRootSignature(rootSignature);
		commandList.RSSetViewports(1, &viewport);
		commandList.RSSetScissorRects(1, &scissorRect);

		D3D12_RESOURCE_BARRIER resBarrier;
        resBarrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
        resBarrier.Flags = D3D12_RESOURCE_BARRIER_FLAG_NONE;
        resBarrier.Transition.pResource = renderTargets[frameIndex];
        resBarrier.Transition.StateBefore = D3D12_RESOURCE_STATE_PRESENT;
        resBarrier.Transition.StateAfter = D3D12_RESOURCE_STATE_RENDER_TARGET;
        resBarrier.Transition.Subresource = D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES;

		// Indicate that the back buffer will be used as a render target.
		commandList.ResourceBarrier(1, &resBarrier);

		auto rtvHandle = D3D12_CPU_DESCRIPTOR_HANDLE(cast(size_t)(rtvHeap.GetCPUDescriptorHandleForHeapStart().ptr + cast(void*)(frameIndex * rtvDescriptorSize)));
		commandList.OMSetRenderTargets(1, &rtvHandle, FALSE, null);

		// Record commands.
		const float[4] clearColor = [ 0.0f, 0.2f, 0.4f, 1.0f ];
		commandList.ClearRenderTargetView(rtvHandle, clearColor.ptr, 0, null);
		commandList.IASetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
		commandList.IASetVertexBuffers(0, 1, &vertexBufferView);
		commandList.DrawInstanced(3, 1, 0, 0);

        resBarrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
        resBarrier.Flags = D3D12_RESOURCE_BARRIER_FLAG_NONE;
        resBarrier.Transition.pResource = renderTargets[frameIndex];
        resBarrier.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET;
        resBarrier.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT;
        resBarrier.Transition.Subresource = D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES;
		// Indicate that the back buffer will now be used to present.
		commandList.ResourceBarrier(1, &resBarrier);

		if (FAILED(commandList.Close()))
		{
			throw new D3D12Exception("command list close failed");
		}
	}


	final void OnResize(int w, int h)
	{
		viewport.Width = w;
		viewport.Height = h;

		scissorRect.left = 0;
		scissorRect.top = 0;
		scissorRect.right = w;
		scissorRect.bottom = h;
	}

	void OnUpdate(float deltaSec) 
	{
		OnRender();
	}


	void OnRender() 
	{
		// Record all the commands we need to render the scene into the command list.
		PopulateCommandList();

		// Execute the command list.
		ID3D12CommandList[] ppCommandLists = [ commandList ];
		commandQueue.ExecuteCommandLists( cast(UINT) ppCommandLists.length, ppCommandLists.ptr);

		// Present the frame.
		if (FAILED(swapChain.Present(1, 0)))
		{
			throw new D3D12Exception("swapchain present error");
		}

		WaitForPreviousFrame();
	}


	void OnDestroy()
	{
		// Wait for the GPU to be done with all resources.
		WaitForPreviousFrame();

		CloseHandle(fenceEvent);

		commandList.Release();
		commandQueue.Release();
		commandAllocator.Release();
		vertexBuffer.Release();
		foreach( rt; renderTargets) 
			rt.Release();
		rtvHeap.Release();
		pipelineState.Release();
		swapChain.Release();
		fence.Release();

		debug
		{
			ID3D12DebugDevice deb;
			device.QueryInterface(&IID_ID3D12DebugDevice, cast(void**)&deb);
			if (deb)
			{
				deb.ReportLiveDeviceObjects(D3D12_RLDO_DETAIL);
			}
		}

		// TODO: clean up missing ID3D12RootSignature and ID3D12PipelineState

		rootSignature.Release();
		device.Release();
	}

	private struct Vertex
	{
		float[3] position;
		float[4] color;

		static D3D12_INPUT_ELEMENT_DESC[] GetVertexLayoutDescr() {
			// Define the vertex input layout.
			D3D12_INPUT_ELEMENT_DESC[] inputElementDescs =
			[
				{ "POSITION", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 0, D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA, 0 },
				{ "COLOR", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, 12, D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA, 0 }
			];
			return inputElementDescs;
		}
	}

	static enum frameCount = 2;

private:
	uint width;
	uint height;
	HWND hWnd;

	// Pipeline objects.
    D3D12_VIEWPORT viewport;
    D3D12_RECT scissorRect;
    IDXGISwapChain3 swapChain;
    ID3D12Device device;
    ID3D12Resource[frameCount] renderTargets;
    ID3D12CommandAllocator commandAllocator;
    ID3D12CommandQueue commandQueue;
    ID3D12RootSignature rootSignature;
    ID3D12DescriptorHeap rtvHeap;
    ID3D12PipelineState pipelineState;
    ID3D12GraphicsCommandList commandList;
    UINT rtvDescriptorSize;

	// App resources.
    ID3D12Resource vertexBuffer;
    D3D12_VERTEX_BUFFER_VIEW vertexBufferView;

    // Synchronization objects.
    UINT frameIndex;
    HANDLE fenceEvent;
    ID3D12Fence fence;
    UINT64 fenceValue;
}

private void GetHardwareAdapter(IDXGIFactory2 pFactory, ref IDXGIAdapter1 ppAdapter)
{
	IDXGIAdapter1 adapter;
	ppAdapter = null;

	for (UINT adapterIndex = 0; DXGI_ERROR_NOT_FOUND != pFactory.EnumAdapters1(adapterIndex, &adapter); ++adapterIndex)
	{
		DXGI_ADAPTER_DESC1 desc;
		adapter.GetDesc1(&desc);

		if (desc.Flags & DXGI_ADAPTER_FLAG_SOFTWARE)
		{
			// skip Basic Render Driver adapter.
			continue;
		}

		// Check to see if the adapter supports Direct3D 12, but don't create the
		// actual device yet.
		if (SUCCEEDED(D3D12CreateDevice(adapter, D3D_FEATURE_LEVEL_11_0, &IID_ID3D12Device, null)))
		{
			break;
		}
	}

	ppAdapter = adapter;
}

class D3D12Exception : Exception 
{
	this() { super("D3D12 exception"); }
	this(string msg) { super(msg); }
}