// D import file generated from 'source\util\reflection.d'
module util.reflection;
int asInt(alias enumMember)()
{
	alias T = typeof(enumMember);
	foreach (i, mem; __traits(allMembers, T))
	{
		if (mem == enumMember.stringof)
			return i;
	}
	ErrorHandler.assertExit(0, "Member " ~ enumMember.stringof ~ " from type " ~ T.stringof ~ " does not exist");
}
bool isLiteral(alias variable)(string var = variable.stringof)
{
	import std.string : isNumeric;
	import std.algorithm : count;
	return isNumeric(var) || count(var, "\"") == 2;
}
T nullCheck(string expression, T, Q)(T defaultValue, Q target)
{
	import std.traits : ReturnType;
	import std.conv : to;
	import std.string : split;
	enum exps = expression.split(".");
	enum firstExp = exps[0] ~ "." ~ exps[1];
	mixin("alias ", exps[0], " = target;");
	if (target is null)
		return defaultValue;
	static if (mixin("isFunction!(" ~ firstExp ~ ")"))
	{
		mixin("ReturnType!(" ~ firstExp ~ ") _v0 = " ~ firstExp ~ ";");
		if (_v0 is null)
			return defaultValue;
	}
	else
	{
		mixin("typeof(" ~ firstExp ~ ") _v0 = " ~ firstExp ~ ";");
	}
	static foreach (i, e; exps[2..$])
	{
		static if (mixin("isFunction!(_v" ~ to!string(i) ~ "." ~ e ~ ")"))
		{
			mixin("ReturnType!(_v" ~ to!string(i) ~ "." ~ e ~ ") _v" ~ to!string(i + 1) ~ "= _v" ~ to!string(i) ~ "." ~ e ~ ";");
		}
		else
		{
			mixin("typeof(_v" ~ to!string(i) ~ "." ~ e ~ ") _v" ~ to!string(i + 1) ~ "= _v" ~ to!string(i) ~ "." ~ e ~ ";");
		}
		static if (i != exps[2..$].length - 1)
		{
			mixin("if (_v" ~ to!string(i + 1) ~ " is null) return defaultValue;");
		}

	}
	mixin("return _v", to!string(exps.length - 2), ";");
}
