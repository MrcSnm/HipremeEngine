module components.transform;

import systems.gameobject;
import math.matrix;
import math.vector;

class HipTransformComponent : HipComponent
{
    Matrix4 transform;

    override void onStart(){}
    override void onRemove(){}
    override void update(float deltaTime){}


    Vector3 position(){return Vector3(transform[13], transform[14], transform[15]);}
    Vector3 scale(){return Vector3(transform[0], transform[5], transform[10]);}
}