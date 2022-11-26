module hip.view.curvetest;
version(Test):
import hip.api;
import hip.hiprenderer;
import hip.console.log;
import hip.view.scene;

import hip.components.transform;
import hip.systems.gameobject;

class CurveScene : Scene
{
    Vector2 ctP;
    HipGameObject goParen;
    HipGameObject goChild;
    override void initialize()
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

        import hip.util.string;
        import hip.util.data_structures;
        import hip.console.log;

        Array!int arr = Array!int(50, 100, 200);
        logln(arr);
        
    }
    override void render()
    {
        
        ctP = HipInput.getMousePosition();
        

        fillRectangle(0, 0, 40, 40);
        // fillRectangle(0, 400, 8, 8);
        // fillRectangle(cast(int)ctP.x, cast(int)ctP.y, 8, 8);
        // fillRectangle(800, 400, 8, 8);

        // drawQuadraticBezierLine(0, 400, cast(int)ctP.x, cast(int)ctP.y, 800, 400, 50);


        renderGeometries();
    }
}