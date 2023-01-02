module hip.util.betterc;
template getParams (alias fn) 
{
	static if ( is(typeof(fn) params == __parameters) )
    	alias getParams = params;
}


T New(T, Args...)(Args args)
{
    import core.stdc.stdlib:malloc;
    import core.lifetime:emplace;
    align(__traits(classInstanceAlignment, T))
	void[] baseMem = malloc(__traits(classInstanceSize, T))[0..__traits(classInstanceSize, T)];

    T ret = cast(T)baseMem.ptr;
    emplace!T(ret, args);
    return ret;
}


enum GenCPPInterface(Self, itf) =  ()
{
    string ret = "class _" ~ __traits(identifier, itf)~"Impl : itf {" ~ q{ extern(C++):
            Self self;
            this(Self self){this.self = self;}
            };
    
    import std.traits;
    static foreach(fn; __traits(allMembers, itf))
    {{
        string mem = "__traits(getMember, itf, \""~ fn~ "\")";
        string retT = "ReturnType!("~mem~")";
        string params = "getParams!("~mem~")";

        ret~= "override " ~ retT ~ " " ~ fn ~ ("("~params~")") ~ "{"~
            "return (cast(Self)self)."~fn~"(__traits(parameters));}";
    }}
    return ret ~ "}";
}();

extern(C++) class CppObject
{
    this(){initialize();}
    void initialize(){}
}

extern(C++) class CppInterface(Self, Interfaces...) : CppObject
{
    static foreach(itf; Interfaces)
    {
        mixin(q{private itf },  ("_"~__traits(identifier, itf)) ~ ";");
    }
        
    override void initialize()
    {
        import std.traits:ReturnType;
        static foreach(itf; Interfaces)
        {
            mixin(GenCPPInterface!(Self, itf));
            mixin( ("_"~__traits(identifier, itf)) ~(" =  New!(_" ~__traits(identifier, itf) ~ "Impl)(cast(Self)this);"));
        }
    }
    
    
    T getInterface(T)()
    {
        static if(__traits(hasMember, Self, "_"~T.stringof))
            return mixin("_",T.stringof);
        else static if(is(T == Self))
			return cast(Self)this;
		else return null;
    }

	~this()
	{
		import core.stdc.stdlib;
		static foreach(itf; Interfaces)
		{{
			alias mem = __traits(getMember, Self, "_"~itf.stringof);
			destroy(mem);
			free(cast(void*)mem);
		}}
	}
}
