# Game 2D Module

This is a module which is WIP. It currently provides some useful functionalities such as:

### hip.component

This module is overall under construction and should be avoided. This will be a deciding point on the engine over doing an Actor vs Component based.

### hip.game2d

The naming convention is not yet decided. The module name itself is subject to be thought.

* HipSprite: Sprite wrapped as an object. May provide more feature than API
* HipText: Text wrapped as an object. May provide more feature than API
* ThreePatch: A specialized nine patch which only render 3 sprites. May be deprecated in the future.
* NinePatch: A way to render scalable textures without losing fidelity.
* TileWorld (WIP): Owns a game world which contains both static and dynamic objects. It handles the objects not being able to penetrate each other by modifying their speed, has gravity or constant gravity. It's update function is `@nogc` and that requirement won't change over time.

### hip.gui

(WIP). Although there is a bunch of things working, the GUI is being designed to be used for both the engine and for games. So, it may change a little bit in the future

#### Main modules

* Widget: Base class for every GUI object.
* Screen: Holds every GUI object and manage its events (such as the cascade effect), drag'n drop event, focus, and selection detection.

#### Widgets

* Label
* LinearLayout
* GridLayout
* ScrollArea
* Button
