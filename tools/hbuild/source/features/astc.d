module features.astc;

public import feature;
import commons;
import std.path;
enum ASTCVersion = "5.4.0";

Feature ASTCFeature;
Task!(encodeTextureToAstcImpl) encodeTextureToAstc;

bool installAstc(
    ref Terminal t,
    ref RealTimeConsoleInput input, 
    TargetVersion ver,
    Download[] content,
	string[] extractionPaths
)
{
	import std.file;
	import core.cpuid;
	string astcVer = "sse2";
	if(avx2())
		astcVer = "avx2";
	else if(sse41())
		astcVer = "sse4.1";
	string astcPath= buildNormalizedPath(extractionPaths[0], "bin", "astcenc-"~astcVer.executableExtension);
	makeFileExecutable(astcPath);
    configs["astc"] = astcPath;
    updateConfigFile();
	return true;
}

private bool encodeTextureToAstcImpl(Feature*[] dependencies, ref Terminal t, ref RealTimeConsoleInput input, string imagePath, int flags)
{
	if(!std.file.exists(imagePath)) 
	{
		t.writelnError("Image at ", imagePath, " does not exists.");
		return false;
	}
	t.writeln("Converting texture from ", imagePath);
	t.flush;

	// with(WorkingDir(outputDirectory))
	// {
	// 	bool ret = dbgExecuteShell(configs["astc"].str ~ " x -y "~zPath, t);
	// 	return ret;
	// }
	return true;
}

void initialize()
{
	ASTCFeature  = Feature(
		name: "astc",
		description: "Tool for compressing textures to Android and iOS",
		ExistenceChecker(["astc"]),
		Installation([Download(
			DownloadURL(
                windows: "https://github.com/ARM-software/astc-encoder/releases/download/$VERSION/astcenc-$VERSION-windows-x64.zip",
                linux: "https://github.com/ARM-software/astc-encoder/releases/download/$VERSION/astcenc-$VERSION-linux-x64.zip",
				osx: "https://github.com/ARM-software/astc-encoder/releases/download/$VERSION/astcenc-$VERSION-macos-universal.zip"
            ),
			outputPath: "$TEMP$NAME"
		)], toDelegate(&installAstc), extractionPathList: ["$CONFIG_DIR/texturetools/astc"]),
		startUsingFeature: null,
		VersionRange.parse(ASTCVersion),
		dependencies: null,
	);
}

void start()
{
	encodeTextureToAstc = Task!(encodeTextureToAstcImpl)([&ASTCFeature]);
}