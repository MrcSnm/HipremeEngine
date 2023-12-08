module hip.api.config;

version(Android)
    enum InputIsTouch = true;
else version(iOS)
    enum InputIsTouch = true;
else 
    enum InputIsTouch = false;