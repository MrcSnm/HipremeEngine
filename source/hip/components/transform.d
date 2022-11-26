module hip.components.transform;

import hip.systems.gameobject;
public import hip.math.matrix;
public import hip.math.vector;

class HipTransformComponent : HipComponent
{

    Matrix4* parentTransform;
    Matrix4 worldTransform;
    Matrix4 transform;
    this()
    {
        transform = Matrix4.identity;
        worldTransform = Matrix4.identity;
    }

    override void onStart()
    {
        HipGameObject thisParent = owner.parent;
        if(thisParent is null)
            return;
        HipTransformComponent c = thisParent.getComponent!HipTransformComponent;
        if(c !is null)
            parentTransform = &c.worldTransform;
        calculateWorld;
    }
    override void onRemove(){}
    override void update(float deltaTime){}




    void calculateWorld()
    {
        if(parentTransform !is null)
            worldTransform = (*parentTransform) * transform;
        else if(owner.parent !is null)
        {
            parentTransform = &owner.parent.getComponent!HipTransformComponent.worldTransform;
            worldTransform = (*parentTransform) * transform;
        }
        else
            worldTransform = transform;
    }

    Vector3 position(){return Vector3(transform[13], transform[14], transform[15]);}
    void setPosition(float x, float y, float z = 0){transform[13] = x; transform[14] = y; transform[15] = z;}
    Vector3 scale(){return Vector3(transform[0], transform[5], transform[10]);}
    void setScale(float x, float y, float z = 1){transform[0] = x; transform[5] = y; transform[10] = z;}
}