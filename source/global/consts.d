module global.consts;
private:
    import sdl.loader;

public:
    immutable static enum ENGINE_NAME = "Hipreme Engine";
    static int SCREEN_WIDTH = 800;
    static int SCREEN_HEIGHT = 600;
    static SDL_Window* gWindow = null;
    static SDL_Surface* gScreenSurface = null;

