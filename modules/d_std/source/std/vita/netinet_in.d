module std.vita.netinet_in;
version(PSVita):
import core.stdc.config;
nothrow @nogc pure:

T _howmany(T)(T x, T y) =>	(((x) + ((y) - 1)) / (y));

alias  __fd_mask = c_ulong;
alias fd_mask = __fd_mask;


enum _NFDBITS = cast(int)__fd_mask.sizeof * 8; /* bits per mask */
alias NFDBITS = _NFDBITS;


struct fd_set {
	__fd_mask[_howmany(FD_SETSIZE, _NFDBITS)]	__fds_bits;
}

/*
 * Copyright (c) 2016, 2017, 2018 vitasdk
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


import std.stdint;
import std.vita.socket;

extern(C):

/** Net Protocols */
enum SceNetProtocol {
	SCE_NET_IPPROTO_IP      = 0,
	SCE_NET_IPPROTO_ICMP    = 1,
	SCE_NET_IPPROTO_IGMP    = 2,
	SCE_NET_IPPROTO_TCP     = 6,
	SCE_NET_IPPROTO_UDP     = 17,
	SCE_NET_SOL_SOCKET      = 0xFFFF
}


enum IPPROTO_IP = SceNetProtocol.SCE_NET_IPPROTO_IP;
enum IPPROTO_ICMP = SceNetProtocol.SCE_NET_IPPROTO_ICMP;
enum IPPROTO_IGMP = SceNetProtocol.SCE_NET_IPPROTO_IGMP;
enum IPPROTO_TCP = SceNetProtocol.SCE_NET_IPPROTO_TCP;
enum IPPROTO_UDP = SceNetProtocol.SCE_NET_IPPROTO_UDP;

alias in_addr_t = uint32_t ;
alias in_port_t = uint16_t ;

struct in_addr {
	in_addr_t s_addr;
}

struct sockaddr_in {
	uint8_t			sin_len;
	sa_family_t		sin_family;
	in_port_t		sin_port;
	in_addr		sin_addr;
	in_port_t		sin_vport;
	char[6]			sin_zero;
}

struct in6_addr {
	union {
		uint8_t[16]		__s6_addr;
		uint16_t[8]	__s6_addr16;
		uint32_t[4]	__s6_addr32;
	}
    alias s6_addr = __s6_addr;
    alias s6_addr16 = __s6_addr16;
    alias s6_addr32 = __s6_addr32;
}

struct sockaddr_in6 {
	uint8_t			sin6_len;
	sa_family_t		sin6_family;
	in_port_t		sin6_port;
	uint32_t		sin6_flowinfo;
	in6_addr		sin6_addr;
	in_port_t		sin6_vport;
	uint32_t		sin6_scope_id;
}

/* Address to accept any incoming messages. */
enum INADDR_ANY = (cast(in_addr_t) 0x00000000);

/* Address to send to all hosts. */
enum INADDR_BROADCAST =(cast(in_addr_t) 0xffffffff);

enum INADDR_LOOPBACK =(cast(in_addr_t) 0x7f000001); // 127.0.0.1;
enum INADDR_NONE =(cast(in_addr_t) 0xffffffff);

auto	IN_CLASSA(uint i) { return ((cast(uint32_t)(i) & 0x80000000) == 0) ;}
enum IN_CLASSA_NET = 0xff000000;
enum IN_CLASSA_NSHIFT = 24;
enum IN_CLASSA_HOST = 0x00ffffff;
enum IN_CLASSA_MAX = 128;

auto	IN_CLASSB(uint i){return ((cast(uint32_t)(i) & 0xc0000000) == 0x80000000);}
enum	IN_CLASSB_NET = 		0xffff0000;
enum	IN_CLASSB_NSHIFT = 	16;
enum	IN_CLASSB_HOST = 		0x0000ffff;
enum	IN_CLASSB_MAX = 		65536;

auto	IN_CLASSC(uint i){return ((cast(uint32_t)(i) & 0xe0000000) == 0xc0000000);}
enum	IN_CLASSC_NET = 0xffffff00;
enum	IN_CLASSC_NSHIFT = 8;
enum	IN_CLASSC_HOST = 0x000000ff;

auto	IN_CLASSD(uint i){return ((cast(uint32_t)(i) & 0xf0000000) == 0xe0000000);}
enum	IN_CLASSD_NET		 = 0xf0000000;	/* These ones aren't really */
enum	IN_CLASSD_NSHIFT	 = 28;		/* net and host fields, but */
enum	IN_CLASSD_HOST		 = 0x0fffffff;	/* routing needn't know.    */
alias	IN_MULTICAST = IN_CLASSD;


auto	IN_EXPERIMENTAL(uint i) =>	((cast(uint32_t)(i) & 0xf0000000) == 0xf0000000);
auto	IN_BADCLASS(uint i) =>		((cast(uint32_t)(i) & 0xf0000000) == 0xf0000000);


enum INADDR_UNSPEC_GROUP	= cast(uint32_t)0xe0000000;	/* 224.0.0.0 */
enum INADDR_ALLHOSTS_GROUP	= cast(uint32_t)0xe0000001;	/* 224.0.0.1 */
enum INADDR_ALLRTRS_GROUP	= cast(uint32_t)0xe0000002;	/* 224.0.0.2 */
enum INADDR_MAX_LOCAL_GROUP	= cast(uint32_t)0xe00000ff;	/* 224.0.0.255 */

enum	IN_LOOPBACKNET =		127;			/* official! */

// #define ntohs __builtin_bswap16
// #define htons __builtin_bswap16
// #define ntohl __builtin_bswap32
// #define htonl __builtin_bswap32


enum SceNetSocketOption {
	/* IP */
	SCE_NET_IP_HDRINCL              = 2,
	SCE_NET_IP_TOS                  = 3,
	SCE_NET_IP_TTL                  = 4,
	SCE_NET_IP_MULTICAST_IF         = 9,
	SCE_NET_IP_MULTICAST_TTL        = 10,
	SCE_NET_IP_MULTICAST_LOOP       = 11,
	SCE_NET_IP_ADD_MEMBERSHIP       = 12,
	SCE_NET_IP_DROP_MEMBERSHIP      = 13,
	SCE_NET_IP_TTLCHK               = 23,
	SCE_NET_IP_MAXTTL               = 24,
	/* TCP */
	SCE_NET_TCP_NODELAY             = 1,
	SCE_NET_TCP_MAXSEG              = 2,
	SCE_NET_TCP_MSS_TO_ADVERTISE    = 3,
	/* SOCKET */
	SCE_NET_SO_REUSEADDR            = 0x00000004,
	SCE_NET_SO_KEEPALIVE            = 0x00000008,
	SCE_NET_SO_BROADCAST            = 0x00000020,
	SCE_NET_SO_LINGER               = 0x00000080,
	SCE_NET_SO_OOBINLINE            = 0x00000100,
	SCE_NET_SO_REUSEPORT            = 0x00000200,
	SCE_NET_SO_ONESBCAST            = 0x00000800,
	SCE_NET_SO_USECRYPTO            = 0x00001000,
	SCE_NET_SO_USESIGNATURE         = 0x00002000,
	SCE_NET_SO_SNDBUF               = 0x1001,
	SCE_NET_SO_RCVBUF               = 0x1002,
	SCE_NET_SO_SNDLOWAT             = 0x1003,
	SCE_NET_SO_RCVLOWAT             = 0x1004,
	SCE_NET_SO_SNDTIMEO             = 0x1005,
	SCE_NET_SO_RCVTIMEO             = 0x1006,
	SCE_NET_SO_ERROR                = 0x1007,
	SCE_NET_SO_TYPE                 = 0x1008,
	SCE_NET_SO_NBIO                 = 0x1100,
	SCE_NET_SO_TPPOLICY             = 0x1101,
	SCE_NET_SO_NAME                 = 0x1102
}


enum IP_HDRINCL		= SceNetSocketOption.SCE_NET_IP_HDRINCL;
enum IP_TOS			= SceNetSocketOption.SCE_NET_IP_TOS;
enum IP_TTL			= SceNetSocketOption.SCE_NET_IP_TTL;
enum IP_MULTICAST_IF		= SceNetSocketOption.SCE_NET_IP_MULTICAST_IF;
enum IP_MULTICAST_TTL	= SceNetSocketOption.SCE_NET_IP_MULTICAST_TTL;
enum IP_MULTICAST_LOOP	= SceNetSocketOption.SCE_NET_IP_MULTICAST_LOOP;
enum IP_ADD_MEMBERSHIP	= SceNetSocketOption.SCE_NET_IP_ADD_MEMBERSHIP;
enum IP_DROP_MEMBERSHIP	= SceNetSocketOption.SCE_NET_IP_DROP_MEMBERSHIP;

/*
 * Argument structure for IP_ADD_MEMBERSHIP and IP_DROP_MEMBERSHIP.
 */
struct ip_mreq {
	in_addr imr_multiaddr;	/* IP multicast address of group */
	in_addr imr_interface;	/* local IP address of interface */
}
