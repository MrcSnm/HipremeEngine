module std.vita.errno;
version(PSVita):
extern(C):

//  Copyright Beman Dawes 2005.
//  Use, modification, and distribution is subject to the Boost Software
//  License, Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
//  http://www.boost.org/LICENSE_1_0.txt)

//  See library home page at http://www.boost.org/libs/system


//  supply errno values likely to be missing, particularly on Windows

@nogc nothrow pure @trusted
{
    int errno(){return *__errno();}
    extern(C) extern int *__errno ();
}


enum EAFNOSUPPORT = 9901;
enum EADDRINUSE = 9902;
enum EADDRNOTAVAIL = 9903;
enum EISCONN = 9904;
enum EBADMSG = 9905;
enum ECONNABORTED = 9906;
enum EALREADY = 9907;
enum ECONNREFUSED = 9908;
enum ECONNRESET = 9909;
enum EDESTADDRREQ = 9910;
enum EHOSTUNREACH = 9911;
enum EIDRM = 9912;
enum EMSGSIZE = 9913;
enum ENETDOWN = 9914;
enum ENETRESET = 9915;
enum ENETUNREACH = 9916;
enum ENOBUFS = 9917;
enum ENOLINK = 9918;
enum ENODATA = 9919;
enum ENOMSG = 9920;
enum ENOPROTOOPT = 9921;
enum ENOSR = 9922;
enum ENOTSOCK = 9923;
enum ENOSTR = 9924;
enum ENOTCONN = 9925;
enum ENOTSUP = 9926;
enum ECANCELED = 9927;
enum EINPROGRESS = 9928;
enum EOPNOTSUPP = 9929;
enum EWOULDBLOCK = 9930;
enum EOWNERDEAD =  9931;
enum EPROTO = 9932;
enum EPROTONOSUPPORT = 9933;
enum ENOTRECOVERABLE = 9934;
enum ETIME = 9935;
enum ETXTBSY = 9936;
enum ETIMEDOUT = 9938;
enum ELOOP = 9939;
enum EOVERFLOW = 9940;
enum EPROTOTYPE = 9941;
enum ENOSYS = 9942;
enum EINVAL = 9943;
enum ERANGE = 9944;
enum EILSEQ = 9945;
//  Windows Mobile doesn't appear to define these:

enum E2BIG = 9946;
enum EDOM = 9947;
enum EFAULT = 9948;
enum EBADF = 9949;
enum EPIPE = 9950;
enum EXDEV = 9951;
enum EBUSY = 9952;
enum ENOTEMPTY = 9953;
enum ENOEXEC = 9954;
enum EEXIST = 9955;
enum EFBIG = 9956;
enum ENAMETOOLONG = 9957;
enum ENOTTY = 9958;
enum EINTR = 9959;
enum ESPIPE = 9960;
enum EIO = 9961;
enum EISDIR = 9962;
enum ECHILD = 9963;
enum ENOLCK = 9964;
enum ENOSPC = 9965;
enum ENXIO = 9966;
enum ENODEV = 9967;
enum ENOENT = 9968;
enum ESRCH = 9969;
enum ENOTDIR = 9970;
enum ENOMEM = 9971;
enum EPERM = 9972;
enum EACCES = 9973;
enum EROFS = 9974;
enum EDEADLK = 9975;
enum EAGAIN = 9976;
enum ENFILE = 9977;
enum EMFILE = 9978;
enum EMLINK = 9979;