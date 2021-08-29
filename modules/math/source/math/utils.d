module math.utils;

int getClosestMultiple(int from, int to)
{
    float temp = to/cast(float)from;
    int tempI = to/from;

    if(temp == tempI)
        return from * tempI;
    else
    {
        temp-= tempI;
        if(temp <= 0.5)
            return from*tempI;
        else
            return from*(tempI+1);
    }
}