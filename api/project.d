module project;
import buildapi;

Project getProject()
{
    Project project = {
        name: "hipengine_api",
        sourceEntryPoint: "source/hipengine/package.d",
        dependencies : null,
        importDirectories : [
            "source"
        ],
        configurations :
        [
            "Script" : Configuration()
        ],
        isDebug: true,
        is64: true,
        outputType : OutputType.library,
        versions : 
        [
            "HipremeG2D",
            "HipremeAudio",
            "Script"
        ]
    };

    return project;
}