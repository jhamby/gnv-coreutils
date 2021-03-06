/* File: mount.h / vms_mount.h
 *
 * VMS defintions needed for a getmntinfo() implementation.
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
 * 11-Sep-2013	J. Malmberg	Original
 *
 ***************************************************************************/

#define getmntinfo vms_getmntinfo

#define MNT_NOWAIT 0

#define MFSNAMELEN 16 /* length of type name */
#define MNAMELEN   256 /* Size of on/from name bufs */

/* Just the fields that coreutils is currently using */

struct statfs {
    char f_fstypename[MFSNAMELEN]; /* filesytsem type name */
    char f_mntfromname[MNAMELEN];  /* mounted filesystem */
    char f_mntonname[MNAMELEN];    /* directory on which mounted */
};

int vms_getmntinfo(struct statfs **mntbufp, int flags);
