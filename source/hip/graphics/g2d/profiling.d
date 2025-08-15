module hip.graphics.g2d.profiling;

/**
 * Draw GC stats on screen for instant feedback.
 * Params:
 *   x = X position
 *   y = Y Position. If it is < 0, it will draw at the default Y which is in the lower part of the screen
 */
void drawGCStats(int x = 0, int y = -1)
{
    import hip.config.opts;
    import hip.util.string;
    import hip.util.data_structures;
    import hip.math.utils;
    import hip.graphics.g2d.renderer2d;
     if(x < 0)
        x = 0;
    if(y < 0)
    {
        import hip.hiprenderer.renderer;
        y = HipRenderer.getCurrentViewport.worldHeight;
    }

    static struct ByteUnit
    {
        double data;
        string unit;

        SmallString asSmallString() @nogc
        {
            return SmallString(
                SmallString(data).toString.limitDecimalPlaces(2),
                unit
            );
        }
    }

    ByteUnit formatFromBytes(size_t byteCount) @nogc
    {
        double actualResult = byteCount;

        if(actualResult <= 1000)
            return ByteUnit(floorDecimal(actualResult, 2), " B");
        actualResult/= 1000;
        if(actualResult <= 1000)
            return ByteUnit(floorDecimal(actualResult, 2), " KB");
        actualResult/= 1000;
            return ByteUnit(floorDecimal(actualResult, 2), " MB");
        actualResult/= 1000;
        return ByteUnit(floorDecimal(actualResult, 2), " GB");
    }

    static if(CustomRuntime)
    {
        import core.arsd.memory_allocation;
        SmallString str = SmallString("Memory Allocated ", formatFromBytes(getMemoryAllocated()).asSmallString().toString);
        drawText(str.toString, x, y, 1.0,  HipColor(0,50,0), HipTextAlign.botLeft);

    }
    else
    {
        import core.memory;
        GC.Stats stats = GC.stats;
        GC.ProfileStats prof = GC.profileStats;
        SmallString timeOnPause = SmallString.get();
        SmallString timeOnCollection = SmallString.get();

        prof.totalPauseTime.toString((string data)
        {
            timeOnPause~= data;
        });
        prof.totalCollectionTime.toString((string data)
        {
            timeOnCollection~= data;
        });


        scope BigString str = BigString(
            "Memory Used: ", formatFromBytes(stats.usedSize).asSmallString.toString,
            "\nFree Memory: ", formatFromBytes(stats.freeSize).asSmallString.toString,
            "\nPaused Time: ", timeOnPause.toString,
            "\nCollection Time:", timeOnCollection.toString,
            "\nCollections Count: ", prof.numCollections,
        );
        drawText(str.toString, x, y, 1.0,  HipColor(0, 0, 0, 150), HipTextAlign.botLeft);
    }
}


private __gshared float lastTiming;
private __gshared float lastTime;
private __gshared int count;
private __gshared immutable countReset = 30;

void setFrameInitTime()
{
    import hip.util.time;
    if(++count == countReset)
    {
        lastTime = HipTime.getCurrentTimeAsMs();
        count = 0;
    }
}
void drawTimings(int x = -1, int y = 0, bool clearTiming = false)
{
    import hip.util.time;
    import hip.util.string;
    import hip.graphics.g2d.renderer2d;

    if(count == 0)
        lastTiming = HipTime.getCurrentTimeAsMs() - lastTime;
    SmallString timeProcessing = SmallString("CPU Time: ", SmallString(lastTiming).toString.limitDecimalPlaces(3), "ms");

    if(x == -1)
        x = getCurrentViewport().worldWidth;

    drawText(timeProcessing.toString, x, 0, 1.0f, HipColor.white, HipTextAlign.topRight);

    // if(clearTiming)
    //     lastTime = currTime;
}