@REM Linux Toolchain: https://sysprogs.com/getfile/1253/ubuntu-gcc9.3.0.exe direct from https://gnutoolchains.com/ubuntu/


@REM mkdir release
@REM dub build && move build_selector.exe release/win64-build_selector.exe
@REM dub build -a=x86_64-apple-darwin && move build_selector.exe release/osx64-build_selector.exe
@REM dub build -a=x86_64-linux-gnu && move build_selector.exe release/linux64-build_selector.exe