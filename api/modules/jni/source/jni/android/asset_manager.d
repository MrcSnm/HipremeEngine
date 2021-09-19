
module jni.android.asset_manager;
version (Android)
{
	extern (C) 
	{
		alias off_t = int;
		alias off64_t = long;
		struct AAssetManager;
		struct AAssetDir;
		struct AAsset;
		enum 
		{
			AASSET_MODE_UNKNOWN = 0,
			AASSET_MODE_RANDOM = 1,
			AASSET_MODE_STREAMING = 2,
			AASSET_MODE_BUFFER = 3,
		}
		AAssetDir* AAssetManager_openDir(AAssetManager* mgr, const char* dirName);
		AAsset* AAssetManager_open(AAssetManager* mgr, const char* filename, int mode);
		const(char)* AAssetDir_getNextFileName(AAssetDir* assetDir);
		void AAssetDir_rewind(AAssetDir* assetDir);
		void AAssetDir_close(AAssetDir* assetDir);
		int AAsset_read(AAsset* asset, void* buf, size_t count);
		off64_t AAsset_seek64(AAsset* asset, off64_t offset, int whence);
		off_t AAsset_seek(AAsset* asset, off_t offset, int whence);
		void AAsset_close(AAsset* asset);
		const(void*) AAsset_getBuffer(AAsset* asset);
		off64_t AAsset_getLength64(AAsset* asset);
		off_t AAsset_getLength(AAsset* asset);
		off64_t AAsset_getRemainingLength64(AAsset* asset);
		off_t AAsset_getRemainingLength(AAsset* asset);
		int AAsset_openFileDescriptor64(AAsset* asset, off64_t* outStart, off64_t* outLength);
		int AAsset_openFileDescriptor(AAsset* asset, off_t* outStart, off_t* outLength);
		int AAsset_isAllocated(AAsset* asset);
	}
}
