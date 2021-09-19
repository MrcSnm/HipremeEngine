
module jni.android.native_activity;
version (Android)
{
	import core.stdc.stdint;
	import jni.jni;
	import jni.android.rect;
	import jni.android.asset_manager;
	import jni.android.native_window;
	import jni.android.input;
	extern (C) 
	{
		struct ANativeActivity
		{
			ANativeActivityCallbacks* callbacks;
			JavaVM* vm;
			JNIEnv* env;
			jobject clazz;
			const char* internalDataPath;
			const char* externalDataPath;
			int32_t sdkVersion;
			void* instance;
			AAssetManager* assetManager;
			const char* obbPath;
		}
		struct ANativeActivityCallbacks
		{
			void function(ANativeActivity* activity) onStart;
			void function(ANativeActivity* activity) onResume;
			void* function(ANativeActivity* activity, size_t* outSize) onSaveInstanceState;
			void function(ANativeActivity* activity) onPause;
			void function(ANativeActivity* activity) onStop;
			void function(ANativeActivity* activity) onDestroy;
			void function(ANativeActivity* activity, int hasFocus) onWindowFocusChanged;
			void function(ANativeActivity* activity, ANativeWindow* window) onNativeWindowCreated;
			void function(ANativeActivity* activity, ANativeWindow* window) onNativeWindowResized;
			void function(ANativeActivity* activity, ANativeWindow* window) onNativeWindowRedrawNeeded;
			void function(ANativeActivity* activity, ANativeWindow* window) onNativeWindowDestroyed;
			void function(ANativeActivity* activity, AInputQueue* queue) onInputQueueCreated;
			void function(ANativeActivity* activity, AInputQueue* queue) onInputQueueDestroyed;
			void function(ANativeActivity* activity, const ARect* rect) onContentRectChanged;
			void function(ANativeActivity* activity) onConfigurationChanged;
			void function(ANativeActivity* activity) onLowMemory;
		}
		alias ANativeActivity_createFunc = void function(ANativeActivity* activity, void* savedState, size_t savedStateSize);
		extern ANativeActivity_createFunc ANativeActivity_onCreate;
		void ANativeActivity_finish(ANativeActivity* activity);
		void ANativeActivity_setWindowFormat(ANativeActivity* activity, int32_t format);
		void ANativeActivity_setWindowFlags(ANativeActivity* activity, uint32_t addFlags, uint32_t removeFlags);
		enum 
		{
			ANATIVEACTIVITY_SHOW_SOFT_INPUT_IMPLICIT = 1,
			ANATIVEACTIVITY_SHOW_SOFT_INPUT_FORCED = 2,
		}
		void ANativeActivity_showSoftInput(ANativeActivity* activity, uint32_t flags);
		enum 
		{
			ANATIVEACTIVITY_HIDE_SOFT_INPUT_IMPLICIT_ONLY = 1,
			ANATIVEACTIVITY_HIDE_SOFT_INPUT_NOT_ALWAYS = 2,
		}
		void ANativeActivity_hideSoftInput(ANativeActivity* activity, uint32_t flags);
	}
}
