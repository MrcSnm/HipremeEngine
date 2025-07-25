# HipRenderer - WebGL 1, OpenGL ES 2/3, OpenGL 2/3, Direct3D 11 and Metal 2.4 Abstraction

## Phylosophy

* HipRenderer was built based on OpenGL 3, as it was the first one to be implemented. That said, most of the nomenclatures are based on known OpenGL jargon.
* Specific Direct3D object wrappers were created later, so, on the OpenGL side it is a do nothing implementation. As a rule of thumb, the abstraction must always cover/prioritize the most specific case.
* Metal was implemented quite later, and after thoughtful sessions implementing it, it was decided that from that point onwards the renderer API would be more resembling to how Metal works, i.e: Less resource binding and more parameter sending based API.
* Not currently thread safe, the class could even be a struct since its purely static.

## Useful enumerations

* HipBlendEquation
* HipBlendFunction
* HipRendererMode (Could later be changed to Primitives)
* HipRendererType

## Renderer API

Can be switched by changing the renderer.conf screen.renderer property:

* GL3
* D3D11
* METAL

## Using it on a DLL

When the application does not own the Window, that is, built with the version(dll), it should be started with `HipRenderer.initExternal(HipRendererType)`

## HipRenderer object mapping table

|     Hipreme Engine    |                   OpenGL                  |                   Direct3D                   |        Metal        |
| :-------------------: | :---------------------------------------: | :------------------------------------------: | :-----------------: |
|     HipFrameBuffer    |        glFramebuffer/glRenderbuffer       |  ID3DRenderTargetView/ID3DShaderResourceView |         None        |
|  IHipVertexArrayImpl  |               glVertexArray               |               ID3D11InputLayout              | MTLVertexDescriptor |
|  IHipVertexBufferImpl |      glGenBuffer + GL\_ARRAY\_BUFFER      |  ID3D11Buffer + D3D11\_BIND\_VERTEX\_BUFFER  |      MTLBuffer      |
|  IHipIndexBufferImpl  | glGenBuffers + GL\_ELEMENT\_ARRAY\_BUFFER |   ID3D11Buffer + D3D11\_BIND\_INDEX\_BUFFER  |      MTLBuffer      |
| ShaderVariablesLayout |     glGenBuffers + GL\_UNIFORM\_BUFFER    | ID3D11Buffer + D3D11\_BIND\_CONSTANT\_BUFFER |      MTLBuffer      |

* For the OpenGL versions that doesn't support GL\_UNIFORM\_BUFFER, it uses glUniform\* calls.

## HipRendererMode mapping table

|  Hipreme Engine |        OpenGL       |                  Direct3D                 |              Metal             |
| :-------------: | :-----------------: | :---------------------------------------: | :----------------------------: |
|      point      |      GL\_POINTS     |   D3D11\_PRIMITIVE\_TOPOLOGY\_POINTLIST   |     MTLPrimitiveType.Point     |
|       line      |      GL\_LINES      |    D3D11\_PRIMITIVE\_TOPOLOGY\_LINELIST   |      MTLPrimitiveType.Line     |
|   lineStrip   |   GL\_LINE\_STRIP   |   D3D11\_PRIMITIVE\_TOPOLOGY\_LINESTRIP   |   MTLPrimitiveType.LineStrip   |
|    triangles    |    GL\_TRIANGLES    |  D3D11\_PRIMITIVE\_TOPOLOGY\_TRIANGLELIST |    MTLPrimitiveType.Triangle   |
| trinagleStrip | GL\_TRIANGLE\_STRIP | D3D11\_PRIMITIVE\_TOPOLOGY\_TRIANGLESTRIP | MTLPrimitiveType.TriangleStrip |

## TextureWrapMode mapping table

|       Hipreme Engine      |            OpenGL           |                Direct3D               |                   Metal                  |   Additional info   |
| :-----------------------: | :-------------------------: | :-----------------------------------: | :--------------------------------------: | :-----------------: |
|      CLAMP\_TO\_EDGE      |     GL\_CLAMP\_TO\_EDGE     |     D3D11\_TEXTURE\_ADDRESS\_CLAMP    |     MTLSamplerAddressMode.ClampToEdge    |         None        |
|           REPEAT          |          GL\_REPEAT         |     D3D11\_TEXTURE\_ADDRESS\_WRAP     |       MTLSamplerAddressMode.Repeat       |         None        |
|      MIRRORED\_REPEAT     |     GL\_MIRRORED\_REPEAT    |    D3D11\_TEXTURE\_ADDRESS\_MIRROR    |    MTLSamplerAddressMode.MirrorRepeat    |         None        |
| MIRRORED\_CLAMP\_TO\_EDGE | GL\_MIRROR\_CLAMP\_TO\_EDGE | D3D11\_TEXTURE\_ADDRESS\_MIRROR\_ONCE |     MTLSamplerAddressMode.ClampToEdge    | Unsupported on GLES |
|     CLAMP\_TO\_BORDER     |    GL\_CLAMP\_TO\_BORDER    |    D3D11\_TEXTURE\_ADDRESS\_BORDER    | MTLSamplerAddressMode.ClampToBorderColor | Unsupported on GLES |

## Shaders

* Function to create a FragmentShader
* Function to create a VertexShader
* Function to create a ShaderProgram
* A function to send the variable to the shader. The Uniform/Constant buffer
* They have specific implementations for GeometryBatch, SpriteBatch and BitmapText, listed on `HipShaderPresets`

### How to use it

For actually using a shader, you must first add a `ShaderVariablesLayout`, for it being able to connect Shader variables with the D code sent variable.

An example can be found on `HipSpriteBatch`.

#### How to create and use a shader

```d

//"Cbuf1" means that if there is a struct/cbuffer, it'll be accessed from that name
@HipShaderVertexUniform("Cbuf1")
struct HipSpriteVertexUniform
{
    Matrix4 uModel = Matrix4.identity;
    Matrix4 uView = Matrix4.identity;
    Matrix4 uProj = Matrix4.identity;
}

@HipShaderFragmentUniform("Cbuf")
struct HipSpriteFragmentUniform
{
    float[4] uBatchColor = [1,1,1,1];

    @(ShaderHint.Blackbox | ShaderHint.MaxTextures)
    IHipTexture[] uTex;
}

Shader shader = HipRenderer.newShader(q{vertexShaderSource}, q{fragmentShaderSource});

///Create a variable layout for the vertex shader 
shader.addVarLayout(ShaderVariablesLayout.from!HipSpriteVertexUniform);

//Now it is possible to set those values
//Setting variable layout for the fragment shader:
shader.addVarLayout(ShaderVariablesLayout.from!HipSpriteFragmentUniform);

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

* Using a HipVertexArrayObject:

```d

@HipShaderInputLayout struct HipSpriteVertex
{
    Vector3 vPosition = Vector3.zero;
    HipColorf vColor = HipColorf(0,0,0,0);
    Vector2 vTexST = Vector2.zero;
    float vTexID = 0;
}

HipVertexArrayObject obj = HipVertexArrayObject.getVAO!HipSpriteVertex;
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

* Using a Mesh

A mesh is basically a shader + vao wrapper, which can make things easier in the long run, it is the expected way on how you're going to use:

```d

mesh = new Mesh(HipVertexArrayObject.getVAO!HipSpriteVertex(), spriteBatchShader);
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
    HipRenderer.drawIndexed(indices.length, HipRendererMode.triangles);
}
HipRenderer.end();
```
