module targets.uwp;
import commons;

ChoiceResult prepareUWP(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
    ProjectDetails project;
	with(WorkingDir(configs["gamePath"].str))
    {
		if(waitRedub(t, DubArguments().command("build").configuration("uwp").compiler("ldc2").opts(cOpts), project) != 0)
        {
            t.writelnError("Could not build for UWP. ");
            return ChoiceResult.Error;
        }
    }
    string file = project.getOutputFile();
    if(std.file.exists(file))
    {
        t.writelnHighlighted("Renaming ", file, " to hipreme_engine.dll for compatibility. ");
        std.file.rename(file, getHipPath("build", "uwp", "HipremeEngine", "HipremeEngine", "hipreme_engine.dll"));
    }

	return ChoiceResult.Continue;
}
