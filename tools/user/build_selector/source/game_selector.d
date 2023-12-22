module game_selector;
import commons;

bool isGameFolderValid(string gameFolder)
{
    return std.file.exists(buildNormalizedPath(gameFolder, "assets")) &&
            std.file.exists(buildNormalizedPath(gameFolder, "source")) && 
            std.file.exists(buildNormalizedPath(gameFolder, "dub.template.json"));
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
    changeGamePath(gamePath);
    hasTypedGamepath = true;

    return ChoiceResult.Continue;
}

private void changeGamePath(string newGamePath)
{
    configs["gamePath"] = newGamePath;
    clearCache();
}

ChoiceResult selectGameFolder(Choice* c, ref Terminal t, ref RealTimeConsoleInput input, in CompilationOptions cOpts)
{
    import std.array;
    import std.algorithm;
    Choice[] extraChoices = 
    [
        Choice("Type the game path manually", &typeGamePath),
        getBackChoice()
    ];
    if(isGameFolderValid(std.file.getcwd()))
        extraChoices = Choice(std.file.getcwd(), null) ~ extraChoices;
    
    Choice[] choices = getProjectsAvailable().map!((string name) => Choice(name, null)).array;
    Choice* selectedChoice = selectInFolderExtra(
        "Select your game",
        getHipPath("projects"), t, input, choices, extraChoices
    );
    if(selectedChoice.onSelected != null)
        selectedChoice.onSelected(selectedChoice, t, input, cOpts);
    // Chose a path
    if(selectedChoice.onSelected == null)
        changeGamePath(selectedChoice.name);
    if(hasTypedGamepath || selectedChoice.onSelected == null)
    {
        configs["selectedChoice"] = 0;
        engineConfig["defaultProject"] = configs["gamePath"].str;
        updateEngineFile();
        updateConfigFile();
    }

    return ChoiceResult.Back;
}