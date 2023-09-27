module game_selector;
import commons;

bool isGameFolderValid(string gameFolder)
{
    return std.file.exists(buildNormalizedPath(gameFolder, "assets")) &&
            std.file.exists(buildNormalizedPath(gameFolder, "source")) && 
            std.file.exists(buildNormalizedPath(gameFolder, "dub.json"));
}


private __gshared bool hasTypedGamepath = false;
private ChoiceResult typeGamePath(Choice* self, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions _)
{
    string gamePath;
    while(!gamePath.length)
    {
        gamePath = getValidPath(t, "Type your game path: ");
        if(!isGameFolderValid(gamePath))
        {
            t.writelnError("The selected path '" ~ gamePath ~ "' is not valid. Please select a valid game folder.");
            gamePath = null;
        }
    }

    t.writelnSuccess("Selected game path '", gamePath, "'");
    configs["gamePath"] = gamePath;
    hasTypedGamepath = true;

    return ChoiceResult.Continue;
}

ChoiceResult selectGameFolder(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
    Choice* selectedChoice = selectInFolderExtra(
        "Select your game",
        buildNormalizedPath(configs["hipremeEnginePath"].str, "projects"), t, input,
        [
            Choice("Type the game path manually", &typeGamePath),
            getBackChoice()
        ]
    );
    if(selectedChoice.onSelected != null)
        selectedChoice.onSelected(selectedChoice, t, input, cOpts);
    if(selectedChoice.onSelected == null)
        configs["gamePath"] = selectedChoice.name;
    if(hasTypedGamepath || selectedChoice.onSelected == null)
    {
        configs["selectedChoice"] = 0;
        engineConfig["defaultProject"] = configs["gamePath"].str;
        updateEngineFile();
        updateConfigFile();
    }

    return ChoiceResult.Back;
}