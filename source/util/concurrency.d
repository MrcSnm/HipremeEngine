module util.concurrency;

/**
*   Creates a function definition for shared an unshared.
*/
mixin template concurrent(string func)
{
    mixin(func);
    mixin("shared "~func);
}