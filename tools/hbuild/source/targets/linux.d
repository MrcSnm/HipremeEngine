module targets.linux;
import commons;

ChoiceResult prepareLinux(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
	if(!std.file.exists("/usr/include/GL/gl.h"))
	{
		t.writelnError("/usr/include/GL/gl.h wasn't found in your system. This is required for the OpenGL implementation.");
		t.writelnHighlighted("\t The following command will be executed to install it: sudo apt-get install libgl1-mesa-dev");
		t.flush;
		wait(spawnShell("sudo apt-get install libgl1-mesa-dev"));
	}

	with(WorkingDir(configs["gamePath"].str))
	{
		ProjectDetails proj;
		if(waitRedub(t, DubArguments().command("build").configuration("script").opts(cOpts), proj) != 0)
			return ChoiceResult.Error;
	}

	if(!c.scriptOnly) with(WorkingDir(getHipPath))
	{
		ProjectDetails proj;
		if(waitRedub(t, DubArguments()
			.configuration("script")
			.runArgs(configs["gamePath"].str)
			.confirmKey(true)
		, proj) != 0)
		{
			t.writelnError("Error building hipreme engine.");
			return ChoiceResult.Error;
		}
	}

	wait(spawnShell((getHipPath("bin", "desktop", "hipreme_engine") ~ " "~ configs["gamePath"].str)));

	return ChoiceResult.Continue;
}
