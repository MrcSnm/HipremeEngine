module global.udas;

/**
* UDA used together with runtime debugger, it won't print if it has this attribute
*/
struct Hidden;

/**
* UDA used together with runtime debugger, mark your class member for being able to change
* the target property on the runtime console
*/
struct RuntimeConsole;
