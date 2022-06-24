# Assets Management

Assets management still need to have their interface more standardized, for handling both sync and async loading operations, controlled by both a variable and a version statement (for platforms which does not support threading).

## Scene Graph:

Building a game without a scene graph is really hard. Implementing it is a real need for medium/big games. That will require:

- Base game object class which can enter on the graph
- TransformableObject
- RenderableObject
- SceneGraph serialization/deserialization

The strategy is still not very clear, but it is a care that will be taken for creating a consistent way to solve problems.


### GUI:

1. Building grounds
- Label
- Button
- RadioButton
- ToggleButton
- TextureButton
- LabelButton
- HorizontalScrollbar
- VerticalScrollbar
- Dialog


2. More involved widgets
- Console
- Message Dialog
- Open/Save File/Folder Dialog
- Folder View

3. Complex Widgets

- TreeView
- DropdownMenu
