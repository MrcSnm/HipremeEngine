module hip.hipaudio.backend.openal.al_err;
version(OpenAL):
import bindbc.openal;

package string alGetErrorString(ALenum err, string file = __FILE__, size_t line = __LINE__) nothrow
{
    string ret;
    if(err != AL_NO_ERROR)
    {
        final switch(err)
        {
            case AL_INVALID_NAME:
                ret = "AL_INVALID_NAME: A bad name (ID) was passed to an OpenAL function";
                break;
            case AL_INVALID_ENUM:
                ret = "AL_INVALID_ENUM: An invalid enum value was passed to an OpenAL function";
                break;
            case AL_INVALID_VALUE:
                ret = "AL_INVALID_VALUE: An invalid value was passed to an OpenAL function";
                break;
            case AL_INVALID_OPERATION:
                ret = "AL_INVALID_OPERATION: A requested operation is not valid";
                break;
            case AL_OUT_OF_MEMORY:
                ret = "AL_OUT_OF_MEMORY: The requested operation resulted in OpenAL running out of memory";
                break;
        }
        import hip.util.conv:to;
        ret~= "("~file~":"~line.to!string~")";
    }
    return ret;
}

package void alCheckError(string title="", string file = __FILE__, size_t line = __LINE__)
{
    version(HIPREME_DEBUG)
    {
        import hip.error.handler;
        ALenum err = alGetError();
        if(err != AL_NO_ERROR)
        {
            scope string errTitle = "OpenAL Error: " ~title;
            ErrorHandler.showErrorMessage(errTitle, alGetErrorString(err, file, line));
        }
    }
}