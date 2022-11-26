/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.error.handler;
import hip.console.log;
import hip.util.conv;
version(Android)
{
    import hip.jni.helper.androidlog;
}

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
        rawerror("ErrorStack: " ~ stackName);
        const int len = cast(int)this.errorStack.length;
        for(int i = 0; i < len; i++)
            rawerror("\t" ~ errorStack[i]);
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

    private static void getError(lazy string errorHeader, lazy string error)
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
    public static void showErrorMessage(string errorTitle, string errorMessage, bool isFatal = false)
    {
        if(isFatal)
        {
            rawfatal("\nFATAL ERROR: " ~ errorTitle);
            rawfatal(errorMessage);
        }
        else
        {
            rawerror("\nError: " ~ errorTitle);
            rawerror(errorMessage);
        }
        getError(errorTitle, errorMessage);
    }
    public static void showWarningMessage(string warningTitle, string warningMessage)
    {
        version(Android)
        {
            alogw("HipremeEngine", "\nWarning: " ~ warningTitle);
            alogw("HipremeEngine", warningMessage);
        }
        else
        {
            rawlog("\nWarning: " ~ warningTitle);
            rawlog(warningMessage);
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
    public static bool assertErrorMessage(bool expression, lazy string errorTitle, lazy string errorMessage, bool isFatal = false,
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
            showErrorMessage(where~errorTitle, "\t"~errorMessage, isFatal);
        return expression;
    }

    public static void assertExit(bool expression, lazy string onAssertionFailure = "Assertion Failure",
    string file = __FILE__, size_t line = __LINE__, string mod = __MODULE__, string func = __PRETTY_FUNCTION__)
    {
        if(ErrorHandler.assertErrorMessage(expression, "HipAssertion", onAssertionFailure, true,
        file, line, mod, func))
        {
            import core.stdc.stdlib;
            exit(EXIT_FAILURE);
        }
    }
    static immutable(string) assertReturn(string expression)(string onAssertionFailureMessage)
    {
        return `if(ErrorHandler.assertErrorMessage(`~expression~`, "HipAssertion", "`~onAssertionFailureMessage~
        `"))return;`;
    }

    public static void showEveryError()
    {
        foreach(stack; stackHistory)
        {
            stack.showStack();
        }
    }
}