module util.libinfos;
import bindbc.openal;
import bindbc.opengl;
import def.debugging.log;
import core.stdc.string:strlen;
import std.conv:to;

void list_audio_devices(const ALCchar *devices)
{
	const(char)* device = devices;
	const(char)* next = devices + 1;
	size_t len = 0;

	rawlog("Devices list:\n");
	rawlog("----------\n");
	while (device && *device != '\0' && next && *next != '\0') 
	{
		rawlog!"%s\n"(to!string(device));
		len = strlen(device);
		device += (len + 1);
		next += (len + 2);
	}
	rawlog("----------\n");
}

void show_opengl_info()
{
    if(!isOpenGLLoaded())
    {
        rawlog("OpenGL is not loaded for being able to show info!");
    }
    else
        rawlog!`OpenGL Infos:
    Vendor:   %s
    Renderer: %s
    Version:  %s`(to!string(glGetString(GL_VENDOR)),
    to!string(glGetString(GL_RENDERER)),
    to!string(glGetString(GL_VERSION)));
}