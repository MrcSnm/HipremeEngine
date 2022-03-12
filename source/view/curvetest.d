module view.curvetest;
import hipengine;
import hiprenderer;
import console.log;
import view.scene;

import components.transform;
import systems.gameobject;

class CurveScene : Scene
{
    Vector2 ctP;
    HipGameObject goParen;
    HipGameObject goChild;
    override void init()
    {
        goParen = new HipGameObject("TransformTest");
        goParen.addComponent!HipTransformComponent;

        goChild = new HipGameObject("TransformTestChild");
        goChild.addComponent!HipTransformComponent;

        goParen.addChild(goChild);

        goParen.update(0);
        goChild.update(0);
        
        goParen.getComponent!HipTransformComponent.setPosition(100, 0, 0);
        goChild.getComponent!HipTransformComponent.setPosition(100, 0, 0);

        goParen.getComponent!HipTransformComponent.calculateWorld;
        goChild.getComponent!HipTransformComponent.calculateWorld;
        logln(goParen.getComponent!HipTransformComponent.worldTransform * goChild.getComponent!HipTransformComponent.transform);
        logln(goChild.getComponent!HipTransformComponent.worldTransform);

        import util.string;
        String s = String("Hello World ", 500, " are you okay there? ", " my dear friend!! ", 1, "*", 2, " = ", 2);
        import console.log;
        logln("Test");
    



    }
    override void render()
    {
        
        ctP = HipInput.getMousePosition();
        
        beginGeometry();

        fillRectangle(0, 0, 40, 40);
        // fillRectangle(0, 400, 8, 8);
        // fillRectangle(cast(int)ctP.x, cast(int)ctP.y, 8, 8);
        // fillRectangle(800, 400, 8, 8);

        // drawQuadraticBezierLine(0, 400, cast(int)ctP.x, cast(int)ctP.y, 800, 400, 50);


        endGeometry();
    }
}