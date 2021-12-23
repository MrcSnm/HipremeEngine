/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module systems.gameobject;
version(HIPREME_DEBUG){import error.handler;}

abstract class HipComponent
{
    private bool hasStarted;
    private HipGameObject owner;
    abstract void onStart();
    private void _onStart(HipGameObject go)
    {
        hasStarted = true;
        owner = go;
        onStart();
    }

    pragma(inline, true)
    public T getComponent(T)(){return owner.getComponent!T;}


    abstract void onRemove();
    abstract void update(float deltaTime);
}

class HipSpriteRendererComponent : HipComponent
{
    import graphics.g2d.sprite;
    import graphics.g2d.spritebatch;

    HipSpriteBatch batch;
    HipSprite sprite;

    struct SpriteData
    {
        HipSpriteBatch batch;
        HipSprite sprite;
    }

    void startWithData(void* data)
    {
        auto s = *cast(SpriteData*)data;
        batch  = s.batch;
        sprite = s.sprite;
    }

    override void update(float delta)
    {
        batch.draw(sprite);
    }
}

mixin template ComponentSpecialization(T)
{
    mixin("T[] " ~ T.stringof~"Components;");

    HipComponent addComponent(T : HipComponent)()
    {
        T comp = new T();
        mixin(T~"Components~= comp;");
        return comp;
    }
}



private __gshared ulong idCounter = 0;

class HipGameObject
{
    ulong id;
    string tag;
    bool isActive;

    protected HipGameObject[] children;
    protected HipComponent[] components;

    mixin ComponentSpecialization!(HipSpriteRendererComponent);

    final public void addChild(HipGameObject go)
    {
        children~= go;
    }

    final public this(string tag)
    {
        id = ++idCounter;
        this.tag = tag;
    }


    HipComponent addComponent(T : HipComponent)()
    {
        T comp = new T();
        components~= comp;
        return comp;
    }
    HipComponent getComponent(T : HipComponent)()
    {
        foreach(c; components)
        {
            T ret = cast(T)c;
            if(ret !is null)
                return ret;
        }
        return null;
    }

    void removeComponent(T)()
    {
        foreach (ulong index, HipComponent c; components)
        {
            if(cast(T)c !is null)
            {
                components[index] = components[$-1];
                components.length--;
                return;
            }
        }
        version(HIPREME_DEBUG)
            ErrorHandler.showErrorMessage("Removing component", tag~" has no component '"~T.stringof~"'");
    }

    void update(float deltaTime)
    {
        if(!isActive)
            return;
        foreach(c; components)
        {
            if(!c.hasStarted)
                c._onStart(this);
            c.update(deltaTime);
        }
        foreach(child; children)
            child.update(deltaTime);
    }
}