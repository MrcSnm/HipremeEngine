
module jni.android.sensor;
import jni.android.android_api;
import jni.android.looper;
import core.stdc.math;
import core.stdc.stdint;
extern (C) 
{
	struct AHardwareBuffer;
	enum ASENSOR_RESOLUTION_INVALID()
	{
		return nanf(cast(char*)"\x00".ptr);
	}
	enum ASENSOR_FIFO_COUNT_INVALID = -1;
	enum ASENSOR_DELAY_INVALID = INT32_MIN;
	enum ASENSOR_INVALID = -1;
	enum 
	{
		ASENSOR_TYPE_INVALID = -1,
		ASENSOR_TYPE_ACCELEROMETER = 1,
		ASENSOR_TYPE_MAGNETIC_FIELD = 2,
		ASENSOR_TYPE_GYROSCOPE = 4,
		ASENSOR_TYPE_LIGHT = 5,
		ASENSOR_TYPE_PRESSURE = 6,
		ASENSOR_TYPE_PROXIMITY = 8,
		ASENSOR_TYPE_GRAVITY = 9,
		ASENSOR_TYPE_LINEAR_ACCELERATION = 10,
		ASENSOR_TYPE_ROTATION_VECTOR = 11,
		ASENSOR_TYPE_RELATIVE_HUMIDITY = 12,
		ASENSOR_TYPE_AMBIENT_TEMPERATURE = 13,
		ASENSOR_TYPE_MAGNETIC_FIELD_UNCALIBRATED = 14,
		ASENSOR_TYPE_GAME_ROTATION_VECTOR = 15,
		ASENSOR_TYPE_GYROSCOPE_UNCALIBRATED = 16,
		ASENSOR_TYPE_SIGNIFICANT_MOTION = 17,
		ASENSOR_TYPE_STEP_DETECTOR = 18,
		ASENSOR_TYPE_STEP_COUNTER = 19,
		ASENSOR_TYPE_GEOMAGNETIC_ROTATION_VECTOR = 20,
		ASENSOR_TYPE_HEART_RATE = 21,
		ASENSOR_TYPE_POSE_6DOF = 28,
		ASENSOR_TYPE_STATIONARY_DETECT = 29,
		ASENSOR_TYPE_MOTION_DETECT = 30,
		ASENSOR_TYPE_HEART_BEAT = 31,
		ASENSOR_TYPE_ADDITIONAL_INFO = 33,
		ASENSOR_TYPE_LOW_LATENCY_OFFBODY_DETECT = 34,
		ASENSOR_TYPE_ACCELEROMETER_UNCALIBRATED = 35,
		ASENSOR_TYPE_HINGE_ANGLE = 36,
	}
	enum 
	{
		ASENSOR_STATUS_NO_CONTACT = -1,
		ASENSOR_STATUS_UNRELIABLE = 0,
		ASENSOR_STATUS_ACCURACY_LOW = 1,
		ASENSOR_STATUS_ACCURACY_MEDIUM = 2,
		ASENSOR_STATUS_ACCURACY_HIGH = 3,
	}
	enum 
	{
		AREPORTING_MODE_INVALID = -1,
		AREPORTING_MODE_CONTINUOUS = 0,
		AREPORTING_MODE_ON_CHANGE = 1,
		AREPORTING_MODE_ONE_SHOT = 2,
		AREPORTING_MODE_SPECIAL_TRIGGER = 3,
	}
	enum 
	{
		ASENSOR_DIRECT_RATE_STOP = 0,
		ASENSOR_DIRECT_RATE_NORMAL = 1,
		ASENSOR_DIRECT_RATE_FAST = 2,
		ASENSOR_DIRECT_RATE_VERY_FAST = 3,
	}
	enum 
	{
		ASENSOR_DIRECT_CHANNEL_TYPE_SHARED_MEMORY = 1,
		ASENSOR_DIRECT_CHANNEL_TYPE_HARDWARE_BUFFER = 2,
	}
	enum 
	{
		ASENSOR_ADDITIONAL_INFO_BEGIN = 0,
		ASENSOR_ADDITIONAL_INFO_END = 1,
		ASENSOR_ADDITIONAL_INFO_UNTRACKED_DELAY = 65536,
		ASENSOR_ADDITIONAL_INFO_INTERNAL_TEMPERATURE,
		ASENSOR_ADDITIONAL_INFO_VEC3_CALIBRATION,
		ASENSOR_ADDITIONAL_INFO_SENSOR_PLACEMENT,
		ASENSOR_ADDITIONAL_INFO_SAMPLING,
	}
	enum ASENSOR_STANDARD_GRAVITY = 9.80665F;
	enum ASENSOR_MAGNETIC_FIELD_EARTH_MAX = 60.0F;
	enum ASENSOR_MAGNETIC_FIELD_EARTH_MIN = 30.0F;
	struct ASensorVector
	{
		union
		{
			float[3] v;
			struct
			{
				float x;
				float y;
				float z;
			}
			struct
			{
				float azimuth;
				float pitch;
				float roll;
			}
		}
		int8_t status;
		uint8_t[3] reserved;
	}
	struct AMetaDataEvent
	{
		int32_t what;
		int32_t sensor;
	}
	struct AUncalibratedEvent
	{
		union
		{
			float[3] uncalib;
			struct
			{
				float x_uncalib;
				float y_uncalib;
				float z_uncalib;
			}
		}
		union
		{
			float[3] bias;
			struct
			{
				float x_bias;
				float y_bias;
				float z_bias;
			}
		}
	}
	struct AHeartRateEvent
	{
		float bpm;
		int8_t status;
	}
	struct ADynamicSensorEvent
	{
		int32_t connected;
		int32_t handle;
	}
	struct AAdditionalInfoEvent
	{
		int32_t type;
		int32_t serial;
		union
		{
			int32_t[14] data_int32;
			float[14] data_float;
		}
	}
	struct ASensorEvent
	{
		int32_t version_;
		int32_t sensor;
		int32_t type;
		int32_t reserved0;
		int64_t timestamp;
		union
		{
			union
			{
				float[16] data;
				ASensorVector vector;
				ASensorVector acceleration;
				ASensorVector magnetic;
				float temperature;
				float distance;
				float light;
				float pressure;
				float relative_humidity;
				AUncalibratedEvent uncalibrated_gyro;
				AUncalibratedEvent uncalibrated_magnetic;
				AMetaDataEvent meta_data;
				AHeartRateEvent heart_rate;
				ADynamicSensorEvent dynamic_sensor_meta;
				AAdditionalInfoEvent additional_info;
			}
			union u64
			{
				uint64_t[8] data;
				uint64_t step_counter;
			}
		}
		uint32_t flags;
		int32_t[3] reserved1;
	}
	struct ASensorManager;
	struct ASensorEventQueue;
	struct ASensor;
	alias ASensorRef = const ASensor*;
	alias ASensorList = const ASensorRef*;
	static if (__ANDROID_API__ >= 26)
	{
		deprecated ASensorManager* ASensorManager_getInstance();
	}
	else
	{
		ASensorManager* ASensorManager_getInstance();
	}
	static if (__ANDROID_API__ >= 26)
	{
		ASensorManager* ASensorManager_getInstanceForPackage(const char* packageName);
	}
	int ASensorManager_getSensorList(ASensorManager* manager, ASensorList* list);
	const(ASensor)* ASensorManager_getDefaultSensor(ASensorManager* manager, int type);
	static if (__ANDROID_API__ >= 21)
	{
		const(ASensor)* ASensorManager_getDefaultSensorEx(ASensorManager* manager, int type, bool wakeUp);
	}
	ASensorEventQueue* ASensorManager_createEventQueue(ASensorManager* manager, ALooper* looper, int ident, ALooper_callbackFunc callback, void* data);
	int ASensorManager_destroyEventQueue(ASensorManager* manager, ASensorEventQueue* queue);
	static if (__ANDROID_API__ >= 26)
	{
		int ASensorManager_createSharedMemoryDirectChannel(ASensorManager* manager, int fd, size_t size);
		int ASensorManager_createHardwareBufferDirectChannel(ASensorManager* manager, const AHardwareBuffer* buffer, size_t size);
		void ASensorManager_destroyDirectChannel(ASensorManager* manager, int channelId);
		int ASensorManager_configureDirectReport(ASensorManager* manager, const ASensor* sensor, int channelId, int rate);
	}
	int ASensorEventQueue_registerSensor(ASensorEventQueue* queue, const ASensor* sensor, int32_t samplingPeriodUs, int64_t maxBatchReportLatencyUs);
	int ASensorEventQueue_enableSensor(ASensorEventQueue* queue, const ASensor* sensor);
	int ASensorEventQueue_disableSensor(ASensorEventQueue* queue, const ASensor* sensor);
	int ASensorEventQueue_setEventRate(ASensorEventQueue* queue, const ASensor* sensor, int32_t usec);
	int ASensorEventQueue_hasEvents(ASensorEventQueue* queue);
	size_t ASensorEventQueue_getEvents(ASensorEventQueue* queue, ASensorEvent* events, size_t count);
	static if (__ANDROID_API__ >= 29)
	{
		int ASensorEventQueue_requestAdditionalInfoEvents(ASensorEventQueue* queue, bool enable);
	}
	const(char)* ASensor_getName(const ASensor* sensor);
	const(char)* ASensor_getVendor(const ASensor* sensor);
	int ASensor_getType(const ASensor* sensor);
	float ASensor_getResolution(const ASensor* sensor);
	int ASensor_getMinDelay(const ASensor* sensor);
	static if (__ANDROID_API__ >= 21)
	{
		int ASensor_getFifoMaxEventCount(const ASensor* sensor);
		int ASensor_getFifoReservedEventCount(const ASensor* sensor);
		const(char)* ASensor_getStringType(const ASensor* sensor);
		int ASensor_getReportingMode(const ASensor* sensor);
		bool ASensor_isWakeUpSensor(const ASensor* sensor);
	}
	static if (__ANDROID_API__ >= 26)
	{
		bool ASensor_isDirectChannelTypeSupported(const ASensor* sensor, int channelType);
		int ASensor_getHighestDirectReportRateLevel(const ASensor* sensor);
	}
	static if (__ANDROID_API__ >= 29)
	{
		int ASensor_getHandle(const ASensor* sensor);
	}
}
