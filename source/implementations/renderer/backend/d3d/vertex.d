module implementations.renderer.backend.d3d.vertex;

version(Windows):
import std.conv:to;
import error.handler;
import directx.d3d11;
import implementations.renderer.backend.d3d.renderer;
import implementations.renderer.backend.vertex.vertex;


/**
* For reflecting OpenGL API, we create an accessor with the create functions, this is a locally
* managed array, but you're able to get it by using the private name, for flexibility.
*/
__gshared ID3D11Buffer[] _hip_d3d_arrVBO;
__gshared ID3D11Buffer[] _hip_d3d_arrVAO;

enum AttributeType
{
    FLOAT = 0,
    INT = 1,
    BOOL = 2
}

uint createVertexArrayObject()
{
    if(_hip_d3d_arrVAO.length + 1 > _hip_d3d_arrVAO.capacity)
        _hip_d3d_arrVAO.reserve(_hip_d3d_arrVAO.length*2);
    
    _hip_d3d_arrVAO~= null;
    return cast(uint)_hip_d3d_arrVAO.length;
}

uint createVertexBufferObject()
{
    if(_hip_d3d_arrVBO.length+1 > _hip_d3d_arrVBO.capacity)
        _hip_d3d_arrVBO.reserve(_hip_d3d_arrVBO.length*2);
    
    _hip_d3d_arrVBO~= null;
    return cast(uint)_hip_d3d_arrVBO.length;
}

void setVertexAttribute(ref VertexAttributeInfo info, uint stride)
{
    // glVertexAttribPointer(info.index, info.length, info.valueType, GL_FALSE, stride, cast(void*)info.offset);
    // glEnableVertexAttribArray(info.index);
}

DXGI_FORMAT _hip_d3d_getFormatFromInfo(ref VertexAttributeInfo info)
{
    DXGI_FORMAT ret;
    switch(info.valueType)
    {
        case AttributeType.FLOAT:
            switch(info.length)
            {
                case 1:
                    ret = DXGI_FORMAT_R32_FLOAT;
                    break;
                case 2:
                    ret = DXGI_FORMAT_R32G32_FLOAT;
                    break;
                case 3:
                    ret = DXGI_FORMAT_R32G32B32_FLOAT;
                    break;
                case 4:
                    ret = DXGI_FORMAT_R32G32B32A32_FLOAT;
                    break;
                default:
                    ErrorHandler.showErrorMessage("DXGI Format Error",
                    "Unknown format type from float with length " ~ to!string(info.length));
            }
            break;
        case AttributeType.BOOL:
        case AttributeType.INT:
            switch(info.length)
            {
                case 1:
                    ret = DXGI_FORMAT_R32_SINT;
                    break;
                case 2:
                    ret = DXGI_FORMAT_R32G32_SINT;
                    break;
                case 3:
                    ret = DXGI_FORMAT_R32G32B32_SINT;
                    break;
                case 4:
                    ret = DXGI_FORMAT_R32G32B32A32_SINT;
                    break;
                default:
                    ErrorHandler.showErrorMessage("DXGI Format Error",
                    "Unknown format type from int/bool with length " ~ to!string(info.length));
            }
            break;
        default:
            ErrorHandler.showErrorMessage("DXGI Format Error", "Unknown format type from info");
            break;
    }
    return ret;
}

void useVertexArrayObject(ref VertexArrayObject obj)
{
    D3D11_INPUT_ELEMENT_DESC[] descs;
    descs.length = obj.infos.length;

    D3D11_INPUT_ELEMENT_DESC desc;
    foreach(i, info; obj.infos)
    {
        desc.SemanticName = cast(char*)(info.name~"\0").ptr;
        desc.SemanticIndex = cast(uint)i;
        desc.Format = _hip_d3d_getFormatFromInfo(info);
        desc.InputSlot = 0;
        desc.AlignedByteOffset = info.offset;
        desc.InputSlotClass = D3D11_INPUT_PER_VERTEX_DATA;
        desc.InstanceDataStepRate = 0;
        descs[i] = desc;
    }

    ID3D11InputLayout inputLayout;

    _hip_d3d_device.CreateInputLayout(descs.ptr, descs.length,
    vs.shader.GetBufferPointer(), vs.shader.GetBufferSize(), &inputLayout);

    _hip_d3d_context.IASetInputLayout(inputLayout);
}

void setVertexArrayObjectData(ref VertexArrayObject obj, void* data, size_t dataSize)
{
    D3D11_BUFFER_DESC bd;
    bd.BindFlags = D3D11_BIND_VERTEX_BUFFER;
    bd.Usage = (obj.isStatic) ? D3D11_USAGE_DEFAULT : D3D11_USAGE_DYNAMIC;
    bd.CPUAccessFlags = 0u;
    bd.MiscFlags = 0u;
    bd.ByteWidth = cast(uint)dataSize;
    bd.StructureByteStride = obj.stride;

    D3D11_SUBRESOURCE_DATA sd;
    sd.pSysMem = data;

    //TODO: Check failure

    
    _hip_d3d_device.CreateBuffer(&bd, &sd, &_hip_d3d_arrVBO[obj.VBO]);
    _hip_d3d_context.IASetVertexBuffers(0u, 1u, &_hip_d3d_arrVBO[obj.VBO], &obj.stride, &obj.offset);


}

void deleteVertexArrayObject(ref VertexArrayObject obj)
{
    // glDeleteBuffers(1, &obj.ID);
    obj.ID = 0;
    obj.index = 0;
}

void deleteVertexBufferObject(ref VertexArrayObject obj)
{
    if(obj.VBO != 0)
    {
        // glDeleteBuffers(1, &obj.VBO);
        obj.VBO = 0;
    }
}

void deleteElementBufferObject(ref VertexArrayObject obj)
{
    if(obj.EBO != 0)
    {
        // glDeleteBuffers(1, &obj.EBO);
        obj.EBO = 0;
    }
}
