module hip.api.graphics.batch;

///Use this interface when you store render commands and draws it a later time.
interface IHipBatch
{
    void flush();
}