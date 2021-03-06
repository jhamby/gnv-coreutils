/* File: vms_uname_hack.h
 *
 * This module puts wrappers around the uname() function to fix up the
 * machine name.
 *
 * Copyright 2016, John Malmberg
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

/* First we have to hide the VMS supplied uname routine
 * with a define, and pull in the original header.
 * This sets other defines to prevent the header from being loaded again.
 */

#ifndef VMS_UNAME_HACK_H
#define VMS_UNAME_HACK_H

#include <utsname.h>

#include <ctype.h>


/* Replacement routines, set up as static routines so that the compiler
 * can optimize inline when possible.
 */
static int vms_uname(struct utsname * uname_info) {

    int result;
    int i;

    result = uname(uname_info);
    if (result != 0) {
        return result;
    }
    i = 0;
    /* Fix: HP_rx2600__(1.50GHz/6.0MB) for use as a directory name */
    while (uname_info->machine[i] != 0) {
       char c;
       c = uname_info->machine[i];
       if (!(isalnum(c) || c == '_')) {
           uname_info->machine[i] = '_';
       }
       i++;
    }
}

/* Now make the replacement routines and structures visible */
#define uname vms_uname

#endif
