// D import file generated from 'source\data\image.d'
module data.image;
import data.asset;
import bindbc.sdl.bind.sdlsurface;
import bindbc.sdl.bind.sdlrwops;
import bindbc.sdl.bind.sdlpixels;
import bindbc.sdl.image;
public import hipengine.api.data.image;
import arsd.image;
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
	SDL_Surface* img;
	bool startDecoding(void[] data);
	uint getWidth();
	uint getHeight();
	void* getPixels();
	ubyte getBytesPerPixel();
	ubyte[] getPalette();
	void dispose();
}
final class HipARSDImageDecoder : IHipAnyImageDecoder
{
	MemoryImage img;
	TrueColorImage trueImg;
	bool startDecoding(void[] data);
	uint getWidth();
	uint getHeight();
	void* getPixels();
	ubyte getBytesPerPixel();
	ubyte[] getPalette();
	void dispose();
}
alias HipPlatformImageDecoder = HipARSDImageDecoder;
public class Image : HipAsset, IImage
{
	protected shared bool _ready;
	IHipImageDecoder decoder;
	string imagePath;
	int width;
	int height;
	ubyte bytesPerPixel;
	ushort bitsPerPixel;
	void* pixels;
	protected void* convertedPixels;
	this(in string path)
	{
		super("Image_" ~ path);
		initialize(path);
	}
	private void initialize(in string path);
	string getName();
	uint getWidth();
	uint getHeight();
	ushort getBytesPerPixel();
	void* getPixels();
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
