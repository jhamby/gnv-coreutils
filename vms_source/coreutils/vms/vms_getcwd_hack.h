/* File: vms_getcwd_hack.h
 *
 * Copyright 2011, John Malmberg
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


#define getcwd decc$getcwd
#include <vms_sys_library/unistd.h>
#undef getcwd

#define decc_getcwd decc$getcwd

#pragma extern_prefix NOCRTL (getcwd)

static char * vms_getcwd(char * buffer, unsigned int size, ...)
{
  int real_size;
  char * result;

    real_size = 0;
    if ((buffer == NULL) && (size == 0))
      {
	real_size = 4097;
      }

    result = decc_getcwd(buffer, real_size, 0);

    return result;
}

#define getcwd vms_getcwd
