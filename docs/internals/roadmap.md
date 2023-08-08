---
description: This is the general roadmap, next steps to be done in Hipreme Engine.
---

# Roadmap

* Examples are the best documentation one can get. No examples == no documentation

## Rendering

* Metal Depth Buffer
* Sprites alpha based sorting + rendering back to front
* Metal shadow buffering (when trying to write in a part of the buffer being used and the frame hasn't ended yet, the renderer should reference a different buffer to not overwrite), this feature is automatic on D3D11 and OpenGL.

## General

* Create a build tester for all platforms.

## Android

* Make update actually use delta time.

## AppleOS

* Make update actually use delta time.
* Find a way to use threads on asset loading (Problem was mutex wasn't being able to lock).
* Find a way to put assets on Xcode Project by using a script.
* DLL Support?

### PSVita

* Make update actually use delta time.

## Scene Graph:

Building a game without a scene graph is really hard. Implementing it is a real need for medium/big games. That will require:

* Base game object class which can enter on the graph
* TransformableObject
* RenderableObject
* SceneGraph serialization/deserialization

The strategy is still not very clear, but it is a care that will be taken for creating a consistent way to solve problems.

### GUI:

1. Building grounds

* Label
* Button
* RadioButton
* ToggleButton
* TextureButton
* LabelButton
* HorizontalScrollbar
* VerticalScrollbar
* Dialog

2. More involved widgets

* Console
* Message Dialog
* Open/Save File/Folder Dialog
* Folder View

3. Complex Widgets

* TreeView
* DropdownMenu
