---
description: Reference for the internal dub format
---

# dub.template.json reference

* **params:** part is checked only once. Keep it at the top of the file. For not conflicting with dub's internal parameters, it uses the syntax #PARAMETER



```json
 "params": {
	"windows": {
		//Defines windows specific parameters
	},
	"linux": {
		//Defines linux specific parameters
	},
	"SOME_GLOBAL_VAR": "This parameter can be used anywhere here by simply using #SOME_GLOBAL_VAR"
 }
```

* **$extends:** A dub.template.json can have a parent dub.json(or dub.template.json), this is used for separating some configurations, such as the release one, since things can get hairy quite fast if not done.

```json
"$extends": "#HIPREME_ENGINE/dub.json"
```

* **engineModules:** Adding the engine separate modules can be done by using . They will automatically use the absolute path and be added to the linkedDependencies on the current section. Also checked in configurations.

```json
 "engineModules": [
	"util",
	"game2d",
	"math"
 ]
```

* **linkedDependencies:** will automatically be added a linker flag called **`/`**`WHOLEARCHIVE:depName`for windows on ldc compiler. Since this is an error prone operation, it may be handled by the templater. Also checked in configurations.

```json
"linkedDependencies": {
	"someDubDep": {"path": "the/path/to/dep"},
	"arsd:anything": "11.0"
 }
```

* **unnamedDependencies:** Those in unnamed dependencies will automatically be added to the "dependencies" section. If the path does not exists, it will be ignored and simply do nothing. Also checked in configurations.

```json
"unnamedDependencies": [
	"some/path/to/dep"
]
```
