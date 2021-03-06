/* File: vms_rename_hack.h
 *
 * rename emulation implemented for coreutils.
 *
 * The VMS rename() returns the wrong error code on failure.
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

#include <stdio.h>
#include <errno.h>

int decc$rename (const char * __old, const char * __new);

static int vms_rename(const char * __old, const char * __new) {

    int result;

    result = decc$rename(__old, __new);
    if (result == 0) {
	return result;
    }
    if (errno == ENOENT) {
        /* The copy/mv utility already verified that the source exists */
        /* Which means that the failure is probably EXDEV or something else */
        /* This will case a copy operation to be tried */
	errno = EXDEV;
    }
    return result;
}

#define rename(__a, __b) vms_rename(__a, __b)
