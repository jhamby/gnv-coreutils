#include <errno.h>
#include <unixlib.h>

#define __NEW_STARLET 1
#include <descrip.h>
#include <stsdef.h>
#include <lib$routines.h>

/*
** Sets current value for a feature
*/
static void set(const char *name, int value) {
    errno = 0;
    int index = decc$feature_get_index(name);
    if (index > 0) {
        decc$feature_set_value(index, 1, value);
    }
}

void vms_set_crtl_values(void) {
    set ("DECC$UNIX_LEVEL", 100);

    const char *disable_feature[] = {
        "DECC$EFS_CASE_SPECIAL",
        "DECC$DETACHED_CHILD_PROCESS",  // DECC$UNIX_LEVEL 90
        "DECC$POSIX_STYLE_UID",         // else getpwuid() doesn't work, DECC$UNIX_LEVEL 90

        "DECC$DISABLE_POSIX_ROOT",        // default is enabled
    };

    const char *enable_feature[] = {
//        "DECC$EFS_FILE_TIMESTAMPS",       // DECC$UNIX_LEVEL 30
        "DECC$ENABLE_GETENV_CACHE",
        "DECC$EXIT_AFTER_FAILED_EXEC",
//        "DECC$FILE_SHARING",              // DECC$UNIX_LEVEL 30
        "DECC$MAILBOX_CTX_STM",
        "DECC$POPEN_NO_CRLF_REC_ATTR",
//        "DECC$POSIX_SEEK_STREAM_FILE",    // DECC$UNIX_LEVEL 1

//        "DECC$ARGV_PARSE_STYLE",          // DECC$UNIX_LEVEL 10
//        "DECC$DISABLE_TO_VMS_LOGNAME_TRANSLATION",  // implied by DECC$FILENAME_UNIX_ONLY, DECC$UNIX_LEVEL 20
//        "DECC$EFS_CASE_PRESERVE",         // DECC$UNIX_LEVEL 10
//        "DECC$EFS_CHARSET",               // DECC$UNIX_LEVEL 20
//        "DECC$FILENAME_UNIX_NO_VERSION",  // DECC$UNIX_LEVEL 20
//        "DECC$FILENAME_UNIX_REPORT",    // DECC$UNIX_LEVEL 20
//        "DECC$READDIR_DROPDOTNOTYPE",     // DECC$UNIX_LEVEL 20
//        "DECC$RENAME_NO_INHERIT",         // DECC$UNIX_LEVEL 20

        "DECC$ACL_ACCESS_CHECK",
//        "DECC$STDIO_CTX_EOL",             // DECC$UNIX_LEVEL 10
        "DECC$ALLOW_REMOVE_OPEN_FILES",
//        "DECC$FILENAME_UNIX_ONLY",        // DECC$UNIX_LEVEL 90
//        "DECC$FILE_PERMISSION_UNIX",      // DECC$UNIX_LEVEL 30
//        "DECC$FILE_OWNER_UNIX",           // DECC$UNIX_LEVEL 30
        "DECC$STREAM_PIPE",
//        "DECC$GLOB_UNIX_STYLE",           // DECC$UNIX_LEVEL 20
        "DECC$UNIX_PATH_BEFORE_LOGNAME",  // overrides DECC$DISABLE_TO_VMS_LOGNAME_TRANSLATION
//        "DECC$STRTOL_ERANGE",             // DECC$UNIX_LEVEL 1

//        "DECC$FIXED_LENGTH_SEEK_TO_EOF",  // DECC$UNIX_LEVEL 1
//        "DECC$SELECT_IGNORES_INVALID_FD", // DECC$UNIX_LEVEL 1
//        "DECC$VALIDATE_SIGNAL_IN_KILL",   // DECC$UNIX_LEVEL 1
//        "DECC$PIPE_BUFFER_SIZE" = 4096  // DECC$UNIX_LEVEL 10
//        "DECC$USE_RAB64",                 // DECC$UNIX_LEVEL 10
//        "DECC$USE_JPI$_CREATOR",          // DECC$UNIX_LEVEL 90
    };

    for(int i = 0; i < sizeof(disable_feature)/sizeof(disable_feature[0]); ++i) {
        set (disable_feature[i], 0);
    }

    for(int i = 0; i < sizeof(enable_feature)/sizeof(enable_feature[0]); ++i) {
        set (enable_feature[i], 1);
    }

    set ("DECC$EXEC_FILEATTR_INHERITANCE", 2);  // DECC$UNIX_LEVEL 30 sets to 1

    // set ("DECC$POSIX_COMPLIANT_PATHNAMES", 1);  // required for realpath(), but getcwd() is failed
     /* Pipe feature settings are no longer needed with virtual memory pipe
        code. Programs that use pipe need to be converted to use the
        virtual memory pipe code, which effectively removes the hangs and
        left over temporary files.

        Comment left here to prevent regressions, as the larger pipe size
        actually hurts memory usage with the new algorithm.
     */
    /* do_not_set ("DECC$PIPE_BUFFER_SIZE", 65535); */

    // decc$set_reentrancy(C$C_MULTITHREAD);    // not required for coreutils
}
