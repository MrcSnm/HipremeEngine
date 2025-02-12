module std.vita.socket;
version(PSVita):


nothrow @nogc int socketpair(int a, int b, int c , ref int[2] d)
{
	return socketpair(a,b,c,d.ptr);
}


nothrow @nogc extern(C):

/*	$NetBSD: socket.h,v 1.77 2005/11/29 03:12:16 christos Exp $	*/

/*
 * Copyright (C) 1995, 1996, 1997, and 1998 WIDE Project.
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
 * 3. Neither the name of the project nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE PROJECT AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * Copyright (c) 1982, 1985, 1986, 1988, 1993, 1994
 *	The Regents of the University of California.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *	@(#)socket.h	8.6 (Berkeley) 5/3/95
 */

import core.stdc.stdint;

alias sa_family_t = uint8_t ;
alias socklen_t = uint32_t ;

enum	FD_SETSIZE = 	256;

/*
 * Socket types.
 */
enum	SOCK_STREAM	= 1;		/* stream socket */
enum	SOCK_DGRAM	= 2;		/* datagram socket */
enum	SOCK_RAW	= 3;		/* raw-protocol interface */
enum	SOCK_RDM	= 4;		/* reliably-delivered message */
enum	SOCK_SEQPACKET	= 5;		/* sequenced packet stream */

/*
 * Option flags per-socket.
 */
enum SO_DEBUG = 0x0001;		/* turn on debugging info recording */
enum SO_ACCEPTCONN = 0x0002;		/* socket has had listen() */
enum SO_REUSEADDR = 0x0004;		/* allow local address reuse */
enum SO_KEEPALIVE = 0x0008;		/* keep connections alive */
enum SO_DONTROUTE = 0x0010;		/* just use interface addresses */
enum SO_BROADCAST = 0x0020;		/* permit sending of broadcast msgs */
enum SO_USELOOPBACK = 0x0040;		/* bypass hardware when possible */
enum SO_LINGER = 0x0080;		/* linger on close if data present */
enum SO_OOBINLINE = 0x0100;		/* leave received OOB data in line */
enum SO_REUSEPORT = 0x0200;		/* allow local address & port reuse */
enum SO_TIMESTAMP = 0x0400;		/* timestamp received dgram traffic */

/*
 * Additional options, not kept in so_options.
 */
enum SO_SNDBUF = 0x1001;		/* send buffer size */
enum SO_RCVBUF = 0x1002;		/* receive buffer size */
enum SO_SNDLOWAT = 0x1003;		/* send low-water mark */
enum SO_RCVLOWAT = 0x1004;		/* receive low-water mark */
enum SO_SNDTIMEO = 0x1005;		/* send timeout */
enum SO_RCVTIMEO = 0x1006;		/* receive timeout */
enum SO_ERROR = 0x1007;		/* get error status and clear */
enum SO_TYPE = 0x1008;		/* get socket type */
enum SO_OVERFLOWED = 0x1009;		/* datagrams: return packets dropped */
enum SO_NONBLOCK = 0x1100;		/* non-blocking I/O */

/*
 * Structure used for manipulating linger option.
 */
struct	linger {
	int	l_onoff;		/* option on/off */
	int	l_linger;		/* linger time in seconds */
}

/*
 * Level number for (get/set)sockopt() to apply to socket itself.
 */
enum	SOL_SOCKET =	0xffff;		/* options for socket level */

/*
 * Address families.
 */
enum AF_UNSPEC = 0;		/* unspecified */
enum AF_LOCAL = 1;		/* local to host (pipes, portals) */
enum AF_UNIX = AF_LOCAL;	/* backward compatibility */
enum AF_INET = 2;		/* internetwork: UDP, TCP, etc. */
enum AF_IMPLINK = 3;		/* arpanet imp addresses */
enum AF_PUP = 4;		/* pup protocols: e.g. BSP */
enum AF_CHAOS = 5;		/* mit CHAOS protocols */
enum AF_NS = 6;		/* XEROX NS protocols */
enum AF_ISO = 7;		/* ISO protocols */
enum AF_OSI = AF_ISO;
enum AF_ECMA = 8;		/* european computer manufacturers */
enum AF_DATAKIT = 9;		/* datakit protocols */
enum AF_CCITT = 10;		/* CCITT protocols, X.25 etc */
enum AF_SNA = 11;		/* IBM SNA */
enum AF_DECnet = 12;		/* DECnet */
enum AF_DLI = 13;		/* DEC Direct data link interface */
enum AF_LAT = 14;		/* LAT */
enum AF_HYLINK = 15;		/* NSC Hyperchannel */
enum AF_APPLETALK = 16;		/* Apple Talk */
enum AF_ROUTE = 17;		/* Internal Routing Protocol */
enum AF_LINK = 18;		/* Link layer interface */
enum AF_COIP = 20;		/* connection-oriented IP, aka ST II */
enum AF_CNT = 21;		/* Computer Network Technology */
enum AF_IPX = 23;		/* Novell Internet Protocol */
enum AF_INET6 = 24;		/* IP version 6 */
enum AF_ISDN = 26;		/* Integrated Services Digital Network*/
enum AF_E164 = AF_ISDN;		/* CCITT E.164 recommendation */
enum AF_NATM = 27;		/* native ATM access */
enum AF_ARP = 28;		/* (rev.) addr. res. prot. (RFC 826) */
enum AF_MAX = 31;

/*
 * Structure used by kernel to store most
 * addresses.
 */
struct sockaddr {
	uint8_t	sa_len;		/* total length */
	sa_family_t	sa_family;	/* address family */
	char[14]		sa_data;	/* actually longer; address value */
}

enum _SS_MAXSIZE = 128U;
enum _SS_ALIGNSIZE = int64_t.sizeof;
enum _SS_PAD1SIZE = (_SS_ALIGNSIZE - uint8_t.sizeof - sa_family_t.sizeof);
enum _SS_PAD2SIZE = (_SS_MAXSIZE - uint8_t.sizeof - sa_family_t.sizeof - _SS_PAD1SIZE - _SS_ALIGNSIZE);

struct sockaddr_storage {
	uint8_t		ss_len;
	sa_family_t	ss_family;
	char[_SS_PAD1SIZE] 		__ss_pad1;
	int64_t		__ss_align;
	char[_SS_PAD2SIZE]		__ss_pad2;
}

/*
 * Protocol families, same as address families for now.
 */
enum PF_UNSPEC = AF_UNSPEC;
enum PF_LOCAL = AF_LOCAL;
enum PF_UNIX = PF_LOCAL;	/* backward compatibility */
enum PF_INET = AF_INET;
enum PF_IMPLINK = AF_IMPLINK;
enum PF_PUP = AF_PUP;
enum PF_CHAOS = AF_CHAOS;
enum PF_NS = AF_NS;
enum PF_ISO = AF_ISO;
enum PF_OSI = AF_ISO;
enum PF_ECMA = AF_ECMA;
enum PF_DATAKIT = AF_DATAKIT;
enum PF_CCITT = AF_CCITT;
enum PF_SNA = AF_SNA;
enum PF_DECnet = AF_DECnet;
enum PF_DLI = AF_DLI;
enum PF_LAT = AF_LAT;
enum PF_HYLINK = AF_HYLINK;
enum PF_APPLETALK = AF_APPLETALK;
enum PF_ROUTE = AF_ROUTE;
enum PF_LINK = AF_LINK;

enum PF_COIP = AF_COIP;
enum PF_CNT = AF_CNT;
enum PF_INET6 = AF_INET6;
enum PF_IPX = AF_IPX;		/* same format as AF_NS */
enum PF_ISDN = AF_ISDN;		/* same as E164 */
enum PF_E164 = AF_E164;
enum PF_NATM = AF_NATM;
enum PF_ARP = AF_ARP;
enum PF_MAX = AF_MAX;
enum MSG_OOB = 0x1;		/* process out-of-band data */
enum MSG_PEEK = 0x2;		/* peek at incoming message */
enum MSG_DONTROUTE = 0x4;		/* send without using routing tables */
enum MSG_EOR = 0x8;		/* data completes record */
enum MSG_TRUNC = 0x10;		/* data discarded before delivery */
enum MSG_CTRUNC = 0x20;		/* control data lost before delivery */
enum MSG_WAITALL = 0x40;		/* wait for full request or error */
enum MSG_DONTWAIT = 0x80;		/* this message should be nonblocking */
enum MSG_BCAST = 0x100;		/* this message was rcvd using link-level brdcst */
enum MSG_MCAST = 0x200;		/* this message was rcvd using link-level mcast */

/*
 * Types of socket shutdown(2).
 */
enum SHUT_RD = 0;		/* Disallow further receives. */
enum SHUT_WR = 1;		/* Disallow further sends. */
enum SHUT_RDWR = 2;		/* Disallow further sends/receives. */

struct iovec {
	void	*iov_base;	/* Base address. */
	size_t	 iov_len;	/* Length. */
}

struct msghdr {
	void		*msg_name;	/* optional address */
	socklen_t	msg_namelen;	/* size of address */
	iovec	*msg_iov;	/* scatter/gather array */
	int		msg_iovlen;	/* # elements in msg_iov */
	void		*msg_control;	/* ancillary data, see below */
	socklen_t	msg_controllen;	/* ancillary data buffer len */
	int		msg_flags;	/* flags on received message */
}

/* BSD-compatible socket API. */
int	accept(int, sockaddr * __restrict, socklen_t * __restrict);
int	bind(int, const sockaddr *, socklen_t);
int	connect(int, const sockaddr *, socklen_t);
int	getpeername(int, sockaddr * __restrict, socklen_t * __restrict);
int	getsockname(int, sockaddr * __restrict, socklen_t * __restrict);

int getnameinfo(sockaddr* addr,size_t addrlen, char* host, size_t hostlen,
    char* serv,size_t servlen, int flags);

int	getsockopt(int, int, int, void * __restrict, socklen_t * __restrict);
int	listen(int, int);
ssize_t	recv(int, void *, size_t, int);
ssize_t	recvfrom(int, void * __restrict, size_t, int,
		sockaddr * __restrict, socklen_t * __restrict);
ssize_t recvmsg(int s, msghdr *msg, int flags);
ssize_t	send(int, const void *, size_t, int);
ssize_t	sendto(int, const void *,
		size_t, int, const sockaddr *, socklen_t);
ssize_t sendmsg(int s, const msghdr *msg, int flags);
int	setsockopt(int, int, int, const void *, socklen_t);
int	shutdown(int, int);
int	socket(int, int, int);
int	socketpair(int, int, int, int *);
