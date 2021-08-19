module bind.dependencies;
import error.handler;
import bindbc.cimgui;

bool loadEngineDependencies()
{
    ErrorHandler.startListeningForErrors("Loading Shared Libraries");

    import implementations.imgui.imgui_impl_sdl;
    import bindbc.loader : SharedLib;
    void function(SharedLib) implementation = null;
    static if(!CIMGUI_USER_DEFINED_IMPLEMENTATION)
        implementation = &bindSDLImgui;

    if(!loadcimgui(implementation))
    {
        ErrorHandler.showErrorMessage("Could not load cimgui", "Cimgui.dll not found");
    }

    return ErrorHandler.stopListeningForErrors();
}