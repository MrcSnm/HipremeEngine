// D import file generated from 'source\jni\android\native_window.d'
module jni.android.native_window;
import jni.android.android_api;
import core.stdc.stdint;
import jni.android.data_space;
import jni.android.hardware_buffer;
import jni.android.rect;
extern (C) 
{
	enum ANativeWindow_LegacyFormat 
	{
		WINDOW_FORMAT_RGBA_8888 = AHardwareBuffer_Format.AHARDWAREBUFFER_FORMAT_R8G8B8A8_UNORM,
		WINDOW_FORMAT_RGBX_8888 = AHardwareBuffer_Format.AHARDWAREBUFFER_FORMAT_R8G8B8X8_UNORM,
		WINDOW_FORMAT_RGB_565 = AHardwareBuffer_Format.AHARDWAREBUFFER_FORMAT_R5G6B5_UNORM,
	}
	enum ANativeWindowTransform 
	{
		ANATIVEWINDOW_TRANSFORM_IDENTITY = 0,
		ANATIVEWINDOW_TRANSFORM_MIRROR_HORIZONTAL = 1,
		ANATIVEWINDOW_TRANSFORM_MIRROR_VERTICAL = 2,
		ANATIVEWINDOW_TRANSFORM_ROTATE_90 = 4,
		ANATIVEWINDOW_TRANSFORM_ROTATE_180 = ANATIVEWINDOW_TRANSFORM_MIRROR_HORIZONTAL | ANATIVEWINDOW_TRANSFORM_MIRROR_VERTICAL,
		ANATIVEWINDOW_TRANSFORM_ROTATE_270 = ANATIVEWINDOW_TRANSFORM_ROTATE_180 | ANATIVEWINDOW_TRANSFORM_ROTATE_90,
	}
	struct ANativeWindow;
	struct ANativeWindow_Buffer
	{
		int32_t width;
		int32_t height;
		int32_t stride;
		int32_t format;
		void* bits;
		uint32_t[6] reserved;
	}
	void ANativeWindow_acquire(ANativeWindow* window);
	void ANativeWindow_release(ANativeWindow* window);
	int32_t ANativeWindow_getWidth(ANativeWindow* window);
	int32_t ANativeWindow_getHeight(ANativeWindow* window);
	int32_t ANativeWindow_getFormat(ANativeWindow* window);
	int32_t ANativeWindow_setBuffersGeometry(ANativeWindow* window, int32_t width, int32_t height, int32_t format);
	int32_t ANativeWindow_lock(ANativeWindow* window, ANativeWindow_Buffer* outBuffer, ARect* inOutDirtyBounds);
	int32_t ANativeWindow_unlockAndPost(ANativeWindow* window);
	static if (__ANDROID_API__ >= 26)
	{
		int32_t ANativeWindow_setBuffersTransform(ANativeWindow* window, int32_t transform);
	}
	static if (__ANDROID_API__ >= 28)
	{
		int32_t ANativeWindow_setBuffersDataSpace(ANativeWindow* window, int32_t dataSpace);
		int32_t ANativeWindow_getBuffersDataSpace(ANativeWindow* window);
	}
	static if (__ANDROID_API__ >= 30)
	{
		enum ANativeWindow_FrameRateCompatibility 
		{
			ANATIVEWINDOW_FRAME_RATE_COMPATIBILITY_DEFAULT = 0,
			ANATIVEWINDOW_FRAME_RATE_COMPATIBILITY_FIXED_SOURCE = 1,
		}
		int32_t ANativeWindow_setFrameRate(ANativeWindow* window, float frameRate, int8_t compatibility);
		void ANativeWindow_tryAllocateBuffers(ANativeWindow* window);
	}
}
