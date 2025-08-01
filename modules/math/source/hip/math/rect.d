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
    float x = 0, y = 0, width = 0, height = 0;
    alias w = width, h = height;

    Vector2 position() const {return Vector2(x,y);}
    Size size() const {return Size(cast(uint)w,cast(uint)h);}


    void move(in float[2] vec){this.x+= vec[0];this.y+= vec[1];}
    void move(in Vector2 vec){this.x+= vec[0];this.y+= vec[1];}
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