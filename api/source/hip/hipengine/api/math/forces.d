module hip.hipengine.api.math.forces;


version(HipMathAPI):
version(none):
import hip.hipengine.api.math.vector;

struct Forces
{
    @disable this();
    @nogc @safe nothrow
    {

        public static Vector2 dragForce(in Vector2 vel, float howMuch){return -vel.unit * howMuch * vel.magSquare;}
        public static Vector3 dragForce(in Vector3 vel, float howMuch){return -vel.unit * howMuch * vel.magSquare;}

        public static Vector2 frictionForce(in Vector2 vel, float howMuch){return howMuch * -vel.unit;}
        public static Vector3 frictionForce(in Vector3 vel, float howMuch){return howMuch * -vel.unit;}

        public static Vector2 gravitationalForce(in Vector2 posA, in Vector2 posB, float massA, float massB, float howMuch)
        {
            Vector2 vecDistance = (posB - posA);
            Vector2 dir = vecDistance.unit;
            return howMuch * ((massA * massB) / vecDistance.magSquare) * dir;
        }

        public static Vector3 gravitationalForce(in Vector3 posA, in Vector3 posB, float massA, float massB, float howMuch)
        {
            Vector3 vecDistance = (posB - posA);
            Vector3 dir = vecDistance.unit;
            return howMuch * ((massA * massB) / vecDistance.magSquare) * dir;
        }

        public static Vector2 springForce(in Vector2 anchor, in Vector2 displacement, float springLength,  float howMuch)
        {
            Vector2 movement = (displacement - anchor);
            float displacementForce = movement.mag - springLength;
            //-k * deltaL
            return (displacementForce * -howMuch) * movement.unit;
        }

        public static Vector3 springForce(in Vector3 anchor, in Vector3 displacement, float springLength,  float howMuch)
        {
            Vector3 movement = (displacement - anchor);
            float displacementForce = movement.mag - springLength;
            movement.normalize;
            //-k * deltaL
            return (displacementForce * -howMuch) * movement;
        }
    }
}