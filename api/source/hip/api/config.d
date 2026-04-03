module hip.api.config;

version(Android)
    enum IsMobile = true;
else version(iOS)
    enum IsMobile = true;
else 
    enum IsMobile = false;

version(Android) enum isLinuxPC = false;
else version(PSVita) enum isLinuxPC = false;
else version(linux) enum isLinuxPC = true;
else enum isLinuxPC = false;

enum HipAssetLoadStrategy
{
	loadAll
}