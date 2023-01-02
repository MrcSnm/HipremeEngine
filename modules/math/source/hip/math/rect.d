/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.math.rect;
public import hip.math.vector;

struct Size
{
    pure nothrow @nogc @safe:
    uint width, height;
    alias w = width, h = height;

    Vector2 opCast() const { return Vector2(w, h);}
}
struct Rect
{
    pure nothrow @nogc @safe:
    float x, y, width, height;
    alias w = width, h = height;

    Vector2 position() const {return Vector2(x,y);}
    Size size() const {return Size(cast(uint)w,cast(uint)h);}


    void move(in float[2] vec){this.x+= vec[0];this.y+= vec[1];}
    void move(in Vector2 vec){this.x+= vec[0];this.y+= vec[1];}

    this(float x, float y, float w, float h){this.x=x;this.y=y;this.w=w;this.h=h;}
    this(float[2] position, float w, float h){this(position[0], position[1], w, h);}
    this(float[2] position, float[2] size){this(position[0], position[1], size[0], size[1]);}
    this(float[2] position, Size size){this(position[0], position[1], size.w, size.h);}
    this(float[4] rec){this(rec[0], rec[1], rec[2], rec[3]);}

    this(int x, int y, int w, int h){this.x=x;this.y=y;this.w=w;this.h=h;}
    this(int[2] position, int, int w, int h){this(position[0], position[1], w, h);}
    this(int[2] position, int[2] size){this(position[0], position[1], size[0], size[1]);}
    this(int[2] position, Size size){this(position[0], position[1], size.w, size.h);}
    this(int[4] rec){this(rec[0], rec[1], rec[2], rec[3]);}

    this(float[2] position, int w, int h){this(position[0], position[1], w, h);}
    this(float[2] position, int[2] size){this(position[0], position[1], size[0], size[1]);}

    this(int[2] position, float w, float h){this(position[0], position[1], w, h);}
    this(int[2] position, float[2] size){this(position[0], position[1], size[0], size[1]);}
}

struct DynamicRect
{
    pure nothrow @nogc @safe:
    Rect rect;
    Vector2 velocity;
    Vector2 position() const {return Vector2(rect.x,rect.y);}
    Size size() const {return Size(cast(uint)rect.w,cast(uint)rect.h);}
    void move(in float[2] vec){rect.x+= vec[0];rect.y+= vec[1];}
    void move(in Vector2 vec){rect.x+= vec[0];rect.y+= vec[1];}

}