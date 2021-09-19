
module error.handler;
import console.log;
import std.conv;
version (Android)
{
	import jni.helper.androidlog;
}
import std.system;
public class EngineErrorStack
{
	public string stackName;
	public string[] errorStack;
	private this(string stackName)
	{
		this.stackName = stackName;
	}
	public static EngineErrorStack getNewStack(string stackName);
	public void addError(string errorHeader, string errorMessage);
	public void showStack();
}
public static class ErrorHandler
{
	private static bool HAS_ANY_ERROR_HAPPENNED = false;
	private static EngineErrorStack currentStack;
	private static EngineErrorStack[] stackHistory;
	private static string[] warnHistory;
	private static bool isListening = false;
	public static string LAST_ERROR = "";
	public static void startListeningForErrors(string stackName = "Default Error");
	public static bool stopListeningForErrors();
	private static void getError(lazy string errorHeader, lazy string error);
	public static void showErrorMessage(string errorTitle, string errorMessage, bool isFatal = false);
	public static void showWarningMessage(string warningTitle, string warningMessage);
	public static bool assertErrorMessage(bool expression, string errorTitle, string errorMessage, bool isFatal = false, string file = __FILE__, size_t line = __LINE__, string mod = __MODULE__, string func = __PRETTY_FUNCTION__);
	public static void assertExit(bool expression, string onAssertionFailure = "Assertion Failure", string file = __FILE__, size_t line = __LINE__, string mod = __MODULE__, string func = __PRETTY_FUNCTION__);
	public static void showEveryError();
}
