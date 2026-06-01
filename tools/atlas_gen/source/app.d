import std.stdio;
import std.file;
import std.path;
import std.conv;
import std.string;
import std.algorithm;
import std.getopt;
import std.array;
import std.math:abs;
import imageformats;

struct Rect {
    int x, y, w, h;
}

int main(string[] args) {
    import std.datetime.stopwatch;
    string input;
    string output = "output.atlas";
    int alphaThreshold = 8;
    int padding = 2;

    getopt(
        args,
        "input|i", &input,
        "output|o", &output,
        "alpha|a", &alphaThreshold,
        "padding|p", &padding
    );

    if (input.length == 0) {
        writeln("Usage: atlas_autocut -i spritesheet.png -o spritesheet.atlas");
        return 1;
    }

    auto img = read_image(input);
    int width = img.w;
    int height = img.h;
    int channels = img.c;

    if (channels < 4) {
        writeln("Image must have alpha channel.");
        return 1;
    }

    bool[] visited = new bool[width * height];
    Rect[] rects;

    bool isSolid(int x, int y) {
        auto idx = (y * width + x) * channels;
        return img.pixels[idx + 3] > alphaThreshold;
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

            minX = max(0, minX - padding);
            minY = max(0, minY - padding);
            maxX = min(width - 1, maxX + padding);
            maxY = min(height - 1, maxY + padding);

            rects ~= Rect(
                minX,
                minY,
                maxX - minX + 1,
                maxY - minY + 1
            );
        }
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