module targets.nintendo_switch;
import commons;
import feature;

ChoiceResult prepareNintendoSwitch(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
    import features.devkitpro;

    if(!DevKitProFeature.getFeature(t, input))
        return ChoiceResult.Error;

	outputTemplate(t, configs["gamePath"].str);
    
    with(WorkingDir(configs["gamePath"].str))
    {
        ProjectDetails d;
        if(waitRedub(t, input, DubArguments().command("run").target("nswitch").configuration("nswitch").opts(cOpts)) != 0)
        {

        }
    }
    return ChoiceResult.None;
}