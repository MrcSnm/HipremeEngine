module features.ruby_gem;
public import feature;
import commons;

Feature FeatureMakeRubyGem(
    string gemName, 
    string purpose, 
    VersionRange supportedVersion = VersionRange.init, 
    TargetVersion currentVersion = TargetVersion.init,
    OS[] requiredOn = null, 
    Feature*[] dependencies = null
)
{
    import std.process;
    return Feature("Ruby Gem: "~gemName, purpose, ExistenceChecker([], [], (ref Terminal t, TargetVersion v, out ExistenceStatus where)
    {
        if(executeShell("gem list | grep "~gemName).status)
        {
            where = ExistenceStatus(ExistenceStatus.Place.notFound);
            return false;
        }
        where = ExistenceStatus(ExistenceStatus.place.inPath);
        return true;
    }), Installation([], (ref Terminal t, ref RealTimeConsoleInput input, TargetVersion ver, Download[] content)
    {
        return wait(spawnShell("sudo gem install "~gemName)) == 0;
    }), null, supportedVersion, currentVersion, requiredOn, dependencies);
}