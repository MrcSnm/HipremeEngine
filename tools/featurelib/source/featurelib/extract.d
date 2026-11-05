module featurelib.extract;

import std.file;
import std.path;
import featurelib.terminal : Terminal, ConsoleInput;
import featurelib.util : findProgramPath, dbgExecuteShell, WorkingDir;

/// Set by the 7-Zip feature so downloads/extractions use the bundled binary
/// instead of requiring 7z on PATH.
__gshared string sevenZipExecutable;

bool isCompactedFile(string fileName)
{
    switch (fileName.extension)
    {
        case ".gz", ".xz", ".zip", ".7zip", ".7z": return true;
        default: return false;
    }
}

bool isRecognizedExtension(string ext)
{
    switch (ext)
    {
        case ".7z", ".7zip", ".tar", ".xz", ".zf", ".bz", ".gz", ".zip": return true;
        default: return false;
    }
}

/// Removes the extension while keeping numeric extensions such as dmd-2.105.0.
string removeExtension(string input)
{
    string ext;
    while ((ext = input.extension).length && ext.isRecognizedExtension)
        input = input.setExtension("");
    return input;
}

bool extractZipToFolder(string zipPath, string outputDirectory, ref Terminal t)
{
    import std.zip;

    ZipArchive zip = new ZipArchive(std.file.read(zipPath));
    if (!std.file.exists(outputDirectory))
    {
        t.writeln("Creating directory ", outputDirectory);
        t.flush();
        std.file.mkdirRecurse(outputDirectory);
    }
    foreach (fileName, archiveMember; zip.directory)
    {
        string outputFile = buildNormalizedPath(outputDirectory, fileName);
        if (!std.file.exists(outputFile))
        {
            if (archiveMember.expandedSize == 0)
                std.file.mkdirRecurse(outputFile);
            else
            {
                string currentDirName = outputFile;
                /// For some reason on linux it thinks that .a files are directories
                t.writeln("Extracting ", fileName);
                t.flush();
                currentDirName = currentDirName.dirName;
                if (!std.file.exists(currentDirName))
                    std.file.mkdirRecurse(currentDirName);
                std.file.write(outputFile, zip.expand(archiveMember));
            }
        }
    }
    return true;
}

version (Posix)
bool extractTarGzToFolder(string tarGzPath, string outputDirectory, ref Terminal t)
{
    if (!std.file.exists(tarGzPath))
    {
        t.writelnError("File ", tarGzPath, " does not exists.");
        return false;
    }
    t.writeln("Extracting ", tarGzPath, " to ", outputDirectory);
    t.flush();
    std.file.mkdirRecurse(outputDirectory);
    return dbgExecuteShell("tar -xf " ~ tarGzPath ~ " -C " ~ outputDirectory, t);
}

bool extractTarToFolder(ref Terminal t, string tarPath, string outputDirectory)
{
    import archive.tar;

    try
    {
        auto tar = new TarArchive(std.file.read(tarPath));
        t.writeln("Extracting ", tarPath, " to ", outputDirectory);
        foreach (file; tar.files)
        {
            if (file.path == "@LongLink")
                continue;
            string outputPath = buildNormalizedPath(outputDirectory, file.path);
            if (std.file.exists(outputPath))
                continue;
            string targetDir = dirName(outputPath);
            if (!std.file.exists(targetDir))
                t.writeln("\t->", targetDir);
            std.file.mkdirRecurse(targetDir);
            std.file.write(outputPath, file.data);
        }
    }
    catch (Exception e)
    {
        t.writelnError("File ", tarPath, " does not exists, ", e.toString);
        return false;
    }
    return true;
}

private string find7Zip()
{
    if (sevenZipExecutable.length)
        return sevenZipExecutable;
    foreach (name; ["7z", "7za", "7zz", "7zr"])
    {
        string path = findProgramPath(name);
        if (path.length)
            return path;
    }
    return null;
}

private bool extract7ZipToFolder(string zPath, string outputDirectory, ref Terminal t)
{
    if (!std.file.exists(zPath))
    {
        t.writelnError("File ", zPath, " does not exists.");
        return false;
    }

    string sevenZip = find7Zip();
    if (!sevenZip.length)
    {
        t.writelnError("7-Zip executable not found in PATH.");
        return false;
    }

    t.writeln("Extracting ", zPath, " to ", outputDirectory);
    t.flush();
    if (!std.file.exists(outputDirectory))
        std.file.mkdirRecurse(outputDirectory);

    with (WorkingDir(outputDirectory))
        return dbgExecuteShell(sevenZip ~ " x -y " ~ zPath, t);
}

bool extractToFolder(
    string zPath,
    string outputDirectory,
    ref Terminal t,
    ConsoleInput input)
{
    switch (zPath.extension)
    {
        case ".gz", ".xz":
            version (Posix)
                return extractTarGzToFolder(zPath, outputDirectory, t);
            else version (Windows)
            {
                /// Handles .gz and .xz, then the inner tar file.
                if (!extract7ZipToFolder(zPath, dirName(zPath), t))
                    return false;
                t.writelnSuccess("Extracted to ", dirName(zPath));
                return extractTarToFolder(t, zPath[0 .. $ - ".xz".length], outputDirectory);
            }
            else assert(false, "No .tar.gz support on non Posix");
        case ".zip":
            return extractZipToFolder(zPath, outputDirectory, t);
        case ".7zip", ".7z":
            return extract7ZipToFolder(zPath, outputDirectory, t);
        default:
            std.file.mkdirRecurse(outputDirectory);
            copy(zPath, buildPath(outputDirectory, baseName(zPath)));
            t.writelnSuccess(zPath, " is not a compressed file, copying it to ", outputDirectory);
            return true;
    }
}

unittest
{
    assert("dmd-2.105.0".removeExtension == "dmd-2.105.0");
    assert("archive.tar.xz".removeExtension == "archive");
    assert(isCompactedFile("x.zip"));
    assert(!isCompactedFile("x.tar"));
}
