module core.stdc.stdio;

/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * and/or other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 *	@(#)stdio.h	5.3 (Berkeley) 3/15/86
 */

/*
 * NB: to fit things in six character monocase externals, the
 * stdio code uses the prefix `__s' for stdio objects, typically
 * followed by a three-character attempt at a mnemonic.
 */


// #include "_ansi.h"
enum	_FSTDIO;			/* ``function stdio'' */

import core.stdc.stddef;
// #include <sys/cdefs.h>

/* typedef only __gnuc_va_list, used throughout the header */
import core.stdc.stdarg;

/*
 * <sys/reent.h> defines __FILE, _fpos_t.
 * They must be defined there because struct _reent needs them (and we don't
 * want reent.h to include this file.
 */

// #include <sys/reent.h>
// #include <sys/types.h>

struct FILE;

// #include <sys/stdio.h>

enum	__SLBF	= 0x0001;		/* line buffered */
enum	__SNBF	= 0x0002;		/* unbuffered */
enum	__SRD	= 0x0004;		/* OK to read */
enum	__SWR	= 0x0008;		/* OK to write */
	/* RD and WR are never simultaneously asserted */
enum	__SRW	= 0x0010;		/* open for reading & writing */
enum	__SEOF	= 0x0020;		/* found EOF */
enum	__SERR	= 0x0040;		/* found error */
enum	__SMBF	= 0x0080;		/* _buf is from malloc */
enum	__SAPP	= 0x0100;		/* fdopen()ed in append mode - so must  write to end */
enum	__SSTR	= 0x0200;		/* this is an sprintf/snprintf string */
enum	__SOPT	= 0x0400;		/* do fseek() optimisation */
enum	__SNPT	= 0x0800;		/* do not do fseek() optimisation */
enum	__SOFF	= 0x1000;		/* set iff _offset is in fact correct */
enum	__SORD	= 0x2000;		/* true => stream orientation (byte/wide) decided */
version(Cygwin)
    enum __SCLE = 0x4000;        /* convert line endings CR/LF <-> NL */
enum	__SL64 = 0x8000;		/* is 64-bit offset large file */

/* _flags2 flags */
enum	__SNLK  = 0x0001;		/* stdio functions do not lock streams themselves */
enum	__SWID	= 0x2000;		/* true => stream orientation wide, false => byte, only valid if __SORD in _flags is true */

/*
 * The following three definitions are for ANSI C, which took them
 * from System V, which stupidly took internal interface macros and
 * made them official arguments to setvbuf(), without renaming them.
 * Hence, these ugly _IOxxx names are *supposed* to appear in user code.
 *
 * Although these happen to match their counterparts above, the
 * implementation does not rely on that (so these could be renumbered).
 */
enum _IOFBF	= 0;		/* setvbuf should set fully buffered */
enum _IOLBF	= 1;		/* setvbuf should set line buffered */
enum _IONBF	= 2;		/* setvbuf should set unbuffered */

enum EOF = -1;

enum BUFSIZ = 1024;

enum FOPEN_MAX =20;
enum FILENAME_MAX =1024;

enum L_tmpnam = FILENAME_MAX;

enum P_tmpdir = "/tmp";

enum SEEK_SET = 0;
enum SEEK_CUR = 1;
enum SEEK_END = 2;

version(PSVita)
{
    struct _reent  //Minimal required
    {
        int _errno;
        FILE* stdint, stdout, stderr;
    }

    extern(C) _reent* getreent();

    FILE* stdout (){return getreent().stdout;}
}

// enum 	stdin	(_REENT->_stdin)
// #define	stdout	(_REENT->_stdout)
// #define	stderr	(_REENT->_stderr)

// #define _stdin_r(x)	((x)->_stdin)
// #define _stdout_r(x)	((x)->_stdout)
// #define _stderr_r(x)	((x)->_stderr)

/*
 * Functions defined in ANSI C standard.
 */


version(WebAssembly)
{
    extern(C) FILE*	 fopen (const(char*) _name, const(char*) _type){return null;}
    extern(C) c_long	 ftell ( FILE *){return EOF;}
    extern(C) size_t fread (void *, size_t _size, size_t _n, FILE *){return 0;}
    extern(C) int    fgetc (FILE *){return EOF;}
    extern(C) size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream){return 0;}
    extern(C) int    fflush(FILE *stream){return EOF;}
    extern(C) int    remove(const char *filename){return -1;}
    extern(C) int	 fputc (int, FILE *){return EOF;}
    extern(C) int	 fseek (FILE *, c_long, int){return EOF;}
    extern(C) int	 fclose (FILE *){return -1;}
}
else
{
    extern(C) nothrow @nogc:
    extern FILE *	tmpfile ();
    extern char *	tmpnam (char *);
    extern char *	tempnam (char *, char*);
    extern int	fclose (FILE *);
    extern int	fflush (FILE *);
    extern FILE *	freopen (const(char*), const(char*), FILE *);
    extern void	setbuf (FILE *, char *);
    extern int	setvbuf (FILE *, char *, int, size_t);
    extern int	fprintf (FILE *, const(char*), ...);
    extern int	fscanf (FILE *, const(char*), ...);
    extern int	printf (const(char*), ...);
    extern int	scanf (const(char*), ...);
    extern int	sscanf (const(char*), const(char*), ...);
    // extern int	vfprintf (FILE *, const(char*), __VALIST);
    // extern int	vprintf (const(char*), __VALIST);
    // extern int	vsprintf (char *, const(char*), __VALIST);
    extern int	fgetc (FILE *);
    extern char *  fgets (char *, int, FILE *);
    extern int	fputc (int, FILE *);
    extern int	fputs (const(char*), FILE *);
    extern int	getc (FILE *);
    extern int	getchar ();
    extern char *  gets (char *);
    extern int	putc (int, FILE *);
    extern int	putchar (int);
    extern int	puts (const(char*));
    extern int	ungetc (int, FILE *);
    extern size_t	fread (void *, size_t _size, size_t _n, FILE *);
    extern size_t	fwrite (const void * , size_t _size, size_t _n, FILE *);
    // extern int	fgetpos (FILE *, fpos_t *);
    extern int	fseek (FILE *, c_long, int);
    // extern int	fsetpos (FILE *, const fpos_t *);
    extern c_long	ftell ( FILE *);
    extern void	rewind (FILE *);
    extern void	clearerr (FILE *);
    extern int	feof (FILE *);
    extern int	ferror (FILE *);
    extern void    perror (const(char*));
    extern FILE *	fopen (const(char*) _name, const(char*) _type);
    extern int	sprintf (char *, const(char*), ...);
    extern int	remove (const(char*));
    extern int	rename (const(char*), const(char*));
}

// extern(C) extern int	fseeko (FILE *, _off_t, int);
// #if __GNU_VISIBLE
// int	fcloseall (void);
// #endif
// #ifndef _REENT_ONLY
// #if __ISO_C_VISIBLE >= 1999
// int	snprintf (char *, size_t, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 4)));
// int	vsnprintf (char *, size_t, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 0)));
// int	vfscanf (FILE *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__scanf__, 2, 0)));
// int	vscanf (const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__scanf__, 1, 0)));
// int	vsscanf (const(char*), const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__scanf__, 2, 0)));
// #endif
// #if __GNU_VISIBLE
// int	asprintf (char **, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 3)));
// int	vasprintf (char **, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 0)));
// #endif
// #if __MISC_VISIBLE /* Newlib-specific */
// int	asiprintf (char **, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 3)));
// char *	asniprintf (char *, size_t *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 4)));
// char *	asnprintf (char *, size_t *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 4)));
// #ifndef diprintf
// int	diprintf (int, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 3)));
// #endif
// int	fiprintf (FILE *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 3)));
// int	fiscanf (FILE *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__scanf__, 2, 3)));
// int	iprintf (const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 1, 2)));
// int	iscanf (const(char*), ...)
//                _ATTRIBUTE ((__format__ (__scanf__, 1, 2)));
// int	siprintf (char *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 3)));
// int	siscanf (const(char*), const(char*), ...)
//                _ATTRIBUTE ((__format__ (__scanf__, 2, 3)));
// int	sniprintf (char *, size_t, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 4)));
// int	vasiprintf (char **, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 0)));
// char *	vasniprintf (char *, size_t *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 0)));
// char *	vasnprintf (char *, size_t *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 0)));
// int	vdiprintf (int, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 0)));
// int	vfiprintf (FILE *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 0)));
// int	vfiscanf (FILE *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__scanf__, 2, 0)));
// int	viprintf (const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 1, 0)));
// int	viscanf (const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__scanf__, 1, 0)));
// int	vsiprintf (char *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 0)));
// int	vsiscanf (const(char*), const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__scanf__, 2, 0)));
// int	vsniprintf (char *, size_t, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 0)));
// #endif /* __MISC_VISIBLE */
// #endif /* !_REENT_ONLY */

// /*
//  * Routines in POSIX 1003.1:2001.
//  */

// #if __POSIX_VISIBLE
// #ifndef _REENT_ONLY
// FILE *	fdopen (int, const(char*));
// #endif
// int	fileno (FILE *);
// #endif
// #if __MISC_VISIBLE || __POSIX_VISIBLE >= 199209
// int	pclose (FILE *);
// FILE *  popen (const(char*), const(char*));
// #endif

// #if __BSD_VISIBLE
// void    setbuffer (FILE *, char *, int);
// int	setlinebuf (FILE *);
// #endif

// #if __MISC_VISIBLE || (__XSI_VISIBLE && __POSIX_VISIBLE < 200112)
// int	getw (FILE *);
// int	putw (int, FILE *);
// #endif
// #if __MISC_VISIBLE || __POSIX_VISIBLE
// int	getc_unlocked (FILE *);
// int	getchar_unlocked (void);
// void	flockfile (FILE *);
// int	ftrylockfile (FILE *);
// void	funlockfile (FILE *);
// int	putc_unlocked (int, FILE *);
// int	putchar_unlocked (int);
// #endif

// /*
//  * Routines in POSIX 1003.1:200x.
//  */

// #if __POSIX_VISIBLE >= 200809
// # ifndef _REENT_ONLY
// #  ifndef dprintf
// int	dprintf (int, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 3)));
// #  endif
// FILE *	fmemopen (void *, size_t, const(char*));
// /* getdelim - see __getdelim for now */
// /* getline - see __getline for now */
// FILE *	open_memstream (char **, size_t *);
// int	vdprintf (int, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 0)));
// # endif
// #endif
// #if __ATFILE_VISIBLE
// int	renameat (int, const(char*), int, const(char*));
// # ifdef __CYGWIN__
// int	renameat2 (int, const(char*), int, const(char*), unsigned int);
// # endif
// #endif

// /*
//  * Recursive versions of the above.
//  */

// int	_asiprintf_r (struct _reent *, char **, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 4)));
// char *	_asniprintf_r (struct _reent *, char *, size_t *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 4, 5)));
// char *	_asnprintf_r (struct _reent *, char *, size_t *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 4, 5)));
// int	_asprintf_r (struct _reent *, char **, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 4)));
// int	_diprintf_r (struct _reent *, int, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 4)));
// int	_dprintf_r (struct _reent *, int, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 4)));
// int	_fclose_r (struct _reent *, FILE *);
// int	_fcloseall_r (struct _reent *);
// FILE *	_fdopen_r (struct _reent *, int, const(char*));
// int	_fflush_r (struct _reent *, FILE *);
// int	_fgetc_r (struct _reent *, FILE *);
// int	_fgetc_unlocked_r (struct _reent *, FILE *);
// char *  _fgets_r (struct _reent *, char *, int, FILE *);
// char *  _fgets_unlocked_r (struct _reent *, char *, int, FILE *);
// #ifdef _COMPILING_NEWLIB
// int	_fgetpos_r (struct _reent *, FILE *, _fpos_t *);
// int	_fsetpos_r (struct _reent *, FILE *, const _fpos_t *);
// #else
// int	_fgetpos_r (struct _reent *, FILE *, fpos_t *);
// int	_fsetpos_r (struct _reent *, FILE *, const fpos_t *);
// #endif
// int	_fiprintf_r (struct _reent *, FILE *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 4)));
// int	_fiscanf_r (struct _reent *, FILE *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__scanf__, 3, 4)));
// FILE *	_fmemopen_r (struct _reent *, void *, size_t, const(char*));
// FILE *	_fopen_r (struct _reent *, const(char*), const(char*));
// FILE *	_freopen_r (struct _reent *, const(char*), const(char*), FILE *);
// int	_fprintf_r (struct _reent *, FILE *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 4)));
// int	_fpurge_r (struct _reent *, FILE *);
// int	_fputc_r (struct _reent *, int, FILE *);
// int	_fputc_unlocked_r (struct _reent *, int, FILE *);
// int	_fputs_r (struct _reent *, const(char*), FILE *);
// int	_fputs_unlocked_r (struct _reent *, const(char*), FILE *);
// size_t	_fread_r (struct _reent *, void *, size_t _size, size_t _n, FILE *);
// size_t	_fread_unlocked_r (struct _reent *, void *, size_t _size, size_t _n, FILE *);
// int	_fscanf_r (struct _reent *, FILE *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__scanf__, 3, 4)));
// int	_fseek_r (struct _reent *, FILE *, long, int);
// int	_fseeko_r (struct _reent *, FILE *, _off_t, int);
// long	_ftell_r (struct _reent *, FILE *);
// _off_t	_ftello_r (struct _reent *, FILE *);
// void	_rewind_r (struct _reent *, FILE *);
// size_t	_fwrite_r (struct _reent *, const void *, size_t _size, size_t _n, FILE *);
// size_t	_fwrite_unlocked_r (struct _reent *, const void *, size_t _size, size_t _n, FILE *);
// int	_getc_r (struct _reent *, FILE *);
// int	_getc_unlocked_r (struct _reent *, FILE *);
// int	_getchar_r (struct _reent *);
// int	_getchar_unlocked_r (struct _reent *);
// char *	_gets_r (struct _reent *, char *);
// int	_iprintf_r (struct _reent *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 3)));
// int	_iscanf_r (struct _reent *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__scanf__, 2, 3)));
// FILE *	_open_memstream_r (struct _reent *, char **, size_t *);
// void	_perror_r (struct _reent *, const(char*));
// int	_printf_r (struct _reent *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 3)));
// int	_putc_r (struct _reent *, int, FILE *);
// int	_putc_unlocked_r (struct _reent *, int, FILE *);
// int	_putchar_unlocked_r (struct _reent *, int);
// int	_putchar_r (struct _reent *, int);
// int	_puts_r (struct _reent *, const(char*));
// int	_remove_r (struct _reent *, const(char*));
// int	_rename_r (struct _reent *,
// 			   const(char*)_old, const(char*)_new);
// int	_scanf_r (struct _reent *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__scanf__, 2, 3)));
// int	_siprintf_r (struct _reent *, char *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 4)));
// int	_siscanf_r (struct _reent *, const(char*), const(char*), ...)
//                _ATTRIBUTE ((__format__ (__scanf__, 3, 4)));
// int	_sniprintf_r (struct _reent *, char *, size_t, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 4, 5)));
// int	_snprintf_r (struct _reent *, char *, size_t, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 4, 5)));
// int	_sprintf_r (struct _reent *, char *, const(char*), ...)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 4)));
// int	_sscanf_r (struct _reent *, const(char*), const(char*), ...)
//                _ATTRIBUTE ((__format__ (__scanf__, 3, 4)));
// char *	_tempnam_r (struct _reent *, const(char*), const(char*));
// FILE *	_tmpfile_r (struct _reent *);
// char *	_tmpnam_r (struct _reent *, char *);
// int	_ungetc_r (struct _reent *, int, FILE *);
// int	_vasiprintf_r (struct _reent *, char **, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 0)));
// char *	_vasniprintf_r (struct _reent*, char *, size_t *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 4, 0)));
// char *	_vasnprintf_r (struct _reent*, char *, size_t *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 4, 0)));
// int	_vasprintf_r (struct _reent *, char **, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 0)));
// int	_vdiprintf_r (struct _reent *, int, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 0)));
// int	_vdprintf_r (struct _reent *, int, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 0)));
// int	_vfiprintf_r (struct _reent *, FILE *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 0)));
// int	_vfiscanf_r (struct _reent *, FILE *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__scanf__, 3, 0)));
// int	_vfprintf_r (struct _reent *, FILE *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 0)));
// int	_vfscanf_r (struct _reent *, FILE *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__scanf__, 3, 0)));
// int	_viprintf_r (struct _reent *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 0)));
// int	_viscanf_r (struct _reent *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__scanf__, 2, 0)));
// int	_vprintf_r (struct _reent *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 2, 0)));
// int	_vscanf_r (struct _reent *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__scanf__, 2, 0)));
// int	_vsiprintf_r (struct _reent *, char *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 0)));
// int	_vsiscanf_r (struct _reent *, const(char*), const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__scanf__, 3, 0)));
// int	_vsniprintf_r (struct _reent *, char *, size_t, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 4, 0)));
// int	_vsnprintf_r (struct _reent *, char *, size_t, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 4, 0)));
// int	_vsprintf_r (struct _reent *, char *, const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__printf__, 3, 0)));
// int	_vsscanf_r (struct _reent *, const(char*), const(char*), __VALIST)
//                _ATTRIBUTE ((__format__ (__scanf__, 3, 0)));

// /* Other extensions.  */

// int	fpurge (FILE *);
// ssize_t __getdelim (char **, size_t *, int, FILE *);
// ssize_t __getline (char **, size_t *, FILE *);

// #if __MISC_VISIBLE
// void	clearerr_unlocked (FILE *);
// int	feof_unlocked (FILE *);
// int	ferror_unlocked (FILE *);
// int	fileno_unlocked (FILE *);
// int	fflush_unlocked (FILE *);
// int	fgetc_unlocked (FILE *);
// int	fputc_unlocked (int, FILE *);
// size_t	fread_unlocked (void *, size_t _size, size_t _n, FILE *);
// size_t	fwrite_unlocked (const void * , size_t _size, size_t _n, FILE *);
// #endif

// #if __GNU_VISIBLE
// char *  fgets_unlocked (char *, int, FILE *);
// int	fputs_unlocked (const(char*), FILE *);
// #endif

// #ifdef __LARGE64_FILES
// #if !defined(__CYGWIN__) || defined(_COMPILING_NEWLIB)
// FILE *	fdopen64 (int, const(char*));
// FILE *  fopen64 (const(char*), const(char*));
// FILE *  freopen64 (const(char*), const(char*), FILE *);
// _off64_t ftello64 (FILE *);
// _off64_t fseeko64 (FILE *, _off64_t, int);
// int     fgetpos64 (FILE *, _fpos64_t *);
// int     fsetpos64 (FILE *, const _fpos64_t *);
// FILE *  tmpfile64 (void);

// FILE *	_fdopen64_r (struct _reent *, int, const(char*));
// FILE *  _fopen64_r (struct _reent *,const(char*), const(char*));
// FILE *  _freopen64_r (struct _reent *, const(char*), const(char*), FILE *);
// _off64_t _ftello64_r (struct _reent *, FILE *);
// _off64_t _fseeko64_r (struct _reent *, FILE *, _off64_t, int);
// int     _fgetpos64_r (struct _reent *, FILE *, _fpos64_t *);
// int     _fsetpos64_r (struct _reent *, FILE *, const _fpos64_t *);
// FILE *  _tmpfile64_r (struct _reent *);
// #endif /* !__CYGWIN__ */
// #endif /* __LARGE64_FILES */

// /*
//  * Routines internal to the implementation.
//  */

// int	__srget_r (struct _reent *, FILE *);
// int	__swbuf_r (struct _reent *, int, FILE *);

// /*
//  * Stdio function-access interface.
//  */

// #if __BSD_VISIBLE
// # ifdef __LARGE64_FILES
// FILE	*funopen (const void *__cookie,
// 		int (*__readfn)(void *__c, char *__buf,
// 				_READ_WRITE_BUFSIZE_TYPE __n),
// 		int (*__writefn)(void *__c, const(char*)__buf,
// 				 _READ_WRITE_BUFSIZE_TYPE __n),
// 		_fpos64_t (*__seekfn)(void *__c, _fpos64_t __off, int __whence),
// 		int (*__closefn)(void *__c));
// FILE	*_funopen_r (struct _reent *, const void *__cookie,
// 		int (*__readfn)(void *__c, char *__buf,
// 				_READ_WRITE_BUFSIZE_TYPE __n),
// 		int (*__writefn)(void *__c, const(char*)__buf,
// 				 _READ_WRITE_BUFSIZE_TYPE __n),
// 		_fpos64_t (*__seekfn)(void *__c, _fpos64_t __off, int __whence),
// 		int (*__closefn)(void *__c));
// # else
// FILE	*funopen (const void *__cookie,
// 		int (*__readfn)(void *__cookie, char *__buf,
// 				_READ_WRITE_BUFSIZE_TYPE __n),
// 		int (*__writefn)(void *__cookie, const(char*)__buf,
// 				 _READ_WRITE_BUFSIZE_TYPE __n),
// 		fpos_t (*__seekfn)(void *__cookie, fpos_t __off, int __whence),
// 		int (*__closefn)(void *__cookie));
// FILE	*_funopen_r (struct _reent *, const void *__cookie,
// 		int (*__readfn)(void *__cookie, char *__buf,
// 				_READ_WRITE_BUFSIZE_TYPE __n),
// 		int (*__writefn)(void *__cookie, const(char*)__buf,
// 				 _READ_WRITE_BUFSIZE_TYPE __n),
// 		fpos_t (*__seekfn)(void *__cookie, fpos_t __off, int __whence),
// 		int (*__closefn)(void *__cookie));
// # endif /* !__LARGE64_FILES */

// # define	fropen(__cookie, __fn) funopen(__cookie, __fn, (int (*)())0, \
// 					       (fpos_t (*)())0, (int (*)())0)
// # define	fwopen(__cookie, __fn) funopen(__cookie, (int (*)())0, __fn, \
// 					       (fpos_t (*)())0, (int (*)())0)
// #endif /* __BSD_VISIBLE */

// #if __GNU_VISIBLE
// typedef ssize_t cookie_read_function_t(void *__cookie, char *__buf, size_t __n);
// typedef ssize_t cookie_write_function_t(void *__cookie, const(char*)__buf,
// 					size_t __n);
// # ifdef __LARGE64_FILES
// typedef int cookie_seek_function_t(void *__cookie, _off64_t *__off,
// 				   int __whence);
// # else
// typedef int cookie_seek_function_t(void *__cookie, off_t *__off, int __whence);
// # endif /* !__LARGE64_FILES */
// typedef int cookie_close_function_t(void *__cookie);
// typedef struct
// {
//   /* These four struct member names are dictated by Linux; hopefully,
//      they don't conflict with any macros.  */
//   cookie_read_function_t  *read;
//   cookie_write_function_t *write;
//   cookie_seek_function_t  *seek;
//   cookie_close_function_t *close;
// } cookie_io_functions_t;
// FILE *fopencookie (void *__cookie,
// 		const(char*)__mode, cookie_io_functions_t __functions);
// FILE *_fopencookie_r (struct _reent *, void *__cookie,
// 		const(char*)__mode, cookie_io_functions_t __functions);
// #endif /* __GNU_VISIBLE */

// #ifndef __CUSTOM_FILE_IO__
// /*
//  * The __sfoo macros are here so that we can 
//  * define function versions in the C library.
//  */
// #define       __sgetc_raw_r(__ptr, __f) (--(__f)->_r < 0 ? __srget_r(__ptr, __f) : (int)(*(__f)->_p++))

// #ifdef __SCLE
// /*  For a platform with CR/LF, additional logic is required by
//   __sgetc_r which would otherwise simply be a macro; therefore we
//   use an inlined function.  The function is only meant to be inlined
//   in place as used and the function body should never be emitted.  

//   There are two possible means to this end when compiling with GCC,
//   one when compiling with a standard C99 compiler, and for other
//   compilers we're just stuck.  At the moment, this issue only
//   affects the Cygwin target, so we'll most likely be using GCC. */

// _ELIDABLE_INLINE int __sgetc_r(struct _reent *__ptr, FILE *__p);

// _ELIDABLE_INLINE int __sgetc_r(struct _reent *__ptr, FILE *__p)
//   {
//     int __c = __sgetc_raw_r(__ptr, __p);
//     if ((__p->_flags & __SCLE) && (__c == '\r'))
//       {
//       int __c2 = __sgetc_raw_r(__ptr, __p);
//       if (__c2 == '\n')
//         __c = __c2;
//       else
//         ungetc(__c2, __p);
//       }
//     return __c;
//   }
// #else
// #define __sgetc_r(__ptr, __p) __sgetc_raw_r(__ptr, __p)
// #endif

// #ifdef __GNUC__
// _ELIDABLE_INLINE int __sputc_r(struct _reent *_ptr, int _c, FILE *_p) {
// #ifdef __SCLE
// 	if ((_p->_flags & __SCLE) && _c == '\n')
// 	  __sputc_r (_ptr, '\r', _p);
// #endif
// 	if (--_p->_w >= 0 || (_p->_w >= _p->_lbfsize && (char)_c != '\n'))
// 		return (*_p->_p++ = _c);
// 	else
// 		return (__swbuf_r(_ptr, _c, _p));
// }
// #else
// /*
//  * This has been tuned to generate reasonable code on the vax using pcc
//  */
// #define       __sputc_raw_r(__ptr, __c, __p) \
// 	(--(__p)->_w < 0 ? \
// 		(__p)->_w >= (__p)->_lbfsize ? \
// 			(*(__p)->_p = (__c)), *(__p)->_p != '\n' ? \
// 				(int)*(__p)->_p++ : \
// 				__swbuf_r(__ptr, '\n', __p) : \
// 			__swbuf_r(__ptr, (int)(__c), __p) : \
// 		(*(__p)->_p = (__c), (int)*(__p)->_p++))
// #ifdef __SCLE
// #define __sputc_r(__ptr, __c, __p) \
//         ((((__p)->_flags & __SCLE) && ((__c) == '\n')) \
//           ? __sputc_raw_r(__ptr, '\r', (__p)) : 0 , \
//         __sputc_raw_r((__ptr), (__c), (__p)))
// #else
// #define __sputc_r(__ptr, __c, __p) __sputc_raw_r(__ptr, __c, __p)
// #endif
// #endif

// #define	__sfeof(p)	((int)(((p)->_flags & __SEOF) != 0))
// #define	__sferror(p)	((int)(((p)->_flags & __SERR) != 0))
// #define	__sclearerr(p)	((void)((p)->_flags &= ~(__SERR|__SEOF)))
// #define	__sfileno(p)	((p)->_file)

// #ifndef __cplusplus
// #ifndef _REENT_SMALL
// #define	feof(p)		__sfeof(p)
// #define	ferror(p)	__sferror(p)
// #define	clearerr(p)	__sclearerr(p)

// #if __MISC_VISIBLE
// #define	feof_unlocked(p)	__sfeof(p)
// #define	ferror_unlocked(p)	__sferror(p)
// #define	clearerr_unlocked(p)	__sclearerr(p)
// #endif /* __MISC_VISIBLE */
// #endif /* _REENT_SMALL */

// #if 0 /* __POSIX_VISIBLE - FIXME: must initialize stdio first, use fn */
// #define	fileno(p)	__sfileno(p)
// #endif

// static __inline int
// _getchar_unlocked(void)
// {
// 	struct _reent *_ptr;

// 	_ptr = _REENT;
// 	return (__sgetc_r(_ptr, _stdin_r(_ptr)));
// }

// static __inline int
// _putchar_unlocked(int _c)
// {
// 	struct _reent *_ptr;

// 	_ptr = _REENT;
// 	return (__sputc_r(_ptr, _c, _stdout_r(_ptr)));
// }

// #ifdef __SINGLE_THREAD__
// #define	getc(_p)	__sgetc_r(_REENT, _p)
// #define	putc(_c, _p)	__sputc_r(_REENT, _c, _p)
// #define	getchar()	_getchar_unlocked()
// #define	putchar(_c)	_putchar_unlocked(_c)
// #endif /* __SINGLE_THREAD__ */

// #if __MISC_VISIBLE || __POSIX_VISIBLE
// #define	getchar_unlocked()	_getchar_unlocked()
// #define	putchar_unlocked(_c)	_putchar_unlocked(_c)
// #endif
// #endif /* __cplusplus */

// #if __MISC_VISIBLE
// /* fast always-buffered version, true iff error */
// #define	fast_putc(x,p) (--(p)->_w < 0 ? \
// 	__swbuf_r(_REENT, (int)(x), p) == EOF : (*(p)->_p = (x), (p)->_p++, 0))
// #endif

// #if __GNU_VISIBLE || (__XSI_VISIBLE && __XSI_VISIBLE < 600)
// #define	L_cuserid	9		/* posix says it goes in stdio.h :( */
// #endif
// #if __POSIX_VISIBLE
// #define L_ctermid       16
// #endif

// #else /* __CUSTOM_FILE_IO__ */

// #define	getchar()	getc(stdin)
// #define	putchar(x)	putc(x, stdout)

// #if __MISC_VISIBLE || __POSIX_VISIBLE
// #define	getchar_unlocked()	getc_unlocked(stdin)
// #define	putchar_unlocked(x)	putc_unlocked(x, stdout)
// #endif

// #endif /* !__CUSTOM_FILE_IO__ */

// _END_STD_C

// #if __SSP_FORTIFY_LEVEL > 0
// #include <ssp/stdio.h>
// #endif

// #endif /* _STDIO_H_ */
