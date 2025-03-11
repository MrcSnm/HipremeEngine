module hip.game2d.tileworld;
public import hip.api.data.tilemap;
public import hip.component.physics;
public import hip.math.collision;
import hip.util.algorithm;



class TileWorld
{
    IHipTilemap map;
    ///Affects position
    float constantGravity = 0;
    ///Affects velocity
    float gravity = 0;

    BodyRectComponent[] dynamicBodies;
    HipTileLayer[] collidibleLayers;

    this(IHipTilemap map, float gravity = 0, float constantGravity = 0)
    {
        this.map = map;
        this.gravity = gravity;
        this.constantGravity = constantGravity;
    }

    private Rect[128] rectCache;
    Rect[] getRectsOverlapping(HipTileLayer layer, in Rect input) @nogc
    {
        import hip.math.utils;
        if(!layer.isInLayerBoundaries(
            cast(int)input.x, cast(int)input.y, cast(int)input.w, cast(int)input.h
        ))
            return rectCache[0..0];
        
        uint tileW = map.tileWidth, tileH = map.tileHeight;
        float x = input.x - layer.x;
        float y = input.y - layer.y;
        


        

        float inputTilesWidth = input.w / tileW;
        float inputTilesHeight = input.h / tileH;

        float i = x/tileW;
        float j = y/tileH;
        float i2 = ceil(min(i + inputTilesWidth, layer.columns));
        float j2 = ceil(min(j + inputTilesHeight, layer.rows - 1));


        float plusI = min(inputTilesWidth, 1);
        float plusJ = min(inputTilesHeight, 1);

        int lastI = -1;
        int lastJ = -1;

        int rects = 0;
        for(; j < j2; j+= plusJ)
        for(float _i = i; _i < i2; _i+= plusI)
        {
            if(_i < 0 || j < 0)
                continue;
            int ui = cast(int)_i;
            int uj = cast(int)j;

            if(ui == lastI && uj == lastJ)
                continue;
            lastI = ui;
            lastJ = uj;

            ushort tID = layer.checkedGetTile(ui, uj);
            if(tID != 0)
            {
                rectCache[rects++] = Rect(layer.x + ui*tileW, layer.y + uj*tileH, tileW, tileH);
            }
        }
        return rectCache[0..rects];
    }

    void addDynamic(IComponentizable component)
    {
        auto comp = component.getComponent!BodyRectComponent;
        assert(comp !is null, "No BodyRectComponent found");
        assert(comp.size.w != 0, "Can't have 0 width component");
        assert(comp.size.h != 0, "Can't have 0 height component");
        dynamicBodies~= comp;
    }

    void addCollidibleLayer(HipTileLayer layer)
    {
        collidibleLayers~= layer;
    }

    void update2(float dt) @nogc
    {
        import hip.util.algorithm:quicksort;
        struct DynamicRectCollision
        {
            Vector2 normal;
            float time;
        }
        __gshared DynamicRectCollision[128] colCache;
        foreach(dynBody; dynamicBodies)
        {
            dynBody.velocity.y += gravity;
            Rect bodyRec = dynBody.rect;
            int z = 0;

            foreach(HipTileLayer l; collidibleLayers)
            for(int j = 0; j < l.rows; j++)
            for(int i = 0; i < l.columns; i++)
            {
                if(l.getTile(i, j) != 0)
                {
                    DynamicRectCollision col = void;
                    if(isDynamicRectOverlappingRect(bodyRec, dynBody.velocity, Rect(l.x + i*l.tileWidth, l.y+j*l.tileHeight, l.tileWidth, l.tileHeight), dt, col.normal, col.time))
                        colCache[z++] = col;
                }
            }
            if(z > 0)
            foreach(col; quicksort(colCache[0..z], ((DynamicRectCollision a, DynamicRectCollision b) => a.time < b.time)))
                resolveDynamicRectOverlappingRect(col.normal, dynBody.velocity, col.time);
            dynBody.position+= dynBody.velocity* dt;
        }
    }

    void update(float dt) @nogc
    {
        import hip.util.algorithm:quicksort;
        struct DynamicRectCollision
        {
            Vector2 normal;
            float time;
        }
        __gshared DynamicRectCollision[128] colCache;
        foreach(dynBody; dynamicBodies)
        {
            dynBody.velocity.y += gravity;
            Rect bodyRec = dynBody.rect;
            int i = 0;

            foreach(l; collidibleLayers)
            foreach(const ref rect; getRectsOverlapping(l, dynBody.expandedRectVel))
            {
                DynamicRectCollision col = void;
                if(isDynamicRectOverlappingRect(bodyRec, dynBody.velocity, rect, dt, col.normal, col.time))
                    colCache[i++] = col;
            }
            if(i > 0)
            foreach(col; quicksort(colCache[0..i], (DynamicRectCollision a, DynamicRectCollision b) => a.time < b.time))
                resolveDynamicRectOverlappingRect(col.normal, dynBody.velocity, col.time);
            dynBody.position+= dynBody.velocity* dt;
        }
    }
}