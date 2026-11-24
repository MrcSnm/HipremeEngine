module hip.data.hipsave;
public import hip.util.allocator;


struct HipSaveHeader
{
    static enum Magic = "HIPSAVE\n";
    const char[HipSaveHeader.Magic.length] magic = HipSaveHeader.Magic;
    uint formatVersion = 1;
    uint hash;
}

struct HipSaveFile
{
    HipSaveHeader header;
    const(ubyte)[] data;
}

private bool hasValidMagic(const(char)[HipSaveHeader.Magic.length] magic)
{
    foreach(i, expected; HipSaveHeader.Magic)
    {
        if(magic[i] != expected)
            return false;
    }
    return true;
}

ubyte[] makeSaveFileBytes(T)(T data, int saveVersion, Allocator* allocator = gcAllocator)
{
    import hip.util.digest : crc32;
    import hip.util.binary : getPackedTypeSize, copyIntoMemory;

    enum uint headerSize = cast(uint)getPackedTypeSize(HipSaveHeader.init);
    uint payloadSize = getPackedTypeSize(data);
    ubyte[] ret = allocator.get!(ubyte)(headerSize + uint.sizeof + payloadSize);

    ubyte[] payload = ret[headerSize + uint.sizeof .. $];
    copyIntoMemory(data, payload);

    HipSaveHeader header;
    header.formatVersion = saveVersion;
    header.hash = crc32(payload);

    copyIntoMemory(cast(uint)payloadSize, ret[headerSize .. headerSize + uint.sizeof]);
    copyIntoMemory(header, ret[0 .. headerSize]);
    return ret;
}

HipSaveFile loadSaveFile(const ubyte[] bytes)
{
    import hip.util.digest : crc32;
    import hip.util.binary : getPackedTypeSize, getStructFromPackedBytes, fromPackedBytes;

    enum uint headerSize = cast(uint)getPackedTypeSize(HipSaveHeader.init);
    enum uint payloadSizeOffset = headerSize + uint.sizeof;
    if(bytes.length < payloadSizeOffset)
        throw new Exception("Invalid save file: too small.");

    HipSaveHeader header = getStructFromPackedBytes!HipSaveHeader(bytes[0 .. headerSize]);
    if(!hasValidMagic(header.magic))
        throw new Exception("Invalid save file: magic mismatch.");

    uint payloadSize = fromPackedBytes!uint(bytes[headerSize .. payloadSizeOffset]);
    if(payloadSize > bytes.length - payloadSizeOffset)
        throw new Exception("Invalid save file: truncated payload.");

    const(ubyte)[] payload = bytes[payloadSizeOffset .. payloadSizeOffset + payloadSize];
    if(crc32(payload) != header.hash)
        throw new Exception("Invalid save file: hash mismatch.");

    return HipSaveFile(header, payload);
}

T loadSaveData(T)(const ubyte[] bytes, Allocator* allocator = gcAllocator)
{
    import hip.util.binary : fromPackedBytes;

    return fromPackedBytes!T(loadSaveFile(bytes).data, allocator);
}

unittest
{
    struct TestSave
    {
        int a;
        string b;
        bool flag;
    }

    TestSave original = TestSave(42, "hello", true);
    ubyte[] bytes = makeSaveFileBytes(original, 7, gcAllocator);
    assert(bytes.length == 34);

    HipSaveFile file = loadSaveFile(bytes);
    assert(file.header.formatVersion == 7);
    assert(file.data.length == 14);
    assert(file.data.ptr is bytes.ptr + 20);

    TestSave loaded = loadSaveData!TestSave(bytes, gcAllocator);
    assert(loaded.a == 42);
    assert(loaded.b == "hello");
    assert(loaded.flag);

    bool threw = false;
    ubyte[] wrongMagic = bytes.dup;
    wrongMagic[0] ^= 0xFF;
    try loadSaveData!TestSave(wrongMagic, gcAllocator);
    catch(Exception) threw = true;
    assert(threw);

    threw = false;
    ubyte[] corrupted = bytes.dup;
    corrupted[$ - 1] ^= 0xFF;
    try loadSaveData!TestSave(corrupted, gcAllocator);
    catch(Exception) threw = true;
    assert(threw);

    threw = false;
    try loadSaveData!TestSave(bytes[0 .. 10], gcAllocator);
    catch(Exception) threw = true;
    assert(threw);
}
