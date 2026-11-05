module featurelib.features.ruby_gem;

import featurelib;
import std.process : executeShell, spawnShell;

Feature FeatureMakeRubyGem(
    string gemName,
    string purpose,
    VersionRange supportedVersion = VersionRange.init,
    TargetVersion currentVersion = TargetVersion.init,
    OS[] requiredOn = null,
    Feature*[] dependencies = null)
{
    return Feature("Ruby Gem: " ~ gemName, purpose, ExistenceChecker([], [], (ref Terminal t, TargetVersion v, out ExistenceStatus where)
    {
        if (executeShell("gem list | grep " ~ gemName).status)
        {
            where = ExistenceStatus(ExistenceStatus.Place.notFound);
            return false;
        }
        where = ExistenceStatus(ExistenceStatus.Place.inPath);
        return true;
    }), Installation([], (ref Terminal t, ConsoleInput input, TargetVersion ver, Download[] content, string[] extractionPaths)
    {
        return t.wait(spawnShell("sudo gem install " ~ gemName)) == 0;
    }), null, supportedVersion, currentVersion, requiredOn, dependencies);
}
