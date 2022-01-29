/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module jni.helper.androidlog;
version(Android):
import jni.android.log;
import util.string : toStringz;
import core.stdc.stdarg : va_end, va_list, va_start;

//INFORMATION SECTION
int alogi(const(char*)tag, const(char*) format, va_list args)
{
    return __android_log_vprint(android_LogPriority.ANDROID_LOG_INFO, tag, format, args);
}
int alogi(const(char*) tag, const(char*) format, ...)
{
    va_list arg_list;
    va_start(arg_list, format);
    int result = alogi(tag,format,arg_list);
    va_end(arg_list);
    return result;
}
int alogi(string tag, string format, ...)
{
    va_list arg_list;
    va_start(arg_list, format);
    const(char*) nTag = toStringz(tag);
    const(char*) nFormat = toStringz(format);
    int result = alogi(nTag, nFormat, arg_list);
    va_end(arg_list);
    return result;    
}


//WARNING SECTION
int alogw(const(char*)tag,const(char*)format,va_list args)
{
    return __android_log_vprint(android_LogPriority.ANDROID_LOG_WARN, tag, format, args);
}
int alogw(const(char*) tag, const(char*) format, ...)
{
    va_list arg_list;
    va_start(arg_list, format);
    int result = alogw(tag, format, arg_list);
    va_end(arg_list);
    return result;
}

int alogw(string tag, string format, ...)
{
    va_list arg_list;
    va_start(arg_list, format);
    const(char*) nTag = toStringz(tag);
    const(char*) nFormat = toStringz(format);
    int result = alogw(nTag, nFormat, arg_list);
    va_end(arg_list);
    return result;    
}

// ERROR SECTION
int aloge(const(char*) tag, const(char*) format, va_list args)
{
    return __android_log_vprint(android_LogPriority.ANDROID_LOG_ERROR, tag, format, args);
}
int aloge(const(char*) tag, const(char*) format, ...)
{
    va_list arg_list;
    va_start(arg_list, format);
    int result = aloge(tag,format,arg_list);
    va_end(arg_list);
    return result;
}
int aloge(string tag, string format, ...)
{
    va_list arg_list;
    va_start(arg_list, format);
    const(char*) nTag = toStringz(tag);
    const(char*) nFormat = toStringz(format);
    int result = aloge(nTag, nFormat, arg_list);
    va_end(arg_list);
    return result;    
}


// FATAL SECTION
int alogf(const(char*) tag, const(char*) format, va_list args)
{
    return __android_log_vprint(android_LogPriority.ANDROID_LOG_FATAL, tag, format, args);
}
int alogf(const(char*) tag, const(char*) format, ...)
{
    va_list arg_list;
    va_start(arg_list, format);
    int result = alogf(tag,format,arg_list);
    va_end(arg_list);
    return result;
}
int alogf(string tag, string format, ...)
{
    va_list arg_list;
    va_start(arg_list, format);
    const(char*) nTag = toStringz(tag);
    const(char*) nFormat = toStringz(format);
    int result = alogf(nTag, nFormat, arg_list);
    va_end(arg_list);
    return result;    
}