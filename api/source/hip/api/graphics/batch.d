module hip.api.graphics.batch;

///Use this interface when you store render commands and draws it a later time.
interface IHipBatch
{
    /**
    *   This function is used for renderer2d being able to manage
    *   the draw order based on when the renderer being called is switched.
    *   This will bring a lot more performance than drawinig whenever
    *   the switch was needed.
    */
    void setCurrentDepth(float depth) @nogc;
    /**
    *   This draw most of the time is used to avoid accessing the same buffer
    *   it doesn't flush the batch, meaning it will only populate from the current
    *   point. 
    */
    void draw();
    /**
    *   Will call draw and restart the buffer access on the batch.
    *   Flush operations should not be called more than once per frame.
    */
    void flush();
}