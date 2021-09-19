
module hiprenderer.config;
struct HipRendererConfig
{
	ubyte multisamplingLevel = 0;
	ubyte bufferingCount = 2;
	bool isMatrixRowMajor = true;
	bool vsync = true;
}
