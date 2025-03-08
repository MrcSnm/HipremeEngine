module hip.graphics.g2d.profiling;
import hip.graphics.g2d.renderer2d;


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

    version(WebAssembly)
    {
        import core.arsd.memory_allocation;
        SmallString str = SmallString("Memory Allocated ", formatFromBytes(getMemoryAllocated()).asSmallString().toString);
        int lbSize = 40;
        int totalSize = lbSize;
        if(x < 0)
            x = 0;
        if(y < 0)
        {
            import hip.hiprenderer.renderer;
            Viewport vp = HipRenderer.getCurrentViewport;
            y = vp.worldHeight - totalSize;
        }
        drawText(str.toString, x, y+lbSize);

    }
    else static if(!CustomRuntime)
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


        scope auto toPrint = [
            SmallString("GC Stats: "),
            SmallString("\tMemory Used: ", formatFromBytes(stats.usedSize).asSmallString.toString),
            SmallString("\tFree Memory: ", formatFromBytes(stats.freeSize).asSmallString.toString),
            SmallString("\tTime Paused on GC: ", timeOnPause.toString),
            SmallString("\tTime Spent on Collection:", timeOnCollection.toString),
            SmallString("\tCollections Count: ", prof.numCollections),
        ].staticArray;

        int lbSize = 40;
        int totalSize = lbSize*cast(int)toPrint.length;
        if(x < 0)
            x = 0;
        if(y < 0)
        {
            import hip.hiprenderer.renderer;
            Viewport vp = HipRenderer.getCurrentViewport;
            y = vp.worldHeight - totalSize;
        }

        foreach(i, str; toPrint)
            drawText(str.toString, x, y+lbSize*cast(int)i, HipColor(0, 50, 0));
    }
}