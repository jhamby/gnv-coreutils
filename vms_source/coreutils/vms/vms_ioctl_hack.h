/* File: vms_ioctl_hack.h
 *
 * ioctl emulation implemented for coreutils.
 *
 * The VMS ioctl() implmentation only works on sockets.  Unix programs
 * expect that all file descriptors can be used for socket routines.
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

/* src/wc.c has a struct fstatus and stropts.h pulls in a definition */
#define fstatus hide_fstatus

#include <stropts.h>
#include <errno.h>
#include <vms_term.h>

#undef fstatus


/* coreutils expects a failure code of EINVAL not EBADF */
/* If needed, this may be able to be expanded to simulate some of the */
/* functions. */

#if __CRTL_VER >= 70000000
    int decc$ioctl (int __sd, int __r, void * __argp);
    static int vms_ioctl(int __sd, int __r, void * __argp) {
        int result;

	/* Get the terminal size */
	if (__r == TIOCGWINSZ) {
	    struct winsize *ws;
	    int xx;
	    char *bp="x"; /* Ignored */
	    char *name;

	    name = getenv("TERM");
	    xx = vms_tgetent(bp, name);
	    ws = (void *)__argp;
	    result = vms_tgetnum("co");
	    if (result <= 0) {
		return -1;
	    }
	    ws->ws_col = result;
	    result = vms_tgetnum("li");
	    if (result <= 0) {
		return -1;
	    }
	    ws->ws_row = result;
	    return 0;
	}
        result = decc$ioctl(__sd, __r, __argp);
        if (result == -1) {
            if (errno == EBADF)
                errno = EINVAL;
        }
        return result;
    }
    #define ioctl(__a, __b, __c) vms_ioctl(__a, __b, __c)
#else
    static int ioctl (int __sd, int __r, void * __argp) {
        errno = ENOSYS;
        return -1;
    }
#endif
