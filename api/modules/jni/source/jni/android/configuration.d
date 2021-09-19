
module jni.android.configuration;
import jni.android.android_api;
version (Android)
{
	import core.stdc.stdint;
	import jni.android.asset_manager;
	extern (C) 
	{
		struct AConfiguration;
		enum 
		{
			ACONFIGURATION_ORIENTATION_ANY = 0,
			ACONFIGURATION_ORIENTATION_PORT = 1,
			ACONFIGURATION_ORIENTATION_LAND = 2,
			ACONFIGURATION_ORIENTATION_SQUARE = 3,
			ACONFIGURATION_TOUCHSCREEN_ANY = 0,
			ACONFIGURATION_TOUCHSCREEN_NOTOUCH = 1,
			ACONFIGURATION_TOUCHSCREEN_STYLUS = 2,
			ACONFIGURATION_TOUCHSCREEN_FINGER = 3,
			ACONFIGURATION_DENSITY_DEFAULT = 0,
			ACONFIGURATION_DENSITY_LOW = 120,
			ACONFIGURATION_DENSITY_MEDIUM = 160,
			ACONFIGURATION_DENSITY_TV = 213,
			ACONFIGURATION_DENSITY_HIGH = 240,
			ACONFIGURATION_DENSITY_XHIGH = 320,
			ACONFIGURATION_DENSITY_XXHIGH = 480,
			ACONFIGURATION_DENSITY_XXXHIGH = 640,
			ACONFIGURATION_DENSITY_ANY = 65534,
			ACONFIGURATION_DENSITY_NONE = 65535,
			ACONFIGURATION_KEYBOARD_ANY = 0,
			ACONFIGURATION_KEYBOARD_NOKEYS = 1,
			ACONFIGURATION_KEYBOARD_QWERTY = 2,
			ACONFIGURATION_KEYBOARD_12KEY = 3,
			ACONFIGURATION_NAVIGATION_ANY = 0,
			ACONFIGURATION_NAVIGATION_NONAV = 1,
			ACONFIGURATION_NAVIGATION_DPAD = 2,
			ACONFIGURATION_NAVIGATION_TRACKBALL = 3,
			ACONFIGURATION_NAVIGATION_WHEEL = 4,
			ACONFIGURATION_KEYSHIDDEN_ANY = 0,
			ACONFIGURATION_KEYSHIDDEN_NO = 1,
			ACONFIGURATION_KEYSHIDDEN_YES = 2,
			ACONFIGURATION_KEYSHIDDEN_SOFT = 3,
			ACONFIGURATION_NAVHIDDEN_ANY = 0,
			ACONFIGURATION_NAVHIDDEN_NO = 1,
			ACONFIGURATION_NAVHIDDEN_YES = 2,
			ACONFIGURATION_SCREENSIZE_ANY = 0,
			ACONFIGURATION_SCREENSIZE_SMALL = 1,
			ACONFIGURATION_SCREENSIZE_NORMAL = 2,
			ACONFIGURATION_SCREENSIZE_LARGE = 3,
			ACONFIGURATION_SCREENSIZE_XLARGE = 4,
			ACONFIGURATION_SCREENLONG_ANY = 0,
			ACONFIGURATION_SCREENLONG_NO = 1,
			ACONFIGURATION_SCREENLONG_YES = 2,
			ACONFIGURATION_SCREENROUND_ANY = 0,
			ACONFIGURATION_SCREENROUND_NO = 1,
			ACONFIGURATION_SCREENROUND_YES = 2,
			ACONFIGURATION_WIDE_COLOR_GAMUT_ANY = 0,
			ACONFIGURATION_WIDE_COLOR_GAMUT_NO = 1,
			ACONFIGURATION_WIDE_COLOR_GAMUT_YES = 2,
			ACONFIGURATION_HDR_ANY = 0,
			ACONFIGURATION_HDR_NO = 1,
			ACONFIGURATION_HDR_YES = 2,
			ACONFIGURATION_UI_MODE_TYPE_ANY = 0,
			ACONFIGURATION_UI_MODE_TYPE_NORMAL = 1,
			ACONFIGURATION_UI_MODE_TYPE_DESK = 2,
			ACONFIGURATION_UI_MODE_TYPE_CAR = 3,
			ACONFIGURATION_UI_MODE_TYPE_TELEVISION = 4,
			ACONFIGURATION_UI_MODE_TYPE_APPLIANCE = 5,
			ACONFIGURATION_UI_MODE_TYPE_WATCH = 6,
			ACONFIGURATION_UI_MODE_TYPE_VR_HEADSET = 7,
			ACONFIGURATION_UI_MODE_NIGHT_ANY = 0,
			ACONFIGURATION_UI_MODE_NIGHT_NO = 1,
			ACONFIGURATION_UI_MODE_NIGHT_YES = 2,
			ACONFIGURATION_SCREEN_WIDTH_DP_ANY = 0,
			ACONFIGURATION_SCREEN_HEIGHT_DP_ANY = 0,
			ACONFIGURATION_SMALLEST_SCREEN_WIDTH_DP_ANY = 0,
			ACONFIGURATION_LAYOUTDIR_ANY = 0,
			ACONFIGURATION_LAYOUTDIR_LTR = 1,
			ACONFIGURATION_LAYOUTDIR_RTL = 2,
			ACONFIGURATION_MCC = 1,
			ACONFIGURATION_MNC = 2,
			ACONFIGURATION_LOCALE = 4,
			ACONFIGURATION_TOUCHSCREEN = 8,
			ACONFIGURATION_KEYBOARD = 16,
			ACONFIGURATION_KEYBOARD_HIDDEN = 32,
			ACONFIGURATION_NAVIGATION = 64,
			ACONFIGURATION_ORIENTATION = 128,
			ACONFIGURATION_DENSITY = 256,
			ACONFIGURATION_SCREEN_SIZE = 512,
			ACONFIGURATION_VERSION = 1024,
			ACONFIGURATION_SCREEN_LAYOUT = 2048,
			ACONFIGURATION_UI_MODE = 4096,
			ACONFIGURATION_SMALLEST_SCREEN_SIZE = 8192,
			ACONFIGURATION_LAYOUTDIR = 16384,
			ACONFIGURATION_SCREEN_ROUND = 32768,
			ACONFIGURATION_COLOR_MODE = 65536,
			ACONFIGURATION_MNC_ZERO = 65535,
		}
		AConfiguration* AConfiguration_new();
		void AConfiguration_delete(AConfiguration* config);
		void AConfiguration_fromAssetManager(AConfiguration* out_, AAssetManager* am);
		void AConfiguration_copy(AConfiguration* dest, AConfiguration* src);
		int32_t AConfiguration_getMcc(AConfiguration* config);
		void AConfiguration_setMcc(AConfiguration* config, int32_t mcc);
		int32_t AConfiguration_getMnc(AConfiguration* config);
		void AConfiguration_setMnc(AConfiguration* config, int32_t mnc);
		void AConfiguration_getLanguage(AConfiguration* config, char* outLanguage);
		void AConfiguration_setLanguage(AConfiguration* config, const char* language);
		void AConfiguration_getCountry(AConfiguration* config, char* outCountry);
		void AConfiguration_setCountry(AConfiguration* config, const char* country);
		int32_t AConfiguration_getOrientation(AConfiguration* config);
		void AConfiguration_setOrientation(AConfiguration* config, int32_t orientation);
		int32_t AConfiguration_getTouchscreen(AConfiguration* config);
		void AConfiguration_setTouchscreen(AConfiguration* config, int32_t touchscreen);
		int32_t AConfiguration_getDensity(AConfiguration* config);
		void AConfiguration_setDensity(AConfiguration* config, int32_t density);
		int32_t AConfiguration_getKeyboard(AConfiguration* config);
		void AConfiguration_setKeyboard(AConfiguration* config, int32_t keyboard);
		int32_t AConfiguration_getNavigation(AConfiguration* config);
		void AConfiguration_setNavigation(AConfiguration* config, int32_t navigation);
		int32_t AConfiguration_getKeysHidden(AConfiguration* config);
		void AConfiguration_setKeysHidden(AConfiguration* config, int32_t keysHidden);
		int32_t AConfiguration_getNavHidden(AConfiguration* config);
		void AConfiguration_setNavHidden(AConfiguration* config, int32_t navHidden);
		int32_t AConfiguration_getSdkVersion(AConfiguration* config);
		void AConfiguration_setSdkVersion(AConfiguration* config, int32_t sdkVersion);
		int32_t AConfiguration_getScreenSize(AConfiguration* config);
		void AConfiguration_setScreenSize(AConfiguration* config, int32_t screenSize);
		int32_t AConfiguration_getScreenLong(AConfiguration* config);
		void AConfiguration_setScreenLong(AConfiguration* config, int32_t screenLong);
		static if (__ANDROID_API__ >= 30)
		{
			int32_t AConfiguration_getScreenRound(AConfiguration* config);
		}
		void AConfiguration_setScreenRound(AConfiguration* config, int32_t screenRound);
		int32_t AConfiguration_getUiModeType(AConfiguration* config);
		void AConfiguration_setUiModeType(AConfiguration* config, int32_t uiModeType);
		int32_t AConfiguration_getUiModeNight(AConfiguration* config);
		void AConfiguration_setUiModeNight(AConfiguration* config, int32_t uiModeNight);
		int32_t AConfiguration_getScreenWidthDp(AConfiguration* config);
		void AConfiguration_setScreenWidthDp(AConfiguration* config, int32_t value);
		int32_t AConfiguration_getScreenHeightDp(AConfiguration* config);
		void AConfiguration_setScreenHeightDp(AConfiguration* config, int32_t value);
		int32_t AConfiguration_getSmallestScreenWidthDp(AConfiguration* config);
		void AConfiguration_setSmallestScreenWidthDp(AConfiguration* config, int32_t value);
		static if (__ANDROID_API__ >= 17)
		{
			int32_t AConfiguration_getLayoutDirection(AConfiguration* config);
			void AConfiguration_setLayoutDirection(AConfiguration* config, int32_t value);
		}
		int32_t AConfiguration_diff(AConfiguration* config1, AConfiguration* config2);
		int32_t AConfiguration_match(AConfiguration* base, AConfiguration* requested);
		int32_t AConfiguration_isBetterThan(AConfiguration* base, AConfiguration* test, AConfiguration* requested);
	}
}
