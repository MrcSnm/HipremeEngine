module gamescript.entry;
import hip.api;

/**
*	Call `dub` to generate the DLL, after that, just execute `dub -c run` for starting your project
*/
class MainScene : AScene, IHipPreloadable
{
    // mixin Preload;
	IHipFont bigFont, smallFont;


    // @Asset("arial_sdf.fnt")
    // IHipFont sdfFont;

	// /** Constructor */
	override void initialize()
	{
		Viewport vp = getCurrentViewport();
		vp.setBounds(0, 0, 800, 600);
		setViewport(vp);

        smallFont = HipDefaultAssets.getDefaultFontWithSize(20);
        bigFont = HipDefaultAssets.getDefaultFontWithSize(64);

        // setFont(sdfFont);
        setFont(bigFont);

	}
	// /** Called every frame */
	override void update(float dt)
	{
        // logg("Built with redub :)"); aaa
        if(HipInput.isMouseButtonJustPressed(HipMouseButton.left))
        {
            logg("Youu aa aomgg just clicked me!");
        }

        if(HipInput.isKeyJustPressed(HipKey.ENTER))
        {
            logg("Don't press ENTER!!");
        }
	}
	// /** Renderer only, may not be called every frame */
	override void render()
	{
        fillRectangle(0, 0, 200, 200, HipColor.red);
        fillRectangle(0, 0, 100, 100, HipColor.green);

        // //Use a non GC allocating string on render (String) for drawing the mousePosition
        import hip.util.string;
        float[2] mousePos = HipInput.getWorldMousePosition();
        setFont(smallFont);
        SmallString s = SmallString(mousePos);
        drawText(s.toString, cast(int)mousePos[0], cast(int)mousePos[1]);

        

        ////////////////////////Higher Level////////////////////////
        // setGeometryColor(HipColor.white);
        setFont(null);
        drawText("Hello World Test Scene (Default Font)", 300, 280, 1, HipColor.white, HipTextAlign.topLeft);
        fillRectangle(300, 300, 100, 100);

        drawText("Null Textures uses that sprite over here ", 300, 480, 1.0, HipColor.white, HipTextAlign.topLeft);
        drawTexture(null, 300, 500);


        drawGCStats();

	}

    override void preload(){}
    override string[] getAssetsForPreload(){ return [] ; }
	override void onResize(uint width, uint height){}
    override void dispose(){}
}

mixin HipEngineMain!MainScene;