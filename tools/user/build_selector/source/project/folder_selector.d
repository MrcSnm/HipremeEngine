module project.folder_selector;
import std.file;

enum SaveNotSupported = "SaveNotSupported";

private bool hasSpace(string name)
{
	foreach(ch; name)
		if(ch == ' ')
			return true;
	return false;
}

private bool isFolderEmpty(string folderPath)
{
	foreach (DirEntry e; dirEntries(folderPath, SpanMode.shallow))
		return false;
	return true;
}

import commons;
bool selectFolderForProject(ref Terminal t, out string projectPath, out string error)
{
	projectPath = showSaveFileDialog(t, "Name of your project(Should not contain spaces)", ["HipremeProject"]);
	if(projectPath.length == 0)
	{
		error = "Execution cancelled. No project will be created.";
		return false;
	}
	else if(projectPath.hasSpace)
	{
		showErrorMessage(t, "Save Project Error", "Your project name '"~projectPath~"' should not contain spaces");
		return selectFolderForProject(t, projectPath, error);
	}
	else if(projectPath.exists && isDir(projectPath) && !isFolderEmpty(projectPath))
	{
		error = projectPath~" not empty. Please select an empty folder.";
		return false;
	}
	else if(projectPath[$-1] == '\0')
		projectPath = projectPath[0..$-1];
	return true;
}

version(Windows)
{
    import arsd.minigui;
    void showErrorMessage(ref Terminal t, string title, string message)
    {
        messageBox(title, message, MessageBoxStyle.OK, MessageBoxIcon.Error);
    }

    string showSaveFileDialog(ref Terminal t, string initialName, string[] filters)
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

        void showErrorMessage(ref Terminal t, string title, string message)
        {
            string cmd = getCommandToShowError(t, title, message);
            if(cmd.length)
                executeShell(cmd);
            else
                defaultShowErrorMessage(t, title, message);
        }


        string showSaveFileDialog(ref Terminal t, string initialName, string[] filters)
        {
            string cmd = getCommandToSaveFileDialog(initialName, filters[0]);
            if(cmd.length)
            {
                string ret = executeShell(cmd).output;
                import std.string:splitLines;
                import std.array:join;
                string[] lines = splitLines(ret);
                if(lines.length > 1)
                {
                    executeShell("zenity --warning --title=\"'"~cmd~"' warnings\" --text=\""~join(lines[0..$-1])~"\"");
                    ret = lines[$-1];
                }
                if(ret.length != 0 && ret[$-1] == '\n') ret = ret[0..$-1];
                return ret;
            }
            return defaultShowSaveFileDialog(t, initialName, filters);
        }
    }
    else
    {
        void showErrorMessage(ref Terminal t, string title, string message){defaultShowErrorMessage(t, title,message);}
        string showSaveFileDialog(ref Terminal t, string initialName, string[] filters){return defaultShowSaveFileDialog(t, initialName, filters);}

    }
}

private void defaultShowErrorMessage(ref Terminal t, string title, string message)
{
    t.writelnError("Error:", title, "\n\t", message);   
}
private string defaultShowSaveFileDialog(ref Terminal t, string initialName, string[] filters)
{
    import std.string : chomp;
    t.writeln("Write a folder name to create your HipProject: "~ initialName);
    t.flush;
    return t.getline("").chomp();
}