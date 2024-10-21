module hip.api.config;

version(Android)
    enum InputIsTouch = true;
else version(iOS)
    enum InputIsTouch = true;
else 
    enum InputIsTouch = false;

version(Android) enum isLinuxPC = false;
else version(linux) enum isLinuxPC = true;
else enum isLinuxPC = false;