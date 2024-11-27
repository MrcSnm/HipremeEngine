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
    import core.memory;
    import hip.util.string;
    import hip.util.data_structures;
    import hip.math.utils;
    GC.Stats stats = GC.stats;
    GC.ProfileStats prof = GC.profileStats;

    static struct ByteUnit
    {
        double data;
        string unit;

        String asString() @nogc
        {
            return String(String(data).toString.limitDecimalPlaces(2), unit);
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
    String timeOnPause;
    String timeOnCollection;

    prof.totalPauseTime.toString((string data)
    {
        timeOnPause~= data;
    });
    prof.totalCollectionTime.toString((string data)
    {
        timeOnCollection~= data;
    });


    scope auto toPrint = [
        String("GC Stats: "),
        String("\tMemory Used: ", formatFromBytes(stats.usedSize).asString),
        String("\tFree Memory: ", formatFromBytes(stats.freeSize).asString),
        String("\tTime Paused on GC: ", timeOnPause),
        String("\tTime Spent on Collection:", timeOnCollection),
        String("\tCollections Count: ", prof.numCollections),
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

    foreach(i, ref String str; toPrint)
        drawText(str.toString, x, y+lbSize*cast(int)i);
}