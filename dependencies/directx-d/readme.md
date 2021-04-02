# DirectX bindings for D language.

___
## Running samples:

Open sample folder in terminal *(a quick way is to shift-RMB in that folder in explorer and choose open command window)* 
and simply type :

__`dub run --arch=x86_64`__

or since dub v1.2 for MS-COFF linker 'arch'

__`dub run --arch=x86_mscoff`__

or for x86

__`dub run`__ 



&nbsp;

Some samples may require using Windows8 config if you are on Windows 8 or Windows 10, if you see related linker errors just specify that config in build:

__`dub run --arch=x86_64 --config=Windows8`__



&nbsp;



___
### Disclaimer:

*Keep in mind that this bindings is still far from ideal, any changes may broke API. It requires a lot of commitment to be finally finished, and one can find something that is not there yet from C++.*

Any questions on [dlang.org forum thread](http://forum.dlang.org/thread/cbjjmigmqpfxbmxwrmru@forum.dlang.org)


&nbsp;


___
### How to contribute:

Found an error? Got "access violation"? Simply open an issue!

There is also a lot of broken things around in code, just search the sources for `"FIXME:"` and `"TODO:"`

&nbsp;


Pull requests are welcome!

&nbsp;


___
#### License:
*MIT License*

