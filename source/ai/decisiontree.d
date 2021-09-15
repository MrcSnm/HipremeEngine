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
    _Condition
}

struct ConditionResult
{
    import util.memory;
    ResultTypes type;
    void* value;

    T* get(T)(){return cast(T*)value;}
    static ConditionResult create(T)(T val)
    {
        static if(is(T == void*))
            return ConditionResult(ResultTypes._void, val);
        else static if(__traits(compiles, mixin("ResultTypes._"~T.stringof)))
            return ConditionResult(mixin("ResultTypes._"~T.stringof), toHeap(val));
        else
            static assert(false, "Could not create result of type "~T.stringof);
    }

    static ConditionResult nullResult(){return ConditionResult(ResultTypes._null, null);}

    void dispose()
    {
        if(value != null)
        {
            free(value);
            value = null;
            type = ResultTypes._null;
        }
    }
}

struct Condition
{
    string name;
    bool function(void* context) condition;
    ConditionResult trueResult = ConditionResult.nullResult;
    ConditionResult falseResult = ConditionResult.nullResult;
}


/**

DecisionTree intuition:

IsVisible:
    true-> Returns PlayerMovement.run
    false-> Returns a new branch if is hearing
        IsHearing:
            true-> Returns "They're hearing you!"
            false-> Returns null

Functions receive a void* context for accepting any data
You can set true or false results for branches by executing the following code
`tree.setTrueBranch("IsVisible.no.IsHearing", ConditionResult.create("They're hearing you!");`

This will make the true branch result at isVisible(false branch) gets the value of the string.

Basic example on how the decision tree works:

HipDecisionTree playerAI = new HipDecisionTree("Enemy-based PlayerAI");
    
playerAI.addCondition(Condition("IsVisible",
(void* ctx)
{
    PlayerAIDecision* d = cast(PlayerAIDecision*)ctx;
    writeln("Checking if visible");
    return d.isVisible;
}));
playerAI.setTrueBranch("IsVisible", ConditionResult.create(cast(int)PlayerMovement.run))
        .setFalseBranch("IsVisible", ConditionResult.create(Condition("IsHearing", 
        (void* ctx)
        {
            PlayerAIDecision* d = cast(PlayerAIDecision*)ctx;
            return d.isHearing;
        })
        ));
playerAI.setTrueBranch("IsVisible.no.IsHearing", ConditionResult.create("They're hearing you!"));

PlayerAIDecision d;
d.isVisible = false;
d.isHearing = false;
ConditionResult res = playerAI.check("IsVisible", &d);
if(res.type == ResultTypes._int)
{
    writeln(*cast(int*)res.value);
}
else if(res.type == ResultTypes._string)
{
    writeln(*cast(string*)res.value);
}
*/

class HipDecisionTree
{
    Condition[string] conditions;
    import std.array:split;
    string name;
    this(string name)
    {
        this.name = name;
    }

    HipDecisionTree addCondition(Condition c)
    {
        conditions[c.name] = c;
        return this;
    }

    HipDecisionTree setTrueBranch(string conditionName, ConditionResult res)
    {
        getConditionByName(conditionName).trueResult = res;
        return this;
    }
    HipDecisionTree setFalseBranch(string conditionName, ConditionResult res)
    {
        getConditionByName(conditionName).falseResult = res;
        return this;
    }

    ConditionResult check(string which, void* ctx)
    {
        assert((which in conditions) != null, "Could not find "~which);
        Condition* c = which in conditions;
        ConditionResult res;

        while(true)
        {
            bool isTrue = c.condition(ctx);
            if(isTrue)
                res = c.trueResult;
            else
                res = c.falseResult;
            if(res.type == ResultTypes._Condition)
                c = cast(Condition*)res.value;
            else
                return res;
        }
    }
    protected Condition* getConditionByName(string name)
    {
        string[] names = name.split(".");
        string lastName = names[0];
        Condition* c = lastName in conditions;
        if(names.length == 1)
            return c;
        assert(names.length % 2 != 0, "Names must not be divisible by 2. They must have a pre accessor as 'yes' or 'no'");

        bool isTrue;
        for(int i = 1; i < names.length; i+= 2)
        {
            isTrue = names[i] == "yes";
            if(isTrue)
                c = c.trueResult.get!Condition;
            else
                c = c.falseResult.get!Condition;
        }
        return c;
    }

}