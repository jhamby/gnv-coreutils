#include "vms_lstat_hack.h"

#include <stdlib.h>
#include <stdio.h>

char * vms_to_unix(const char * vms_spec);

int main(int argc, char **argv) {

    int x;
    chdir(argv[1]);

    x = rmdir(argv[2]);
    if (x != 0)
        perror("rmdir");

}
