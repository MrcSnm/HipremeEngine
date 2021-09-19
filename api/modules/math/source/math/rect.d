
module math.rect;
struct Size
{
	uint w;
	uint h;
	alias width = w;
	alias height = h;
}
struct Rect
{
	float x;
	float y;
	float w;
	float h;
	alias width = w;
	alias height = h;
}
bool overlaps(Rect r1, Rect r2);
