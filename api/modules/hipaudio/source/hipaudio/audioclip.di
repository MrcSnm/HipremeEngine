// D import file generated from 'source\hipaudio\audioclip.d'
module hipaudio.audioclip;
import std.path : baseName;
import data.hipfs;
import error.handler;
import data.audio.audio;
import hipaudio.audio;
import hipaudio.backend.audiosource;
struct HipAudioBufferWrapper
{
	void* buffer;
	uint bufferSize;
	bool isAvailable;
	const bool opEquals(R)(const R other)
	{
		import core.stdc.string : memcmp;
		static if (is(R == void*))
		{
			return memcmp(other, buffer, bufferSize) == 0;
		}
		else
		{
			static if (is(R == typeof(this)))
			{
				return memcmp(other.buffer, this.buffer, bufferSize) == 0;
			}
			else
			{
				return &this == other;
			}
		}
	}
}
public abstract class HipAudioClip
{
	IHipAudioDecoder decoder;
	void[] dataToDecode;
	void* outBuffer;
	uint chunkSize;
	private HipAudioBufferWrapper[] buffersToRecycle;
	private HipAudioBufferWrapper[] buffersCreated;
	ulong totalDecoded = 0;
	HipAudioType type;
	HipAudioEncoding encoding;
	bool isStreamed = false;
	string fullPath;
	string fileName;
	this(IHipAudioDecoder decoder)
	{
		this.decoder = decoder;
	}
	this(IHipAudioDecoder decoder, uint chunkSize)
	in (chunkSize > 0)
	{
		import core.stdc.stdlib : malloc;
		this(decoder);
		this.chunkSize = chunkSize;
		outBuffer = malloc(chunkSize);
		ErrorHandler.assertExit(outBuffer != null, "Out of memory");
	}
	public bool load(in void[] data, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false);
	public final uint updateStream();
	protected abstract void onUpdateStream(void* data, uint decodedSize);
	protected abstract HipAudioBufferWrapper createBuffer(void* data, uint size);
	protected abstract void destroyBuffer(void* buffer);
	package final HipAudioBufferWrapper* findBuffer(void* buf);
	public abstract void setBufferData(void* buffer, uint size, void* data);
	public final void* pollFreeBuffer();
	public final void* getBuffer(void* data, uint size);
	package final void setBufferAvailable(void* buffer);
	public uint loadStreamed(in void[] data, HipAudioEncoding encoding);
	public void* getClipData();
	public ulong getClipSize();
	public float getDuration();
	public final float getDecodedDuration();
	public final bool load(string audioPath, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false);
	public final uint loadStreamed(string audioPath, HipAudioEncoding encoding);
	public void unload();
}
