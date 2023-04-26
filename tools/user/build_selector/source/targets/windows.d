module targets.windows;
import commons;

void prepareWindows(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
    std.file.chdir(configs["gamePath"].str);
	waitDub(t, "build -c script "~cOpts.getDubOptions, "");
	std.file.chdir(configs["hipremeEnginePath"].str);
	waitDub(t, "-c script "~cOpts.getDubOptions ~ " -- "~configs["gamePath"].str, "", true);
}