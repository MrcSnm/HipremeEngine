module hip.event.handlers.input_listener;
public import hip.api.input.button;
public import hip.api.input.keyboard;
public import hip.api.input.mouse;
import hip.api.input.core : IHipInputListener;
import hip.event.dispatcher;
import hip.event.handlers.keyboard;
import hip.event.handlers.mouse;
import hip.util.string;

String str(const(HipButton)* btn)
{
    return String("Button ", btn.id, " ",btn.type, "  [autoremove: ", btn.isAutoRemove, "]");
}

class HipInputListener : IHipInputListener
{
    protected HipButton[] touchListeners;
    protected HipButton[] keyboardListeners;

    protected ScrollListener[] scrollListeners;
    protected TouchMoveListener[] moveListeners;

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
        keyboardListeners~= HipButton(cast(ushort)key, type, remove, action);
        
        return &keyboardListeners[$-1];
    }

    const(HipButton)* addTouchListener(HipMouseButton btn, 
        HipInputAction action,
        HipButtonType type = HipButtonType.down,
        AutoRemove remove = AutoRemove.no
        )
    {
        touchListeners~= HipButton(cast(ushort)btn, type, remove, action);
        return &touchListeners[$-1];
    }

    const(ScrollListener)* addScrollListener(HipScrollAction onScroll, AutoRemove isAutoRemove = AutoRemove.no)
    {
        scrollListeners~= ScrollListener(onScroll, isAutoRemove);
        return &scrollListeners[$-1];
    }
    const(TouchMoveListener)* addTouchMoveListener(HipTouchMoveAction onTouchMove, AutoRemove isAutoRemove = AutoRemove.no)
    {
        moveListeners~= TouchMoveListener(onTouchMove, isAutoRemove);
        return &moveListeners[$-1];
    }

    /**
    *   Mainly used for the scriptInputListener
    */
    void clearAll()
    {
        import hip.console.log;
        hiplog("Clearing all input events.");
        touchListeners.length = 0;
        scrollListeners.length = 0;
        moveListeners.length = 0;
        keyboardListeners.length = 0;
    }

    import hip.util.array:remove;
    bool removeKeyboardListener(const(HipButton)* button)
    {
        import hip.console.log;
        hiplog("Removing keyboard listener ", button.str);
        return remove(keyboardListeners, button);
    }
    bool removeTouchListener(const(HipButton)* button)
    {
        import hip.console.log;
        hiplog("Removing touch listener f ", button.str);
        return remove(touchListeners, button);
    }
    bool removeScrollListener(const(ScrollListener)* onScroll)
    {
        import hip.console.log;
        hiplog("Removing scroll listener ");
        return remove(scrollListeners, onScroll);
    }
    bool removeTouchMoveListener(const(TouchMoveListener)* onTouchMove)
    {
        import hip.console.log;
        hiplog("Removing touch move listener ");
        return remove(moveListeners, onTouchMove);
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

        if(mouse.getDeltaPosition().magSquare != 0)
        {
            import hip.api.input.core;
            import hip.console.log;
            float[2] pos = HipInput.getWorldTouchPosition();
            int x = cast(int)pos[0], y = cast(int)pos[1];
            foreach(ref move; moveListeners)
            {
                move.action(x, y);
                if(move.isAutoRemove)
                    removeTouchMoveListener(&move);
            }
        }
        auto scroll = mouse.getScroll();
        if(scroll.magSquare != 0)
        {
            foreach(ref listener; scrollListeners)
            {
                listener.action(cast(float[3])scroll);
                if(listener.isAutoRemove)
                    removeScrollListener(&listener);
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