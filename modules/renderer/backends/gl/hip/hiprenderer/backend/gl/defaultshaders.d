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

    string getFrameBufferShader(){return import("opengl/framebuffer.glsl");}
    string getGeometryBatchShader(){return import("opengl/geometrybatch.glsl");}
    string getBitmapTextShader(){return import("opengl/bitmaptext.glsl");}

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

            #ifndef INSTANCED
                ATTRIBUTE(0) vec3 vPosition;
                ATTRIBUTE(1) vec4 vColor;
                ATTRIBUTE(2) vec2 vTexST;
                ATTRIBUTE(3) float vTexID;
            #else
                ATTRIBUTE(0) vec2 vPosition;
                ATTRIBUTE(1) vec2 vXY;
                ATTRIBUTE(2) vec2 vSize;
                ATTRIBUTE(3) vec4 vColor;
                ATTRIBUTE(4) float vZ;
                ATTRIBUTE(5) float vRotation;
                ATTRIBUTE(6) float vTexID;
            #endif

            UNIFORM_BUFFER_OBJECT(0, Cbuf1, cbuf1, 
            {
                mat4 uMVP;
            });

            void vertexMain()
            {

                #ifdef INSTANCED
                    inTexST = vPosition; //Currently only default is supported
                    float s = sin(vRotation);
                    float c = cos(vRotation);
                    vec2 actualPos = vec2(
                        vPosition.x * c - vPosition.y * s,
                        vPosition.x * s + vPosition.y * c
                    ) * vSize + vXY;
                    gl_Position = cbuf1.uMVP*vec4(actualPos, vZ, 1.0);
                #else 
                    inTexST = vTexST;
                    gl_Position = cbuf1.uMVP*vec4(vPosition, 1.0);
                #endif
                inVertexColor = vColor;
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
}