// D import file generated from 'source\view\tilemaptest.d'
module view.tilemaptest;
import data.assetpacker;
import view.scene;
import data.assetpacker;
import console.log;
import hiprenderer;
import graphics.g2d.sprite;
import graphics.g2d.tilemap;
import graphics.g2d.spritebatch;
class TilemapTestScene : Scene
{
	Tilemap map;
	HipSpriteBatch batch;
	HipSprite spr;
	HipSprite sprite;
	HipSprite sprite2;
	this()
	{
		batch = new HipSpriteBatch;
		map = Tilemap.readTiledTMX("maps/Test.tmx");
		spr = new HipSprite(map.tilesets[0].texture);
		sprite = new HipSprite("graphics/sprites/sprite.png");
		sprite2 = new HipSprite("graphics/sprites/shaun.png");
	}
	override void render();
}
