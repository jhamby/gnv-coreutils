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
#define HOST_OPERATING_SYSTEM "HP/OpenVMS"
#endif

/* GNULIB substitutions */
#ifdef GNULIB_DIRNAME
#undef GNULIB_DIRNAME
#endif
#define GNULIB_DIRNAME 1

#ifdef GNULIB_FACCESSAT
#undef GNULIB_FACCESSAT
#endif
#define GNULIB_FACCESSAT 1

#ifdef GNULIB_FCHOWNAT
#undef GNULIB_FCHOWNAT
#endif
#define GNULIB_FCHOWNAT 1

#ifdef GNULIB_FCHMODAT
#undef GNULIB_FCHMODAT
#endif
#define GNULIB_FCHMODAT 1

#ifdef GNULIB_FDOPENDIR
#undef GNULIB_FDOPENDIR
#endif
#define GNULIB_FDOPENDIR 0

#ifdef GNULIB_FFLUSH
#undef GNULIB_FFLUSH
#endif
#define GNULIB_FFLUSH 1

#ifdef GNULIB_FILENAMECAT
#undef GNULIB_FILENAMECAT
#endif
#define GNULIB_FILENAMECAT 1

#ifdef GNULIB_FOPEN_SAFER
#undef GNULIB_FOPEN_SAFER
#endif
#define GNULIB_FOPEN_SAFER 1

#ifdef GNULIB_FSCANF
#undef GNULIB_FSCANF
#endif
#define GNULIB_FSCANF 1

#ifdef GNULIB_GETCWD
#undef GNULIB_GETCWD
#endif
#define GNULIB_GETCWD 0

#ifdef GNULIB_FOPENAT
#undef GNULIB_FOPENAT
#endif
#define GNULIB_FOPENAT 1

#ifdef GNULIB_FSCANF
#undef GNULIB_FSCANF
#endif
#define GNULIB_FSCANF 0

#ifdef GNULIB_SNPRINTF
#undef GNULIB_SNPRINTF
#endif
#define GNULIB_SNPRINTF 0

#ifdef GNULIB_STATAT
#undef GNULIB_STATAT
#endif
#define GNULIB_STATAT 1

#ifdef GNULIB_STRERROR
#undef GNULIB_STRERROR
#endif
#define GNULIB_STRERROR 0

/* Other broken things */

#ifdef PRI_MACROS_BROKEN
#undef PRI_MACROS_BROKEN
#endif
#define PRI_MACROS_BROKEN 0

#define PRIuMAX "llu"
#define PRIdMAX "lld"
#define PRIoMAX "llo"
#define PRIxMAX "llx"

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

/* same-inode.h has VMS specific hack that is now wrong. */
/* Disable the header file if it is not needed. */
#ifdef _USE_STD_STAT
#define SAME_INODE_H 1
#  define SAME_INODE(a, b)    \
    ((a).st_ino == (b).st_ino \
     && (a).st_dev == (b).st_dev)
#endif

/* arg_nonnull */
#include "lib/arg-nonnull.h"

/* Need to provide a VMS specific freading() routine. */

#ifdef HAVE___FREADING
#undef HAVE___FREADING
#endif
#define HAVE___FREADING 1

/* Need to provide a VMS specific freadptrinc() routine. */
#ifdef HAVE___FREADPTRINC
#undef HAVE___FREADPTRINC
#endif
#define HAVE___FREADPTRINC 1

/* Need to provide a VMS specific __fpurge() routine. */
#ifdef HAVE___FPURGE
#undef HAVE___FPURGE
#endif
#define HAVE___FPURGE 1

/* Need to provide a VMS specific __readahead() routine. */
#ifdef HAVE___FREADAHEAD
#undef HAVE___FREADAHEAD
#endif
#define HAVE___FREADAHEAD 1

/* Need to provide a INTMAX_MAX and UINTMAX_MAX. */
#ifdef INTMAX_MAX
#undef INTMAX_MAX
#endif
#define INTMAX_MAX __INT64_MAX

#ifdef UINTMAX_MAX
#undef UINTMAX_MAX
#endif
#define UINTMAX_MAX __UINT64_MAX

#ifdef INTMAX_MIN
#undef INTMAX_MIN
#endif
#define INTMAX_MIN __INT64_MIN

#ifdef uintmax_t
#undef uintmax_t
#endif
#define uintmax_t unsigned long long

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
#ifdef __ALPHA
#pragma message disable ptrmismatch
#endif
#pragma message disable questcompare
#pragma message disable questcompare1
#pragma message disable macroredef
#pragma message disable uninit1
#pragma message disable notincrtl
long long strtoimax (char const *ptr, char **endptr, int base);
unsigned long long strtoumax (char const *ptr, char **endptr,
                              int base);
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
#define S_ISNAM (0)
#endif

#ifndef S_ISNAM
#define S_ISNAM (0)
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

#include <dirent.h>
int vms_open(const char *file_spec, int flags, ...);
DIR * vms_fdopendir(int fd);
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

#include <stdio.h>
static size_t vms_freadahead (FILE * stream) { return 0;}
#define __freadahead(stream) vms_freadahead(stream)

static const char * vms_freadptr(FILE *stream, size_t *sizep) {
    return NULL;
    }
#define freadptr(stream, sizep) vms_freadptr(stream, sizep)
char * canonicalize_file_name (const char *name);
int asprintf (char **resultp, const char *format, ...);

#ifdef HAVE___FSETERR
#undef HAVE___FSETERR
#endif
#define HAVE___FSETERR 1

static void __fseterr(FILE * fp) {
    struct _iobuf * stream;
    stream = (struct _iobuf *) fp;
    stream->_flag |= _IOERR;
}

/* argv-iter.c missing prototype for getdelim */
ssize_t getdelim (char **lineptr, size_t *n, int delimiter, FILE* fp);


#ifndef UTIME_NOW
#define UTIME_NOW (-1)
#endif

#ifndef UTIME_OMIT
#define UTIME_OMIT (-2)
#endif

/* fdutimensat.c needs these */
int futimens (int fd, struct timespec const times[2]);
#define utimesat rpl_utimensat
int rpl_utimensat (int fd, char const *file, struct timespec const times[2],
               int flag);

/* xvasprintf needs va_copy */
#ifdef va_copy
#undef va_copy
#endif
#define va_copy(a,b) ((a) = (b))

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

/* fpending.c needs this */
/* fpending.m4 suggests '{*fp)->_ptr - (*fp)->_base' for VMS. */
#ifdef PENDING_OUTPUT_N_BYTES
#undef PENDING_OUTPUT_N_BYTES
#endif
#define PENDING_OUTPUT_N_BYTES vms_pending_output_n_bytes(fp)

static int vms_pending_output_n_bytes(FILE * fp) {
    struct _iobuf * stream;
    stream = (struct _iobuf *) fp;
    return stream->_ptr - stream->_base;
}

/* getloadavg.c has existing incomplete VMS specific code */
#ifdef LOAD_AVE_TYPE
#undef LOAD_AVE_TYPE
#endif
#define LOAD_AVE_TYPE unsigned long

#include <descrip.h>
#define sys$assign SYS$ASSIGN
#define sys$qiow SYS$QIOW
#define sys$dassgn SYS$DASSGN
/* This is wrong, but needed to get getloadavg compile */
/* channel is an unsigned short and an int will cause problems */
/* event flag 0 should not be used, and an IOSB should be used. */
unsigned long SYS$ASSIGN(struct dsc$descriptor_s * name,
                         int * channel,
                         unsigned long acmode,
                         unsigned long mbxnam_dsc);
unsigned long SYS$DASSGN(int chan);
unsigned long SYS$QIOW(unsigned long efn_flag,
  int channel, unsigned long func,
  unsigned long iosb_ptr, unsigned long astadr, int astprm,
  void * p1, unsigned long len,
  unsigned long p3, unsigned long p4,
  unsigned long p5, unsigned long p6);


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
#define lchmod chmod /* Incomplete hack needed by dirchownmod.c */

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

/* Need to find out how to do a mknod */
#ifndef HAVE_MKNOD
int mknod(char const *file, mode_t mode, dev_t dev);
#endif

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

#include "vms_lstat_hack.h"

#include "vms_getcwd_hack.h"

#include "vms_ioctl_hack.h"

#define chroot(x) (-1)

/* The few places fork is used can be replaced with vfork() */
/* src/split.c explicitly uses vfork via some edits. */
/* src/sort.c does not compile in the fork() call */
#ifndef fork
#define fork(x) vfork(x)
#endif

#define gethostid() vms_gethostid()

#include "vms_sysctl_hack.h"

#include "vms_rename_hack.h"

#include "vms_ttyname_hack.h"

#define open vms_open
#define open_safer vms_open
#define fdopendir(__fd) vms_fdopendir(__fd)
#define dirfd(__dirp) vms_dirfd(__dirp)
#define close(__fd) vms_close(__fd)
#define dup(__fd1) vms_dup(__fd1)
#define dup_safer(__fd1) vms_dup(__fd1)
#define dup2(__fd1, __fd2) vms_dup2(__fd1, __fd2)
#define closedir(__dirp) vms_closedir(__dirp)
#define fstat(__fd, __stbuf) vms_fstat(__fd, __stbuf)
int vms_fstat(int __fd, struct stat * stbuf);
#define fchdir(__fd) vms_fchdir(__fd)
int vms_fchdir(int fd);

#include <time.h>
#include <unistd.h>
#ifdef __ia64__
/* nanosleep not working on IA64 */
static int vms_fake_nanosleep(const struct timespec *rqdly,
                              struct timespec *rmdly) {
    int result;
    result = sleep(rqdly->tv_sec);
    if (result == 0) {
        return 0;
    } else {
        return -1;
    }
}
#define nanosleep(x,y) vms_fake_nanosleep(x, y)
#endif

#include "gnv_vms_iconv.h"

#include <stdarg.h>

/* Missing defintions in various modules */
int euidaccess(const char * file, int mode);
int faccessat(int fd, char const *file, int mode, int flag);
int fdutimensat(int fd, int dir, char const *file,
                struct timespec const ts[2], int atflag);
int __fpurge(FILE *fp);
int fstatat(int fd, char const *file, struct stat *st, int flag);
ssize_t getline(char **lineptr, size_t *n, FILE *stream);
int getloadavg(double loadavgp[], int nelem);
int group_member(gid_t gid);
int isblank(int c);
int linkat(int fd1, const char *file1,
           int fd2, const char *file2, int flag);
int tolower(int);
int u8_uctomb(unsigned char *s, unsigned int uc, int n);
int unlinkat(int fd, char const *name, int flag);
int utimensat(int fd, const char *file, struct timespec const times[2],
              int flag);
int vasprintf(char **resultp, const char *format, va_list args);
int vms_fifo_write_pipe(int *pipe_fd);
unsigned long vms_gethostid(void);
int xgetgroups(char const *username, gid_t gid, gid_t **groups);



#endif /* _VMS_COREUTILS_HACKS_H */