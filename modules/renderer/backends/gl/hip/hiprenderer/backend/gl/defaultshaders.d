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
    import hip.util.format: format;

    string getBaseVertex()
    {
        return shaderVersion~"\n"~floatPrecision~"\n"~`
#if __VERSION__ == 100
    #define ATTRIBUTE(LOC) attribute
    #define IN varying
    #define OUT varying
#else
    #define ATTRIBUTE(LOC) layout (location = LOC) in
    #define IN in
    #define OUT out
#endif
        `;
    }

    string getBaseFragment()
    {
        __gshared string baseShader;
        if(baseShader is null)
        {
            string defs;
            version(WebAssembly) defs~= "#define WASM\n";
            version(PSVita) defs~= "#define PSVITA\n";
            baseShader = shaderVersion~"\n"~floatPrecision~"\n"~defs ~
`#if defined(WASM) || defined(PSVITA)
    #define TEXTURE_2D texture2D
#else
    #define TEXTURE_2D texture
#endif
#if __VERSION__ == 100
    #define IN varying
    #define OUT varying
    #define OUT_COLOR gl_FragColor
#else
    #define IN in
    #define OUT out
    #define OUT_COLOR outPixelColor
    out vec4 outPixelColor;
#endif
    `;

        }
        return baseShader;
    }



    string getDefaultFragment()
    {
        return getBaseFragment~q{

            uniform vec4 globalColor;
            IN vec4 vertexColor;
            IN vec2 tex_uv;
            uniform sampler2D tex1;

            void main()
            {
                OUT_COLOR = vertexColor*globalColor*TEXTURE_2D(tex1, tex_uv);
            }
        };
    }
    string getFrameBufferFragment()
    {
        return getBaseFragment~q{

            IN vec2 inTexST;
            uniform sampler2D uBufferTexture;
            uniform vec4 uColor;

            void main()
            {
                vec4 col = TEXTURE_2D(uBufferTexture, inTexST);
                float grey = (col.r+col.g+col.b)/3.0;
                OUT_COLOR = grey * uColor;
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
            if(sup == 1) textureSlotSwitchCase = "OUT_COLOR = TEXTURE_2D(uTex[0], inTexST)*inVertexColor*uBatchColor;\n";
            else
            {
                for(int i = 0; i < sup; i++)
                {
                    string strI = to!string(i);
                    if(i != 0)
                        textureSlotSwitchCase~="\t\t\t\telse ";
                    textureSlotSwitchCase~="if(texId == "~strI~")"~
                    "{OUT_COLOR = TEXTURE_2D(uTex["~strI~"], inTexST)*inVertexColor*uBatchColor;}\n";
                }
            }
            textureSlotSwitchCase~="}\n";
            enum shaderSource = q{
                uniform vec4 uBatchColor;

                IN vec4 inVertexColor;
                IN vec2 inTexST;
                IN float inTexID;

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
                "\t\tOUT_COLOR = TEXTURE_2D(uTex["~strI~"], inTexST)*inVertexColor*uBatchColor;break;\n";
            }
            textureSlotSwitchCase~="}\n";

                enum shaderSource = q{

                    uniform vec4 uBatchColor;

                    IN vec4 inVertexColor;
                    IN vec2 inTexST;
                    IN float inTexID;

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
        return getBaseFragment ~ q{
            uniform vec4 uGlobalColor;
            IN vec4 inVertexColor;

            void main()
            {
                OUT_COLOR = inVertexColor * uGlobalColor;
            }
        };
    }

    string getBitmapTextFragment()
    {
        return getBaseFragment ~  q{
            uniform vec4 uColor;
            uniform sampler2D uTex;
            IN vec2 inTexST;

            void main()
            {
                float r = TEXTURE_2D(uTex, inTexST).r;
                OUT_COLOR = vec4(r,r,r,r)*uColor;
            }
        };
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
        return getBaseVertex ~ q{

            ATTRIBUTE(0) vec3 position;
            ATTRIBUTE(1) vec4 color;
            ATTRIBUTE(2) vec2 texCoord;
            uniform mat4 proj;


            OUT vec4 vertexColor;
            OUT vec2 tex_uv;

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
        return getBaseVertex ~ q{

            ATTRIBUTE(0) vec2 vPosition;
            ATTRIBUTE(1) vec2 vTexST;

            OUT vec2 inTexST;

            void main()
            {
                gl_Position = vec4(vPosition, 0.0, 1.0);
                inTexST = vTexST;
            }
        };
    }
    string getSpriteBatchVertex()
    {
        return getBaseVertex ~ q{
            ATTRIBUTE(0) vec3 vPosition;
            ATTRIBUTE(1) vec4 vColor;
            ATTRIBUTE(2) vec2 vTexST;
            ATTRIBUTE(3) float vTexID;

            uniform mat4 uMVP;

            OUT vec4 inVertexColor;
            OUT vec2 inTexST;
            OUT float inTexID;

            void main()
            {
                gl_Position = uMVP*vec4(vPosition, 1.0);
                inVertexColor = vColor;
                inTexST = vTexST;
                inTexID = vTexID;
            }
        };
    }
    string getGeometryBatchVertex()
    {
        return getBaseVertex ~ q{

        ATTRIBUTE(0) vec3 vPosition;
        ATTRIBUTE(1) vec4 vColor;

        uniform mat4 uMVP;

        OUT vec4 inVertexColor;

            void main()
            {
                gl_Position = uMVP*vec4(vPosition, 1.0);
                inVertexColor = vColor;
            }
        };
    }

    string getBitmapTextVertex()
    {
        return getBaseVertex ~ q{

            ATTRIBUTE(0) vec3 vPosition;
            ATTRIBUTE(1) vec2 vTexST;

            uniform mat4 uMVP;

            OUT vec2 inTexST;

            void main()
            {
                gl_Position = uMVP * vec4(vPosition, 1.0);
                inTexST = vTexST;
            }
        };
    }

}