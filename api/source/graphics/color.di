// D import file generated from 'source\graphics\color.d'
module graphics.color;
struct HipColor
{
	float r = 0;
	float g = 0;
	float b = 0;
	float a = 0;
	this(float r, float g, float b, float a)
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}
	static HipColor fromInt(int color);
	static enum white = HipColor(1, 1, 1, 1);
	static enum black = HipColor(0, 0, 0, 0);
	static enum red = HipColor(1, 0, 0, 1);
	static enum green = HipColor(0, 1, 0, 1);
	static enum blue = HipColor(0, 0, 1, 1);
	static enum yellow = HipColor(1, 1, 0, 1);
	static enum purple = HipColor(1, 0, 1, 1);
	static enum teal = HipColor(0, 1, 1, 1);
}
