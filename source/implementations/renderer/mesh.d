module implementations.renderer.mesh;
import implementations.renderer.shader;

class Mesh
{
    version(Android)
    {
        pragma(msg, "Android mesh is not yet supported, as the indices are unsigned int values, GL ES 2.0
Supports up to unsigned short");
    }
    protected uint[] indices;
    protected float[] vertices;
    protected Shader currentShader;
    ///Defines if it is going to use the indices array
    bool isVertexArray;
    ///Not yet supported
    bool isInstanced;

    this(bool isVertexArray)
    {
        this.isVertexArray = isVertexArray;
    }


    public void setIndices(ref uint[] indices)
    {
        this.indices = indices;
    }
    public void setVertices(ref float[] vertices)
    {
        this.vertices = vertices;
    }
    public void setShader(Shader s)
    {
        this.currentShader = s;
    }

    public void draw()
    {
        if(isVertexArray)
        {
            // HipRenderer.drawVertices()
        }
        //else if(isInstanced)
        /*
        {
            HipRenderer.drawInstanced()
        }
        */
        else
        {
            // HipRenderer.drawIndexed()
        }
    }


    
}