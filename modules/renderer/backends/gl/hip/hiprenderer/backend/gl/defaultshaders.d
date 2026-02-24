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
    HipShaderPresets.FRAME_BUFFER: DefaultShader(GLDefaultShadersPath, &getFrameBufferShader),
    HipShaderPresets.GEOMETRY_BATCH: DefaultShader(GLDefaultShadersPath, &getGeometryBatchShader),
    HipShaderPresets.SPRITE_BATCH: DefaultShader(GLDefaultShadersPath, &getSpriteBatchShader),
    HipShaderPresets.BITMAP_TEXT: DefaultShader(GLDefaultShadersPath, &getBitmapTextShader),
    HipShaderPresets.NONE: DefaultShader(GLDefaultShadersPath)
];


private {

    
    import hip.util.conv;
    import hip.util.format: format;


    string getFrameBufferShader()
    {
        return `
            INOUT vec2 inTexST;
            #ifdef VERTEX
            ATTRIBUTE(0) vec2 vPosition;
            ATTRIBUTE(1) vec2 vTexST;


            void vertexMain()
            {
                gl_Position = vec4(vPosition, 0.0, 1.0);
                inTexST = vTexST;
            }
            #endif

            #ifdef FRAGMENT
            uniform sampler2D uBufferTexture;
            uniform vec4 uColor;

            void fragmentMain()
            {
                vec4 col = SAMPLE2D(uBufferTexture, inTexST);
                float grey = (col.r+col.g+col.b)/3.0;
                OUT_COLOR = grey * uColor;
            }
            #endif
        `;
    }

    string getSpriteBatchShader()
    {
        import hip.hiprenderer.renderer;
        int sup = HipRenderer.getMaxSupportedShaderTextures();
        string textureSlotSwitchCase = (GLESVersion == 3 || !UseGLES) ? "switch(texId)\n{\n" : "";
        if(sup == 1) textureSlotSwitchCase = "OUT_COLOR = SAMPLE2D(uTex[0], inTexST)*inVertexColor*cbuf.uBatchColor;\n";
        else
        {
            for(int i = 0; i < sup; i++)
            {
                string strI = to!string(i);
                static if(GLESVersion == 2)
                {
                    if(i != 0)
                        textureSlotSwitchCase~="\t\t\t\telse ";
                    textureSlotSwitchCase~="if(texId == "~strI~")"~
                    "{OUT_COLOR = SAMPLE2D(uTex["~strI~"], inTexST)*inVertexColor*cbuf.uBatchColor;}\n";
                }
                else
                {
                    textureSlotSwitchCase~="case "~strI~": "~
                    "\t\tOUT_COLOR = SAMPLE2D(uTex["~strI~"], inTexST)*inVertexColor*cbuf.uBatchColor;break;\n";
                }
            }
            if(GLESVersion != 2)
                textureSlotSwitchCase~= "}";
        }
        enum shaderSource = q{
            INOUT vec4 inVertexColor;
            INOUT vec2 inTexST;
            INOUT float inTexID;
            #ifdef VERTEX
            ATTRIBUTE(0) vec3 vPosition;
            ATTRIBUTE(1) vec4 vColor;
            ATTRIBUTE(2) vec2 vTexST;
            ATTRIBUTE(3) float vTexID;

            UNIFORM_BUFFER_OBJECT(0, Cbuf1, cbuf1, 
            {
                mat4 uMVP;
            });

            void vertexMain()
            {
                gl_Position = cbuf1.uMVP*vec4(vPosition, 1.0);
                inVertexColor = vColor;
                inTexST = vTexST;
                inTexID = vTexID;
            }
            #endif

            #ifdef FRAGMENT
            UNIFORM_BUFFER_OBJECT(0, Cbuf, cbuf, 
            {
                vec4 uBatchColor;
            });

            void fragmentMain()
        };


        return format!q{
                uniform sampler2D uTex[%s];}(sup)~
            shaderSource~
        "{"~q{
                int texId = int(inTexID);
        }~ textureSlotSwitchCase ~ "}\n#endif";
        // outPixelColor = texture(uTex[texId], inTexST)* inVertexColor;
        // outPixelColor = vec4(texId, texId, texId, 1.0)* inVertexColor;

    }
    
    string getGeometryBatchShader()
    {
        return `
            INOUT vec4 inVertexColor;
            #ifdef VERTEX
            ATTRIBUTE(0) vec3 vPosition;
            ATTRIBUTE(1) vec4 vColor;

            UNIFORM_BUFFER_OBJECT(0, Geom, geom, 
            {
                mat4 uMVP;
            });
            void vertexMain()
            {
                gl_Position = geom.uMVP*vec4(vPosition, 1.0);
                inVertexColor = vColor;
            }
            #endif


            #ifdef FRAGMENT
            UNIFORM_BUFFER_OBJECT(0, FragVars, frag, 
            {
                vec4 uGlobalColor;
            });

            void fragmentMain()
            {
                OUT_COLOR = inVertexColor * frag.uGlobalColor;
            }
            #endif`;
    }

    string getBitmapTextShader()
    {
        return `
            INOUT vec2 inTexST;
            #ifdef VERTEX
            ATTRIBUTE(0) vec3 vPosition;
            ATTRIBUTE(1) vec2 vTexST;

            UNIFORM_BUFFER_OBJECT(0, Cbuf, cbuf, 
            {
                mat4 uMVP;
            });

            void vertexMain()
            {
                gl_Position = cbuf.uMVP * vec4(vPosition, 1.0);
                inTexST = vTexST;
            }
            #endif
            #ifdef FRAGMENT
            UNIFORM_BUFFER_OBJECT(0, FragVars, frag, 
            {
                vec4 uColor;
            });
            uniform sampler2D uTex;

            void fragmentMain()
            {
                float r = SAMPLE2D(uTex, inTexST).r;
                OUT_COLOR = vec4(r,r,r,r)*frag.uColor;
            }
            #endif
        `;
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

}