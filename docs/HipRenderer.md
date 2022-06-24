# HipRenderer - OpenGL ES 2/3, OpenGL 3, Direct3D 11 Abstraction


## Phylosophy

- HipRenderer was built based on OpenGL 3, as it was the first one to be implemented. That said, most of the nomenclatures are based on known OpenGL jargon.

- Specific Direct3D object wrappers were created later, so, on the OpenGL side it is a do nothing implementation. As a rule of thumb, the abstraction must always cover/prioritize the most specific case.

- Not currently thread safe, the class could even be a struct since its purely static.


## Useful enumerations

- HipBlendEquation
- HipBlendFunction
- HipRendererMode (Could later be changed to Primitives)
- HipRendererType


## Renderer API
Can be switched by changing the renderer.conf screen.renderer property:

- GL3
- D3D11



## Using it on a DLL
When the application does not own the Window, that is, built with the version(dll), it should be started with `HipRenderer.initExternal(HipRendererType)`


## HipRenderer object mapping table

| Hipreme Engine | OpenGL | Direct3D |
|:--------------:|:------:|:--------:|
| HipFrameBuffer | glFramebuffer/glRenderbuffer | ID3DRenderTargetView/ID3DShaderResourceView |
| IHipVertexArrayImpl | glVertexArray | ID3D11InputLayout |
| IHipVertexBufferImpl | glGenBuffer + GL_ARRAY_BUFFER | ID3D11Buffer + D3D11_BIND_VERTEX_BUFFER |
| IHipIndexBufferImpl | glGenBuffers + GL_ELEMENT_ARRAY_BUFFER | ID3D11Buffer + D3D11_BIND_INDEX_BUFFER |
| ShaderVariablesLayout | glGenBuffers + GL_UNIFORM_BUFFER | ID3D11Buffer + D3D11_BIND_CONSTANT_BUFFER |

- Please, notice that on Uniform Buffers, HipRenderer was a bit incosistent. There may be some opportunity for refactor. This happened due to Shaders being implemented without the idea of uniform buffers in the beggining.


## HipRendererMode mapping table

| Hipreme Engine | OpenGL | Direct3D |
|:--------------:|:------:|:--------:|
|POINT | GL_POINTS | D3D11_PRIMITIVE_TOPOLOGY_POINTLIST |
|LINE | GL_LINES | D3D11_PRIMITIVE_TOPOLOGY_LINELIST |
|LINE_STRIP | GL_LINE_STRIP | D3D11_PRIMITIVE_TOPOLOGY_LINESTRIP |
|TRIANGLES | GL_TRIANGLES | D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST |
|TRIANGLE_STRIP | GL_TRIANGLE_STRIP | D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP |

## TextureWrapMode mapping table
| Hipreme Engine | OpenGL | Direct3D | Additional info |
|:--------------:|:------:|:--------:|:---------------:|
|CLAMP_TO_EDGE | GL_CLAMP_TO_EDGE | D3D11_TEXTURE_ADDRESS_CLAMP | None |
|REPEAT | GL_REPEAT | D3D11_TEXTURE_ADDRESS_WRAP | None |
|MIRRORED_REPEAT | GL_MIRRORED_REPEAT| D3D11_TEXTURE_ADDRESS_MIRROR | None |
|MIRRORED_CLAMP_TO_EDGE | GL_MIRROR_CLAMP_TO_EDGE | D3D11_TEXTURE_ADDRESS_MIRROR_ONCE | Unsopported on GLES |
|CLAMP_TO_BORDER | GL_CLAMP_TO_BORDER | D3D11_TEXTURE_ADDRESS_BORDER | Unsupported on GLES |


## Shaders

- Function to create a FragmentShader
- Function to create a VertexShader
- Function to create a ShaderProgram
- A function to send the variable to the shader. The Uniform/Constant buffer
- They have specific implementations for GeometryBatch, SpriteBatch and BitmapText, listed on `HipShaderPresets`


### How to use it

For actually using a shader, you must first add a `ShaderVariablesLayout`, for it being able to connect Shader variables with the D code sent variable.

An example can be found on `HipSpriteBatch`.


#### How to create and use a shader

```d
Shader shader = HipRenderer.newShader(q{vertexShaderSource}, q{fragmentShaderSource});

///Create a variable layout for the vertex shader 
//"Cbuf1" means that if there is a struct/cbuffer, it'll be accessed from that name
shader.addVarLayout(new ShaderVariablesLayout("Cbuf1"), ShaderTypes.VERTEX, ShaderHint.NONE)
.append("uModel", Matrix4.identity) //Append a variable with name "uModel" and value Matrix4.identity
.append("uView", Matrix4.identity)
.append("uProj", Matrix4.identity));

//Now it is possible to set those values
//Setting variable layout for the fragment shader:
shader.addVarLayout(new ShaderVariablesLayout("Cbuf", ShaderTypes.FRAGMENT, ShaderHint.NONE)
    .append("uBatchColor", cast(float[4])[1,1,1,1]));

//Pretty much the same thing, only ShaderTypes has changed.

//Now, there comes an important part if you wish to make it work in both OpenGL and Direct3D with the same commands
//You can define a default Cbuf to know which variables you're setting. If this struct is not found, the command is simply ignored, so, you can make it work for both OpenGL without uniform buffers and Direct3D which requires cbuffers

shader.useLayout.Cbuf; //Cbuf is now the default variable setting target.

shader.uBatchColor = cast(float[4])[0.5, 0.5, 0.5];

//Bind the shader
shader.bind();
//Update the shader variables
shader.sendVars();

```

## Setting the shader vertex inputs

- Using a HipVertexArrayObject:

```d
HipVertexArrayObject obj = new HipVertexArrayObject();
//Define the attributes that this VAO contains:
with(HipAttributeType)
{
    obj.appendAttribute(2, FLOAT, float.sizeof, "vPosition") //X, Y
        .appendAttribute(2, FLOAT, float.sizeof, "vTexST"); //ST
}
//After that, we defined how the vertex input is formatted. There is helper functions that does exactly that (HipVertexArrayObject.getXY_ST_VAO)
//Now, for locking this format, call sendAttributes passing a Shader as an argument:
obj.bind();
obj.sendAttributes(shader);

//Create the data input
vao.createIndexBuffer(6, HipBufferUsage.STATIC);
vao.createVertexBuffer(4, HipBufferUsage.DYNAMIC);

//Now you can call both setVertices/updateVertices, setIndices/updateIndices for setting your data

index_t[] indices = [0, 1, 2, 2, 1, 0];
vao.setIndices(indices.length, indices.ptr);

float[] vertices = [
//  X, Y, S, T
    0, 0, 0, 0,
    0, 1, 0, 1,
    1, 1, 1, 1,
    1, 0, 1, 0
];
vao.setVertices(vertices.length, vertices.ptr);
```

- Using a Mesh

A mesh is basically a shader + vao wrapper, which can make things easier in the long run, it is the expected way on how you're going to use:

```d

mesh = new Mesh(HipVertexArrayObject.getXYZ_RGBA_ST_TID_VAO(), spriteBatchShader);
mesh.vao.bind();
mesh.createVertexBuffer(4, HipBufferUsage.DYNAMIC);
mesh.createIndexBuffer(6, HipBufferUsage.STATIC);
mesh.sendAttributes();
//setIndices and setVertices almost the same
```


## Rendering it

```d

HipRenderer.begin();

if(mesh)
{
    mesh.draw(indices.length);
}
else
{
    shader.bind();
    vao.bind();
    HipRenderer.setRendererMode(HipRendererMode.TRIANGLES);
    HipRenderer.drawIndexed(indices.length);
}
HipRenderer.end();
```

