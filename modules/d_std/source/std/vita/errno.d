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


enum EPERM = 1;	/* Not owner */
enum ENOENT = 2;	/* No such file or directory */
enum ESRCH = 3;	/* No such process */
enum EINTR = 4;	/* Interrupted system call */
enum EIO = 5;	/* I/O error */
enum ENXIO = 6;	/* No such device or address */
enum E2BIG = 7;	/* Arg list too long */
enum ENOEXEC = 8;	/* Exec format error */
enum EBADF = 9;	/* Bad file number */
enum ECHILD = 10;	/* No children */
enum EAGAIN = 11;	/* No more processes */
enum ENOMEM = 12;	/* Not enough space */
enum EACCES = 13;	/* Permission denied */
enum EFAULT = 14;	/* Bad address */
enum ENOTBLK = 15;	/* Block device required */
enum EBUSY = 16;	/* Device or resource busy */
enum EEXIST = 17;	/* File exists */
enum EXDEV = 18;	/* Cross-device link */
enum ENODEV = 19;	/* No such device */
enum ENOTDIR = 20;	/* Not a directory */
enum EISDIR = 21;	/* Is a directory */
enum EINVAL = 22;	/* Invalid argument */
enum ENFILE = 23;	/* Too many open files in system */
enum EMFILE = 24;	/* File descriptor value too large */
enum ENOTTY = 25;	/* Not a character device */
enum ETXTBSY = 26;	/* Text file busy */
enum EFBIG = 27;	/* File too large */
enum ENOSPC = 28;	/* No space left on device */
enum ESPIPE = 29;	/* Illegal seek */
enum EROFS = 30;	/* Read-only file system */
enum EMLINK = 31;	/* Too many links */
enum EPIPE = 32;	/* Broken pipe */
enum EDOM = 33;	/* Mathematics argument out of domain of function */
enum ERANGE = 34;	/* Result too large */
enum ENOMSG = 35;	/* No message of desired type */
enum EIDRM = 36;	/* Identifier removed */
enum EDEADLK = 45;	/* deadlock */
enum ENOLCK = 46;	/* no lock */
enum ENOSTR = 60;	/* Not a stream */
enum ENODATA = 61;	/* No data (for no delay io) */
enum ETIME = 62;	/* Stream ioctl timeout */
enum ENOSR = 63;	/* No stream resources */
enum EREMOTE = 66;	/* The object is remote */
enum ENOLINK = 67;	/* Virtual circuit is gone */
enum EPROTO = 71;	/* Protocol error */
enum EMULTIHOP = 74;	/* Multihop attempted */
enum EBADMSG = 77;	/* Bad message */
enum EFTYPE = 79;	/* Inappropriate file type or format */
enum ENOSYS = 88;	/* Function not implemented */
enum ENOTEMPTY = 90;	/* Directory not empty */
enum ENAMETOOLONG = 91;	/* File or path name too long */
enum ELOOP = 92;	/* Too many symbolic links */
enum EOPNOTSUPP = 95;	/* Operation not supported on socket */
enum EPFNOSUPPORT = 96;	/* Protocol family not supported */
enum ECONNRESET = 104;	/* Connection reset by peer */
enum ENOBUFS = 105;	/* No buffer space available */
enum EAFNOSUPPORT = 106;	/* Address family not supported by protocol family */
enum EPROTOTYPE = 107;	/* Protocol wrong type for socket */
enum ENOTSOCK = 108;	/* Socket operation on non-socket */
enum ENOPROTOOPT = 109;	/* Protocol not available */
enum ESHUTDOWN = 110;	/* Can't send after socket shutdown */
enum ECONNREFUSED = 111;	/* Connection refused */
enum EADDRINUSE = 112;	/* Address already in use */
enum ECONNABORTED = 113;	/* Software caused connection abort */
enum ENETUNREACH = 114;	/* Network is unreachable */
enum ENETDOWN = 115;	/* Network interface is not configured */
enum ETIMEDOUT = 116;	/* Connection timed out */
enum EHOSTDOWN = 117;	/* Host is down */
enum EHOSTUNREACH = 118;	/* Host is unreachable */
enum EINPROGRESS = 119;	/* Connection already in progress */
enum EALREADY = 120;	/* Socket already connected */
enum EDESTADDRREQ = 121;	/* Destination address required */
enum EMSGSIZE = 122;	/* Message too long */
enum EPROTONOSUPPORT = 123;	/* Unknown protocol */
enum ESOCKTNOSUPPORT = 124;	/* Socket type not supported */
enum EADDRNOTAVAIL = 125;	/* Address not available */
enum ENETRESET = 126;	/* Connection aborted by network */
enum EISCONN = 127;	/* Socket is already connected */
enum ENOTCONN = 128;	/* Socket is not connected */
enum ETOOMANYREFS = 129;
enum EUSERS = 131;
enum EDQUOT = 132;
enum ESTALE = 133;
enum ENOTSUP = 134;	/* Not supported */
enum EILSEQ = 138;	/* Illegal byte sequence */
enum EOVERFLOW = 139;	/* Value too large for defined data type */
enum ECANCELED = 140;	/* Operation canceled */
enum ENOTRECOVERABLE = 141;	/* State not recoverable */
enum EOWNERDEAD = 142;	/* Previous owner died */
enum EWOULDBLOCK = EAGAIN;	/* Operation would block */

enum __ELASTERROR = 2000;	/* Users can add values starting here */