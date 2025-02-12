module std.vita.netdb;
version(PSVita):
import std.vita.netinet_in;
import std.vita.socket;
extern(C):
nothrow @nogc:

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


struct hostent {
	char *h_name;
	char **h_aliases;
	int h_addrtype;
	int h_length;
	char **h_addr_list;

    auto h_addr(){return h_addr_list[0]; }
};

struct servent {
	char *s_name;
	char **s_aliases;
	int s_port;
	char *s_proto;
}
struct protoent
{
	char*   p_name;
	char**  p_aliases;
	int     p_proto;
}
servent* getservbyport(int port, const char* proto){return null; } //Not available


struct addrinfo {
	int ai_flags;
	int ai_family;
	int ai_socktype;
	int ai_protocol;
	size_t ai_addrlen;
	char *ai_canonname;
	sockaddr *ai_addr;
	addrinfo *ai_next;
}

/* Error return codes from getaddrinfo() */
enum EAI_BADFLAGS        = -1;      /* Invalid value for `ai_flags' field.  */
enum EAI_NONAME          = -2;      /* NAME or SERVICE is unknown.  */
enum EAI_AGAIN           = -3;      /* Temporary failure in name resolution.  */
enum EAI_FAIL            = -4;      /* Non-recoverable failure in name res.  */
enum EAI_NODATA          = -5;      /* No address associated with NAME.  */
enum EAI_FAMILY          = -6;      /* `ai_family' not supported.  */
enum EAI_SOCKTYPE        = -7;      /* `ai_socktype' not supported.  */
enum EAI_SERVICE         = -8;      /* SERVICE not supported for `ai_socktype'.  */
enum EAI_ADDRFAMILY      = -9;      /* Address family for NAME not supported.  */
enum EAI_MEMORY          = -10;     /* Memory allocation failure.  */
enum EAI_SYSTEM          = -11;     /* System error returned in `errno'.  */

enum EAI_OVERFLOW        = -12;     /* Argument buffer overflow.  */
enum EAI_INPROGRESS      = -100;    /* Processing request in progress.  */
enum EAI_CANCELED        = -101;    /* Request canceled.  */
enum EAI_NOTCANCELED     = -102;    /* Request not canceled.  */
enum EAI_ALLDONE         = -103;    /* All requests done.  */
enum EAI_INTR            = -104;    /* Interrupted by a signal.  */
enum EAI_IDN_ENCODE      = -105;    /* IDN encoding failed.  */

/* Flag values for getaddrinfo() */
enum AI_PASSIVE          = 0x00000001;      /* Get address to use bind() */
enum AI_CANONNAME        = 0x00000002;      /* Fill ai_canonname */
enum AI_NUMERICHOST      = 0x00000004;      /* Prevent name resolution */
enum AI_NUMERICSERV      = 0x00000008;      /* Fon't use name resolution. */

/* Valid flags for addrinfo */
enum AI_MASK             = (AI_PASSIVE | AI_CANONNAME | AI_NUMERICHOST | AI_ADDRCONFIG);
enum AI_ALL              = 0x00000100;      /* IPv6 and IPv4-mapped (with AI_V4MAPPED) */
enum AI_V4MAPPED_CFG     = 0x00000200;      /* Accept IPv4-mapped if kernel supports */
enum AI_ADDRCONFIG       = 0x00000400;      /* Only if any address is assigned */
enum AI_V4MAPPED         = 0x00000800;      /* Accept IPv4-mapped IPv6 address */

/* Constants for getnameinfo() */
enum NI_MAXHOST          = 1025;
enum NI_MAXSERV          = 32;

/* Flag values for getnameinfo() */
enum NI_NOFQDN           = 0x00000001;
enum NI_NUMERICHOST      = 0x00000002;
enum NI_NAMEREQD         = 0x00000004;
enum NI_NUMERICSERV      = 0x00000008;
enum NI_DGRAM            = 0x00000010;
enum NI_WITHSCOPEID      = 0x00000020;

hostent *gethostbyname(const char *name);
hostent *gethostbyaddr(const void *addr, socklen_t len, int type);
servent *getservbyname(const char *name, const char *proto);
const(char)* gai_strerror(int);
int getaddrinfo(const char *node, const char *service, const addrinfo *hints, addrinfo **res);
void freeaddrinfo(addrinfo *res);