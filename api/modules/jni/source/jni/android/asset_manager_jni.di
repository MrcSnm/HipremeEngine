// D import file generated from 'source\jni\android\asset_manager_jni.d'
module jni.android.asset_manager_jni;
import jni.android.asset_manager;
import jni.jni;
version (Android)
{
	extern (C) AAssetManager* AAssetManager_fromJava(JNIEnv* env, jobject assetManager);
}
