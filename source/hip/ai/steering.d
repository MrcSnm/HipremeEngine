module hip.ai.steering;
import hip.math.random;
import hip.math.utils;
public import hip.math.utils:AxisNavigation;
public import hip.math.vector;

Vector3 seek(Vector3 target, Vector3 position, float speed, float dt)
{
    Vector3 dir = target-position;
    dir.normalize;
    return dir*speed*dt;
}
Vector3 seekAndStop(Vector3 target, Vector3 position, float speed, float dt)
{
    Vector3 dir = target-position;
    Vector3 velocity = dir;
    velocity.normalize;
    velocity*=speed*dt;

    if(velocity.mag > dir.mag)
        return dir;
    return velocity;
}


Vector3 arrive(Vector3 target, Vector3 position, float slowdownFactor, float speed, float dt)
{
    Vector3 dir = target-position;
    slowdownFactor = (dir.mag/slowdownFactor);
    dir.normalize;
    return dir*(speed*slowdownFactor*dt);
}


Vector3 pursuit(Vector3 target, Vector3 targetVelocity, Vector3 position, float speed, float dt, float predictionFactor = 1)
{
    Vector3 dir = (target+(targetVelocity*predictionFactor)) - position;
    dir.normalize;
    return dir*(speed*dt);
}

Vector3 flee(Vector3 target, Vector3 position, float speed, float dt)
{
    Vector3 dir = target-position;
    dir.normalize;
    return dir*(-speed*dt);
}

Vector3 evade(Vector3 target, Vector3 targetVelocity, Vector3 position, float speed, float dt,float predictionFactor = 1)
{
    Vector3 dir = (target+(targetVelocity*predictionFactor)) - position;
    dir.normalize;
    return dir*(-speed*dt);
}

enum WanderAxis
{
    xy, yz, xz, zx, zy, yx
}

Vector3 wander(
    Vector3 velocity,
    Vector3 displacement,
    float circleDistance,
    float circleRadius,
    ref float wanderAngle,
    float angleChangeFactor,
    float speed,
    float dt,
    AxisNavigation axis = AxisNavigation.xy
)
{
    Vector3 circle = velocity;
    circle.normalize;
    circle*= circleDistance;
    displacement.normalize;
    displacement*= circleRadius;

    wanderAngle+= Random.rangef(0, 2) * angleChangeFactor - angleChangeFactor*0.5f;
    displacement = toCircleBounds(displacement, wanderAngle, axis);

    Vector3 wanderForce = circle+displacement;

    return wanderForce * (speed*dt);
}

struct PathFollowerStatus
{
    Vector3[] waypoints;
    uint currentWaypoint;
    this(Vector3[] waypoints)
    {
        this.waypoints = waypoints;
        currentWaypoint = 0;
    }

    pragma(inline, true) Vector3 getWaypoint(){return waypoints[currentWaypoint];}
    pragma(inline, true) bool hasFinished(){return currentWaypoint >= waypoints.length;}
    pragma(inline, true) void checkAdvance(ref Vector3 pos, float range)
    {
        if(!hasFinished && getWaypoint.distance(pos) <= range)
        {
            currentWaypoint++;
        }
    }
}

Vector3 pathFollow(Vector3 position, ref PathFollowerStatus status, float speed, float dt, float minRange=0)
{
    status.checkAdvance(position, minRange);
    if(status.hasFinished)
        return Vector3.zero;
    return seekAndStop(status.getWaypoint, position, speed, dt);
}


//Incomplete
void flocking(
    Vector3 position, float perceptionRadius,
    ref Vector3 alignment,
    Vector3[] groupPosition, Vector3[] groupAlignment
)
{

    Vector3 alignmentSteering = Vector3.zero;
    ulong groupSize = 0;
    for(ulong i = 0; i < groupPosition.length; i++)
    {
        if(groupPosition[i] != position && position.distance(groupPosition[i]) <= perceptionRadius)
        {
            alignmentSteering = alignmentSteering + groupPosition[i];
            groupSize++;
        }
    }
    if(groupSize != 0)
    {
        alignmentSteering/= groupSize;
        alignment = alignment - alignmentSteering;
    }
    
}