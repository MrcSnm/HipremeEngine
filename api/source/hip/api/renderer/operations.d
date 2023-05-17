module hip.api.renderer.operations;


/// Those are fairly known functions in the graphics programming world
enum HipBlendFunction
{
    ZERO,
    ONE,
    SRC_COLOR,
    ONE_MINUS_SRC_COLOR,
    DST_COLOR,
    ONE_MINUS_DST_COLOR,
    SRC_ALPHA,
    ONE_MINUS_SRC_ALPHA,
    DST_ALPHA,
    ONE_MINUS_DST_ALPHA,
    CONSTANT_COLOR,
    ONE_MINUS_CONSTANT_COLOR,
    CONSTANT_ALPHA,
    ONE_MINUS_CONSTANT_ALPHA,
}

/** 
 * The equation is made by:
 * HipBlendEquation(HipBlendFunction, HipBlendFunction)
 */
enum HipBlendEquation
{
    DISABLED,
    ADD,
    SUBTRACT,
    REVERSE_SUBTRACT,
    MIN,
    MAX
}

///Which function should be employed whene testing the Depth/Z-Buffer
enum HipDepthTestingFunction
{
    ///Means that nothing will be drawed
    Never,
    ///Same as no depth test
    Always,
    ///Render if the value is less than the current depth
    Less,
    ///Render if the value is less or equal than the current depth
    LessEqual,
    ///Render if the value is greater than the current depth
    Greater,
    ///Render if the value is greater or equal than the current depth
    GreaterEqual,
    ///Render if the value is equal against the current depth
    Equal,
    ///Render if the value is not equal against the current depth
    NotEqual,
}

enum HipStencilOperation
{
    ///	The currently stored stencil value is kept.
    Keep,
    ///	The stencil value is set to 0.
    Zero,
    /// The stencil value is replaced with the reference value set with glStencilFunc.
    Replace,
    /// The stencil value is increased by 1 if it is lower than the maximum value.
    Increment,
    /// Same as Increment but wraps it back to 0 as soon as the maximum value is exceeded.
    IncrementWrap,
    /// The stencil value is decreased by 1 if it is higher than the minimum value.
    Decrement,
    /// Same as Decrement but wraps it to the maximum value if it ends up lower than 0.
    DecrementWrap,
    /// Bitwise inverts the current stencil buffer value.
    Invert,
}

///Simply an alias to the depth testing function.
alias HipStencilTestingFunction = HipDepthTestingFunction;