#include <stdio.h>
#include <stdlib.h>
/*#include <curses.h>*/
#include <signal.h>
#include <string.h>
#include <bcmnvram.h>
#include <fcntl.h>
#include "ezp-lib.h"
    
#define BUF_LEN     1024
#define skip_space(ptr) while (*ptr == ' ') { ptr++; }

static void
sig_handle(int sig)
{
    /* Ignore the signal */
    printf("Received a signal (%d).\n", sig);
    switch(sig)
    {
        case SIGHUP:{
            exit(0);
            }
            break;
        default:
            break;
    }
    return;
}

int
main()
{
    int i, fd, flags; 

    /* Catch all signals except SIGKILL. */
    for (i = 0; i < 15; i++) {
        signal(i, sig_handle);
    }

    while (1) {
        FILE *fp;
        char buf1[BUF_LEN], buf2[BUF_LEN];
        char *ptr, *ptr2, *ptrtok;

        printf("AXIMCom> ");
        ptr = fgets(buf1, sizeof(buf1), stdin);
        skip_space(ptr);

        if (*ptr == '\n') {
            continue;
        }

        /* If it is authenticated, perhibit all commands. */
        ptr2 = nvram_safe_get("license_invalid");
        if (*ptr2 == '0') {
            continue;
        }

        /* Allow iwpriv only */
        if (strtok(ptr, "`;\"'?<>|*&^%$@!\\.+-") && strtok(NULL, "`;\"'?<>|*&^%$@!\\.+-")) {
            printf("Illegal character: %s", ptr);
            continue;
        }
        if (strncmp(ptr, "iwpriv", 6) && strncmp(ptr, "ated", 4) && strncmp(ptr, "security_ic", 11)) {
            printf("Illegal command: %s", ptr);
            continue;
        }

        if (!strncmp(ptr,   "security_ic", 11)) {
            FILE * pFile;
            long lSize;
            char * buffer;
            size_t result;
            pFile = fopen ( "/tmp/ezp-i2c_security" , "rb" );
            if (pFile==NULL) {
                printf("No data\n");
                continue;
            }
            // obtain file size:
            fseek (pFile , 0 , SEEK_END);
            lSize = ftell (pFile);
            rewind (pFile);
            // allocate memory to contain the whole file:
            buffer = (char*) malloc (sizeof(char)*lSize);
            if (buffer == NULL) {
                printf("Memory error\n"); 
                continue;
            }
            // copy the file into the buffer:
            result = fread (buffer,1,lSize,pFile);
            if (result != lSize) {
                printf("Reading error\n");
                continue;
            }
            /* the whole file is now loaded in the memory buffer. */
            printf("%s\n",buffer);
            // terminate
            fclose (pFile);
            free (buffer);
            continue;
        }

        if (!(fp = popen(ptr, "r"))) {
            printf("Unable to execute this command: %s", ptr);
            continue;
        }
        if(strncmp(ptr, "ated", 4)) {
            while (fgets(buf2, sizeof(buf2), fp)) {
                printf("%s", buf2);
            }
        }

        pclose(fp);
    }
    return 0;
}
