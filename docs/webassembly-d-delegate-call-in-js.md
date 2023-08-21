---
description: Shows how to call D delegates from JS
---

# WebAssembly D Delegate Call in JS

Notable export is \_\_callDFunc This function expects a function handle which is passed from the code, example usages:



```d
extern(C) int testDFunction(JSFunction!(void function(string abc)));
//Usage in code

testDFunction(sendJSFunction!((string abc)
{
writeln("Hello Javascript argument abc!! ", abc);
}));
```

On Javascript Side, use it as:

```javascript
testDFunction(funcHandle)
{
exports.__callDFunc(funcHandle, WasmUtils.toDArguments("This is a Javascript string"));
return 9999;
}
```

Delegates are a bit more complex, define your function as:

```d
extern(C) void testDDelegate(JSDelegateType!(void delegate(string abc)));

//Usage in code
int a = 912;
string theStr;
testDDelegate(sendJSDelegate!((string abc)
{
writeln(++a);
theStr = abc;
}).tupleof); //Tupleof is necessary as JSDelegate is actually 3 ubyte*
```

On the Javascript side:

```javascript
testDDelegate(funcHandle, dgFunc, dgCtx)
{
exports.__callDFunc(funcHandle, WasmUtils.toDArguments(dgFunc, dgCtx, "Javascript string on D delegate"));
}
```

