// D import file generated from 'source\jni\android\android_native_app_glue.d'
module jni.android.android_native_app_glue;
version (Android)
{
	import core.runtime : rt_init, rt_term;
	import core.stdc.errno : errno;
	import core.stdc.stdarg : va_list, va_start;
	import core.stdc.stdlib : free, malloc;
	import core.stdc.string : memcpy, memset, strerror;
	import core.sys.posix.pthread;
	import core.sys.posix.unistd : close, pipe, read, write;
	import jni.android.input;
	import jni.android.native_window;
	import jni.android.rect : ARect;
	import jni.android.configuration;
	import jni.android.log;
	import jni.android.looper;
	import jni.android.native_activity;
	version (Android)
	{
		@system 
		{
			struct android_poll_source
			{
				int id;
				android_app* app;
				void function(android_app*, android_poll_source*) process;
			}
			struct android_app
			{
				void* userData;
				void function(android_app*, int) onAppCmd;
				int function(android_app*, AInputEvent*) onInputEvent;
				ANativeActivity* activity;
				AConfiguration* config;
				void* savedState;
				size_t savedStateSize;
				ALooper* looper;
				AInputQueue* inputQueue;
				ANativeWindow* window;
				ARect contentRect;
				int activityState;
				int destroyRequested;
				pthread_mutex_t mutex;
				pthread_cond_t cond;
				int msgread;
				int msgwrite;
				pthread_t thread;
				android_poll_source cmdPollSource;
				android_poll_source inputPollSource;
				int running;
				int stateSaved;
				int destroyed;
				int redrawNeeded;
				AInputQueue* pendingInputQueue;
				ANativeWindow* pendingWindow;
				ARect pendingContentRect;
			}
			enum 
			{
				LOOPER_ID_MAIN = 1,
				LOOPER_ID_INPUT = 2,
				LOOPER_ID_USER = 3,
			}
			enum 
			{
				APP_CMD_INPUT_CHANGED,
				APP_CMD_INIT_WINDOW,
				APP_CMD_TERM_WINDOW,
				APP_CMD_WINDOW_RESIZED,
				APP_CMD_WINDOW_REDRAW_NEEDED,
				APP_CMD_CONTENT_RECT_CHANGED,
				APP_CMD_GAINED_FOCUS,
				APP_CMD_LOST_FOCUS,
				APP_CMD_CONFIG_CHANGED,
				APP_CMD_LOW_MEMORY,
				APP_CMD_START,
				APP_CMD_RESUME,
				APP_CMD_SAVE_STATE,
				APP_CMD_PAUSE,
				APP_CMD_STOP,
				APP_CMD_DESTROY,
			}
			extern (C) void android_main(android_app* app);
			private 
			{
				int LOGI(const(char)* warning);
				int LOGE(const(char)* fmt, ...);
				int LOGV(const(char)* fmt, ...);
				void free_saved_state(android_app* android_app);
				void print_cur_config(android_app* android_app);
				public 
				{
					byte android_app_read_cmd(android_app* android_app);
					void android_app_pre_exec_cmd(android_app* android_app, byte cmd);
					void android_app_post_exec_cmd(android_app* android_app, byte cmd);
					void app_dummy();
					private 
					{
						void android_app_destroy(android_app* android_app);
						void process_input(android_app* app, android_poll_source* source);
						void process_cmd(android_app* app, android_poll_source* source);
						extern (C) void* android_app_entry(void* param);
						android_app* android_app_create(ANativeActivity* activity, void* savedState, size_t savedStateSize);
						void android_app_write_cmd(android_app* android_app, byte cmd);
						void android_app_set_input(android_app* android_app, AInputQueue* inputQueue);
						void android_app_set_window(android_app* android_app, ANativeWindow* window);
						void android_app_set_activity_state(android_app* android_app, byte cmd);
						void android_app_free(android_app* android_app);
						extern (C) void onDestroy(ANativeActivity* activity);
						extern (C) void onStart(ANativeActivity* activity);
						extern (C) void onResume(ANativeActivity* activity);
						extern (C) void* onSaveInstanceState(ANativeActivity* activity, size_t* outLen);
						extern (C) void onPause(ANativeActivity* activity);
						extern (C) void onStop(ANativeActivity* activity);
						extern (C) void onConfigurationChanged(ANativeActivity* activity);
						extern (C) void onLowMemory(ANativeActivity* activity);
						extern (C) void onWindowFocusChanged(ANativeActivity* activity, int focused);
						extern (C) void onNativeWindowCreated(ANativeActivity* activity, ANativeWindow* window);
						extern (C) void onNativeWindowDestroyed(ANativeActivity* activity, ANativeWindow* window);
						extern (C) void onInputQueueCreated(ANativeActivity* activity, AInputQueue* queue);
						extern (C) void onInputQueueDestroyed(ANativeActivity* activity, AInputQueue* queue);
						public extern (C) void ANativeActivity_onCreate(ANativeActivity* activity, void* savedState, size_t savedStateSize);
					}
				}
			}
		}
	}
}
