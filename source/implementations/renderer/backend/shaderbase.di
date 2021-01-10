/**
*   This file was made only as a way to document how the shaders should impl should be declared
*/
module implementations.renderer.shaderimpl.shaderbase;

struct FragmentShader;
struct VertexShader;
struct ShaderProgram;

enum DEFAULT_FRAGMENT;
enum DEFAULT_VERTEX;

FragmentShader createFragmentShader();
VertexShader createVertexShader();
ShaderProgram createShaderProgram();

bool compileShader(VertexShader vs, string shaderSource);
bool compileShader(FragmentShader fs, string shaderSource);
bool linkProgram(ShaderProgram program, VertexShader vs,  FragmentShader fs);

void useShader(ShaderProgram program);
void deleteShader(FragmentShader* fs);
void deleteShader(VertexShader* vs);