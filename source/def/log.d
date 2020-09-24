module def.log;
private import global.opts;

version(Android) { import jni.helper.androidlog; }
else { import std.stdio;}

void log_err(string toLog, ...)
{
    static if(!HE_NO_LOG)
    {
        version(Android)
        {
            // aloge("HipremeEngine_ERROR", toLog, )
        }
        else
        {
            // writefln(toLog, )
        }
    }
}