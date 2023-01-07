module hip.component.base;

interface IComponent
{
    int getID();
    string getName();
}

mixin template IncludeComponents(Components...)
{
    static assert(is(typeof(this) : IComponentizable));
    private IComponent[] components;
    static foreach(C; Components)
    {
        static assert(is(C : IComponent), C.stringof ~ " is not a component!");
        mixin("private C _"~__traits(identifier, C)~";");
    }

    void initializeComponents()
    {
        static if(is(typeof(super) : IComponentizable))
            super.initializeComponents();
        static foreach(C; Components)
        {{
            alias mem =  __traits(getMember, typeof(this), "_"~__traits(identifier, C));
            mem = new C();
            components~= mem;
        }}
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
    static int _compId = 0;
    if(_compId == 0)
        _compId = ++compID;
    return _compId;
}