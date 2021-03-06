/* File: vms_pstat_hack.h
 *
 * A hack to make it look like the pstat feature is present on VMS.
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
 */

/* Used in physmem.c */

#define HAVE_PSTAT_GETSTATIC 1
#define HAVE_PSTAT_GETDYNAMIC 1

sruct pss_static {
    double physical_memory;
    double page_size;
}

static int pstat_getstatic(
    struct pst_static *buf, size_t elemsize, size_t elemcount,
    int index) {
	return -1;
}

struct pst_dynamic {
    double psd_free;
}

int pstat_getdynamic(
    struct pst_dynamic *buf, size_t elemsize, size_t elemcount,
    int index) {
	return -1;
}

#if 0  /* Sample use */
   { /* This works on hpux11.  */
     struct pst_static pss;
     if (0 <= pstat_getstatic (&pss, sizeof pss, 1, 0))
       {
         double pages = pss.physical_memory;
         double pagesize = pss.page_size;
         if (0 <= pages && 0 <= pagesize)
           return pages * pagesize;
       }
   }
#endif

