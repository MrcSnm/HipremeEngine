/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.graphics.g2d.tilemap;
public import hip.graphics.g2d.spritebatch;
public import hip.assets.texture;
public import hip.api.data.tilemap;

import hip.util.reflection;
enum hasTSXSupport = Version.HipTSX && hasModule!"arsd.dom";


void render(HipTileLayer layer, IHipTilemap map, HipSpriteBatch batch, bool shouldRenderBatch = false)
{
    uint w = layer.width, h = layer.height;
    uint th = map.tileHeight, tw = map.tileWidth;

    ushort lastId;
    IHipTextureRegion lastTexture;

    for(int i = 0, _y = layer.y; i < w; i++, _y+= th)
        for(int j =0, _x = layer.x; j < h; j++, _x+= tw)
        {
            ushort targetTile = layer.tiles[i*w+j];
            if(targetTile == 0)
                continue;
            if(lastId != targetTile)
            {
                /**
                * Probably worth caching as it is: 
                * - one pointer dereference (map->)
                * - one function call (getTextureRegionForID)
                * - one function call (getTilesetForID)
                * - one pointer derefenrece (tileset->)
                * - one function call (getTextureRegion)
                */
                lastId = targetTile;
                lastTexture = map.getTextureRegionForID(targetTile);
            }
            batch.draw(lastTexture, _x, _y);
        }

    if(shouldRenderBatch)
        batch.render();
}

void render(IHipTilemap map, HipSpriteBatch batch, bool shouldRenderBatch)
{
    foreach(l; map.layers)
        l.render(map, batch, false);
    if(shouldRenderBatch)
        batch.flush();
}