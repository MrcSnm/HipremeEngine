module error.handler;
import std.stdio;
import std.conv;
version(Android)
{
    import jni.helper.androidlog;
}
import std.system;

/** 
 * Base clas for documenting errors
 */
 
public class EngineErrorStack
{
    public string stackName;
    public string[] errorStack;

    private this(string stackName)
    {
        this.stackName = stackName;
    }

    public static EngineErrorStack getNewStack(string stackName)
    {
        return new EngineErrorStack(stackName);
    }
    /** 
     * Adds an error to the stack
     * Params:
     *   errorHeader = Error Short
     *   errorMessage = Error Long
     */
    public void addError(string errorHeader, string errorMessage)
    {
        errorStack~= errorHeader ~ ": " ~ errorMessage;
    }

    public void showStack()
    {
        static if(os == OS.android)
        {
            aloge("HipremeEngine", "ErrorStack: " ~ stackName);
            const int len = cast(int)this.errorStack.length;
            for(int i = 0; i < len; i++)
                aloge("HipremeEngine", "\t" ~ errorStack[i]);
        }
        else
        {
            writeln("ErrorStack: " ~ stackName);
            const int len = cast(int)this.errorStack.length;
            for(int i = 0; i < len; i++)
                writeln("\t" ~ errorStack[i]);
        }
    }
}


/** 
 * Class Used for handling errors
 */
public static class ErrorHandler
{
    private static bool HAS_ANY_ERROR_HAPPENNED = false;

    private static EngineErrorStack currentStack;
    private static EngineErrorStack[] stackHistory;
    private static string[] warnHistory;
    private static bool isListening = false;
    public static string LAST_ERROR = "";
    
    /** 
     * This function will look wether any error has happenned
     *  stackName = This will help identify where the error ocurred
     */
    public static void startListeningForErrors(string stackName = "Default Error")
    {
        if(isListening)
            stopListeningForErrors();
        HAS_ANY_ERROR_HAPPENNED = false;
        isListening = true;
        currentStack = EngineErrorStack.getNewStack(stackName);
    }
    /** 
     * Will stop listening and 
     * Returns: HAS_ANY_ERROR_HAPPENNED
     */
    public static bool stopListeningForErrors()
    {
        if(HAS_ANY_ERROR_HAPPENNED)
            stackHistory~= currentStack;
        currentStack = null;
        isListening = false;
        return HAS_ANY_ERROR_HAPPENNED;
    }

    private static void getError(string errorHeader, string error)
    {
        if(isListening)
        {
            LAST_ERROR = errorHeader ~ ": \n" ~ error;
            currentStack.addError(errorHeader, error);
        }
    }


    /** 
     * This function adds to the error stack
     * Params:
     *   errorTitle = Error Header
     *   errorMessage = Error Message
     */
    public static void showErrorMessage(string errorTitle, string errorMessage)
    {
        static if(os == OS.android)
        {
            aloge("HipremeEngine", "\nError: " ~ errorTitle);
            aloge("HipremeEngine", errorMessage);
        }
        else
        {
            writeln("\nError: " ~ errorTitle);
            writeln(errorMessage);
        }
        getError(errorTitle, errorMessage);
    }
    public static void showWarningMessage(string warningTitle, string warningMessage)
    {
        static if(os == OS.android)
        {
            alogw("HipremeEngine", "\nWarning: " ~ warningTitle);
            alogw("HipremeEngine", warningMessage);
        }
        else
        {
            writeln("\nWarning: " ~ warningTitle);
            writeln(warningMessage);
        }
        warnHistory~= warningTitle~": "~warningMessage;
    }

    /** 
     * 
     * Params:
     *   expression = Expression for looking wether an error has happenned
     *   errorTitle = Error Header
     *   errorMessage = Error Message
     * Returns: If the error happenned
     */
    public static bool assertErrorMessage(bool expression, string errorTitle, string errorMessage,
    string file = __FILE__, size_t line =__LINE__, string mod = __MODULE__, string func = __PRETTY_FUNCTION__)
    {
        version(HIPREME_DEBUG)
        {
            string where = "at module '"~mod~"' "~file~":"~to!string(line)~"("~func~")\n\t";
        }
        else
        {
            string where="";
        }
        expression = !expression; //Negate the expression, as it must return wether error ocurred
        if(expression)
            showErrorMessage(where~errorTitle, "\t"~errorMessage);
        return expression;
    }

    public static void showEveryError()
    {
        foreach(stack; stackHistory)
        {
            stack.showStack();
        }
    }
}