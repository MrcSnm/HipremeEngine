import std.stdio;
import std.file;
import std.path;
import std.conv;
import std.string;
import std.algorithm;
import std.getopt;
import std.array;
import std.math:abs;
import gamut;

struct Rect {
    int x, y, w, h;
}

int rectDistance(Rect a, Rect b)
{
    int ax2 = a.x + a.w;
    int ay2 = a.y + a.h;
    int bx2 = b.x + b.w;
    int by2 = b.y + b.h;

    int dx = max(0, max(b.x - ax2, a.x - bx2));
    int dy = max(0, max(b.y - ay2, a.y - by2));

    return max(dx, dy); //  Chebyshev
}

Rect unionRect(Rect a, Rect b)
{
    int x1 = min(a.x, b.x);
    int y1 = min(a.y, b.y);
    int x2 = max(a.x + a.w, b.x + b.w);
    int y2 = max(a.y + a.h, b.y + b.h);

    return Rect(x1, y1, x2 - x1, y2 - y1);
}

int main(string[] args) {
    string input;
    string output = null;
    int alphaThreshold = 8;
    int mergeDistance = 16;
    int minArea = 4;
    int padding = 2;

    getopt(
        args,
        "input|i", &input,
        "output|o", &output,
        "alpha|a", &alphaThreshold,
        "padding|p", &padding,
        "merge-distance|m", &mergeDistance,
        "min-area", &minArea
    );

    if (input.length == 0) {
        writeln("Usage: atlas_autocut -i spritesheet.png -o spritesheet.atlas");
        return 1;
    }

    if(output.length == 0)
        output = input.withExtension(".atlas").array;

    Image img;
    img.loadFromFile(input, LOAD_RGB | LOAD_ALPHA | LOAD_8BIT);
    if(img.isValid)
    {
        img.changeLayout(LAYOUT_GAPLESS | LAYOUT_VERT_STRAIGHT);
    }
    else
    {
        writeln("Invalid image at path ", input);
        return 1;
    }
    int width = img.width();
    int height = img.height();

    ubyte[] pixels = img.allPixelsAtOnce();

    if (img.type != PixelType.rgba8) {
        writeln("Image must have alpha channel. Image Format: ", img.type);
        return 1;
    }

    bool[] visited = new bool[width * height];
    Rect[] rects;

    bool isSolid(int x, int y) {
        auto idx = (y * width + x) * 4;
        return pixels[idx + 3] > alphaThreshold;
    }
    int[] queue = new int[width*height];
    int qLength = 0;
    foreach (y; 0 .. height) 
    {
        qLength = 0;
        foreach (x; 0 .. width) 
        {
            int start = y * width + x;

            if (visited[start] || !isSolid(x, y))
                continue;

            int minX = x;
            int maxX = x;
            int minY = y;
            int maxY = y;

            queue[qLength++] = start;
            visited[start] = true;

            while (qLength > 0) {
                int current = queue[--qLength];

                int cx = current % width;
                int cy = current / width;

                minX = min(minX, cx);
                maxX = max(maxX, cx);
                minY = min(minY, cy);
                maxY = max(maxY, cy);

                foreach (dy; -1 .. 2) {
                    foreach (dx; -1 .. 2) {
                        if (abs(dx) + abs(dy) != 1)
                            continue;

                        int nx = cx + dx;
                        int ny = cy + dy;

                        if (nx < 0 || ny < 0 || nx >= width || ny >= height)
                            continue;

                        int ni = ny * width + nx;

                        if (!visited[ni] && isSolid(nx, ny)) {
                            visited[ni] = true;
                            queue[qLength++] = ni;
                        }
                    }
                }
            }

            rects ~= Rect(
                minX,
                minY,
                maxX - minX + 1,
                maxY - minY + 1
            );
        }
    }

    rects = rects
    .filter!(r => r.w * r.h >= minArea)
    .array;

    bool changed = true;

    while (changed)
    {
        changed = false;

        outer:
        foreach (i; 0 .. rects.length)
        {
            foreach (j; i + 1 .. rects.length)
            {
                if (rectDistance(rects[i], rects[j]) <= mergeDistance)
                {
                    rects[i] = unionRect(rects[i], rects[j]);
                    rects = rects[0 .. j] ~ rects[j + 1 .. $];
                    changed = true;
                    break outer;
                }
            }
        }
    }
    foreach (ref r; rects)
    {
        int x1 = max(0, r.x - padding);
        int y1 = max(0, r.y - padding);
        int x2 = min(width, r.x + r.w + padding);
        int y2 = min(height, r.y + r.h + padding);

        r = Rect(x1, y1, x2 - x1, y2 - y1);
    }


    rects.sort!((a, b) => a.y == b.y ? a.x < b.x : a.y < b.y);

    auto atlas = File(output, "w");

    atlas.writeln(baseName(input));
    atlas.writeln("size: ", width, ", ", height);
    atlas.writeln("format: RGBA8888");
    atlas.writeln("filter: Linear,Linear");
    atlas.writeln("repeat: none");
    atlas.writeln();

    foreach (i, r; rects) {
        atlas.writeln("sprite_", i);
        atlas.writeln("  rotate: false");
        atlas.writeln("  xy: ", r.x, ", ", r.y);
        atlas.writeln("  size: ", r.w, ", ", r.h);
        atlas.writeln("  orig: ", r.w, ", ", r.h);
        atlas.writeln("  offset: 0, 0");
        atlas.writeln("  index: -1");
        atlas.writeln();
    }
    writeln("Written ", rects.length, " sprites to file ", output);
    return 0;
}