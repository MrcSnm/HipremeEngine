// D import file generated from 'source\data\ini.d'
module data.ini;
import util.conv : to;
struct IniVar
{
	string name;
	string value;
	T get(T)()
	{
		return to!T(value);
	}
	string get();
	auto opAssign(T)(T value)
	{
		this.value = to!string(value);
		return value;
	}
	const pure nothrow @safe string toString();
}
struct IniBlock
{
	string name;
	string comment;
	IniVar[string] vars;
	const pure @safe string toString();
	auto opDispatch(string member)()
	{
		return vars[member];
	}
	alias vars this;
}
class IniFile
{
	IniBlock[string] blocks;
	string path;
	bool configFound = false;
	bool noError = true;
	string[] errors;
	static IniFile parse(string path);
	public T tryGet(T)(string varPath, T defaultVal = T.init)
	{
		import util.string : split;
		string[] accessors = varPath.split(".");
		if (accessors.length < 2)
			return defaultVal;
		IniBlock* b = accessors[0] in this;
		if (b is null)
			return defaultVal;
		IniVar* v = accessors[1] in *b;
		if (v is null)
			return defaultVal;
		return v.get!T;
	}
	auto opDispatch(string member)()
	{
		return blocks[member];
	}
	alias blocks this;
}
