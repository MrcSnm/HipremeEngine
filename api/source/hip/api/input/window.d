module hip.api.input.window;

interface IHipWindow
{
    void start();
    void setName(string name);
    void setSize(uint width, uint height);
    int[2] getSize();
    void setFullscreen(bool fullscreen);
    void setVSyncActive(bool active);
}