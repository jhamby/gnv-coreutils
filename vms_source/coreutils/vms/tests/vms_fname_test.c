#include <stdlib.h>
#include <stdio.h>

char * vms_to_unix(const char * vms_spec);

int main(int argc, char **argv) {

    char * unix_spec;

    unix_spec = vms_to_unix(argv[1]);
    puts(unix_spec);

}
