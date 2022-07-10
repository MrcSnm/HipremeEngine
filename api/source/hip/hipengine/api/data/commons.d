module hip.hipengine.api.data.commons;

interface ILoadable
{
        /** Should return if the load was successful */
    bool load();
    /** Should return if the asset is ready for use*/
    bool isReady();
}