
module hiprenderer.viewport;
import hiprenderer.renderer;
import math.vector;
import math.scaling;
import bindbc.sdl;
public class Viewport
{
	SDL_Rect bounds;
	this(){}
	this(int x, int y, uint width, uint height)
	{
		this.setBounds(x, y, width, height);
	}
	void setAsCurrentViewport();
	void setPosition(int x, int y);
	void setBounds(int x, int y, uint width, uint height);
	void update();
	void setSize(uint width, uint height);
	alias bounds this;
}
public class FitViewport : Viewport
{
	uint worldWidth;
	uint worldHeight;
	this(int x, int y, uint worldWidth, uint worldHeight)
	{
		super();
		this.setSize(worldWidth, worldHeight);
	}
	this(int worldWidth, int worldHeight)
	{
		this(0, 0, worldWidth, worldHeight);
	}
	override void setSize(uint width, uint height);
}
