/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module app;

import hip.internal_configuration : HasMain;
import hip.engine_runtime : arguments, HipremeMain;

static if(HasMain)
{
	export int main(string[] args)
	{
		arguments = args;
		import hip.console.log : setVerboseLogging;
		foreach(arg; args)
			if(arg == "--verbose")
				setVerboseLogging(true);
		int[2] windowSize = [-1, -1];
		version(WebAssembly)
		{
			import hip.windowing.platforms.browser;
			string[] _;
			windowSize = getWindowSize(null, _);
		}
		return HipremeMain(windowSize[0], windowSize[1]);
	}
	__gshared auto keepMain = &main;
}

version(UWP)
{
	import core.sys.windows.dll;
	mixin SimpleDllMain;

}

public import exportd;
import android_entry;
