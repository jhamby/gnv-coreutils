/* File: vms_gethostid.c
 *
 * gethostid emulation implemented for coreutils.
 *
 * For VMS just return the scssystemid.
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

#include <syidef.h>
#include <efndef.h>
#include <iledef.h>
#include <iosbdef.h>
#include <stsdef.h>
#include <descrip.h>
#include <errno.h>
#include <stdio.h>
#include <starlet.h>

unsigned long vms_gethostid(void) {

    int status;
    struct _ile3 syi_items[2];
    unsigned long result;
    unsigned short result_len;
    struct _iosb syi_iosb;

    syi_items[0].ile3$w_code = SYI$_SCSSYSTEMID;
    syi_items[0].ile3$w_length = 4;
    syi_items[0].ile3$ps_bufaddr = &result;
    syi_items[0].ile3$ps_retlen_addr = &result_len;
    syi_items[1].ile3$w_code = 0;
    syi_items[1].ile3$w_length = 0;

    /* Just get the scssystemid, it is as good as any other number */
    /* At least it will probably be unique amoung VMS systems in the network */
    status = SYS$GETSYIW(EFN$C_ENF, 0, NULL, syi_items, &syi_iosb, NULL, 0);
    if ($VMS_STATUS_SUCCESS(status) && $VMS_STATUS_SUCCESS(syi_iosb.iosb$w_status)) {
        return result;
    }
    errno = ENOSYS;
    return 0;
}
