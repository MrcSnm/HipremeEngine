module hip.graphics.g2d.particles;
import hip.math.vector;
import hip.api.graphics.color;

struct HipParticle
{
    Vector2 position;
    Vector2 velocity;
    Vector2 acceleration;
    Vector2 force;

    float lifeTime;
    float mass = 1.0;
    float invMass;

    this(float x, float y, float mass = 1.0f)
    {
        position = Vector2(x,y);
        velocity = Vector2.zero;
        acceleration = Vector2.zero;
        force = Vector2.zero;
        assert(mass != 0, "Mass can't be 0");
        this.mass = mass;
        invMass = 1.0/mass;
        lifeTime = 0;
    }

    void addForce(Vector2 force)
    {
        this.force+= force;
    }

    void update(float dt)
    {
        acceleration = force * invMass;
        velocity+= acceleration * dt;
        position+= velocity * dt;
        force = Vector2.zero;
    }

}
class HipParticleSystem
{
    HipParticle[] particles;
    uint active;

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

    void spawnParticles(uint count)
    {
        uint i = 0;
        uint newActive = active;
        ulong max = particles.length;
        while(i < count && newActive < max)
        {
            //Maybe here should have an initialize particle function
            newActive++;
            i++;
        }
    }

    void update(float dt)
    {
        for(uint i = 0; i < active; i++)
        {
            HipParticle* p = &particles[i];
            p.acceleration+= p.force * p.invMass * dt;
            p.velocity+= p.acceleration * dt;
            p.position+= p.velocity * dt;
            p.force = Vector2.zero;
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