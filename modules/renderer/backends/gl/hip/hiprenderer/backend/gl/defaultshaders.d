module hip.hiprenderer.backend.gl.defaultshaders;
import hip.api.renderer.core;
import hip.config.renderer;
private enum GLDefaultShadersPath = __MODULE__;


static if(!HasOpenGL)
{
    immutable DefaultShader[] DefaultShaders;
}
else:

immutable DefaultShader[] DefaultShaders = [
    HipShaderPresets.DEFAULT: DefaultShader(GLDefaultShadersPath, &getDefaultVertex, &getDefaultVertex),
    HipShaderPresets.FRAME_BUFFER: DefaultShader(GLDefaultShadersPath, &getFrameBufferVertex, &getFrameBufferFragment),
    HipShaderPresets.GEOMETRY_BATCH: DefaultShader(GLDefaultShadersPath, &getGeometryBatchVertex, &getGeometryBatchFragment),
    HipShaderPresets.SPRITE_BATCH: DefaultShader(GLDefaultShadersPath, &getSpriteBatchVertex, &getSpriteBatchFragment),
    HipShaderPresets.BITMAP_TEXT: DefaultShader(GLDefaultShadersPath, &getBitmapTextVertex, &getBitmapTextFragment),
    HipShaderPresets.NONE: DefaultShader(GLDefaultShadersPath)
];


private {

    version(GLES32) version = GLES3;
    version(GLES30) version = GLES3;

    version(GLES3)
    {
        enum shaderVersion = "#version 300 es";
        enum floatPrecision = "precision mediump float;";
        // enum floatPrecision = "";
    }
    else version(GLES20)
    {
        enum shaderVersion = "#version 100";
        enum floatPrecision = "precision mediump float;";
    }
    else
    {
        enum shaderVersion = "#version 330 core";
        enum floatPrecision = "";
    }

    import hip.util.conv;
    import hip.util.format: fastUnsafeCTFEFormat, format;



    private string getBaseFragment()
    {
        __gshared string baseShader;
        if(baseShader is null)
        {
            string defs;
            version(WebAssembly) defs~= "#define WASM\n";
            version(PSVita) defs~= "#define PSVITA\n";
            baseShader = shaderVersion~"\n"~floatPrecision~"\n"~defs ~
    `#ifdef WASM
        #define TEXTURE_2D texture2D
    #elif defined(PSVITA)
        #define TEXTURE_2D texture2D
    #else
        #define TEXTURE_2D texture
    #endif`;

        }
        return baseShader;
    }



    string getDefaultFragment()
    {
        return getBaseFragment~q{

            uniform vec4 globalColor;
            in vec4 vertexColor;
            in vec2 tex_uv;
            uniform sampler2D tex1;
            out vec4 outPixelColor;

            void main()
            {
                outPixelColor = vertexColor*globalColor*TEXTURE_2D(tex1, tex_uv);
            }
        };
    }
    string getFrameBufferFragment()
    {
        return getBaseFragment~q{

            in vec2 inTexST;
            uniform sampler2D uBufferTexture;
            uniform vec4 uColor;
            out vec4 outPixelColor;

            void main()
            {
                vec4 col = TEXTURE_2D(uBufferTexture, inTexST);
                float grey = (col.r+col.g+col.b)/3.0;
                outPixelColor = grey * uColor;
            }
        };
    }

    version(GLES20) //They are very different, so, better to keep them separate
    {
        string getSpriteBatchFragment()
        {
            import hip.hiprenderer.renderer;
            int sup = HipRenderer.getMaxSupportedShaderTextures();
            string textureSlotSwitchCase;
            if(sup == 1) textureSlotSwitchCase = "gl_FragColor = TEXTURE_2D(uTex[0], inTexST)*inVertexColor*uBatchColor;\n";
            else
            {
                for(int i = 0; i < sup; i++)
                {
                    string strI = to!string(i);
                    if(i != 0)
                        textureSlotSwitchCase~="\t\t\t\telse ";
                    textureSlotSwitchCase~="if(texId == "~strI~")"~
                    "{gl_FragColor = TEXTURE_2D(uTex["~strI~"], inTexST)*inVertexColor*uBatchColor;}\n";
                }
            }
            textureSlotSwitchCase~="}\n";
            enum shaderSource = q{
                uniform vec4 uBatchColor;

                varying vec4 inVertexColor;
                varying vec2 inTexST;
                varying float inTexID;

                void main()
            };


            return getBaseFragment~format!q{
                    uniform sampler2D uTex[%s];}(sup)~
                shaderSource~
            "{"~q{
                    int texId = int(inTexID);
            }~ textureSlotSwitchCase;
        }
    }
    else
    {
        string getSpriteBatchFragment()
        {
            import hip.hiprenderer.renderer;
            int sup = HipRenderer.getMaxSupportedShaderTextures();
            //Push the line breaks for easier debugging on gpu debugger
            string textureSlotSwitchCase = "switch(texId)\n{\n";
            for(int i = 0; i < sup; i++)
            {
                string strI = to!string(i);
                textureSlotSwitchCase~="case "~strI~": "~
                "\t\toutPixelColor = TEXTURE_2D(uTex["~strI~"], inTexST)*inVertexColor*uBatchColor;break;\n";
            }
            textureSlotSwitchCase~="}\n";

                enum shaderSource = q{

                    uniform vec4 uBatchColor;

                    in vec4 inVertexColor;
                    in vec2 inTexST;
                    in float inTexID;

                    out vec4 outPixelColor;
                    void main()
                };
            return getBaseFragment~format!q{
                    uniform sampler2D uTex[%s];}(sup)~
                shaderSource~
            "{"~q{
                    int texId = int(inTexID);
            } ~textureSlotSwitchCase~
            "}";
            // outPixelColor = texture(uTex[texId], inTexST)* inVertexColor * uBatchColor;
            // outPixelColor = vec4(texId, texId, texId, 1.0)* inVertexColor * uBatchColor;
        }

    }
    string getGeometryBatchFragment()
    {
        version(GLES20)
        {
            enum attr1 = q{varying};
            enum outputPixelVar = q{};
            enum outputAssignment = q{gl_FragColor};
        }
        else
        {
            enum attr1 = q{in};
            enum outputPixelVar = q{out vec4 outPixelColor;};
            enum outputAssignment = q{outPixelColor};
        }
        enum shaderSource = q{
            uniform vec4 uGlobalColor;
            %s vec4 inVertexColor;
            %s

            void main()
            {
                %s = inVertexColor * uGlobalColor;
            }
        }.fastUnsafeCTFEFormat(attr1, outputPixelVar, outputAssignment);
        return getBaseFragment~shaderSource;
    }

    string getBitmapTextFragment()
    {
        version(GLES20)
        {
            enum attr1 = q{varying};
            enum outputPixelVar = q{};
            enum outputAssignment = q{gl_FragColor};
        }
        else
        {
            enum attr1 = q{in};
            enum outputPixelVar = q{out vec4 outPixelColor;};
            enum outputAssignment = q{outPixelColor};
        }
        enum shaderSource = q{


            uniform vec4 uColor;
            uniform sampler2D uTex;
            %s vec2 inTexST;
            %s

            void main()
            {
                float r = TEXTURE_2D(uTex, inTexST).r;
                %s = vec4(r,r,r,r)*uColor;
            }
        }.fastUnsafeCTFEFormat(attr1, outputPixelVar, outputAssignment);
        return getBaseFragment~shaderSource;
    }


    // //getSDFFragment
    // string getBitmapTextFragment()
    // {
    //     version(GLES20)
    //     {
    //         enum attr1 = q{varying};
    //         enum outputPixelVar = q{};
    //         enum outputAssignment = q{gl_FragColor};
    //     }
    //     else
    //     {
    //         enum attr1 = q{in};
    //         enum outputPixelVar = q{out vec4 outPixelColor;};
    //         enum outputAssignment = q{outPixelColor};
    //     }

    //     enum shaderSource = q{
    //     %s vec2 inTexST;
    //     %s

    //     uniform sampler2D uTex;
    //     // uniform vec4 bgColor;
    //     uniform vec4 uColor;

    //     float screenPxRange = 4.5;

    //     void main() {
    //         float sd = texture(uTex, inTexST).r;
    //         float screenPxDistance = screenPxRange*(sd - 0.5);
    //         float opacity = clamp(screenPxDistance + 0.5, 0.0, 1.0);
    //         // color = mix(bgColor, fgColor, opacity);
    //         %s = uColor * opacity;
    //     }}.fastUnsafeCTFEFormat(attr1, outputPixelVar, outputAssignment);

    //     return getBaseFragment~shaderSource;
    // }


    string getDefaultVertex()
    {
        return shaderVersion~"\n"~floatPrecision~"\n"~q{

            layout (location = 0) in vec3 position;
            layout (location = 1) in vec4 color;
            layout (location = 2) in vec2 texCoord;
            uniform mat4 proj;


            out vec4 vertexColor;
            out vec2 tex_uv;

            void main()
            {
                gl_Position = proj*vec4(position, 1.0);
                vertexColor = color;
                tex_uv = texCoord;
            }
        };
    }
    string getFrameBufferVertex()
    {
        return shaderVersion~"\n"~floatPrecision~"\n"~q{

            layout (location = 0) in vec2 vPosition;
            layout (location = 1) in vec2 vTexST;

            out vec2 inTexST;

            void main()
            {
                gl_Position = vec4(vPosition, 0.0, 1.0);
                inTexST = vTexST;
            }
        };
    }
    string getSpriteBatchVertex()
    {
        version(GLES20) //`in` representation in GLES 20 is `attribute``
        {
            enum attr1 = q{attribute};
            enum attr2 = q{attribute};
            enum attr3 = q{attribute};
            enum attr4 = q{attribute};
            enum out1 = q{varying};
            enum out2 = q{varying};
            enum out3 = q{varying};
        }
        else
        {
            enum attr1 = q{layout (location = 0) in};
            enum attr2 = q{layout (location = 1) in};
            enum attr3 = q{layout (location = 2) in};
            enum attr4 = q{layout (location = 3) in};
            enum out1 = q{out};
            enum out2 = q{out};
            enum out3 = q{out};
        }
        enum shaderSource = q{
            %s vec3 vPosition;
            %s vec4 vColor;
            %s vec2 vTexST;
            %s float vTexID;

            uniform mat4 uMVP;

            %s vec4 inVertexColor;
            %s vec2 inTexST;
            %s float inTexID;

            void main()
            {
                gl_Position = uMVP*vec4(vPosition, 1.0);
                inVertexColor = vColor;
                inTexST = vTexST;
                inTexID = vTexID;
            }
        }.fastUnsafeCTFEFormat(attr1, attr2, attr3, attr4, out1, out2, out3);
        return shaderVersion~"\n"~floatPrecision~"\n"~shaderSource;
    }
    string getGeometryBatchVertex()
    {
        version(GLES20)
        {
            enum attr1 = q{attribute};
            enum attr2 = q{attribute};
            enum out1 = q{varying};
        }
        else
        {
            enum attr1 = q{layout (location = 0) in};
            enum attr2 = q{layout (location = 1) in};
            enum out1 = q{out};
        }

        enum shaderSource = q{

        %s vec3 vPosition;
        %s vec4 vColor;

            uniform mat4 uMVP;

            %s vec4 inVertexColor;

            void main()
            {
                gl_Position = uMVP*vec4(vPosition, 1.0);
                inVertexColor = vColor;
            }
        }.fastUnsafeCTFEFormat(attr1, attr2, out1);
        return shaderVersion~"\n"~floatPrecision~"\n"~shaderSource;
    }

    string getBitmapTextVertex()
    {
        version(GLES20)
        {
            enum attr1 = q{attribute};
            enum attr2 = q{attribute};
            enum out1 = q{varying};
        }
        else
        {
            enum attr1 = q{layout (location = 0) in};
            enum attr2 = q{layout (location = 1) in};
            enum out1 = q{out};
        }
        enum shaderSource = q{

            %s vec3 vPosition;
            %s vec2 vTexST;

            uniform mat4 uMVP;

            %s vec2 inTexST;

            void main()
            {
                gl_Position = uMVP * vec4(vPosition, 1.0);
                inTexST = vTexST;
            }
        }.fastUnsafeCTFEFormat(attr1, attr2, out1);
        return shaderVersion~"\n"~floatPrecision~"\n"~shaderSource;
    }

}