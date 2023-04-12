module ui;

enum SaveNotSupported = "SaveNotSupported";

version(Windows)
{
    import arsd.minigui;
    void showErrorMessage(string title, string message)
    {
        messageBox(title, message, MessageBoxStyle.OK, MessageBoxIcon.Error);
    }

    string showSaveFileDialog(string initialName, string[] filters)
    {
        string fName;
        getSaveFileName((string folderName){fName = folderName;}, initialName, filters);
        return fName;
    }
}
else
{
    version(linux)
    {
        import std.process;
        import std.stdio;
        private string getCommandToShowError(string title, string message)
        {
            if(executeShell("which zenity").output)
                return "zenity --error --title=\""~title~"\" --text=\""~message~"\"";
            return "";
        }
        private string getCommandToSaveFileDialog(string title, string filter)
        {
            if(executeShell("which zenity").output)
                return "zenity --file-selection --confirm-overwrite --directory --save --title=\""~
                    title~"\" --file-filter=\""~filter~" | *\"";
            return "";
        }

        void showErrorMessage(string title, string message)
        {
            string cmd = getCommandToShowError(title, message);
            if(cmd.length)
                executeShell(cmd);
            else
                defaultShowErrorMessage(title, message);
        }


        string showSaveFileDialog(string initialName, string[] filters)
        {
            string cmd = getCommandToSaveFileDialog(initialName, filters[0]);
            if(cmd.length)
                return executeShell(cmd).output;
            return defaultShowSaveFileDialog(initialName, filters);
        }
    }
    else
    {
        void showErrorMessage(string title, string message){defaultShowErrorMessage(title,message);}
        string showSaveFileDialog(string initialName, string[] filters){return defaultShowSaveFileDialog(initialName, filters);}

    }
}

private void defaultShowErrorMessage(string title, string message)
{
    import std.stdio;
    writeln("Error:", title, "\n\t", message);   
}
private string defaultShowSaveFileDialog(string initialName, string[] filters)
{
    import std.stdio;
    writeln("Write a folder name to save HipProject: ", initialName);
    return readln();
}