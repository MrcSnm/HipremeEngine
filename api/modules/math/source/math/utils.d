
module math.utils;
import std.math;
import math.vector;
int getClosestMultiple(int from, int to);
enum AxisNavigation 
{
	xy,
	yz,
	xz,
	zx,
	zy,
	yx,
}
Vector3 toCircleBounds(Vector3 v, float angle, AxisNavigation axis = AxisNavigation.xy);
