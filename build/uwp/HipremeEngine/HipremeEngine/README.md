
# HipremeEngine UWP Project

This project has the filters auto generated directly when dub is run for
UWP project.

For being victorious in debugging your UWP application, always check
the "Output" window. A lot of effort was done for making UWP debugging
easier.

In no time, that folder will be bloated with auto generated files from
Visual Studio. So, to make it a lot easier for development, UWPResources
folder was created for reflecting the "assets" folder from the parent
path.

## Troubleshooting UWP

- Q: **Where is my debug message?**
- R: Check on visual studio the output window

- Q: **Unable to activate Windows Store app 'XXX.YYYYYYYY_ZZZZZZZZApp'. The activation request failed with error 'Operation not supported. Unknown error: 0x8004090a'.**
- R: Check in your XBOX if you're signed in to your account.

- Q: **0x80070002 error while trying to launch a deployed game to XBox**
- R: Try remotely debugging it, your code probably threw an exception

- Q: **The HipremeEngine.exe process started, but the request failed with error 'Operation not supported. Unknown error: 0x80040905'**
- R: check the Output window, your program probably reached an `exit()`