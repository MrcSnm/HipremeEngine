module systems.ecs;

class HipComponent
{
    ///HipEntity id
    ulong owner;
}

class HipEntity
{
    ulong id;
    string tag;

    protected HipComponent[] components;

    HipComponent getComponent(T)()
    {
        
        return cast(T)components[i];
    }
}


class HipECS
{

}