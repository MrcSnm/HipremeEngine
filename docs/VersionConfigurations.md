# Version Configurations for HipremeEngine

## HipremeEngine Specific versions

| Identifier | Behaviour | Requisites | Reference |
|:----------:|:---------:|:----------:|:---------:|
|**dll**| Compilation switch when needing to output a shared ibrary | None | None |
|**HIPREME_DEBUG**| Activates debug API such as D3D renderer debugging mode||
|**HipremeEngineLua**| Activates the lua script interpreter| bindbc-lua dependency | [How to use Lua from HipEngine]() |
|**HipAssets**| Activates asset manager and asset packer on the data module | data module | [Loading and Packing Assets]() |
|**HipJSON**| Activates the JSON/JSONC reader on the data module | data module | None |
|**FunctionArrayAvailable**| Activates function arrays on some classes, HipFS contains extra validations that depends on that feature | Function Array implementation | None |
|**HipCheckUnknownKeycode**| Will assert(false) when receving a key code that is not registered withing HpKey | None | [How to use Keyboard]() |
|**HipSDLImage**| HipSDLImage decoder, removal planned | bindbc-sdl | None |
|**HipARSDImage**| Use arsd.image as the implementation for the image decoder | arsd-official:image_files dependency | None |
|**HipGL3**| Uses the OpenGL3 implementation, making uniform buffer objects available | bindbc-opengl or gles dependency | None |
| | **API** | | 
|**HipGraphicsAPI**| Activates higher level implementations such as Sprite and Ninepatch | | [2D graphics api scripting reference]() |
|**HipInputAPI**| Activates scripting api for mouse, keyboard, gamepad and input mapping | May depend on the platform you're running | [How to use input API]() |
|**HipMathAPI**| Vector, forces formulas, collision, random | Add directly the math module | [Hip Math Reference]() |
|**HipTweenAPI**| Provides easing, tween sequence, parallel tween, properties interpolation | HipTimerAPI | [How to use Hip Tween]() |
|**HipTimerAPI**| Provides a timer for callbacks to be executed when the timer finishes or every tick | None | [How to use Hip Timer]() |
|**HipScriptingAPI**| Provides an API for hot loading scripting languages (including D scripting) | None | [Hip Scripting Reference]() |
|**HipDStdFile**| Uses D std.file module instead of core.stdc.stdio for file manipulation, which may be required for better interoperability, provides FileProgression | std.file implemented | [HipFS Module]()
