module hip.event.handlers.input_listener;
public import hip.api.input.button;
public import hip.api.input.keyboard;
public import hip.api.input.mouse;
import hip.event.dispatcher;
import hip.event.handlers.keyboard;
import hip.event.handlers.mouse;



class HipInputListener
{
    protected HipButton[] touchListeners;
    protected HipButton[] keyboardListeners;

    protected KeyboardHandler keyboard;
    protected HipMouse mouse;

    this(EventDispatcher dispatcher)
    {
        this.keyboard = dispatcher.keyboard;
        this.mouse = dispatcher.mouse;
    }

    const(HipButton)* addKeyboardListener(HipKey key, 
        HipInputAction action,
        HipButtonType type = HipButtonType.down,
        AutoRemove remove = AutoRemove.no
        )
    {
        keyboardListeners~= HipButton(cast(ushort)key, type, action, remove);
        return &keyboardListeners[$-1];
    }

    const(HipButton)* addTouchListener(HipMouseButton btn, 
        HipInputAction action,
        HipButtonType type = HipButtonType.down,
        AutoRemove remove = AutoRemove.no
        )
    {
        touchListeners~= HipButton(cast(ushort)btn, type, action, remove);
        return &touchListeners[$-1];
    }
    /**
    *   Mainly used for the scriptInputListener
    */
    void clearAll()
    {
        touchListeners.length = 0;
        keyboardListeners.length = 0;
    }

    bool removeKeyboardListener(const(HipButton)* button)
    {
        import hip.util.array:remove;
        return remove(keyboardListeners, button);
    }
    bool removeTouchListener(const(HipButton)* button)
    {
        import hip.util.array:remove;
        return remove(touchListeners, button);
    }

    void update()
    {
        foreach(ref key; keyboardListeners)
        {
            bool shouldExecute = false;
            final switch(key.type) with(HipButtonType)
            {
                case down:
                    shouldExecute = keyboard.isKeyJustPressed(cast(char)key.id);
                    break;
                case up:
                    shouldExecute = keyboard.isKeyJustReleased(cast(char)key.id);
                    break;
            }
            if(shouldExecute)
            {
                key.action(keyboard.getMetadata(cast(char)key.id));
                if(key.isAutoRemove)
                    removeKeyboardListener(&key);
            }
        }

        foreach(ref touch; touchListeners)
        {
            bool shouldExecute = false;
            final switch(touch.type) with(HipButtonType)
            {
                case down:
                    shouldExecute = mouse.isJustPressed(cast(HipMouseButton)touch.id);
                    break;
                case up:
                    shouldExecute = mouse.isJustReleased(cast(HipMouseButton)touch.id);
                    break;
            }
            if(shouldExecute)
            {
                touch.action(mouse.getMetadata(cast(HipMouseButton)touch.id));
                if(touch.isAutoRemove)
                    removeTouchListener(&touch);
            }
        }
    }
}