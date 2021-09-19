
module data.image;
import data.hipfs;
import util.concurrency;
import data.asset;
import util.system;
public interface IHipImageDecoder
{
	bool startDecoding(void[] data);
	uint getWidth();
	uint getHeight();
	void* getPixels();
	ubyte getBytesPerPixel();
	ubyte[] getPalette();
	final ushort getBitsPerPixel();
	void dispose();
}
public interface IHipPNGDecoder : IHipImageDecoder
{
}
public interface IHipJPEGDecoder : IHipImageDecoder
{
}
public interface IHipWebPDecoder : IHipImageDecoder
{
}
public interface IHipBMPDecoder : IHipImageDecoder
{
}
public interface IHipAnyImageDecoder : IHipPNGDecoder, IHipJPEGDecoder, IHipWebPDecoder, IHipBMPDecoder
{
}
IHipBMPDecoder bmp;
IHipJPEGDecoder jpeg;
IHipPNGDecoder png;
IHipWebPDecoder webP;
final class HipSDLImageDecoder : IHipAnyImageDecoder
{
	this()
	{
		bmp = this;
		jpeg = this;
		png = this;
		webP = this;
	}
	void* img;
	bool startDecoding(void[] data);
	uint getWidth();
	uint getHeight();
	void* getPixels();
	ubyte getBytesPerPixel();
	ubyte[] getPalette();
	void dispose();
}
alias HipPlatformImageDecoder = HipSDLImageDecoder;
public class Image : HipAsset
{
	protected shared bool _ready;
	IHipImageDecoder decoder;
	string imagePath;
	uint width;
	uint height;
	ubyte bytesPerPixel;
	ushort bitsPerPixel;
	void* pixels;
	protected void* convertedPixels;
	this(in string path)
	{
		super("Image_" ~ path);
		decoder = new HipPlatformImageDecoder;
		imagePath = sanitizePath(path);
	}
	bool loadFromMemory(ref ubyte[] data);
	void* convertPalettizedToRGBA();
	bool loadFromFile();
	override bool load();
	override bool isReady();
	bool load(void function() onLoad);
	override void onDispose();
	override void onFinishLoading();
	alias w = width;
	alias h = height;
}
