module hip.graphics.g2d.particles;
import hip.math.vector;
import hip.api.graphics.color;

struct HipParticle
{
    Vector2 initPosition;
    Vector2 initVelocity;
    Vector2 initAcceleration;
    float initAngle = 0;
    float initScale = 0;
    float timeStamp = 0;
}
struct ValueRange
{
    float min = 0, max = 0;

    float rnd()
    {
        import hip.math.random;
        return Random.rangef(min, max);
    }
}

struct HipParticleSystemConfig
{
    ///Means a variating initial value (random)
    
    ValueRange scaleInit = ValueRange(1,1);
    ValueRange scaleEnd = ValueRange(0,0);
    ValueRange velocityXInit = ValueRange(0,0);
    ValueRange velocityYInit = ValueRange(0,0);
    ///In which angle will apply the acceleration
    ValueRange angleInit = ValueRange(0,0);

    ValueRange accelerationXInit = ValueRange(0,0);
    ValueRange accelerationYInit = ValueRange(0,0);

    ///In which rotation will init.
    ValueRange rotationInit = ValueRange(0,0);
    ///Default color stop is to go from opaque white to transparent white.
    immutable DefaultParticleColorStops = [HipColorStop(HipColor.white, 0), HipColorStop(HipColor(255,255,255,0), 1)];

    HipColorStop[] colors = DefaultParticleColorStops;
    float lifeTime = 2.0;
}

/** 
 * 2D Particle System 
 */
class HipParticleSystem
{
    HipParticle[] particles;
    HipParticleSystemConfig config;
    float currentTime = 0;
    ///How many particles to spawn per second.
    float emissionRate = 200;
    ///Will never spawn more than that value
    uint maxActive = 500;
    ///Stores how many particles to spawn, accumulates when not integer.
    protected float spawnAccumulator = 0;
    ///Particles to iterate
    protected uint active;

    this(uint maxParticles)
    {
        particles = new HipParticle[](maxParticles);
        active = 0;
    }

    protected void killParticle(uint id)
    {
        assert(id < particles.length, "Particle out of range");
        HipParticle temp = particles[id];
        --active;
        particles[id] = particles[active];
        particles[active] = temp;   
    }

    struct EmissionZone
    {
        ValueRange x, y;
    }
    EmissionZone emissionZone;

    void setEmissionZone(int minX, int maxX, int minY, int maxY)
    {
        emissionZone =  EmissionZone(ValueRange(minX, maxX), ValueRange(minY, maxY));
    }

    void spawnParticles(uint count)
    {
        uint i = 0;
        uint newActive = active;
        ulong max = particles.length;
        while(i < count && newActive < max)
        {
            //Maybe here should have an initialize particle function

            particles[newActive] = HipParticle(
                Vector2(emissionZone.x.rnd, emissionZone.y.rnd), 
                Vector2(config.velocityXInit.rnd, config.velocityYInit.rnd),
                Vector2(config.accelerationXInit.rnd, config.accelerationYInit.rnd),
                config.angleInit.rnd(),
                config.scaleInit.rnd(),
                currentTime
            );
            newActive++;
            i++;
        }

        active = newActive;
    }

    void update(float dt)
    {
        currentTime+= dt;
        uint currActive = active;
        for(uint i = 0; i < currActive; i++)
        {
            HipParticle* p = &particles[i];
            if(currentTime - p.timeStamp >= config.lifeTime)
                killParticle(i);
        }
        spawnAccumulator+= dt*emissionRate;
        spawnParticles(cast(uint)spawnAccumulator);
        spawnAccumulator-= cast(uint)spawnAccumulator;
    }

    void draw()
    {
        import hip.graphics.g2d.renderer2d;
        import hip.math.utils;
        float invLifetime = 1.0f / config.lifeTime;
        for(uint i = 0; i < active; i++)
        {
            HipParticle* p = &particles[i];
            float t = (currentTime - p.timeStamp) * invLifetime;

            Vector2 partPos = p.initPosition + p.initVelocity*t + p.initAcceleration*0.5*t*t;
            HipColor partColor = config.colors.gradientColor(t);

            float scale = lerp(p.initScale, config.scaleEnd.max, t);
            drawTexture(null, cast(int)partPos.x, cast(int)partPos.y, 0, partColor, scale, scale);
        }
    }
}   


class HipParticleSystemDOD
{
    float[] accelerations;
    float[] velocities;
    float[] positions;
    HipColor[] colors;

}