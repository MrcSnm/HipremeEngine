module hip.filesystem.systems.android;
import hip.api.filesystem.hipfs;
import hip.filesystem.hipfs;
import hip.error.handler;

version(Android)
{
    public import hip.jni.android.asset_manager;
    public import hip.jni.android.asset_manager_jni;
    __gshared AAssetManager* aaMgr;
    class HipAndroidFile : HipFile
    {
        import core.stdc.stdio;
        AAsset* asset;
        @disable this();
        this(string path, FileMode mode)
        {
            super(path, mode);
        }
        override ulong getSize()
        {
            ErrorHandler.assertLazyErrorMessage(asset != null, "HipAndroidFile error",
            "Can't get size from null asset '"~path~"'");
            return cast(ulong)AAsset_getLength64(asset);
        }
        override bool open(string path, FileMode mode)
        {
            import hip.util.string;
            asset = AAssetManager_open(aaMgr, path.toStringz, AASSET_MODE_BUFFER);
            return asset != null;
        }
        override int read(void* buffer, ulong count)
        {
            ErrorHandler.assertErrorMessage(asset != null, "HipAndroidFile error", "Can't read null asset");
            return AAsset_read(asset, buffer, count);
        }
        override long seek(long count, int whence = SEEK_CUR)
        {
            ErrorHandler.assertErrorMessage(asset != null, "HipAndroidFile error", "Can't seek null asset");
            super.seek(count, whence);
            version(offset64)
                return AAsset_seek64(asset, count, SEEK_CUR);
            else
                return AAsset_seek(asset, cast(int)count, SEEK_CUR);
        }
        bool write(string path, const(void)[] data)
        {
            return false;
        }
        void close()
        {
            if(asset != null)
                AAsset_close(asset);
        }
    }

    class HipAndroidFileSystemInteraction : IHipFileSystemInteraction
    {
        bool read(string path, void delegate(ubyte[] data) onSuccess, void delegate(string err) onError)
        {
            ubyte[] output;
            HipAndroidFile f = new HipAndroidFile(path, FileMode.READ);
            output.length = f.size;
            bool ret = f.read(output.ptr, f.size) >= 0;
            f.close();
            destroy(f);
            if(!ret)
                onError("Could not read file.");
            else
                onSuccess(output);
            return ret;
        }
        bool write(string path, const(void)[] data)
        {
            HipAndroidFile f = new HipAndroidFile(path, FileMode.WRITE);
            bool ret = f.write(path, data);
            f.close();
            destroy(f);
            return ret;
        }
        bool exists(string path)
        {
            HipAndroidFile f = new HipAndroidFile(path, FileMode.WRITE);
            bool x = f.asset != null;
            f.close();
            destroy(f);
            return x;
        }
        bool remove(string path)
        {
            return false;
        }
        
        bool isDir(string path)
        {
            return false; 
        }
        
    }
}