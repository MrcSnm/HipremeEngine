/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module util.libinfos;
import bindbc.openal;
import bindbc.freeimage;
import implementations.renderer.backend.gl.renderer;
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
	version(Android){}
	else{
		if(!isOpenGLLoaded())
		{
			rawlog("OpenGL is not loaded for being able to show info!");
			return;
		}
	}
	rawlog!`OpenGL Infos:
    Vendor:   %s
    Renderer: %s
    Version:  %s`(to!string(glGetString(GL_VENDOR)),
    to!string(glGetString(GL_RENDERER)),
    to!string(glGetString(GL_VERSION)));
}

void show_FreeImage_info()
{
	string ver = to!string(FreeImage_GetVersion());
	rawlog("libFreeImage version: ", ver,"\n", to!string(FreeImage_GetCopyrightMessage()));
}