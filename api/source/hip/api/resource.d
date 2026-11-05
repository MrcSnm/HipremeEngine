module hip.api.resource;

interface IHipResource
{
    void dispose();
}

abstract class HipResource : IHipResource
{
    bool released;
    abstract void dispose();
    final void release()
    {
        if(!released)
        {
            dispose();
            released = true;   
        }
    }
}

abstract class HipResourceManager
{
    private HipResource[] resources;
    final void addResource(HipResource r){resources~= r;}

    void freeResources()
    {
        foreach_reverse(r; resources) 
            r.release();
        resources.length = 0;
    }

}