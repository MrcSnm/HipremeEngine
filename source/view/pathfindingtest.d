module view.pathfindingtest;
import ai.pathfinding;
import hiprenderer;
import graphics.g2d.geometrybatch;

import view;


ubyte[] map = 
[
    // 8 columns
    1,1,1,1,1,1,1,1,
    1,0,0,0,1,1,1,1,
    1,0,1,0,0,0,0,1,
    1,0,0,1,0,1,1,1,
    1,0,0,1,0,0,0,1,
    1,1,1,1,1,1,0,1
];

uint rectSize = 64;

class PathFindingTest : Scene
{
    GeometryBatch batch;
    AStarResult!ubyte ret;
    this()
    {
        batch = new GeometryBatch();

        ret = AStar2D_4Way(map, 1, 1, 8, 6, 5, 1);
    }
    override void update(float dt)
    {

    }
    override void render()
    {
        uint mapColumns = 8;
        uint mapRows = cast(uint)map.length/mapColumns;

        for(int i =0; i < mapRows; i++)
        {
            for(int z =0; z < mapColumns; z++)
            {
                if(map[i*mapColumns+z] == 1)
                    batch.setColor(HipColor.red);
                else
                    batch.setColor(HipColor.yellow);
                batch.fillRectangle(rectSize*z, rectSize*i, rectSize, rectSize);
            }
        }

        for(ulong i = 0; i < ret.path.length; i++)
        {
            float c = 1.0f/ret.path.length * i;
            // float c = 1;
            batch.setColor(HipColor(c,c,c,c));
            batch.fillRectangle(rectSize*(ret.path[i]%mapColumns), rectSize*(ret.path[i]/mapColumns), rectSize, rectSize);
        }
        batch.flush();
    }
}