module view.chaintest;
import hiprenderer.renderer;
import hipengine;
import console.log;
import hipengine.api.math.forces;

import math.vector;
import view.scene;
import graphics.g2d.renderer2d;
import graphics.g2d.particles;
import util.conv;

class DConsole
{

    public void render()
    {
        drawRectangle(0, 0, HipRenderer.width, 400);
        
    }
}

class ChainTestScene : Scene
{
    HipParticle[] particles;
    Vector2[] anchors;
    this()
    {
        for(int i = 0; i < 10; i++)        
        {
            particles~= HipParticle(HipRenderer.width/4, 20*(i+1));
            anchors~= particles[i].position;
        }

    }

    override void render()
    {
        setGeometryColor(HipColor.white);
        foreach(p; particles)
        {
            drawEllipse(
                cast(int)p.position.x,
                cast(int)p.position.y,
            5, 5);
        }

        setGeometryColor(HipColor.yellow);
        for(int i = 1; i < cast(int)particles.length; i++)
        {
            drawLine(
                cast(int)particles[i-1].position.x,
                cast(int)particles[i-1].position.y,
                cast(int)particles[i].position.x,
                cast(int)particles[i].position.y
            );
        }
        
        endGeometry();
    }

    override void update(float dt)
    {
        float springiness = 2000;
        float springLength = 50;

        if(HipInput.isKeyPressed(' '))// foreach(ref p; particles)
        {
            //Weight
            HipParticle* p = &particles[$-1];
            p.addForce(Vector2(400, 0));
        }

        particles[0].addForce(Vector2(0, particles[0].mass));

        foreach(ref p; particles) 
        {
            p.addForce(Forces.dragForce(p.velocity, 0.01));
            p.addForce(Vector2(0, 9.8)); //Apply weight force
        }
        Vector2 firstForce = Forces.springForce(anchors[0], particles[0].position, springLength, springiness);
        particles[0].addForce(firstForce);

        for(int i = 1; i < particles.length; i++)
        {
            Vector2 spForce = Forces.springForce(particles[i-1].position,
            particles[i].position, springLength, springiness);

            particles[i-1].addForce(-spForce);
            particles[i].addForce(spForce);
        }

        foreach(ref p;particles)
            p.update(dt);

        
    }
}