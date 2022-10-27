module hip.event.handlers.input_listener;
public import hip.api.input.button;
public import hip.api.input.keyboard;
import hip.event.handlers.keyboard;



class HipInputListener
{
    protected HipButton[] actionListeners;
    protected HipButton[] keyboardListeners;

    protected KeyboardHandler keyboard;

    this(KeyboardHandler keyboard)
    {
        this.keyboard = keyboard;
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

    const(HipButton)* addActionListener(HipKey key, 
        HipInputAction action,
        HipButtonType type = HipButtonType.down,
        AutoRemove remove = AutoRemove.no
        )
    {
        actionListeners~= HipButton(cast(ushort)key, type, action, remove);
        return &actionListeners[$-1];
    }
    /**
    *   Mainly used for the scriptInputListener
    */
    void clearAll()
    {
        actionListeners.length = 0;
        keyboardListeners.length = 0;
    }

    bool removeKeyboardListener(const(HipButton)* button)
    {
        import hip.util.array:remove;
        return remove(keyboardListeners, button);
    }
    bool removeActionListener(const(HipButton)* button)
    {
        import hip.util.array:remove;
        return remove(actionListeners, button);
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
    }
}