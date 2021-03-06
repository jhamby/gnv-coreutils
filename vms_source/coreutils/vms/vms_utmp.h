/* File: vms_utmp.h
 *
 * Help to fake it that VMS has utmp.h support.
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

/* HAVE_STRUCT_UTMP_UT_USER */
/* HAVE_STRUCT_UTMP_UT_PID */
/* HAVE_UT_HOST */

#define UT_NAMESIZE 16
#define UT_LINESIZE 64
#define UT_HOSTSIZE 256

/* ut_type - Only define the types that can exist on VMS */
#define EMPTY 0          /* Record does not contain valid info */
/* #define RUN_LVL 1 */  /* Change in system run-level */
#define BOOT_TIME 2      /* Time of system boot */
/* #define NEW_TIME 3 */ /* Time after system clock change in ut_tv */
/* #define OLD_TIME 4 */ /* Time before system clock change in ut_tv */

#define INIT_PROCESS 5        /* Process spawned by init(8) */
/* #define LOGIN_PROCESS 6 */ /* Session leader for user login */
#define USER_PROCESS 7        /* Normal user process */
/* #define DEAD_PROCESS 8 */  /* Terminated process */
/* #define ACCOUNTING 9 */    /* Not implemented */

struct utmp {
    short       ut_type;               /* Type of record */
    pid_t       ut_pid;                /* pid of process */
    time_t      ut_time;               /* Time entry was made */
    char        ut_line[UT_LINESIZE];  /* Device name of login */
    char        ut_user[UT_NAMESIZE];  /* Logged in user */
    char        ut_host[UT_HOSTSIZE];  /* Hostname for remote login */
};
