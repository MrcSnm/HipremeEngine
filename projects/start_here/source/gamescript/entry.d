module gamescript.entry;
import hip.api;
import hip.game2d.particles;

@HipShaderUniform(ShaderTypes.fragment, "SDF", "sdf", 1)
struct SDFUBO
{
    float edge; 
    float softness; 
    float outlineEdge; 
    float outlineWidth;
    float[4] outlineColor; 
}

struct PingPongFBO
{
    IHipFrameBuffer[2] fbo;
    bool a;

    void create(uint width, uint height, TextureFormat format, DepthFormat depth)
    {
        fbo[0] = HipRenderer.newFrameBuffer(width, height, format, depth);
        fbo[1] = HipRenderer.newFrameBuffer(width, height, format, depth);

        foreach(f; fbo)
        {
            f.bind();
            f.clear();
            f.unbind();
        }
    }

    IHipFrameBuffer get()
    {
        return fbo[a ? 0 : 1];
    }

    void toggle(){a = !a;}

    IHipTexture texture()
    {
        return fbo[a ? 1 : 0].getTexture();
    }

    alias get this;
}

/**
*	Call `dub` to generate the DLL, after that, just execute `dub -c run` for starting your project
*/
class MainScene : AScene, IHipPreloadable
{
    import hip.game.shader;
    import hip.math.rect;
    mixin Preload;
	IHipFont bigFont, smallFont;
    HipParticleSystem particles;
    float playerSpeed = 150;
    Rect player = Rect(200, 200, 50, 50);

    PingPongFBO fb;

    
    // @Asset("candara.fnt")
    // IHipFont font;


    // // @Asset("arial_sdf.fnt")
    // // IHipFont sdfFont;
    // Shader sdfShader;
    // ShaderVariablesLayout sdfBuffer;

	// /** Constructor */
	override void initialize()
	{
        import hip.api;
        setWindowTitle("Hipreme Engine Sample");
        auto sz = getMaxScreenSize();
        logg(sz);
        setWindowSize(sz[0], sz[1], false);
        setWorldSize(800, 600);
        particles = new HipParticleSystem(500);
        fb.create(800, 600, TextureFormat.rgba8, DepthFormat.depth16);
        logg(fb.getTexture.getWidth);
        setRenderTarget(fb);
        fb.clear();
        setRenderTarget(null);
        // // smallFont = HipDefaultAssets.getDefaultFontWithSize(20);
        // // bigFont = HipDefaultAssets.getDefaultFontWithSize(64);

        // sdfShader = createSpriteBatchShaderEffect("sdf.glsl", import("sdf.glsl"), ShaderVariablesLayout.getInfo!(SDFUBO)(HipRenderer.getInfo)).shader;
        // sdfBuffer = sdfShader.getBuffer("SDF");
        // Shader s = createSpriteBatchShaderEffect(
        //     q{
        //         vec4 effect(EffectInput fx)
        //         {
        //             float sz = 0.1;
        //             // if(cbuf.uScreenSize.x != 0.0)
        //                 sz = length(cbuf.uScreenSize);
        //             return sin(cbuf.uTime) * fx.uBatchColor * fx.vertexColor * fx.textureColor;
        //         }
        //     }
        // ).shader;
        // setFont(sdfFont);
        // setFont(bigFont);

	}
	// /** Called every frame */
	override void update(float dt)
	{
        static int i = 0;
        i++;
        // logg("Built with redub :)"); aaa
        if(HipInput.isMouseButtonJustPressed(HipMouseButton.left))
        {
            logg("Youu aa aomgg just clicked me! ", i);
        }

        if(HipInput.isKeyJustPressed(HipKey.ENTER))
        {
            logg("Don't press ENTER!!");
        }
        float[3] movement = HipInput.getAnalog(HipGamepadAnalogs.leftStick);
        Vector2 mov = Vector2(movement[0], movement[1]);
        mov.normalize();
        mov*= playerSpeed * dt;

        player.x+= mov.x;
        player.y+= mov.y;
        
        particles.update(dt);
	}
	// /** Renderer only, may not be called every frame */
	override void render()
	{
        // setFont(font);
        // setSpriteBatchShader(sdfShader);

        // sdfBuffer.set(SDFUBO(
        //     0.5f,
        //     0.1f,
        //     0.7f,
        //     0.1f,
        //     [1,1, 1,1],
        // ));

        setRenderTarget(fb);
        // HipRenderer.clear(HipColorf.red);
        fillRectangle(0, 0, 200, 200, HipColor.red);
        fillRectangle(0, 0, 100, 100, HipColor.green);

        // //Use a non GC allocating string on render (String) for drawing the mousePosition
        import hip.util.string;
        float[2] mousePos = HipInput.getWorldMousePosition();
        // setFont(smallFont);
        SmallString s = SmallString(mousePos);
        drawText(s.toString, cast(int)mousePos[0], cast(int)mousePos[1]);

        

        // // //////////////////////Higher Level////////////////////////
        setGeometryColor(HipColor.white);
        setFont(null);
        drawText("Hello World Test Scene (Default Font)", 0, 280, 0.5f, HipColor.white, HipTextAlign.topLeft);
        fillRectangle(300, 300, 100, 100);

        drawText("Null Textures uses that sprite over here ", 300, 480, 1.0, HipColor.white, HipTextAlign.topLeft);
        drawTexture(null, 300, 500);

        particles.draw();

        fillRectangle(player.x, player.y, player.w, player.h, HipColor.green);
        drawGCStats();



        setRenderTarget(null);
        fb.toggle();
        drawTexture(fb.texture, 0, 0, 0, HipColor.white);

	}
	override void onResize(uint width, uint height){}
    override void dispose(){}
}

mixin HipEngineMain!MainScene;