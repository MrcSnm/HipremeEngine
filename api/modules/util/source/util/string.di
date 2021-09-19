// D import file generated from 'source\util\string.d'
module util.string;
public import std.conv : to;
pure string replaceAll(string str, char what, string replaceWith = "");
pure string replaceAll(string str, string what, string replaceWith = "");
pure long indexOf(in string str, in string toFind, int startIndex = 0);
pure long lastIndexOf(in string str, in string toFind);
T toDefault(T)(string s, T defaultValue = T.init)
{
	if (s == "")
		return defaultValue;
	T v = defaultValue;
	try
	{
		v = to!T(s);
	}
	catch(Exception e)
	{
	}
	return v;
}
