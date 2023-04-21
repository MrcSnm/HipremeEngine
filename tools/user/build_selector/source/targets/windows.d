module targets.windows;
import commons;

void prepareWindows(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
    std.file.chdir(configs["hipremeEnginePath"].str);
	auto pid = runDub("-c script "~cOpts.getDubOptions ~ " -- "~configs["gamePath"].str);
	wait(pid);
}