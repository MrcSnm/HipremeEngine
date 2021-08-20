/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

/* dstep -I/path/to/ndk-r9d/toolchains/llvm-3.4/prebuilt/linux-x86/lib/clang/3.4/include /path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include/android/log.h -o log.d*/

module jni.android.log;

import core.stdc.stdarg;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

enum android_LogPriority
{
    ANDROID_LOG_UNKNOWN,
    ANDROID_LOG_DEFAULT,
    ANDROID_LOG_VERBOSE,
    ANDROID_LOG_DEBUG,
    ANDROID_LOG_INFO,
    ANDROID_LOG_WARN,
    ANDROID_LOG_ERROR,
    ANDROID_LOG_FATAL,
    ANDROID_LOG_SILENT
}

int __android_log_write(int prio, const(char)* tag, const(char)* text);
int __android_log_print(int prio, const(char)* tag, const(char)* fmt, ...);
int __android_log_vprint(int prio, const(char)* tag, const(char)* fmt, va_list ap);
void __android_log_assert(const(char)* cond, const(char)* tag, const(char)* fmt, ...);
