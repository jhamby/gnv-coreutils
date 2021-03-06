#ifndef _POSIX_EXIT
#define _POSIX_EXIT=1
#endif
#include <stdlib.h>
#include <stdio.h>

int vms_execvp (const char *file_name, char * argv[]);

int main(int argc, char ** argv) {

int status;

   if (argc < 2) {
       exit(EXIT_FAILURE);
   }

   status = vms_execvp(argv[1], &argv[1]);
   if (status < 0) {
       perror("vms_execvp");
   }
}
