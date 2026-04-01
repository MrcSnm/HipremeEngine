module tools.compiler_getter;
import commons;
import feature;
import features.dmd;
import features.ldc;



private struct CompilerFeature
{
	Feature feature;
	string compiler;
	string compilerTargetVersion;
}

private CompilerFeature LDCCompiler() { return CompilerFeature(LDCFeature, "ldc2", "ldcVersion");}
private CompilerFeature DMDCompiler() { return CompilerFeature(DMDFeature, "dmd", "dmdVersion");}

private CompilerFeature[2] getCompilerFeatureOrder()
{
	version(AArch64)version(OSX)
		return [LDCCompiler, DMDCompiler];
	return [DMDCompiler, LDCCompiler];
}


bool getCompiler(ref Terminal t, ref RealTimeConsoleInput input, string compilerType)
{
    if(!compilerType.length)
	{
		if("dmdPath" !in configs && "ldcPath" !in configs)
		{
			auto features = getCompilerFeatureOrder();
			foreach(CompilerFeature f; features)
			{
				if(f.feature.getFeature(t, input, TargetVersion.fromGameBuild(f.compilerTargetVersion)))
					return true;
			}
            t.writelnError("HipremeEngine needs either LDC or DMD");
            return false;
		}
	}
	else
	{
		final switch(compilerType)
		{
			case "dmd":
				if("dmdPath" !in configs && !DMDFeature.getFeature(t, input, TargetVersion.fromGameBuild("dmdVersion")))
				{
					t.writelnError("HipremeEngine needs DMD");
					return false;
				}
				break;
			case "ldc2", "ldc":
				if("ldcPath" !in configs && !LDCFeature.getFeature(t, input, TargetVersion.fromGameBuild("ldcPath")))
				{
					t.writelnError("HipremeEngine needs LDC");
					return false;
				}
				break;
		}
	}
    return true;
}