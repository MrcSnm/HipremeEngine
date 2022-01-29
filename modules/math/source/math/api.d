module math.api;

mixin template ExportMathAPI()
{
    import math.vector;
    import math.random;

    // export extern(C) float dot(ref Vector2 first, Vector2 other){return first.dot(other);}
    // export extern(C) float mag(ref Vector2 first){return first.mag;}
    // export extern(C) void normalize(ref Vector2 first){return first.normalize;}
    // export extern(C) Vector2 unit(ref Vector2 first){return first.unit;}
    // export extern(C) Vector2 project(ref Vector2 first, Vector2 other){return first.project(other);}
    // export extern(C) Vector2 rotate(ref Vector2 first, float radians){return first.rotate(radians);}


    //     //Vector3
    // export extern(C) float dot_3(ref Vector3 first, Vector3 other){return first.dot(other);}
    // export extern(C) float mag_3(ref Vector3 first){return first.mag;}
    // export extern(C) void normalize_3(ref Vector3 first){first.normalize;}
    // export extern(C) float distance_3(ref Vector3 first, Vector3 other){return first.distance(other);}
    // export extern(C) Vector3 unit_3(ref Vector3 first){return first.unit;}
    // export extern(C) Vector3 rotateZ_3(ref Vector3 first, float radians){return first.rotateZ(radians);}
    // export extern(C) Vector3 project_3(ref Vector3 first, Vector3 other){return first.project(other);}
    // export extern(C) Vector3 axisAngle(ref Vector3 first, Vector3 other, float angle){return first.axisAngle(other, angle);}
    // export extern(C) Vector3 cross(ref Vector3 first, Vector3 other){return first.cross(other);}

    //     //Vector4
    // export extern(C) float dot_4(ref Vector4 first, Vector4 other){return first.dot(other);}
    // export extern(C) float mag_4(ref Vector4 first){return first.mag;}
    // export extern(C) void normalize_4(ref Vector4 first){return first.normalize;}
    // export extern(C) Vector4 unit_4(ref Vector4 first){return first.unit;}
    // export extern(C) Vector4 project_4(ref Vector4 first, Vector4 other){return first.project(other);}

    // export extern(C) int range(int min, int max){return Random.range(min,max);}
    // export extern(C) uint rangeu(uint min, uint max){return Random.rangeu(min,max);}
    // export extern(C) ubyte rangeub(ubyte min, ubyte max){return Random.rangeub(min,max);}
    // export extern(C) float rangef(float min, float max){return Random.rangef(min,max);}
}