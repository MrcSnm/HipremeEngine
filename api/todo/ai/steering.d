
module ai.steering;
import std.math : cos, sin;
import math.random;
import math.utils;
public import math.utils : AxisNavigation;
public import math.vector;
Vector3 seek(Vector3 target, Vector3 position, float speed, float dt);
Vector3 seekAndStop(Vector3 target, Vector3 position, float speed, float dt);
Vector3 arrive(Vector3 target, Vector3 position, float slowdownFactor, float speed, float dt);
Vector3 pursuit(Vector3 target, Vector3 targetVelocity, Vector3 position, float speed, float dt, float predictionFactor = 1);
Vector3 flee(Vector3 target, Vector3 position, float speed, float dt);
Vector3 evade(Vector3 target, Vector3 targetVelocity, Vector3 position, float speed, float dt, float predictionFactor = 1);
enum WanderAxis 
{
	xy,
	yz,
	xz,
	zx,
	zy,
	yx,
}
Vector3 wander(Vector3 velocity, Vector3 displacement, float circleDistance, float circleRadius, ref float wanderAngle, float angleChangeFactor, float speed, float dt, AxisNavigation axis = AxisNavigation.xy);
struct PathFollowerStatus
{
	Vector3[] waypoints;
	uint currentWaypoint;
	this(Vector3[] waypoints)
	{
		this.waypoints = waypoints;
		currentWaypoint = 0;
	}
	pragma (inline, true)Vector3 getWaypoint();
	pragma (inline, true)bool hasFinished();
	pragma (inline, true)void checkAdvance(ref Vector3 pos, float range);
}
Vector3 pathFollow(Vector3 position, ref PathFollowerStatus status, float speed, float dt, float minRange = 0);
void flocking(Vector3 position, float perceptionRadius, ref Vector3 alignment, Vector3[] groupPosition, Vector3[] groupAlignment);
