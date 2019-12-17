module error.handler;
import std.stdio;
import std.conv;

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
        writeln("ErrorStack: " ~ stackName);
        const int len = cast(int)this.errorStack.length;
        for(int i = 0; i < len; i++)
            writeln("\t" ~ errorStack[i]);
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
     * Params:
     *   errorTitle = Error Header
     *   errorMessage = Error Message
     */
    public static void showErrorMessage(string errorTitle, string errorMessage)
    {
        writeln("\nError: " ~ errorTitle);
        writeln(errorMessage);
        getError(errorTitle, errorMessage);
    }
    /** 
     * 
     * Params:
     *   expression = Expression for looking wether an error has happenned
     *   errorTitle = Error Header
     *   errorMessage = Error Message
     * Returns: If the error happenned
     */
    public static bool assertErrorMessage(bool expression, string errorTitle, string errorMessage)
    {
        if(expression)
            showErrorMessage(errorTitle, errorMessage);
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