module std.vita.endian;
version(PSVita):
import std.stdint;

nothrow @nogc pure @trusted:

static pragma(inline, true)
{
    uint16_t __bswap16(uint16_t _x)
    {
        return (cast(uint16_t)((_x >> 8) | ((_x << 8) & 0xff00)));
    }

    uint32_t __bswap32(uint32_t _x)
    {

        return (cast(uint32_t)((_x >> 24) | ((_x >> 8) & 0xff00) |
            ((_x << 8) & 0xff0000) | ((_x << 24) & 0xff000000)));
    }

    uint64_t __bswap64(uint64_t _x)
    {

        return (cast(uint64_t)((_x >> 56) | ((_x >> 40) & 0xff00) |
            ((_x >> 24) & 0xff0000) | ((_x >> 8) & 0xff000000) |
            ((_x << 8) & (cast(uint64_t)0xff << 32)) |
            ((_x << 24) & (cast(uint64_t)0xff << 40)) |
            ((_x << 40) & (cast(uint64_t)0xff << 48)) | ((_x << 56))));
    }
}

///Ps vita is little endian
uint32_t htonl(uint32_t _x)	=> __bswap32(_x);
uint16_t htons(uint16_t _x)	=> __bswap16(_x);
uint32_t ntohl(uint32_t _x)	=> __bswap32(_x);
uint16_t ntohs(uint16_t _x)	=> __bswap16(_x);