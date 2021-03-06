/* File: vms_getmntinfo.c
 *
 * VMS routine to implement a getmntinfo() function.
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
 * 11-Sep-2013  J. Malmberg    Original
 *
 ***************************************************************************/

#ifdef DEBUG
#include <stdio.h>
#include "vms_mount.h"
#else
#include "sys/mount.h"
#endif

#include <stdlib.h>
#include <unixlib.h>
#include <string.h>

#include <dcdef.h>
#include <descrip.h>
#include <dvidef.h>
#include <dvsdef.h>
#include <efndef.h>
#include <gen64def.h>
#include <iledef.h>
#include <iosbdef.h>
#include <lnmdef.h>
#include <psldef.h>
#include <stsdef.h>
#include <starlet.h>


static struct statfs * vms__mntbufp = NULL;
static int vms__mntbufp_size = 0;

static void expand_buffer_if_needed(int dev_cnt) {
    if (dev_cnt == vms__mntbufp_size) {
        vms__mntbufp = realloc(vms__mntbufp, sizeof (struct statfs) * 100);
        vms__mntbufp_size += 100;
    }
}

#ifndef ME_REMOTE
/* A file system is remote if the name starts with _DNFS */
# define ME_REMOTE(Fs_name, Fs_type) \
   (strncmp(Fs_name, "_DNFS", 5) == 0)
#endif

static int vms_getdvi_fstype(const char * devname, char * fstype) {
    int status;
    struct _ile3 itemlist[2];
    struct _iosb dvi_iosb;
    int dvi_acp;
    unsigned short dvi_acp_len;
    struct dsc$descriptor_s devname_dsc;

     /* Get some information about the disk */
    /*--------------------------------------*/
    itemlist[0].ile3$w_length = sizeof dvi_acp;
    itemlist[0].ile3$w_code = DVI$_ACPTYPE;
    itemlist[0].ile3$ps_bufaddr = &dvi_acp;
    itemlist[0].ile3$ps_retlen_addr = &dvi_acp_len;
    itemlist[1].ile3$w_length = 0;
    itemlist[1].ile3$w_code = 0;

    /* Cast needed for HP C compiler diagnostic */
    devname_dsc.dsc$a_pointer = (char *)devname;
    devname_dsc.dsc$w_length = strlen(devname);
    devname_dsc.dsc$b_dtype = DSC$K_DTYPE_T;
    devname_dsc.dsc$b_class = DSC$K_CLASS_S;

    status = SYS$GETDVIW
       (EFN$C_ENF, 0,
        &devname_dsc,
        itemlist,
        &dvi_iosb,
        NULL, 0, 0, NULL);
    if (!$VMS_STATUS_SUCCESS(status) || !$VMS_STATUS_SUCCESS(dvi_iosb.iosb$w_status)) {
        strcpy(fstype, "error");
        return 0;
    }

    /* translate the code to text */
    switch(dvi_acp) {
    case DVI$C_ACP_F11V1:
        strcpy(fstype, "F11V1");
        break;
    case DVI$C_ACP_F11V2:
        strcpy(fstype, "F11V2");
        break;
    case DVI$C_ACP_F11V3:
        strcpy(fstype, "ISO9660");
        break;
    case DVI$C_ACP_F11V4:
        strcpy(fstype, "HighSierra");
        break;
    case DVI$C_ACP_F11V5:
        strcpy(fstype, "F11V5");
        break;
    case DVI$C_ACP_F11V6:
        strcpy(fstype, "F11V6");
        break;
    case DVI$C_ACP_F64:
        strcpy(fstype, "Spiralog");
        break;
    case DVI$C_ACP_HBVS:
        strcpy(fstype, "VOLSHAD");
        break;
    case DVI$C_ACP_UCX:
        strcpy(fstype, "TCPIP");
        break;
    default:
        strcpy(fstype, "Unknown");
    }
    return dvi_acp;
}


/* Get the disks mounted on the PSX$ROOT */

static int vms_get_mountpoints(int dev_cnt) {
    int status;
    $DESCRIPTOR(table_dsc, "LNM$MNT_DATABASE");
    $DESCRIPTOR (db_fao_dsc, "MNT_DB_!UL");
    $DESCRIPTOR (parent_dsc, "LNM$SYSTEM_DIRECTORY");
    unsigned char acmode = PSL$C_KERNEL;
    int lnm_index;
    unsigned short lnm_index_len = 4;
    unsigned short retname_len;

    int mp_cnt;
    struct _ile3 lnm_list[3];

    lnm_list[0].ile3$w_length = sizeof(int);
    lnm_list[0].ile3$w_code = LNM$_INDEX;
    lnm_list[0].ile3$ps_bufaddr = &lnm_index;
    lnm_list[0].ile3$ps_retlen_addr = &lnm_index_len;
    lnm_list[1].ile3$w_length = LNM$C_NAMLENGTH;
    lnm_list[1].ile3$w_code = LNM$_STRING;
    lnm_list[1].ile3$ps_bufaddr = NULL;
    lnm_list[1].ile3$ps_retlen_addr = &retname_len;
    lnm_list[2].ile3$w_length = 0;
    lnm_list[2].ile3$w_code = 0;

    mp_cnt = 0;
    do {
        char name[LNM$C_NAMLENGTH+1];
        char mntfrom[LNM$C_NAMLENGTH+1];
        char * new_path;
        struct dsc$descriptor_s name_dsc;

        expand_buffer_if_needed(dev_cnt);

        name_dsc.dsc$a_pointer = name;
        name_dsc.dsc$w_length = LNM$C_NAMLENGTH;
        name_dsc.dsc$b_dtype = DSC$K_DTYPE_T;
        name_dsc.dsc$b_class = DSC$K_CLASS_S;

        status = SYS$FAO(&db_fao_dsc,
                         &name_dsc.dsc$w_length,
                         &name_dsc, mp_cnt);
        if (!$VMS_STATUS_SUCCESS(status)) {
            /* Should only fail on a programming error */
            break;
        }

        lnm_list[1].ile3$ps_bufaddr = mntfrom;
        lnm_index = 0;
        status = SYS$TRNLNM(0, &table_dsc, &name_dsc, &acmode, lnm_list);
        if (!$VMS_STATUS_SUCCESS(status)) {
            break;
        }

        /* The name is probably expected in Unix format */
        mntfrom[retname_len] = 0;

        /* Get rid of the version */
        if ((mntfrom[retname_len - 2] == ';') &&
            (mntfrom[retname_len - 1] == '1')) {
            mntfrom[retname_len - 2] = 0;
        }

        strcpy(vms__mntbufp[dev_cnt].f_mntfromname, mntfrom);

        lnm_list[1].ile3$ps_bufaddr = vms__mntbufp[dev_cnt].f_mntonname;
        lnm_index = 1;
        status = SYS$TRNLNM(0, &table_dsc, &name_dsc, &acmode, lnm_list);
        if (!$VMS_STATUS_SUCCESS(status)) {
            break;
        }
        vms__mntbufp[dev_cnt].f_mntonname[retname_len] = 0;

        /* Find out the file system that is mounted */
        vms_getdvi_fstype(mntfrom, vms__mntbufp[dev_cnt].f_fstypename);

        mp_cnt++;
        dev_cnt++;
    } while ($VMS_STATUS_SUCCESS(status));

    return dev_cnt;
}

/* Get all the disks mounted */
int vms_getmntinfo(struct statfs **mntbufp, int flags) {

    int dev_cnt;
    unsigned long dc_disk = DC$_DISK;
    struct _ile3 dvs_list[2];

    /* Initialize the list */
    if (vms__mntbufp == NULL) {
        vms__mntbufp = malloc(sizeof (struct statfs) * 100);
        vms__mntbufp_size = 100;
    }

    /* Coreutils care about:
     * f_mntfromname
     * f_mntonname
     * f_fstypename
     */

    dev_cnt = 0;

    /* First get the PSX$ROOT mount points */
    dev_cnt = vms_get_mountpoints(dev_cnt);

    dvs_list[0].ile3$w_length = sizeof(int);
    dvs_list[0].ile3$w_code = DVS$_DEVCLASS;
    dvs_list[0].ile3$ps_bufaddr = &dc_disk;
    dvs_list[0].ile3$ps_retlen_addr = NULL;
    dvs_list[1].ile3$w_length = 0;
    dvs_list[1].ile3$w_code = 0;

    /* Then get the mounted disks */
    {
        struct _generic_64 dcontext = { 0 };
        unsigned short length;
        int status;
        struct dsc$descriptor_s res_filespec_dsc;
        struct dsc$descriptor_s def_filespec_dsc;
        char ret_name[64];
        unsigned short ret_name_len;
        int dsk_cnt;
        const char * template = "*";
        int dvi_acp;

        dsk_cnt  = 0;

        res_filespec_dsc.dsc$a_pointer = ret_name;
        res_filespec_dsc.dsc$w_length = sizeof (ret_name);
        res_filespec_dsc.dsc$b_dtype = DSC$K_DTYPE_T;
        res_filespec_dsc.dsc$b_class = DSC$K_CLASS_S;

        def_filespec_dsc.dsc$a_pointer = (char *)template;
        def_filespec_dsc.dsc$w_length = strlen(template);
        def_filespec_dsc.dsc$b_dtype = DSC$K_DTYPE_T;
        def_filespec_dsc.dsc$b_class = DSC$K_CLASS_S;

        do {
            char * new_path;
            char * slashptr;
            char * retnameptr;

            expand_buffer_if_needed(dev_cnt);

            status = SYS$DEVICE_SCAN(&res_filespec_dsc,
                                     &ret_name_len,
                                     &def_filespec_dsc,
                                     dvs_list,
                                     &dcontext);

            if (!$VMS_STATUS_SUCCESS(status)) {
                break;
            }
            ret_name[ret_name_len] = 0;

            retnameptr = ret_name;
            if (retnameptr[0] == '_') {
                retnameptr++;
            }
            new_path = decc$translate_vms(retnameptr);

            strcpy(vms__mntbufp[dev_cnt].f_mntfromname, ret_name);
            strcpy(vms__mntbufp[dev_cnt].f_mntonname, new_path);
            slashptr = strchr(&vms__mntbufp[dev_cnt].f_mntonname[1], '/');
            if (slashptr != NULL) {
                *slashptr = 0;
            }

            /* Find out the file system that is mounted */
            dvi_acp = vms_getdvi_fstype(ret_name,
                                        vms__mntbufp[dev_cnt].f_fstypename);

            if (dvi_acp != 0) {
                dsk_cnt++;
                dev_cnt++;
            }
        } while ($VMS_STATUS_SUCCESS(status));
    }

    *mntbufp = vms__mntbufp;
    return dev_cnt;

}

#ifdef DEBUG

int main(int argc, char **argv) {

int fs_count;
struct statfs * mntbufp;
int i;

    fs_count = vms_getmntinfo(&mntbufp, MNT_NOWAIT);
    printf ("mount count = %d\n", fs_count);
    i = 0;
    while (i < fs_count) {
        printf("From: %s, on: %s, type: %s\n",
               mntbufp[i].f_mntfromname,
               mntbufp[i].f_mntonname,
               mntbufp[i].f_fstypename);
        i++;
    }
}
#endif
