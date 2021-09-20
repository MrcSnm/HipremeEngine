module hipengine.api.graphics.g2d.hipsprite;
public import hipengine.api.graphics.color;

interface IHipSprite
{
    void setPosition(float x, float y);
    void setScale(float x, float y);
    void setColor(HipColor color);
    void setRotation(float rotation);
    void setScroll(float x, float y);
    void setRegion(float x1, float y1, float x2, float y2);
}