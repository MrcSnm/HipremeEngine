// D import file generated from 'source\ai\decisiontree.d'
module ai.decisiontree;
enum ResultTypes 
{
	_string,
	_bool,
	_int,
	_uint,
	_ushort,
	_ulong,
	_float,
	_double,
	_char,
	_byte,
	_ubyte,
	_void,
	_null,
	_Condition,
}
struct ConditionResult
{
	import util.memory;
	ResultTypes type;
	void* value;
	T* get(T)()
	{
		return cast(T*)value;
	}
	static ConditionResult create(T)(T val)
	{
		static if (is(T == void*))
		{
			return ConditionResult(ResultTypes._void, val);
		}
		else
		{
			static if (__traits(compiles, mixin("ResultTypes._" ~ T.stringof)))
			{
				return ConditionResult(mixin("ResultTypes._" ~ T.stringof), toHeap(val));
			}
			else
			{
				static assert(false, "Could not create result of type " ~ T.stringof);
			}
		}
	}
	static ConditionResult nullResult();
	void dispose();
}
struct Condition
{
	string name;
	bool function(void* context) condition;
	ConditionResult trueResult = ConditionResult.nullResult;
	ConditionResult falseResult = ConditionResult.nullResult;
}
class HipDecisionTree
{
	Condition[string] conditions;
	import std.array : split;
	string name;
	this(string name)
	{
		this.name = name;
	}
	HipDecisionTree addCondition(Condition c);
	HipDecisionTree setTrueBranch(string conditionName, ConditionResult res);
	HipDecisionTree setFalseBranch(string conditionName, ConditionResult res);
	ConditionResult check(string which, void* ctx);
	protected Condition* getConditionByName(string name);
}
