/* File: vms_sysctl_hack.h
 *
 * sysctl emulation implemented for coreutils.
 *
 * The uname utility needs this for the processor and machine type.
 *
 * We could use sys$getsyi() in the future to get the a more precise
 * machine type.
 *
 * For now just use the arch member returned by utime().
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
 */

#include <errno.h>
#include <utsname.h>

#define UNAME_PROCESSOR 1
#define UNAME_HARDWARE_PLATFORM 2

#define CTL_HW 1

/* #define HW_NCPU 1 */ /* Used for NPROC.LIS - not needed */

/* #define HW_PHYSMEM 2 */ /* Used for physmen.lis - 2 GB limit */

/* #Defining CTL_KERN and KERN_BOOTTIME used by uptime.c - not needed. */

/* Read or write system parameters.  */
static int sysctl (int *mib, int nlen, void *oldval,
                   size_t *oldlenp, void *newval, size_t newlen) {

struct utsname name;

    if (uname (&name) == -1) {
        return -1;
    }

    /* Only support CTL_HW */
    if (mib[0] != CTL_HW) {
        errno = ENOSYS;
        return -1;
    }
    if (nlen < 2) {
        errno = EINVAL;
        return -1;
    }
    switch(mib[1]) {
#ifndef _POSIX_C_SOURCE
    case UNAME_PROCESSOR:
    case UNAME_HARDWARE_PLATFORM:
        /* *oldlenp is size limit */
        /* *oldval is where to put the name */
        strncpy(oldval, name.arch, *oldlenp);
        return 1;
#endif
    default:
        errno = ENOSYS;
        return -1;
   }
}
