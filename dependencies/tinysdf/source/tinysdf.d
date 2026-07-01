module tinysdf;
import std.algorithm : min, max;
import std.math;

struct SDFResult
{
    ubyte[] pixels;
    int width;
    int height;
}

SDFResult bitmapToSDF(
    const(ubyte)[] src,
    int srcW,
    int srcH,
    int spread,
    int padding
)
{
    assert(src.length >= srcW * srcH);
    assert(spread > 0);
    assert(padding >= spread);

    int w = srcW + padding * 2;
    int h = srcH + padding * 2;

    ubyte[] bitmap;
    bitmap.length = w * h;
    bitmap[] = 0;

    // Copia bitmap original para o centro com padding.
    foreach (y; 0 .. srcH)
    {
        auto srcRow = src[y * srcW .. y * srcW + srcW];
        auto dstOff = (y + padding) * w + padding;
        bitmap[dstOff .. dstOff + srcW] = srcRow;
    }

    bool inside(int x, int y)
    {
        if (x < 0 || y < 0 || x >= w || y >= h)
            return false;

        return bitmap[y * w + x] >= 128;
    }

    bool isEdge(int x, int y)
    {
        bool c = inside(x, y);

        // Só considera borda se existe vizinho com estado diferente.
        foreach (dy; -1 .. 2)
        foreach (dx; -1 .. 2)
        {
            if (dx == 0 && dy == 0)
                continue;

            if (inside(x + dx, y + dy) != c)
                return true;
        }

        return false;
    }

    struct Edge
    {
        int x;
        int y;
    }

    Edge[] edges;

    foreach (y; 0 .. h)
    foreach (x; 0 .. w)
    {
        if (isEdge(x, y))
            edges ~= Edge(x, y);
    }

    ubyte[] sdf;
    sdf.length = w * h;

    float maxDist = cast(float) spread;
    float maxDist2 = maxDist * maxDist;
    float scale = 127.0f / maxDist;

    foreach (y; 0 .. h)
    foreach (x; 0 .. w)
    {
        float best2 = maxDist2;

        foreach (e; edges)
        {
            float dx = cast(float)(x - e.x);
            float dy = cast(float)(y - e.y);
            float d2 = dx * dx + dy * dy;

            if (d2 < best2)
                best2 = d2;
        }

        float dist = sqrt(best2);
        if (dist > maxDist)
            dist = maxDist;

        float signedDist = inside(x, y) ? dist : -dist;

        float v = 128.0f + signedDist * scale;

        if (v < 0.0f) v = 0.0f;
        if (v > 255.0f) v = 255.0f;

        sdf[y * w + x] = cast(ubyte)(v + 0.5f);
    }

    return SDFResult(sdf, w, h);
}

struct TinySDF
{
    int radius = 8;
    float cutoff = 0.25f;

    // bitmap: grayscale 0..255, width*height
    // retorna SDF grayscale 0..255
    ubyte[] generate(const(ubyte)[] bitmap, int width, int height)
    {
        assert(bitmap.length == width * height);

        auto gridOuter = new double[](width * height);
        auto gridInner = new double[](width * height);
        auto f = new double[](max(width, height));

        enum double INF = 1e20;

        foreach (i; 0 .. width * height)
        {
            double a = bitmap[i] / 255.0;

            if (a == 1.0)
            {
                gridOuter[i] = 0;
                gridInner[i] = INF;
            }
            else if (a == 0.0)
            {
                gridOuter[i] = INF;
                gridInner[i] = 0;
            }
            else
            {
                // Antialias: estima distância subpixel pela cobertura
                gridOuter[i] = (0.5 - a) * (0.5 - a);
                gridInner[i] = (a - 0.5) * (a - 0.5);
            }
        }

        edt(gridOuter, width, height, f);
        edt(gridInner, width, height, f);

        auto sdf = new ubyte[](width * height);

        foreach (i; 0 .. width * height)
        {
            double d = sqrt(gridOuter[i]) - sqrt(gridInner[i]);

            double v = 255.0 - 255.0 * (d / radius + cutoff);

            if (v < 0) v = 0;
            if (v > 255) v = 255;

            sdf[i] = cast(ubyte)(v + 0.5);
        }

        return sdf;
    }

    ubyte[] generateWithPadding(const(ubyte)[] src, int srcW, int srcH,
                            int padding,
                            out int dstW, out int dstH)
    {
        dstW = srcW + padding * 2;
        dstH = srcH + padding * 2;

        auto padded = new ubyte[](dstW * dstH);
        padded[] = 0;

        for (int y = 0; y < srcH; y++)
        {
            auto srcRow = src[y * srcW .. y * srcW + srcW];
            auto dstRow = padded[(y + padding) * dstW + padding
                            .. (y + padding) * dstW + padding + srcW];

            dstRow[] = srcRow[];
        }

        return generate(padded, dstW, dstH);
    }

    private static void edt(double[] data, int width, int height, double[] f)
    {
        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < height; y++)
                f[y] = data[y * width + x];

            edt1d(f[0 .. height], height);

            for (int y = 0; y < height; y++)
                data[y * width + x] = f[y];
        }

        for (int y = 0; y < height; y++)
        {
            auto row = data[y * width .. y * width + width];
            edt1d(row, width);
        }
    }

    private static void edt1d(double[] f, int n)
    {
        auto d = new double[](n);
        auto v = new int[](n);
        auto z = new double[](n + 1);

        int k = 0;
        v[0] = 0;
        z[0] = -double.infinity;
        z[1] = double.infinity;

        for (int q = 1; q < n; q++)
        {
            double s;

            do
            {
                int vk = v[k];
                s = ((f[q] + q * q) - (f[vk] + vk * vk)) / (2.0 * q - 2.0 * vk);

                if (s <= z[k])
                    k--;
                else
                    break;
            }
            while (k >= 0);

            k++;
            v[k] = q;
            z[k] = s;
            z[k + 1] = double.infinity;
        }

        k = 0;

        for (int q = 0; q < n; q++)
        {
            while (z[k + 1] < q)
                k++;

            int vk = v[k];
            double diff = q - vk;
            d[q] = diff * diff + f[vk];
        }

        f[] = d[];
    }
}
