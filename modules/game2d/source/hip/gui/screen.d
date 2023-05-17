module hip.gui.screen;
public import hip.gui.widget;
import hip.api.input.button;
import std.internal.digest.sha_SSSE3;

/** 
 * Screen is where all widgets should be contained.
 * This way, the event methods are forwarded correctly, there can exist a drag and drop.
 * Render order by stack is also possible
 */
class Screen : Widget
{
    protected Widget focusedWidget;
    protected Widget draggedWidget;
    private Widget widgetHolded;
    private Widget widgetMouseEntered;


    this(){setupEvents();}

    private const(HipButton)* mouseDownEv, mouseUpEv;
    private const(ScrollListener)* scrollEv;
    private const(TouchMoveListener)* moveEv;



    final void setupEvents()
    {
        import hip.api:HipInput, HipMouseButton;
        mouseDownEv = HipInput.addTouchListener(HipMouseButton.left, 
        (const AHipButtonMetadata meta)
        {
            handleMouseDown();
        });

        mouseUpEv = HipInput.addTouchListener(HipMouseButton.left,
        (const(AHipButtonMetadata) meta)
        {
            stopDragging();
            handleMouseUp();
        }, HipButtonType.up);

        moveEv = HipInput.addTouchMoveListener((int x, int y)
        {
            handleMouseEnter(x, y);
            startDragging(x, y);
        });
        
    }
    

    int findWidget(Widget w)
    {
        for(int i = 0; i < children.length; i++) 
            if(children[i] is w) return i;
        return -1;
    }

    private void handleMouseDown()
    {
        import hip.api;

        Widget w = findWidgetAt(HipInput.getWorldTouchPosition());
        widgetHolded = w;
        setFocusOn(w);
        if(w !is null) w.onMouseDown();
    }
    private void handleMouseUp()
    {
        import hip.api;
        if(widgetHolded !is null)
        {
            widgetHolded.onMouseUp();
            if(findWidgetAt(HipInput.getWorldTouchPosition()) is widgetHolded)
                widgetHolded.onMouseClick();
        }
        widgetHolded = null;
    }

    private void handleMouseEnter(int x, int y)
    {
        Widget mEnterWidget = findWidgetAt(x, y);
        if(widgetMouseEntered !is mEnterWidget)
        {
            if(widgetMouseEntered)
                widgetMouseEntered.onMouseExit();
            if(mEnterWidget)
                mEnterWidget.onMouseEnter();
        }
        widgetMouseEntered = mEnterWidget;
    }
    private void startDragging(int x, int y)
    {
        if(widgetHolded && !draggedWidget)
        {
            setDragging(widgetHolded, x , y);
        }
        if(draggedWidget !is null)
            draggedWidget.onDragged(x, y);
    }

    private void pushToTop(Widget w)
    {
        int pos = findWidget(w);
        if(pos == children.length) return;
        else if(pos != -1)
        {
            children[pos..$-1] = children[pos+1..$];
            children[$-1] = w;
        }
    }

    void setFocusOn(Widget w)
    {
        if(focusedWidget is w) return;
        if(focusedWidget !is null)
            focusedWidget.onFocusExit();
        focusedWidget = w;
        if(w !is null)
        {
            pushToTop(w);
            w.onFocusEnter();
        }
    }

    void setDragging(Widget w, int x, int y)
    {
        if(w !is null && w.isDraggable)
        {
            w.onDragStart(x, y);
            draggedWidget = w;
        }
    }

    void stopDragging()
    {
        if(draggedWidget !is null)
        {
            draggedWidget.onDragEnd();
            draggedWidget = null;
        }
    }

}