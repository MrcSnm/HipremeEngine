
module jni.android.hardware_buffer;
import core.stdc.stdint;
import jni.android.rect;
import jni.android.android_api;
enum AHardwareBuffer_Format 
{
	AHARDWAREBUFFER_FORMAT_R8G8B8A8_UNORM = 1,
	AHARDWAREBUFFER_FORMAT_R8G8B8X8_UNORM = 2,
	AHARDWAREBUFFER_FORMAT_R8G8B8_UNORM = 3,
	AHARDWAREBUFFER_FORMAT_R5G6B5_UNORM = 4,
	AHARDWAREBUFFER_FORMAT_R16G16B16A16_FLOAT = 22,
	AHARDWAREBUFFER_FORMAT_R10G10B10A2_UNORM = 43,
	AHARDWAREBUFFER_FORMAT_BLOB = 33,
	AHARDWAREBUFFER_FORMAT_D16_UNORM = 48,
	AHARDWAREBUFFER_FORMAT_D24_UNORM = 49,
	AHARDWAREBUFFER_FORMAT_D24_UNORM_S8_UINT = 50,
	AHARDWAREBUFFER_FORMAT_D32_FLOAT = 51,
	AHARDWAREBUFFER_FORMAT_D32_FLOAT_S8_UINT = 52,
	AHARDWAREBUFFER_FORMAT_S8_UINT = 53,
	AHARDWAREBUFFER_FORMAT_Y8Cb8Cr8_420 = 35,
}
enum AHardwareBuffer_UsageFlags 
{
	AHARDWAREBUFFER_USAGE_CPU_READ_NEVER = 0LU,
	AHARDWAREBUFFER_USAGE_CPU_READ_RARELY = 2LU,
	AHARDWAREBUFFER_USAGE_CPU_READ_OFTEN = 3LU,
	AHARDWAREBUFFER_USAGE_CPU_READ_MASK = 15LU,
	AHARDWAREBUFFER_USAGE_CPU_WRITE_NEVER = 0LU << 4,
	AHARDWAREBUFFER_USAGE_CPU_WRITE_RARELY = 2LU << 4,
	AHARDWAREBUFFER_USAGE_CPU_WRITE_OFTEN = 3LU << 4,
	AHARDWAREBUFFER_USAGE_CPU_WRITE_MASK = 15LU << 4,
	AHARDWAREBUFFER_USAGE_GPU_SAMPLED_IMAGE = 1LU << 8,
	AHARDWAREBUFFER_USAGE_GPU_FRAMEBUFFER = 1LU << 9,
	AHARDWAREBUFFER_USAGE_GPU_COLOR_OUTPUT = AHARDWAREBUFFER_USAGE_GPU_FRAMEBUFFER,
	AHARDWAREBUFFER_USAGE_COMPOSER_OVERLAY = 1LU << 11,
	AHARDWAREBUFFER_USAGE_PROTECTED_CONTENT = 1LU << 14,
	AHARDWAREBUFFER_USAGE_VIDEO_ENCODE = 1LU << 16,
	AHARDWAREBUFFER_USAGE_SENSOR_DIRECT_DATA = 1LU << 23,
	AHARDWAREBUFFER_USAGE_GPU_DATA_BUFFER = 1LU << 24,
	AHARDWAREBUFFER_USAGE_GPU_CUBE_MAP = 1LU << 25,
	AHARDWAREBUFFER_USAGE_GPU_MIPMAP_COMPLETE = 1LU << 26,
	AHARDWAREBUFFER_USAGE_VENDOR_0 = 1LU << 28,
	AHARDWAREBUFFER_USAGE_VENDOR_1 = 1LU << 29,
	AHARDWAREBUFFER_USAGE_VENDOR_2 = 1LU << 30,
	AHARDWAREBUFFER_USAGE_VENDOR_3 = 1LU << 31,
	AHARDWAREBUFFER_USAGE_VENDOR_4 = 1LU << 48,
	AHARDWAREBUFFER_USAGE_VENDOR_5 = 1LU << 49,
	AHARDWAREBUFFER_USAGE_VENDOR_6 = 1LU << 50,
	AHARDWAREBUFFER_USAGE_VENDOR_7 = 1LU << 51,
	AHARDWAREBUFFER_USAGE_VENDOR_8 = 1LU << 52,
	AHARDWAREBUFFER_USAGE_VENDOR_9 = 1LU << 53,
	AHARDWAREBUFFER_USAGE_VENDOR_10 = 1LU << 54,
	AHARDWAREBUFFER_USAGE_VENDOR_11 = 1LU << 55,
	AHARDWAREBUFFER_USAGE_VENDOR_12 = 1LU << 56,
	AHARDWAREBUFFER_USAGE_VENDOR_13 = 1LU << 57,
	AHARDWAREBUFFER_USAGE_VENDOR_14 = 1LU << 58,
	AHARDWAREBUFFER_USAGE_VENDOR_15 = 1LU << 59,
	AHARDWAREBUFFER_USAGE_VENDOR_16 = 1LU << 60,
	AHARDWAREBUFFER_USAGE_VENDOR_17 = 1LU << 61,
	AHARDWAREBUFFER_USAGE_VENDOR_18 = 1LU << 62,
	AHARDWAREBUFFER_USAGE_VENDOR_19 = 1LU << 63,
}
struct AHardwareBuffer_Desc
{
	uint32_t width;
	uint32_t height;
	uint32_t layers;
	uint32_t format;
	uint64_t usage;
	uint32_t stride;
	uint32_t rfu0;
	uint64_t rfu1;
}
struct AHardwareBuffer_Plane
{
	void* data;
	uint32_t pixelStride;
	uint32_t rowStride;
}
struct AHardwareBuffer_Planes
{
	uint32_t planeCount;
	AHardwareBuffer_Plane[4] planes;
}
struct AHardwareBuffer;
static if (__ANDROID_API__ >= 26)
{
	int AHardwareBuffer_allocate(const AHardwareBuffer_Desc* desc, AHardwareBuffer** outBuffer);
	void AHardwareBuffer_acquire(AHardwareBuffer* buffer);
	void AHardwareBuffer_release(AHardwareBuffer* buffer);
	void AHardwareBuffer_describe(const AHardwareBuffer* buffer, AHardwareBuffer_Desc* outDesc);
	int AHardwareBuffer_lock(AHardwareBuffer* buffer, uint64_t usage, int32_t fence, const ARect* rect, void** outVirtualAddress);
	int AHardwareBuffer_unlock(AHardwareBuffer* buffer, int32_t* fence);
	int AHardwareBuffer_sendHandleToUnixSocket(const AHardwareBuffer* buffer, int socketFd);
	int AHardwareBuffer_recvHandleFromUnixSocket(int socketFd, AHardwareBuffer** outBuffer);
}
static if (__ANDROID_API__ >= 29)
{
	int AHardwareBuffer_lockPlanes(AHardwareBuffer* buffer, uint64_t usage, int32_t fence, const ARect* rect, AHardwareBuffer_Planes* outPlanes);
	int AHardwareBuffer_isSupported(const AHardwareBuffer_Desc* desc);
	int AHardwareBuffer_lockAndGetInfo(AHardwareBuffer* buffer, uint64_t usage, int32_t fence, const ARect* rect, void** outVirtualAddress, int32_t* outBytesPerPixel, int32_t* outBytesPerStride);
}
