// D import file generated from 'source\ai\pathfinding.d'
module ai.pathfinding;
import util.data_structures;
private struct AStarNode
{
	AStarNode* previous;
	int id;
	int g;
	int h;
	int f();
}
pragma (inline, true)int manhattanHeuristic(int posX, int posY, int targetX, int targetY);
struct AStarResult(T)
{
	bool isPossible;
	T[] path;
}
AStarResult!T AStar2D_4Way(T, Q)(ref T[] map, uint startX, uint startY, int columns, uint targetX, uint targetY, Q walls)
{
	import util.array;
	uint start = startY * columns + startX;
	uint target = targetY * columns + targetX;
	AStarResult!T ret;
	AStarNode[] open = [AStarNode(null, start, 0, manhattanHeuristic(startX, startY, targetX, targetY))];
	AStarNode[] closed;
	pragma (inline, true)
	{
		enum append = (AStarNode* prev, T num)
		{
			import std.traits : isArray;
			static if (is(typeof(walls) == typeof(null)))
			{
			}
			else
			{
				static if (isArray!Q)
				{
					for (ulong i = 0;
					 i < walls.length; i++)
					{
						if (map[num] == walls[i])
							return ;
					}
				}
				else
				{
					if (map[num] == walls)
						return ;
				}
			}
			if (!closed.contains!"id"(num))
			{
				int ind = open.indexOf!"id"(num);
				if (ind != -1)
				{
					if (prev.g + 1 < open[ind].g)
					{
						open[ind].g = prev.g + 1;
						open[ind].previous = prev;
					}
				}
				else if (prev != null)
					open ~= AStarNode(prev, num, prev.g + 1, manhattanHeuristic(num % columns, num / columns, targetX, targetY));
			}
		}
		;
	}
	int current;
	AStarNode* node;
	while (!open.isEmpty)
	{
		ulong lowestF = 0;
		for (ulong i = 0;
		 i < open.length; i++)
		{
			if (open[i].f < open[lowestF].f)
				lowestF = i;
		}
		closed ~= open[lowestF];
		node = &open[lowestF];
		current = node.id;
		if (open[lowestF].id == target)
		{
			ret.isPossible = true;
			break;
		}
		int currentColumn = current % columns;
		if (current - columns >= 0)
			append(node, cast(T)(current - columns));
		if ((current + 1) % columns > currentColumn)
			append(node, cast(T)(current + 1));
		if (current + columns < map.length)
			append(node, cast(T)(current + columns));
		if (current - 1 >= 0 && ((current - 1) % columns < currentColumn))
		{
			append(node, cast(T)(current - 1));
		}
		open.remove(*node);
	}
	while (node.previous)
	{
		ret.path ~= cast(T)node.id;
		node = node.previous;
	}
	ret.path ~= cast(T)node.id;
	return ret;
}
