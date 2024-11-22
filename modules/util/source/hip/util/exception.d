module hip.util.exception;

void enforce(bool condition, scope lazy string msg)
{
    if(!condition)
        throw new Exception(msg);
}