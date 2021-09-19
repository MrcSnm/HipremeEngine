// D import file generated from 'source\math\vector.d'
module math.vector;
import core.math : sqrt, sin, cos;
public struct Vector2
{
	this(float x, float y)
	{
		values = [x, y];
	}
	this(float[2] v)
	{
		values = [v[0], v[1]];
	}
	Vector2 opIndexUnary(string op)(size_t index)
	{
		static if (op == "-")
		{
			return Vector(-values[0], -values[1]);
		}

		return this;
	}
	const float dot()(auto ref Vector2 other)
	{
		return values[0] * other[0] + values[1] * other[1];
	}
	const float mag();
	void normalize();
	const Vector2 unit();
	const Vector2 project(ref Vector2 reference);
	static float dot(ref Vector2 first, ref Vector2 second);
	Vector2 rotate(float radians);
	auto const opBinary(string op)(auto ref Vector2 rhs)
	{
		static if (op == "+")
		{
			return Vector2(values[0] + rhs[0], values[1] + rhs[1]);
		}
		else
		{
			static if (op == "-")
			{
				return Vector2(values[0] - rhs[0], values[1] - rhs[1]);
			}
			else
			{
				static if (op == "*")
				{
					return dot(rhs);
				}

			}
		}
	}
	auto const opBinary(string op)(auto ref float rhs)
	{
		mixin("return Vector2(values[0] " ~ op ~ "rhs , values[1] " ~ op ~ "rhs);");
	}
	float opIndexAssign(float value, size_t index);
	ref Vector2 opAssign(Vector2 other) return;
	static Vector2 zero();
	private float[2] values;
	scope ref float x() return;
	scope ref float y() return;
	ref float opIndex(size_t index) return;
}
public struct Vector3
{
	this(float x, float y, float z)
	{
		values = [x, y, z];
	}
	this(float[3] v)
	{
		values = [v[0], v[1], v[2]];
	}
	Vector3 opIndexUnary(string op)(size_t index)
	{
		static if (op == "-")
		{
			return Vector(-values[0], -values[1], -values[2]);
		}

		return this;
	}
	const float dot()(auto ref Vector3 other)
	{
		return values[0] * other[0] + values[1] * other[1] + values[2] * other[2];
	}
	const float mag();
	void normalize();
	float distance(Vector3 other);
	const Vector3 unit();
	const Vector3 project(ref Vector3 reference);
	pragma (inline, true)auto axisAngle(ref const Vector3 axis, float angle)
	{
		auto n = axis.unit;
		auto proj = n * axis.dot(n);
		auto perpendicular = this - proj;
		auto rot = perpendicular * cos(angle) + n.cross(perpendicular) * sin(angle);
		return proj + rot;
	}
	const Vector3 cross(ref Vector3 other);
	static float Dot(ref Vector3 first, ref Vector3 second);
	Vector3 rotateZ(float radians);
	auto const opBinary(string op)(auto ref Vector3 rhs)
	{
		static if (op == "+")
		{
			return Vector3(values[0] + rhs[0], values[1] + rhs[1], values[2] + rhs[2]);
		}
		else
		{
			static if (op == "-")
			{
				return Vector3(values[0] - rhs[0], values[1] - rhs[1], values[2] - rhs[2]);
			}
			else
			{
				static if (op == "*")
				{
					return dot(rhs);
				}

			}
		}
	}
	const Vector3 opBinary(string op, T)(auto ref T rhs)
	{
		mixin("return Vector3(values[0] " ~ op ~ "rhs , values[1] " ~ op ~ "rhs, values[2] " ~ op ~ "rhs);");
	}
	const Vector3 opBinaryRight(string op, T)(auto ref T lhs)
	{
		mixin("return Vector3(values[0] " ~ op ~ "rhs , values[1] " ~ op ~ "rhs, values[2] " ~ op ~ "rhs);");
	}
	auto opOpAssign(string op, T)(T value)
	{
		mixin("this.x" ~ op ~ "= value;");
		mixin("this.y" ~ op ~ "= value;");
		mixin("this.z" ~ op ~ "= value;");
		return this;
	}
	float opIndexAssign(float value, size_t index);
	ref Vector3 opAssign(Vector3 other) return;
	ref Vector3 opAssign(float[3] other) return;
	static Vector3 Zero();
	private float[3] values;
	scope ref float x() return;
	scope ref float y() return;
	scope ref float z() return;
	ref float opIndex(size_t index) return;
}
public struct Vector4
{
	this(float x, float y, float z, float w)
	{
		values = [x, y, z, w];
	}
	this(float[4] v)
	{
		values = [v[0], v[1], v[2], v[3]];
	}
	Vector3 opIndexUnary(string op)(size_t index)
	{
		static if (op == "-")
		{
			return Vector(-values[0], -values[1], -values[2], -values[3]);
		}

		return this;
	}
	const float dot()(auto ref Vector4 other)
	{
		return values[0] * other[0] + values[1] * other[1] + values[2] * other[2] + values[3] * other[3];
	}
	const float mag();
	void normalize();
	const Vector4 unit();
	const Vector4 project(ref Vector4 reference);
	static float Dot(ref Vector3 first, ref Vector3 second);
	auto const opBinary(string op)(auto ref Vector3 rhs)
	{
		static if (op == "+")
		{
			return Vector4(values[0] + rhs[0], values[1] + rhs[1], values[2] + rhs[2], values[3] + rhs[3]);
		}
		else
		{
			static if (op == "-")
			{
				return Vector4(values[0] - rhs[0], values[1] - rhs[1], values[2] - rhs[2], values[3] - rhs[3]);
			}
			else
			{
				static if (op == "*")
				{
					return dot(rhs);
				}

			}
		}
	}
	auto const opBinary(string op)(auto ref float rhs)
	{
		mixin("return Vector4(values[0] " ~ op ~ "rhs,\x0a        values[1] " ~ op ~ "rhs,\x0a        values[2] " ~ op ~ "rhs,\x0a        values[3] " ~ op ~ "rhs);");
	}
	float opIndexAssign(float value, size_t index);
	ref Vector4 opAssign(Vector4 other) return;
	ref Vector4 opAssign(float[4] other) return;
	static Vector4 Zero();
	private float[4] values;
	scope ref float x() return;
	scope ref float y() return;
	scope ref float z() return;
	scope ref float w() return;
	ref float opIndex(size_t index) return;
}
