module gen_tables;
import std.stdio;
import std.math;
import std.conv:to;

enum PRECISION = 256;
enum MAX_PER_LINE = 10;

void main()
{
    string data = "immutable float["~to!string(PRECISION)~"] sineTable = [\n\t";
    int i = 0;
    for(float v = 0; v < PI_2; v+= PI_2 / (PRECISION - 1))
    {
        if(i != 0)
            data~=", ";
        data~= sin(v).to!string~"f";
        if(++i == MAX_PER_LINE)
        {
            data~= ",\n\t";
            i = 0;
        }
    }
    data~= ", 1.0f\n];";

    writeln = data;
}
