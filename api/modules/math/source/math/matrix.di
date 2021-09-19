// D import file generated from 'source\math\matrix.d'
module math.matrix;
import core.math;
enum MatrixType 
{
	COLUMN_MAJOR,
	ROW_MAJOR,
}
struct Matrix3
{
	float[9] values;
	pragma (inline, true)static Matrix3 translation(float x, float y);
	Matrix3 translate(float x, float y);
	Matrix3 scale(float x, float y);
	Matrix3 transpose();
	static Matrix3 rotation(float radians);
	Matrix3 rotate(float radians);
	const Matrix3 opBinary(string op, R)(const R rhs)
	{
		Matrix3 ret;
		ret.values = this.values;
		static if (op == "*")
		{
			static if (is(R == float))
			{
				ret[] *= rhs;
			}
			else
			{
				for (uint i = 0;
				 i < 9; i += 3)
				{
					{
						ret[i] = values[i] * rhs[0] + values[i + 1] * rhs[3] + values[i + 2] * rhs[6];
						ret[i + 1] = values[i] * rhs[1] + values[i + 1] * rhs[4] + values[i + 2] * rhs[7];
						ret[i + 2] = values[i] * rhs[2] + values[i + 1] * rhs[5] + values[i + 2] * rhs[8];
					}
				}
			}
		}
		else
		{
			static if (op == "+")
			{
				foreach (i, v; values)
				{
					ret[i] += rhs[i];
				}
			}
			else
			{
				static if (op == "-")
				{
					foreach (i, v; values)
					{
						ret[i] -= rhs[i];
					}
				}
				else
				{
					static if (op == "/")
					{
						static if (is(R == float))
						{
							ret[] /= rhs;
						}

					}

				}
			}
		}
		return ret;
	}
	string toString();
	const T opCast(T)()
	{
		static assert(is(T == float[9]), "Matrix3 can only be cast to float[9]");
		return values;
	}
	alias values this;
}
struct Matrix4
{
	float[16] values;
	static Matrix4 identity();
	pragma (inline, true)static Matrix4 translation(float x, float y, float z);
	Matrix4 translate(float x, float y, float z);
	static Matrix4 createScale(float x, float y, float z);
	Matrix4 scale(float x, float y, float z);
	Matrix4 transpose();
	static Matrix4 rotationX(float radians);
	static Matrix4 rotationY(float radians);
	static Matrix4 rotationZ(float radians);
	Matrix4 rotate(float x_angle, float y_angle, float z_angle);
	const Matrix4 opBinary(string op, R)(const R rhs)
	{
		Matrix4 ret;
		ret.values = this.values;
		static if (op == "*")
		{
			static if (is(R == float))
			{
				ret[] *= rhs;
			}
			else
			{
				for (uint i = 0;
				 i < 16; i += 4)
				{
					{
						ret[i] = values[i] * rhs[0] + values[i + 1] * rhs[4] + values[i + 2] * rhs[8] + values[i + 3] * rhs[12];
						ret[i + 1] = values[i] * rhs[1] + values[i + 1] * rhs[5] + values[i + 2] * rhs[9] + values[i + 3] * rhs[13];
						ret[i + 2] = values[i] * rhs[2] + values[i + 1] * rhs[6] + values[i + 2] * rhs[10] + values[i + 3] * rhs[14];
						ret[i + 3] = values[i] * rhs[3] + values[i + 1] * rhs[7] + values[i + 2] * rhs[11] + values[i + 3] * rhs[15];
					}
				}
			}
		}
		else
		{
			static if (op == "+")
			{
				foreach (i, v; values)
				{
					ret[i] += rhs[i];
				}
			}
			else
			{
				static if (op == "-")
				{
					foreach (i, v; values)
					{
						ret[i] -= rhs[i];
					}
				}
				else
				{
					static if (op == "/")
					{
						static assert(is(R == float), "Only float is valid for matrix division");
						ret[] /= rhs;
					}

				}
			}
		}
		return ret;
	}
	static Matrix4 orthoLH(float left, float right, float bottom, float top, float znear, float zfar);
	static Matrix4 alternateHandedness(Matrix4 mat);
	string toString();
	alias values this;
}
