
module jni.helper.androidlog;
version (Android)
{
	import jni.android.log;
	import std.conv : to;
	import std.string : toStringz;
	import core.stdc.stdarg : va_end, va_list, va_start;
	int alogi(const(char*) tag, const(char*) format, va_list args);
	int alogi(const(char*) tag, const(char*) format, ...);
	int alogi(string tag, string format, ...);
	int alogw(const(char*) tag, const(char*) format, va_list args);
	int alogw(const(char*) tag, const(char*) format, ...);
	int alogw(string tag, string format, ...);
	int aloge(const(char*) tag, const(char*) format, va_list args);
	int aloge(const(char*) tag, const(char*) format, ...);
	int aloge(string tag, string format, ...);
	int alogf(const(char*) tag, const(char*) format, va_list args);
	int alogf(const(char*) tag, const(char*) format, ...);
	int alogf(string tag, string format, ...);
}
