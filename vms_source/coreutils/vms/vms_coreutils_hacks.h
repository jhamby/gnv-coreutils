/* File: vms_coreutils_hacks.h
 *
 * Hacks needed for building coreutils on VMS
 *
 * Copyright 2013, John Malmberg
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
 * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * 19-Oct-2013	J. Malmberg	Original
 *
 ***************************************************************************/

#ifndef _VMS_COREUTILS_HACKS_H
#define _VMS_COREUTILS_HACKS_H

#define __POSIX_TTYNAME 1

#define __UNIX_PUTC 1

#ifndef HOST_OPERATING_SYSTEM
#define HOST_OPERATING_SYSTEM "VSI/OpenVMS"
#endif

/* config_h.com enables all GNULIB_ definitions */

#define GWINSZ_IN_SYS_IOCTL 1

/* Other broken things */

#ifdef REPLACE_NL_LANGINFO
#undef REPLACE_NL_LANGINFO
#endif
#define REPLACE_NL_LANGINFO 0

#ifdef HAVE_LANGINFO_CODESET
#undef HAVE_LANGINFO_CODESET
#endif
#define HAVE_LANGINFO_CODESET 1

#define MOUNTED_GETMNTINFO 1
#ifdef HAVE_STRUCT_STATFS_F_FSTYPENAME
#undef HAVE_STRUCT_STATFS_F_FSTYPENAME
#endif
#define HAVE_STRUCT_STATFS_F_FSTYPENAME 1

#include <vms_fcntl_hacks.h>

/* Needed by gai_strerror */
#ifdef EAI_OVERFLOW
#undef EAI_OVERFLOW
#endif
#define EAI_OVERFLOW -12

/* fd_safer_flag.c needs this */
int dup_safer_flag (int fd, int flag);

/* argv-iter.h needs types.h - probably harmless to include here. */
#include <types.h>

/* strtod.c needs fp.h */
#include <fp.h>

/* for SETLOCALE_NULL_MAX definition */
#include <setlocale_null.h>

/* This function is triggered when memory is exhausted. */
void xalloc_die (void);
#pragma assert func_attrs(xalloc_die) noreturn

/* arg_nonnull */
#include "lib/arg-nonnull.h"

/* standard build inserts the contents of this file into .h files. */
#include "c^+^+defs.h"

/* stdint.h provides INTMAX_MAX and UINTMAX_MAX, but now we need _WIDTH. */

#define BOOL_MAX 1
#define BOOL_WIDTH 1
#define CHAR_WIDTH 8
#define SCHAR_WIDTH 8
#define UCHAR_WIDTH 8
#define SHRT_WIDTH 16
#define USHRT_WIDTH 16
#define INT_WIDTH 32
#define UINT_WIDTH 32
#define SIZE_WIDTH 32
#define WORD_BIT 32
#define LONG_BIT 32
#define LONG_WIDTH 32
#define ULONG_WIDTH 32
#define LLONG_WIDTH 64
#define ULLONG_WIDTH 64
#define UINTPTR_WIDTH 64	/* 64 bits for long and short pointers */

/* Need definition of mempcpy, stpcpy to avoid using [.lib]string.h */
/* Possibly implement as static inline for performance. */
void * mempcpy(void * dest, const void * src, size_t n);
char * stpcpy(char * dest, const char * src);
char * stpncpy (char *dest, const char *src, size_t n);
char * mbsstr (const char *haystack, const char *needle);
char * strndup (char const *s, size_t n);
void * memrchr (void const *s, int c_in, size_t n);
char * strchrnul (const char * s, int c_in);
void * rawmemchr (const void *s, int c_in);
int mbscasecmp (const char *s1, const char *s2);
size_t mbslen (const char *string);
/* Need the nstrftime */
#ifdef my_strftime
#undef my_strftime
#endif
#define my_strftime nstrftime

/* Missing from stat.h */
#ifndef S_IXUGO
#define S_IXUGO (S_IXUSR | S_IXGRP | S_IXOTH)
#endif

#ifndef S_IRWXUGO
#define S_IRWXUGO (S_IRWXU | S_IRWXG | S_IRWXO)
#endif

#ifndef S_ISNAM
#define S_ISNAM(p) (0)
#endif

#ifndef S_ISOFD
#define S_ISOFD(p) (0)
#endif

#ifndef S_ISOFL
#define S_ISOFL(p) (0)
#endif

#ifndef S_ISCTG
#define S_ISCTG(p) (0)
#endif

#ifndef S_ISDOOR
#define S_ISDOOR(p) (0)
#endif

#ifndef S_ISMPX
#define S_ISMPX(p) (0)
#endif

#ifndef S_ISMPB
#define S_ISMPB(p) (0)
#endif

#ifndef S_ISMPC
#define S_ISMPC(p) (0)
#endif

#ifndef S_ISNWK
#define S_ISNWK(p) (0)
#endif

#ifndef S_ISPORT
#define S_ISPORT(p) (0)
#endif

#ifndef S_ISWHT
#define S_ISWHT(p) (0)
#endif

#ifndef S_TYPEISSHM
#define S_TYPEISSHM(p) (0)
#endif

#ifndef S_TYPEISTMO
#define S_TYPEISTMO(p) (0)
#endif

#ifndef S_TYPEISMQ
#define S_TYPEISMQ(p) (0)
#endif

#ifndef S_TYPEISSEM
#define S_TYPEISSEM(p) (0)
#endif


/* parse-datetime.c expects unsetenv to return a value. */
#define unsetenv hide_unsetenv
void decc$unsetenv (const char * __name);
#include <stdlib.h>
#undef unsetenv

static int vms_unsetenv(const char * name) {
    decc$unsetenv(name);
    return 0;
}
#define unsetenv(__name) vms_unsetenv(__name)

#ifdef execvp
#undef execvp
#endif

#include <dirent.h>
int vms_open(const char *file_spec, int flags, ...);
DIR * fdopendir(int fd);
int vms_close(int fd);
int vms_dirfd(DIR * dirp);
int vms_dup(int fd1);
int vms_dup2(int fd1, int fd2);
int vms_closedir(DIR * dirp);

DIR * vms_opendir(const char * name);

#define opendir vms_opendir
#define opendir_safer vms_opendir

/* Want to use GNU getopt so hide it */
#define __GETOPT_PREFIX rpl_

char * canonicalize_file_name (const char *name);
int asprintf (char **resultp, const char *format, ...);

#include <stdio.h>

/* argv-iter.c missing prototype for getdelim */
ssize_t getdelim (char **lineptr, size_t *n, int delimiter, FILE* fp);


#ifndef UTIME_NOW
#define UTIME_NOW (-1)
#endif

#ifndef UTIME_OMIT
#define UTIME_OMIT (-2)
#endif

/* error.c needs this */
#ifdef HAVE_DECL_STRERROR_R
#undef HAVE_DECL_STRERROR_R
#endif
#define HAVE_DECL_STRERROR_R 0

/* acl_entries.c needs this */
#ifdef acl_t
#undef acl_t
#endif
#define acl_t void *

/* fchmodat.c needs this. */
int fchmodat(int fd, const char * file, mode_t mode, int flag);

/* getpass needs termios.h - grab from bash port */
#ifdef HAVE_TERMIOS_H
#undef HAVE_TERMIOS_H
#endif
#define HAVE_TERMIOS_H 1

/* We create a utmp.h */
#ifdef HAVE_UTMP_H
#undef HAVE_UTMP_H
#endif
#define HAVE_UTMP_H 1

#ifdef HAVE_STRUCT_UTMP_UT_TYPE
#undef HAVE_STRUCT_UTMP_UT_TYPE
#endif
#define HAVE_STRUCT_UTMP_UT_TYPE 1

#ifdef HAVE_STRUCT_UTMP_UT_USER
#undef HAVE_STRUCT_UTMP_UT_USER
#endif
#define HAVE_STRUCT_UTMP_UT_USER 1

#ifdef HAVE_STRUCT_UTMP_UT_PID
#undef HAVE_STRUCT_UTMP_UT_PID
#endif
#define HAVE_STRUCT_UTMP_UT_PID 1

#ifdef HAVE_STRUCT_UT_HOST
#undef HAVE_STRUCT_UT_HOST
#endif
#define HAVE_STRUCT_UT_HOST 1

#ifdef HAVE_UT_HOST
#undef HAVE_UT_HOST
#endif
#define HAVE_UT_HOST 1

/* RE_TRANSLATE_TYPE needed for regex.c */
/* Looks like some bugs in the macro setup. */
#ifdef RE_TRANSLATE_TYPE
#undef RE_TRANSLATE_TYPE
#endif
#define RE_TRANSLATE_TYPE unsigned char *
#ifdef __RE_TRANSLATE_TYPE
#undef __RE_TRANSLATE_TYPE
#endif
#define __RE_TRANSLATE_TYPE unsigned char *

#ifdef __USE_GNU
#undef __USE_GNU
#endif
#define __USE_GNU unsigned char *

#ifdef _REGEX_LARGE_OFFSETS
#undef _REGEX_LARGE_OFFSETS
#endif
#define _REGEX_LARGE_OFFSETS unsigned char *"

#include <stat.h>

int lchmod (const char *, mode_t);

/* Needed for openat-safer.c */
int openat (int fd, char const *file, int flags, ...);

/* Needed for pipe2-safer.c */
int pipe2 (int fd[2], int flags);
int fd_safer_flag (int fd, int flag);

/* Needed for fchownat users, they expect i in unistd.h */
int fchownat (int fd, char const *file, uid_t owner, gid_t group, int flag);

/* selinux hack needs this */
#ifdef _GL_UNUSED_PARAMETER
#undef _GL_UNUSED_PARAMETER
#endif
#define _GL_UNUSED_PARAMETER
#ifdef _GL_UNUSED
#undef _GL_UNUSED
#endif
#define _GL_UNUSED

/* lib/error.h needs this */
#ifndef _GL_ATTRIBUTE_FORMAT_PRINTF_STANDARD
#define _GL_ATTRIBUTE_FORMAT_PRINTF_STANDARD(a, b)
#endif

/* Need to find out how to do a mknod */

int mkfifo(char const *file, mode_t mode);
int mkfifoat(int dirfd, const char *path, mode_t mode);
int mknod(char const *file, mode_t mode, dev_t dev);
int mknodat(int dirfd, const char *path, mode_t mode, dev_t dev);

/* copy needs this */
#ifdef LINK_FOLLOWS_SYMLINKS
#undef LINK_FOLLOWS_SYMLINKS
#endif
#define LINK_FOLLOWS_SYMLINKS 0

/* env.c needs this */
#include <unixlib.h>

/* mknod.c needs this */
#ifdef major_t
#undef major_t
#endif
#define major_t unsigned int

#ifdef minor_t
#undef minor_t
#endif
#define minor_t unsigned int

/* numfmt.c needs this */
#ifndef __attribute
#define __attribute(x)
#endif

/* timeout.c needs this */
#ifdef WCOREDUMP
#undef WCOREDUMP
#endif
#define WCOREDUMP(x) 0

#include "vms_pwd_hack.h"

#include "vms_ioctl_hack.h"

#define chroot(x) (-1)

#define gethostid() vms_gethostid()

#include "vms_uname_hack.h"

#include "vms_sysctl_hack.h"

#include "vms_rename_hack.h"

#include "vms_ttyname_hack.h"

#define open vms_open
#define open_safer vms_open
#define dirfd(__dirp) vms_dirfd(__dirp)
#define close(__fd) vms_close(__fd)
#define dup(__fd1) vms_dup(__fd1)
#define dup_safer(__fd1) vms_dup(__fd1)
#define dup2(__fd1, __fd2) vms_dup2(__fd1, __fd2)
#define closedir(__dirp) vms_closedir(__dirp)
#define fstat(__fd, __stbuf) vms_fstat(__fd, __stbuf)
int vms_fstat(int __fd, struct stat * stbuf);
int fchdir(int fd);

#define mktime hide_mktime
#include <time.h>
#undef mktime
#define mktime lib_mktime
#include <unistd.h>

/* fdutimensat.c needs these */
int futimens (int fd, struct timespec const times[2]);
#define utimesat rpl_utimensat
int rpl_utimensat (int fd, char const *file, struct timespec const times[2],
               int flag);

#define execvp(__name, __args) vms_execvp(__name, __args)
int vms_execvp (const char *file_name, char * argv[]);

#include "gnv_vms_iconv.h"

#include <stdarg.h>

/* VMS V8.4-2L3 <stdarg.h> doesn't define this unless __DECC_VER >= 70500000. */
/* VSI C V7.4-001 doesn't have __VA_COPY_BUILTIN(). */
#ifndef va_copy
#define va_copy(cp, ap) cp = (__va_list) ((__char_ptr32) ap)
#endif

/* Missing defintions in various modules */
int euidaccess(const char * file, int mode);
void explicit_bzero(void *s, size_t n);
int faccessat(int fd, char const *file, int mode, int flag);
int fdutimensat(int fd, int dir, char const *file,
                struct timespec const ts[2], int atflag);
int fstatat(int fd, char const *file, struct stat *st, int flag);
ssize_t getline(char **lineptr, size_t *n, FILE *stream);
int getloadavg(double loadavgp[], int nelem);
int group_member(gid_t gid);
int linkat(int fd1, const char *file1,
           int fd2, const char *file2, int flag);
int tolower(int);
int mkdirat(int dirfd, const char *pathname, mode_t mode);
void *reallocarray(void *ptr, size_t nmemb, size_t size);
char *secure_getenv(char const *name);
int unlinkat(int fd, char const *name, int flag);
int utimensat(int fd, const char *file, struct timespec const times[2],
              int flag);
int vasprintf(char **resultp, const char *format, va_list args);
int vms_fifo_write_pipe(int *pipe_fd);
unsigned long vms_gethostid(void);
int xgetgroups(char const *username, gid_t gid, gid_t **groups);

/* Only place timezone_t is used by coreutils source it is set to 0 */
struct fake_timezone {
   struct fake_timezone * next;
   char tz_is_set;
#if HAVE_TZNAME && !HAVE_TM_ZONE
   char tzname_copy[2];
#endif
   char abbrs[256];
};

typedef struct fake_timezone * timezone_t;

time_t mktime_z (timezone_t tz, struct tm *tm);
struct tm * localtime_rz (timezone_t tz, time_t const *t, struct tm *tm);
time_t mktime (struct tm *timeptr);
time_t timegm(struct tm *tmp);
timezone_t tzalloc(char const * name);
void tzfree(timezone_t tz);

#include <signal.h>

int pthread_sigmask (int how, const sigset_t *new_mask, sigset_t *old_mask);

typedef union { long double ld; long long ll; } max_align_t;

#define BASE_TYPE 64

#endif /* _VMS_COREUTILS_HACKS_H */
