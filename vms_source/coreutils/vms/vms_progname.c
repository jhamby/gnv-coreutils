/* File: vms_progname.c
 *
 * This module provides a fixup of the program name.
 *
 * Make sure that the argv[0] string is set as close as possible to
 *    what the original command was given.
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


#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#include <descrip.h>
#include <dvidef.h>
#include <efndef.h>
#include <fscndef.h>
#include <iledef.h>
#include <iosbdef.h>
#include <stsdef.h>
#include <starlet.h>

#include "progname.h"

/* String containing name the program is called with.
   To be initialized by main().  */

const char *program_name = NULL;

static char vms_new_nam[256];

char const * getprogname(void) {
   return program_name;
}

void set_program_name(const char *argv0) {
int status;
int result;

#ifdef DEBUG
    printf("original argv0 = %s\n", argv0);
#endif

    /* Posix requires non-NULL argv[0] */
    if (argv0 == NULL) {
        fputs ("A NULL argv[0] was passed through an exec system call.\n",
               stderr);
        abort();
    }

    program_name = argv0;

    result = 0;

    /* If the path name starts with a /, then it is an absolute path	     */
    /* that may have been generated by the CRTL instead of the command name  */
    /* If it is the device name between the slashes, then this was likely    */
    /* from the run command and needs to be fixed up.			     */
    /* If the DECC$POSIX_COMPLIANT_PATHNAMES is set to 2, then it is the     */
    /* DISK$VOLUME that will be present, and it will still need to be fixed. */
    if (argv0[0] == '/') {
	char * nextslash;
	int length;
	struct _ile3 itemlist[3];
	struct _iosb dvi_iosb;
	char alldevnam[64];
	unsigned short alldevnam_len;
	struct dsc$descriptor_s devname_dsc;
	char diskvolnam[256];
	unsigned short diskvolnam_len;

	  /* Get some information about the disk */
	/*--------------------------------------*/
	itemlist[0].ile3$w_length = (sizeof alldevnam) - 1;
	itemlist[0].ile3$w_code = DVI$_ALLDEVNAM;
	itemlist[0].ile3$ps_bufaddr = alldevnam;
	itemlist[0].ile3$ps_retlen_addr = &alldevnam_len;
	itemlist[1].ile3$w_length = (sizeof diskvolnam) - 1 - 5;
	itemlist[1].ile3$w_code = DVI$_VOLNAM;
	itemlist[1].ile3$ps_bufaddr = &diskvolnam[5];
	itemlist[1].ile3$ps_retlen_addr = &diskvolnam_len;
	itemlist[2].ile3$w_length = 0;
	itemlist[2].ile3$w_code = 0;

	/* Add the prefix for the volume name. */
	/* SYS$GETDVI will append the volume name to this */
	strcpy(diskvolnam,"DISK$");

	nextslash = strchr(&argv0[1], '/');
	if (nextslash != NULL) {
	    length = nextslash - argv0 - 1;

	    /* Cast needed for HP C compiler diagnostic */
	    devname_dsc.dsc$a_pointer = (char *)&argv0[1];
	    devname_dsc.dsc$w_length = length;
	    devname_dsc.dsc$b_dtype = DSC$K_DTYPE_T;
	    devname_dsc.dsc$b_class = DSC$K_CLASS_S;

	    status = SYS$GETDVIW
	       (EFN$C_ENF,
		0,
		&devname_dsc,
		itemlist,
		&dvi_iosb,
		NULL, 0, 0);
	    if (!$VMS_STATUS_SUCCESS(status)) {
		/* If the sys$getdviw fails, then this path was passed by */
		/* An exec() program and not from DCL, so do nothing */
		/* An example is "/tmp/program" where tmp: does not exist */
#ifdef DEBUG
		printf("sys$getdviw failed with status %d\n", status);
#endif
		result = 0;
	    } else if (!$VMS_STATUS_SUCCESS(dvi_iosb.iosb$w_status)) {
#ifdef DEBUG
		printf("sys$getdviw failed with iosb %d\n", dvi_iosb.iosb$w_status);
#endif
		result = 0;
	    } else {
		char * devnam;
		int devnam_len;
		char argv_dev[64];

		/* Null terminate the returned alldevnam */
		alldevnam[alldevnam_len] = 0;
		devnam = alldevnam;
		devnam_len = alldevnam_len;

		/* Need to skip past any leading underscore */
		if (devnam[0] == '_') {
		    devnam++;
		    devnam_len--;
		}

		/* And remove the trailing colon */
		if (devnam[devnam_len - 1] == ':') {
		    devnam_len--;
		    devnam[devnam_len] = 0;
		}

		/* Null terminate the returned volnam */
		diskvolnam_len += 5;
		diskvolnam[diskvolnam_len] = 0;

		/* Check first for normal CRTL behavior */
		if (devnam_len == length) {
		    strncpy(vms_new_nam, &argv0[1], length);
		    vms_new_nam[length] = 0;
		    result = (strcasecmp(devnam, vms_new_nam) == 0);
		}

		/* If we have not got a match check for POSIX Compliant */
		/* behavior.  To be more accurate, we could also check */
		/* to see if that feature is active. */
		if ((result == 0) && (diskvolnam_len == length)) {
		    strncpy(vms_new_nam, &argv0[1], length);
		    vms_new_nam[length] = 0;
		    result = (strcasecmp(diskvolnam, vms_new_nam) == 0);
		}
	    }
	}
    } else {
	/* The path did not start with a slash, so it could be VMS format */
	/* If it is vms format, it has a volume/device in it as it must   */
	/* be an absolute path */
	struct dsc$descriptor_s path_desc;
	int status;
	unsigned int field_flags;
	struct _ile2 item_list[5];
	char * volume;
	char * name;
	int name_len;
	char * ext;

	path_desc.dsc$a_pointer = (char *)argv0; /* cast ok */
	path_desc.dsc$w_length = strlen(argv0);
	path_desc.dsc$b_dtype = DSC$K_DTYPE_T;
	path_desc.dsc$b_class = DSC$K_CLASS_S;

	/* Don't actually need to initialize anything buf itmcode */
	/* I just do not like uninitialized input values */

	/* Sanity check, this must be the same length as input */
	item_list[0].ile2$w_code = FSCN$_FILESPEC;
	item_list[0].ile2$w_length = 0;
	item_list[0].ile2$ps_bufaddr = NULL;

	/* If the device is present, then it if a VMS spec */
	item_list[1].ile2$w_code = FSCN$_DEVICE;
	item_list[1].ile2$w_length = 0;
	item_list[1].ile2$ps_bufaddr = NULL;

	/* we need the program name and type */
	item_list[2].ile2$w_code = FSCN$_NAME;
	item_list[2].ile2$w_length = 0;
	item_list[2].ile2$ps_bufaddr = NULL;

	item_list[3].ile2$w_code = FSCN$_TYPE;
	item_list[3].ile2$w_length = 0;
	item_list[3].ile2$ps_bufaddr = NULL;

	/* End the list */
	item_list[4].ile2$w_code = 0;
	item_list[4].ile2$w_length = 0;
	item_list[4].ile2$ps_bufaddr = NULL;

	status = SYS$FILESCAN(
		(struct dsc$descriptor_s *)&path_desc,
		item_list, &field_flags, NULL, NULL);


	if ($VMS_STATUS_SUCCESS(status) &&
	   (item_list[0].ile2$w_length == path_desc.dsc$w_length) &&
	   (item_list[1].ile2$w_length != 0)) {

	    char * dollar;
	    int keep_ext;
	    int i;

	    /* We need the filescan to be successful, */
	    /* same length as input, and a volume to be present */

	    /* We will assume that we only get to this path on a version */
	    /* of VMS that does not support the EFS character set */

	    /* There may be a xxx$ prefix on the image name.  Linux */
	    /* programs do not handle that well, so strip the prefix */
	    name = item_list[2].ile2$ps_bufaddr;
	    name_len = item_list[2].ile2$w_length;
	    dollar = strrchr(name, '$');
	    if (dollar != NULL) {
		dollar++;
		name_len = name_len - (dollar - name);
		name = dollar;
	    }

	    strncpy(vms_new_nam, name, name_len);
	    vms_new_nam[name_len] = 0;

	    /* Commit to using the new name */
	    program_name = vms_new_nam;

	    /* We only keep the extension if it is not ".exe" */
	    keep_ext = 0;
	    ext = item_list[3].ile2$ps_bufaddr;

	    if (item_list[3].ile2$w_length != 1) {
		keep_ext = 1;
		if (item_list[3].ile2$w_length == 4) {
		    if ((ext[1] == 'e' || ext[1] == 'E') &&
		        (ext[2] == 'x' || ext[2] == 'X') &&
		        (ext[3] == 'e' || ext[3] == 'E')) {
			    keep_ext = 0;
		    }
		}
	    }

	    if (keep_ext == 1) {
		strncpy(&vms_new_nam[name_len], ext, item_list[3].ile2$w_length);
	    }
	}
    }

    if (result) {
	char * lastslash;
	char * dollar;
	char * dotexe;
	char * lastdot;
	char * extension;

	/* This means it is probably the name from a DCL command */
	/* Find the last slash which separates the file from the */
	/* path. */
	lastslash = strrchr(argv0, '/');

	if (lastslash != NULL) {
	    int i;

	    lastslash++;

	    /* There may be a xxx$ prefix on the image name.  Linux */
	    /* programs do not handle that well, so strip the prefix */
	    dollar = strrchr(lastslash, '$');

	    if (dollar != NULL) {
		dollar++;
		lastslash = dollar;
	    }

	    strcpy(vms_new_nam, lastslash);

	    /* In UNIX mode + EFS character set, there should not be a */
	    /* version present, as it is not possible when parsing to  */
	    /* tell if it is a version or part of the UNIX filename as */
	    /* UNIX programs use numeric extensions for many reasons.  */

	    lastdot = strrchr(vms_new_nam, '.');
	    if (lastdot != NULL) {
		int i;

		i = 1;
		while (isdigit(lastdot[i])) {
		    i++;
		}
		if (lastdot[i] == 0) {
		    *lastdot = 0;
		}
	    }

	    /* Find the .exe on the name (case insenstive) and toss it */
	    dotexe = strrchr(vms_new_nam, '.');
	    if (dotexe != NULL) {
		if ((dotexe[1] == 'e' || dotexe[1] == 'E') &&
		    (dotexe[2] == 'x' || dotexe[2] == 'X') &&
		    (dotexe[3] == 'e' || dotexe[3] == 'E') &&
		    (dotexe[4] == 0)) {

		    *dotexe = 0;
		} else {
		    /* Also need to handle a null extension because of a */
		    /* CRTL bug. */
		    if (dotexe[1] == 0) {
			*dotexe = 0;
		    }
		}
	    }

	    /* Commit to new name */
	    program_name = vms_new_nam;

	} else {
	    /* There is no way that the code should ever get here */
	    /* As we already verified that the '/' was present */
	    fprintf(stderr, "Sanity failure somewhere we lost a '/'\n");
	}

    }

}

#ifdef DEBUG

int main(int argc, char ** argv, char **env) {

    set_program_name(argv[0]);
    printf("modified argv[0] = %s\n", program_name);

    return 0;
}

#endif
