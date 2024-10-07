@REM Linux Toolchain: https://sysprogs.com/getfile/1253/ubuntu-gcc9.3.0.exe direct from https://gnutoolchains.com/ubuntu/


@REM mkdir release
@REM dub build && move hbuild.exe release/win64-hbuild.exe
@REM dub build -a=x86_64-apple-darwin && move hbuild.exe release/osx64-hbuild.exe
@REM dub build -a=x86_64-linux-gnu && move hbuild.exe release/linux64-hbuild.exe