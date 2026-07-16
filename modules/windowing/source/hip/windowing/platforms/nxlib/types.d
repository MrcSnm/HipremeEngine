module hip.windowing.platforms.nxlib.types;

/**
 * @file switch/types.h
 * @brief Various system types.
 * @copyright libnx Authors
 */


alias  u8 = ubyte;       ///<   8-bit unsigned integer.
alias  u16 = ushort;     ///<  16-bit unsigned integer.
alias  u32 = uint;     ///<  32-bit unsigned integer.
alias  u64 = ulong;     ///<  64-bit unsigned integer.
// alias  u128 = __uint128_t; ///< 128-bit unsigned integer.

alias  s8 = byte;       ///<   8-bit signed integer.
alias  s16 = short;     ///<  16-bit signed integer.
alias  s32 = int;     ///<  32-bit signed integer.
alias  s64 = long;     ///<  64-bit signed integer.
// typedef __int128_t s128; ///< 128-bit unsigned integer.

alias  vu8 = /*volatile*/ u8;     ///<   8-bit volatile unsigned integer.
alias  vu16 = /*volatile*/ u16;   ///<  16-bit volatile unsigned integer.
alias  vu32 = /*volatile*/ u32;   ///<  32-bit volatile unsigned integer.
alias  vu64 = /*volatile*/ u64;   ///<  64-bit volatile unsigned integer.
// alias  vu128 = /*volatile*/ u128; ///< 128-bit volatile unsigned integer.

alias vs8 = /*volatile*/s8 ;     ///<   8-bit volatile signed integer.
alias vs16 = /*volatile*/s16 ;   ///<  16-bit volatile signed integer.
alias vs32 = /*volatile*/s32 ;   ///<  32-bit volatile signed integer.
alias vs64 = /*volatile*/s64 ;   ///<  64-bit volatile signed integer.
// alias vs128 = /*volatile*/s128 ; ///< 128-bit volatile signed integer.

alias Handle = u32;                 ///< Kernel object handle.
alias Result = u32;                 ///< Function error code result type.
alias ThreadFunc = void function(void *); ///< Thread entrypoint function.
alias VoidFn = void function();       ///< Function without arguments nor return value.

struct Uuid { u8[0x10] uuid; };   ///< Unique identifier.

struct UtilFloat3 { float[3] value; } ;   ///< 3 floats.

/// Creates a bitmask from a bit number.
uint BIT(ubyte n) @nogc nothrow @safe {return 1 << n;}
ulong BITL(ubyte n) @nogc nothrow @safe {return 1 << n;}

// /// Packs a struct so that it won't include padding bytes.
// #ifndef NX_PACKED
// #define NX_PACKED     __attribute__((packed))
// #endif

/// Marks a function as not returning, for the purposes of compiler optimization.
alias NX_ROTERUN = noreturn;

/// Flags a function as deprecated.
// #ifndef NX_DEPRECATED
// #ifndef LIBNX_NO_DEPRECATION
// #define NX_DEPRECATED __attribute__ ((deprecated))
// #else
// #define NX_DEPRECATED
// #endif
// #endif

/// Flags a function as (always) inline.
// #define NX_INLINE __attribute__((always_inline)) static inline

/// Flags a function as constexpr in C++14 and above; or as (always) inline otherwise.
/// Invalid handle.
enum INVALID_HANDLE = cast(Handle)0;
