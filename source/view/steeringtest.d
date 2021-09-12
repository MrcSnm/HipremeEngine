module view.steeringtest;
import hiprenderer.texture;
import graphics.g2d.sprite;
import graphics.g2d.spritebatch;
import ai.steering;
import view;

enum Tests
{
    Arrive,
    Wander, 
    PathFollow
}

enum TEST = Tests.PathFollow;

class SteeringTest : Scene
{
    HipSpriteBatch b;
    HipSprite main;
    HipSprite target;
    static if(TEST == Tests.Wander)
        float wa = 0;

    static if(TEST == Tests.PathFollow)
    {
        PathFollowerStatus status = 
        PathFollowerStatus([
            Vector3(200, 0, 0),
            Vector3(200, 200, 0),
            Vector3(0, 200, 0),
            Vector3(0, 0, 0)
        ]);
    }

    this()
    {
        // target = new HipSprite(new TextureRegion("graphics/sprites/sprite.png", 32*4u, 0u, 32u, 32u));
        // main = new HipSprite(new TextureRegion("graphics/sprites/sprite.png", 32u*2u, 0u, 32u, 32u));
        main = new HipSprite("graphics/sprites/sprite.png");
        target = new HipSprite("graphics/sprites/sprite.png");
        target.setPosition(500, 330);
        b = new HipSpriteBatch();
    }
    override void update(float dt)
    {
        Vector3 pos;
        static if(TEST == Tests.Arrive)
            pos = arrive(Vector3(target.x, target.y, 0), Vector3(main.x, main.y, 0), 2, 1, dt);
        else static if(TEST == Tests.Wander)
            pos = wander(Vector3(1,0,0), Vector3(1,0,0), 40, 30, wa, 5, 4, dt);
        else static if(TEST == Tests.PathFollow)
            pos = pathFollow(Vector3(main.x,main.y,0), status, 100, dt);

        main.setPosition(main.x+pos.x, main.y+pos.y);
    }
    override void render()
    {
        b.begin();
        b.draw(main);
        b.draw(target);
        b.end();
    }
}