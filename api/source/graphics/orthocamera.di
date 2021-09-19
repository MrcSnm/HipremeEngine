// D import file generated from 'source\graphics\orthocamera.d'
module graphics.orthocamera;
import hiprenderer.viewport;
import hiprenderer;
import math.matrix;
class HipOrthoCamera
{
	Matrix4 view;
	Matrix4 proj;
	Matrix4 viewProj;
	float znear = 0.001F;
	float zfar = 100.0F;
	this()
	{
		view = Matrix4.identity;
		Viewport v = HipRenderer.getCurrentViewport();
		proj = Matrix4.orthoLH(v.x, v.w, v.h, v.y, znear, zfar);
	}
	void translate(float x, float y, float z);
	void setScale(float x, float y, float z = 1);
	void scale(float x, float y, float z = 0);
	void setPosition(float x, float y, float z = 0);
	pragma (inline, true)@property float x();
	pragma (inline, true)@property float y();
	pragma (inline, true)@property float z();
	void update();
}
