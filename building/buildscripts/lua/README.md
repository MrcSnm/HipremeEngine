## Lua Support

For building lua to the Hipreme Engine, just execute the following:

curl -R -O http://www.lua.org/ftp/lua-5.4.3.tar.gz
tar zxf lua-5.4.3.tar.gz

### Rename
    > Linux: mv lua-5.4.3 lua 
    > Windows: rename lua-5.4.3 lua

### Remove
    > Linux: rm *.gz
    > Windows: del /f *.gz

cd lua
cd src

Now remove the terminal program and the lua compiler

### Remove
    > Linux: rm lua.c luac.c
    > Windows: del /f lua.c luac.c


Windows may require Microsoft Visual Studio, which is a great toll for only building lua.
Lua may then be saved on this repo prebuilt.