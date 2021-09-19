
module debugging.runtime;
import std.traits : isFunction;
struct Hidden;
struct RuntimeConsole;
private string[] REGISTERED_TYPES;
struct RuntimeVariable
{
	void* var;
	string name;
	string type;
}
class RuntimeDebug
{
	public static void instancePrint(alias instance)(ref const typeof(instance) cls = instance)
	{
		version (HIPREME_DEBUG)
		{
			import std.stdio : writefln;
			alias T = typeof(instance);
			MEMBERS:
			foreach (member; __traits(allMembers, T))
			{
				static if (__traits(compiles, __traits(getMember, T, member)))
				{
					enum name = "cls." ~ member;
					foreach (attr; __traits(getAttributes, mixin("T." ~ member)))
					{
						static if (is(attr == Hidden))
						{
							continue MEMBERS;
						}

					}
					static if (!mixin("isFunction!(" ~ cls.stringof ~ "." ~ member ~ ")") && (member != "Monitor"))
					{
						mixin("writefln(\"" ~ instance.stringof ~ "." ~ member ~ ": %s\", mixin(name));");
					}

				}

			}
		}

	}
	public static void attachVar(alias varSymbol)(ref const typeof(varSymbol) var = varSymbol)
	{
		version (HIPREME_DEBUG)
		{
			alias T = typeof(varSymbol);
			static if (is(T == class))
			{
				static foreach (member; __traits(allMembers, T))
				{
					static if (__traits(compiles, __traits(getMember, T, member)))
					{
						foreach (attr; __traits(getAttributes, mixin("T." ~ member)))
						{
							static if (is(attr == RuntimeConsole))
							{
								break;
							}

						}
					}

				}
			}
			else
			{
			}
		}

	}
}
