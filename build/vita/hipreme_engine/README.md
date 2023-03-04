# hello_world_vita_d
Hipreme Engine port for the Vita SDK.

Details into setting up vita sdk on: https://vitasdk.org/

You'll need the VitaSDK in your path. This process could be automatized in future.

## Generating a build for Vita

You'll need to create a folder "assets" in the same folder this README is located. It will be packaged to vita.
After that, you can run `./build.sh`. Which you will probably need to modify to get your PS Vita IP Address (The data is sent via CURL).


Install the .vpk file, after that, you'll be using from Hipreme Engine root folder `vitarun.sh`. Which will only transfer the binary data required to run your game. That way there won't be any need to install it again.
