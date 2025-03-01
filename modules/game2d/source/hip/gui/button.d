module hip.gui.button;
import hip.api.graphics.g2d.renderer2d;
public import hip.gui.widget;


interface IButtonRenderer 
{
    void render(Widget.Bounds worldBounds, Button.State state);
    static IButtonRenderer DebugButtonRenderer()
    {
        __gshared IButtonRenderer dbgRenderer;
        if(dbgRenderer is null)
        {
            dbgRenderer = new class IButtonRenderer
            {
                void render(Widget.Bounds worldBounds, Button.State state) const
                {
                    alias b = worldBounds;
                    final switch(state) with(Button.State)
                    {
                        case idle: fillRoundRect(b.x, b.y, b.width, b.height, 12, HipColor.red);
                            break;
                        case hovered: fillRoundRect(b.x, b.y, b.width, b.height, 12, HipColor(255, 127, 0));
                            break;
                        case pressed: fillRoundRect(b.x, b.y, b.width, b.height, 12, HipColor(127, 0, 0));
                            break;
                    }
                }
            };
        }
        return dbgRenderer;
    }
}

class SpriteButtonRenderer : IButtonRenderer
{
    IHipTextureRegion idle;
    IHipTextureRegion hover;
    IHipTextureRegion pressed;


    void render(Widget.Bounds worldBounds, Button.State state)
    {
        IHipTextureRegion target;
        final switch ( state )
        {
            case Button.state.idle: target = idle; break;
            case Button.state.hovered: target = hover; break;
            case Button.state.pressed: target = pressed; break;
        }
        drawRegion(target, worldBounds.x, worldBounds.y);
    }
}

class Button : Widget
{
    enum State
    {
        idle,
        pressed,
        hovered,
    }

    State state;
    IButtonRenderer renderer;

    protected void delegate() onClick;
    protected void delegate() onHover;

    this(int x, int y, int w, int h)
    {
        setPosition(x,y);
        width = w;
        height = h;
        renderer = IButtonRenderer.DebugButtonRenderer;
    }
    Button setOnHover(void delegate() onHover)
    {
        this.onHover = onHover;
        return this;
    }
    Button setOnClick(void delegate() onClick)
    {
        this.onClick = onClick;
        return this;
    }

    private bool isMouseInsideButton()
    {
        import hip.api;
        import hip.math.collision;
        Bounds b = getWorldBounds();
        float[2] pos = HipInput.getMousePosition();
        return isPointInRect(pos[0], pos[1], b.x, b.y, b.width, b.height);
    }

    override void onMouseEnter()
    {
        if(onHover) onHover();
        state = State.hovered;
    }
    override void onMouseDown()
    {
        state = State.pressed;
    }
    override void onMouseUp()
    {
        if(state == State.pressed && onClick) onClick();
        state = State.idle;
    }
    override void onMouseExit()
    {
        if(state != State.pressed)
            state = State.idle;

    }

    void setButtonRenderer(IButtonRenderer renderer)
    {
        this.renderer = renderer;
    }
    override void onRender()
    {
        import hip.api;
        renderer.render(Bounds(worldTransform.x, worldTransform.y, width, height), state);
        super.onRender();
    }
}