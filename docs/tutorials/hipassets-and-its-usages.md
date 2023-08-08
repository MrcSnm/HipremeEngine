# HipAssets and its usages

Currently, the engine supports the following asset types:

* `IHipAudioClip` -> Required to play sounds, currently streamed is not supported, its implementation is minimal.
* `HipCSV` -> Load your excel file! This will be used to a future implementation on localization.
* `HipFontAsset` -> Can be both a `.ttf`, `.otf`, `.bmfont`. The renderer will know how to use.
* `Image` -> You'll almost never use that directly.
* `HipINI` -> Configuration file, good alternative to JSON.
* `HipJSONC` -> JSON with comments, follows almost all the `std.json` syntax.
* `HipTexture`/`IHipTexture` -> What you'll probably be using when dealing using `drawSprite`.
* `IHipTextureAtlas` -> You can get a HipTexture from it by using opIndex\[], `atlas["frameA"]`, accepts `.atlas`, `.json`, `.txt`(sprite sheet)
* `IHipTilemap` -> Accepts both ".tmx" and ".tmj" (Tiled format).
* `string` -> Yes you can load strings at runtime! Only `.txt` should be supported though.

## Loading Strategies

* loadAll
* ~~perScene~~

Currently only loadAll is supported since that is simply easier to get things done in the start. In the future, they may get a special UDA for whether `@Preload`ing them or not.

## Loading global assets

Global assets have a different strategy: They are loaded before they appear in a scene, for that, you use:

```d
@Asset("texts/shared.txt")
__gshared string myGlobalString;

@Asset("images/bomb.png")
__gshared IHipTexture bomb;
```

They are loaded before your game runs, so, they won't be null.

## Loading custom types

You can also load custom types with `@Asset`. You'll need to pass to the first parameter the path where your asset is, and for the second parameter a function pointer which returns your desired type (in this case JSON) and accepts a string argument:

```d
@Asset("texts/mytable.json", &parseJSON)
JSON myTable;
```

You can use that for any type required, all it needs to implement is the function `T parserFunc(T)(string content)`.

## Loading assets per scene

Assets are always loaded only once. The `preload()` function present over there actually only populates the `MyScene` instance members. The assets are already loaded by the time the scene is created. If there exists a `@Asset() __gshared` , this member will be populated at load time. Meaning there's no necessity to call `preload()`.

For loading the assets, you can use the following type of code:

```d

class MyScene : Scene, IHipPreloadable
{
import hip.api;
mixin Preload;

@Asset("images/bomb.png")
IHipTexture bomb;

@Asset("sounds/pop.wav")
IHipAudioClip pop;

@Asset("texts/gametext.txt")
string tutorial;

@Asset("texts/shared.txt")
__gshared string aGloballyLoadedString;

override void initialize()
{
  ///This call is required for assets that aren't `static` or `__gshared`. It expands to:
  preload();
  /*
  this.bomb     = HipAssetManager.get!IHipTexture("images/bomb.png");
  this.pop      = HipAssetManager.get!IHipAudioClip("sounds/pop.wav");
  this.tutorial = HipAssetManager.get!string("texts/gametext.txt");
  */
}
}
```
