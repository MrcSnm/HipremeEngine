module hip.component.base;

interface IComponent
{
    int getID();
    string getName();
}

/**
 * Adds each of the components to the class. If they contain a mixin template called `ExpandFields`, it will
 be automatically mixed in.
 * Params - Components - A list of IBaseComponent implementations
 * Best Practice: Use `pragma(inline, true)` and `final` if they are a function, as could be a significant difference in the binary
 * ExpandFields Example :
 ```d
 mixin template ExpandFields() ///Expand fields from BodyRectComponent
{ //Used for convenient access without needing to use _BodyRectComponent.position.x
    pragma(inline, true)
    {
        final ref float x(){ return _BodyRectComponent.position.x; }
        final ref float y(){ return _BodyRectComponent.position.y; }
        final ref Vector2 velocity(){ return _BodyRectComponent.velocity; }
        final ref Vector2 position(){ return _BodyRectComponent.position; }
        final ref Size size(){ return _BodyRectComponent.size; }
    }
}
 ```
 */
mixin template IncludeComponents(Components...)
{
    static assert(is(typeof(this) : IComponentizable));
    private IComponent[] components;
    static foreach(C; Components)
    {
        static assert(is(C : IComponent), C.stringof ~ " is not a component!");
        mixin("private C _"~__traits(identifier, C)~";");

        static if(__traits(compiles, __traits(getMember, C, "ExpandFields")))
            mixin C.ExpandFields;
    }

    void initializeComponents()
    {
        static if(is(typeof(super) : IComponentizable))
            super.initializeComponents();
        static foreach(C; Components)
        {
            components~= __traits(getMember, typeof(this), "_"~__traits(identifier, C)) = new C();
        }
    }

    /**
     * Used more internally in the class. It returns the component in compilation time and gives
     * a compilation failure if it doesn't exists
     * Returns: The Component evaluated in compilation time
     */
    T Get(T)()
    {
        return mixin("_",__traits(identifier, T));
    }
    IComponent getComponentBase(int id)
    {
        foreach(c; components)
            if(c.getID() == id)
                return c;
        return null;
    }
}

class IBaseComponent(T) : IComponent
{
    final int getID(){return getComponentID!T;}
    final string getName(){return __traits(identifier, T);}
}

interface IComponentizable
{
    IComponent getComponentBase(int id);
    T getComponent(T)() if(is(T : IComponent)) {return cast(T)getComponentBase(getComponentID!T);}

}

private __gshared int compID = 0;
private int getComponentID(T)()
{
    __gshared int _compId = 0;
    if(_compId == 0)
        _compId = ++compID;
    return _compId;
}