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
    HipShaderPresets.SPRITE_BATCH: DefaultShader(GLDefaultShadersPath, &getSpriteBatchShader, &isSpriteBatchInstanced),
    HipShaderPresets.BITMAP_TEXT: DefaultShader(GLDefaultShadersPath, &getBitmapTextShader),
    HipShaderPresets.NONE: DefaultShader(GLDefaultShadersPath)
];


private {

    
    import hip.util.conv;
    import hip.util.format: format;

    string getFrameBufferShader(string){return import("opengl/framebuffer.glsl");}
    string getGeometryBatchShader(string){return import("opengl/geometrybatch.glsl");}
    string getBitmapTextShader(string){return import("opengl/bitmaptext.glsl");}

    bool isSpriteBatchInstanced()
    {
        version(WebAssembly)
        {
            import gles;
            return isWebGL2;
        }
        else version(Windows)
            return true;
        else
            return false;
    }

    string getSpriteBatchShader(string effect)
    {
        import hip.hiprenderer.renderer;
        int sup = HipRenderer.getMaxSupportedShaderTextures();
        string textureSlotSwitchCase = (GLESVersion == 3 || !UseGLES) ? "switch(texId)\n{\n" : "";
        if(sup == 1) textureSlotSwitchCase = "fx.textureColor = SAMPLE2D(uTex[0], inTexST);\n";
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
                    "{fx.textureColor = SAMPLE2D(uTex["~strI~"], inTexST);}\n";
                }
                else
                {
                    textureSlotSwitchCase~="case "~strI~": "~
                    "\t\tfx.textureColor = SAMPLE2D(uTex["~strI~"], inTexST);break;\n";
                }
            }
            if(GLESVersion != 2)
                textureSlotSwitchCase~= "}";
        }
        enum shaderSource = q{
            INOUT vec4 inVertexColor;
            INOUT vec2 inTexST;
            INOUT float inTexID;
            INOUT vec2 inWorldPosition;

            #ifdef VERTEX

            #ifndef INSTANCED
                ATTRIBUTE(0) vec2 vPosition;
                ATTRIBUTE(1) vec4 vColor;
                ATTRIBUTE(2) vec2 vTexST;
                ATTRIBUTE(3) float vZ;
                ATTRIBUTE(4) float vTexID;
            #else
                ATTRIBUTE(0) vec2 vPosition;
                
                ATTRIBUTE(1) ivec2 vXY;
                ATTRIBUTE(2) uvec2 vSize;
                ATTRIBUTE(3) vec4 vColor;
                ATTRIBUTE(4) float vRotation;
                ATTRIBUTE(5) uint vZ;
                ATTRIBUTE(6) uint vTexID;
                ATTRIBUTE(7) vec2 vUVMin;
                ATTRIBUTE(8) vec2 vUVMax;
            #endif

            UNIFORM_BUFFER_OBJECT(0, Cbuf1, cbuf1, { mat4 uMVP; });

            void vertexMain()
            {

                #ifdef INSTANCED
                    inTexST = vPosition * vUVMax + vUVMin; //Currently only default is supported
                    float s = sin(vRotation);
                    float c = cos(vRotation);
                    vec2 actualPos = vec2(
                        vPosition.x * c - vPosition.y * s,
                        vPosition.x * s + vPosition.y * c
                    ) * vec2(vSize) + vec2(vXY);
                    gl_Position = cbuf1.uMVP*vec4(actualPos, vZ, 1.0);
                #else 
                    inTexST = vTexST;
                    gl_Position = cbuf1.uMVP*vec4(vPosition, vZ, 1.0);
                #endif
                inVertexColor = vColor;
                inTexID = float(vTexID);
                inWorldPosition = vPosition;
            }
            #endif

            #ifdef FRAGMENT
            UNIFORM_BUFFER_OBJECT(0, Cbuf, cbuf, { vec4 uBatchColor; vec2 uScreenSize; float uTime;});

            struct EffectInput
            {
                vec4 textureColor;
                vec4 vertexColor;
                vec4 uBatchColor;
                vec2 worldPosition;
            };

        };
        if(effect is null)
        {
            effect = q{vec4 effect(EffectInput fx)
            {
                return fx.textureColor * fx.vertexColor * fx.uBatchColor;
            }
            };
        }


        return format!q{
                uniform sampler2D uTex[%s];}(sup)~
            shaderSource~
            effect ~
        "void fragmentMain(){"~q{
                int texId = int(inTexID);
                bool isText = (texId & (1 << 15)) != 0;
                texId = texId & 0xff;
                EffectInput fx;
                fx.uBatchColor = cbuf.uBatchColor;
                fx.vertexColor = inVertexColor;
                fx.worldPosition = inWorldPosition;
        }~ textureSlotSwitchCase ~ "fx.textureColor = mix(fx.textureColor, fx.textureColor.rrrr, isText); OUT_COLOR = effect(fx); }\n#endif";
        // outPixelColor = texture(uTex[texId], inTexST)* inVertexColor;
        // outPixelColor = vec4(texId, texId, texId, 1.0)* inVertexColor;

    }
}