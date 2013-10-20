/* GNU's read utmp module modifed for VMS simulation.

   Copyright (C) 1992-2001, 2003-2006, 2009-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* Written by jla; revised by djm */

#include <config.h>

#include "readutmp.h"

#include <errno.h>
#include <stdio.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#include <jpidef.h>
#include <syidef.h>
#include <efndef.h>
#include <stsdef.h>
#include <ssdef.h>
#include <descrip.h>

#pragma member_alignment save
#pragma nomember_alignment longword
struct item_list_3 {
        unsigned short len;
        unsigned short code;
        void * bufadr;
        unsigned short * retlen;
};
#pragma member_alignment restore

#pragma message save
#pragma message disable noparmlist

int SYS$GETJPIW
       (unsigned long efn,
        pid_t * pid,
        const struct dsc$descriptor_s * procname,
        const struct item_list_3 * itmlst,
        void * iosb,
        void (* astadr)(__unknown_params),
        void * astprm);

int SYS$GETSYIW
       (unsigned long efn,
        unsigned long * ,
        const struct dsc$descriptor_s * nodename,
        const struct item_list_3 * itmlst,
        void * iosb,
        void (* astadr)(__unknown_params),
        void * astprm,
        void * nullarg);

#pragma message restore

unsigned long LIB$EDIV(const unsigned long *divisor,
                       const unsigned long *dividend,
                       unsigned long *quotent,
                       unsigned long *remainder);

#include "xalloc.h"

/* Copy UT->ut_name into storage obtained from malloc.  Then remove any
   trailing spaces from the copy, NUL terminate it, and return the copy.  */

char *
extract_trimmed_name (const STRUCT_UTMP *ut)
{
  char *p, *trimmed_name;

  trimmed_name = xmalloc (sizeof (UT_USER (ut)) + 1);
  strncpy (trimmed_name, UT_USER (ut), sizeof (UT_USER (ut)));
  /* Append a trailing NUL.  Some systems pad names shorter than the
     maximum with spaces, others pad with NULs.  Remove any trailing
     spaces.  */
  trimmed_name[sizeof (UT_USER (ut))] = '\0';
  for (p = trimmed_name + strlen (trimmed_name);
       trimmed_name < p && p[-1] == ' ';
       *--p = '\0')
    continue;
  return trimmed_name;
}

/* Is the utmp entry U desired by the user who asked for OPTIONS?  */

static bool
desirable_utmp_entry (STRUCT_UTMP const *u, int options)
{
  bool user_proc = IS_USER_PROCESS (u);
  if ((options & READ_UTMP_USER_PROCESS) && !user_proc)
    return false;
  if ((options & READ_UTMP_CHECK_PIDS)
      && user_proc
      && 0 < UT_PID (u)
      && (kill (UT_PID (u), 0) < 0 && errno == ESRCH))
    return false;
  return true;
}

/* Convert a VMS timestamp to Unix timestamp if possible */
static time_t unixtime_from_vmstime(const unsigned long * vmstime) {
    unsigned long newtime[2];
    unsigned long quotent[2];
    unsigned long remainder;
    const unsigned long divisor = 10000000;
    unsigned long status;
    const unsigned long unix_epoch_hi = 0x7c9567;
    const unsigned long unix_epoch_lo = 0x4beb4000;

    if (vmstime[1] < unix_epoch_hi) {
        return 0;
    }
    newtime[1] = vmstime[1] - unix_epoch_hi;
    if (vmstime[0] < unix_epoch_lo) {
        newtime[0] = vmstime[0] - unix_epoch_lo;
    } else {
        newtime[0] = vmstime[0] + unix_epoch_lo;
        newtime[1]--;
    }

    status = LIB$EDIV(&divisor, newtime, quotent, &remainder);
    if ($VMS_STATUS_SUCCESS(status)) {
        return quotent[0];
    }
    return 0;
}

/* Get VMS boot time.  Hopefully system was booted after 1-Jan-1970 */
time_t vms_read_boottime(void) {

    int status;
    time_t result;
    struct item_list_3 syi_items[2];
    unsigned long vms_boottime[2];
    unsigned short vms_boottime_len;
    unsigned short syi_iosb[4];

    syi_items[0].code = SYI$_BOOTTIME;
    syi_items[0].len = 8;
    syi_items[0].bufadr = &vms_boottime;
    syi_items[0].retlen = &vms_boottime_len;
    syi_items[1].code = 0;
    syi_items[1].len = 0;

    /* Get the boot time */
    status = SYS$GETSYIW(EFN$C_ENF, 0, NULL, syi_items, syi_iosb, NULL, 0, 0);
    if ($VMS_STATUS_SUCCESS(status) && $VMS_STATUS_SUCCESS(syi_iosb[0])) {
        result = unixtime_from_vmstime(vms_boottime);
        return result;
    }
    errno = ENOSYS;
    return 0;
}


unsigned long read_getjpi(STRUCT_UTMP * utmp, pid_t * context) {

    int pid_status;
    unsigned short ut_pid_len;
    struct item_list_3 jpi_items[8];
    unsigned short jpi_iosb[4];
    unsigned long jobmode;
    unsigned short jobmode_len;
    unsigned long jobtype;
    unsigned short jobtype_len;
    unsigned long logintim[2];
    unsigned short logintim_len;
    unsigned short ut_line_len;
    unsigned short ut_host_len;
    unsigned short ut_user_len;

    jpi_items[0].code = JPI$_PID;
    jpi_items[0].len = 4;
    jpi_items[0].bufadr = &utmp->ut_pid;
    jpi_items[0].retlen = &ut_pid_len;
    jpi_items[1].code = JPI$_MODE;
    jpi_items[1].len = 4;
    jpi_items[1].bufadr = &jobmode;
    jpi_items[1].retlen = &jobmode_len;
    jpi_items[2].code = JPI$_LOGINTIM;
    jpi_items[2].len = 8;
    jpi_items[2].bufadr = logintim;
    jpi_items[2].retlen = &logintim_len;
    jpi_items[3].code = JPI$_TERMINAL;
    jpi_items[3].len = UT_LINESIZE - 2;
    jpi_items[3].bufadr = &utmp->ut_line[1];
    jpi_items[3].retlen = &ut_line_len;
    jpi_items[4].code = JPI$_TT_ACCPORNAM;
    jpi_items[4].len = UT_HOSTSIZE - 1;
    jpi_items[4].bufadr = utmp->ut_host;
    jpi_items[4].retlen = &ut_host_len;
    jpi_items[5].code = JPI$_USERNAME;
    jpi_items[5].len = UT_NAMESIZE - 1;
    jpi_items[5].bufadr = utmp->ut_user;
    jpi_items[5].retlen = &ut_user_len;
    jpi_items[6].code = JPI$_JOBTYPE;
    jpi_items[6].len = 4;
    jpi_items[6].bufadr = &jobtype;
    jpi_items[6].retlen = &jobtype_len;
    jpi_items[7].code = 0;
    jpi_items[7].len = 0;

    utmp->ut_type = EMPTY;
    utmp->ut_time = 0;
    utmp->ut_line[0] = '/';
    utmp->ut_line[1] = 0;
    utmp->ut_host[0] = 0;
    utmp->ut_user[0] = 0;

    /* First get the pid, then the process info if we have privilege */
    pid_status = SYS$GETJPIW(EFN$C_ENF, context, NULL,
                            jpi_items, jpi_iosb, NULL, 0);
    if ($VMS_STATUS_SUCCESS(pid_status) && $VMS_STATUS_SUCCESS(jpi_iosb[0])) {
        int status;
        int i;

        if (jobmode == JPI$K_INTERACTIVE) {
            utmp->ut_type = USER_PROCESS;
            /* Unless it does not have a real terminal */
            /* Quick check for MBA devices, not a robust check */
            if ((ut_line_len == 0) || (utmp->ut_line[1] == 'M')) {
                utmp->ut_type = INIT_PROCESS;
            }
        } else {
            utmp->ut_type = INIT_PROCESS;
        }

        utmp->ut_time = unixtime_from_vmstime(logintim);
        utmp->ut_line[ut_line_len + 1] = 0;
        if (utmp->ut_line[ut_line_len] == ':') {
            utmp->ut_line[ut_line_len] = 0;
        }

        /* Fix the lengths */
        i = ut_line_len - 1;
        while (utmp->ut_line[i] == ' ') {
            utmp->ut_line[i] = 0;
            i--;
            ut_line_len--;
            if (i == 0) {
                break;
            }
        }
        if (utmp->ut_line[1] == 0) {
            utmp->ut_line[0] = 0;
        } else {
            /* The who utility expects these in lower case */
            for (i = 1; i < ut_line_len; i++) {
                utmp->ut_line[i] = tolower(utmp->ut_line[i]);
            }
        }

        utmp->ut_host[ut_user_len] = 0;
        i = ut_host_len - 1;
        while (utmp->ut_host[i] == ' ') {
            utmp->ut_host[i] = 0;
            i--;
            if (i == 0) {
                break;
            }
        }

        utmp->ut_user[ut_user_len] = 0;
        i = ut_user_len - 1;
        while (utmp->ut_user[i] == ' ') {
            utmp->ut_user[i] = 0;
            i--;
            if (i == 0) {
                break;
            }
        }
        return pid_status;
    }
    if (pid_status == SS$_NORMAL) {
        pid_status = jpi_iosb[0];
    }
    return pid_status;

}


/* Read the utmp entries corresponding to file FILE into freshly-
   malloc'd storage, set *UTMP_BUF to that pointer, set *N_ENTRIES to
   the number of entries, and return zero.  If there is any error,
   return -1, setting errno, and don't modify the parameters.
   If OPTIONS & READ_UTMP_CHECK_PIDS is nonzero, omit entries whose
   process-IDs do not currently exist.  */


int
read_utmp (char const *file, size_t *n_entries, STRUCT_UTMP **utmp_buf,
           int options)
{
  size_t n_read = 0;
  size_t n_alloc = 0;
  STRUCT_UTMP *utmp = NULL;
  pid_t context;
  int status;

  context = -1;

  /* First record is the boot time */
  utmp = x2nrealloc (utmp, &n_alloc, sizeof *utmp);
  utmp[n_read].ut_type = BOOT_TIME;
  utmp[n_read].ut_time = vms_read_boottime();
  n_read += desirable_utmp_entry (&utmp[n_read], options);

  /* Then the process list */
  for (;;)
    {
      if (n_read == n_alloc)
        utmp = x2nrealloc (utmp, &n_alloc, sizeof *utmp);

        status = read_getjpi(&utmp[n_read], &context);
        if ($VMS_STATUS_SUCCESS(status)) {
          n_read += desirable_utmp_entry (&utmp[n_read], options);
        }
        if (!((status == SS$_NOPRIV) ||
              (status == SS$_SUSPENDED) ||
              $VMS_STATUS_SUCCESS(status))) {
            break;
        }
    }
  *n_entries = n_read;
  *utmp_buf = utmp;

  return 0;
}