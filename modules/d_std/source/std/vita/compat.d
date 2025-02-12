module std.vita.compat;
version(PSVita):
extern(C):
//
// detail/vita_compat.hpp
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Copyright (c) 2003-2021 Christopher M. Kohlhoff (chris at kohlhoff dot com)
//
// Distributed under the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
//

enum NI_NOFQDN = 0x01;
enum NI_DGRAM = 0x10;
enum IPPROTO_IPV6 = 41;
enum IPV6_UNICAST_HOPS = 4;
enum IPV6_MULTICAST_IF = 9;
enum IPV6_MULTICAST_HOPS = 10;
enum IPV6_MULTICAST_LOOP = 11;
enum IPV6_JOIN_GROUP = 12;
enum IPV6_LEAVE_GROUP = 13;
enum IPV6_V6ONLY = 27;
enum IPPROTO_ICMPV6 = 58;