module directx.d3d11_4;
/*-------------------------------------------------------------------------------------
*
* Copyright (c) Microsoft Corporation
*
*-------------------------------------------------------------------------------------*/

version(Windows):

public import directx.dxgi1_5;
public import directx.d3d11_3;

mixin(uuid!(ID3D11Device4, "8992ab71-02e6-4b8d-ba48-b056dcda42c4"));
extern (C++) interface ID3D11Device4 : ID3D11Device3 {
    HRESULT RegisterDeviceRemovedEvent(HANDLE hEvent, DWORD* pdwCookie);

    void UnregisterDeviceRemoved(DWORD dwCookie);
}
