
module jni.android.rect;
import core.stdc.stdint;
extern (C) struct ARect
{
	alias value_type = int32_t;
	int32_t left;
	int32_t top;
	int32_t right;
	int32_t bottom;
}
