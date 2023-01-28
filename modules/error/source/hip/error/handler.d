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
            rawfatal(errorTitle, "\t[[", errorMessage, "]]");
        }
        else
        {
            rawerror(errorTitle, "\t[[", errorMessage, "]]");
        }
        getError(errorTitle, errorMessage);
    }
    public static void showWarningMessage(string warningTitle, string warningMessage)
    {
        rawwarn("\nWarning: " ~ warningTitle);
        rawwarn(warningMessage);
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
    public static bool assertErrorMessage(bool expression, string errorTitle, string errorMessage, bool isFatal = false,
    string file = __FILE__, size_t line =__LINE__, string mod = __MODULE__, string func = __PRETTY_FUNCTION__)
    {
        expression = !expression; //Negate the expression, as it must return wether error ocurred
        if(expression)
        {
            version(HIPREME_DEBUG)
            {
                string where = "at module '"~mod~"' "~file~":"~to!string(line)~"("~func~")\n\t";
            }
            else{string where="";}
            showErrorMessage(where~errorTitle, errorMessage, isFatal);
        }
        return expression;
    }

    /** 
     * 
     * Params:
     *   expression = Expression for looking wether an error has happenned
     *   errorTitle = Error Header
     *   errorMessage = Error Message
     * Returns: If the error happenned
     */
    public static bool assertLazyErrorMessage(bool expression, lazy string errorTitle, lazy string errorMessage, bool isFatal = false,
    string file = __FILE__, size_t line =__LINE__, string mod = __MODULE__, string func = __PRETTY_FUNCTION__)
    {
        expression = !expression; //Negate the expression, as it must return wether error ocurred
        if(expression)
        {
            version(HIPREME_DEBUG)
            {
                string where = "at module '"~mod~"' "~file~":"~to!string(line)~"("~func~")\n\t";
            }
            else{string where="";}
            showErrorMessage(where~errorTitle, errorMessage, isFatal);
        }
        return expression;
    }

    /**
    *   If you're running on a loop or need to concat your failure message, prefer using assertLazyExit.
    */
    public static void assertExit(bool expression, string onAssertionFailure = "Assertion Failure",
    string file = __FILE__, size_t line = __LINE__, string mod = __MODULE__, string func = __PRETTY_FUNCTION__)
    {
        if(!expression)
        {
            cast(void)ErrorHandler.assertErrorMessage(false, "HipAssertion", onAssertionFailure, true,
            file, line, mod, func);
            import core.stdc.stdlib;
            exit(EXIT_FAILURE);
        }
    }

    public static void assertLazyExit(bool expression, lazy string onAssertionFailure,
    string file = __FILE__, size_t line = __LINE__, string mod = __MODULE__, string func = __PRETTY_FUNCTION__)
    {
        if(!expression)
        {
            cast(void)ErrorHandler.assertLazyErrorMessage(false, "HipAssertion", onAssertionFailure, true,
            file, line, mod, func);
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