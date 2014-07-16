#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <signal.h>
#include <sys/socket.h>
#include "assert.h"

#include "common.h"
#include "ezp-lib.h"
#include "ezp.h"
enum con_type{
    CH341=0
};

int
valid_togopower(webs_t wp, char *value, struct variable *v)
{
    return TRUE;
}

int
save_togopower(webs_t wp, char *value, struct variable *v, struct service *s)
{
    int fd = socket(AF_INET,SOCK_DGRAM,0);  
    struct sockaddr_in addr={};  
    char *type, *id, *togo_action;
    char contype; 
    char tmp[LONG_BUF_LEN],i, output[LONG_BUF_LEN];
    unsigned char checksum;
    addr.sin_family = AF_INET;  
    addr.sin_port = htons(6666);  
    addr.sin_addr.s_addr=inet_addr("127.0.0.1");  

    snprintf(tmp, sizeof(tmp), "type");
    type = websGetVar(wp, tmp, "");
    snprintf(tmp, sizeof(tmp), "id");
    id = websGetVar(wp, tmp, "");
    snprintf(tmp, sizeof(tmp), "togo_action");
    togo_action = websGetVar(wp, tmp, "");
    checksum=atoi(togo_action)+0xa6;
    if (!strcmp(type,"ch341")) contype=CH341;
    snprintf(output, sizeof(output), "type=%d,id=%s,action=%2s,checksum=%2X,", contype, id, togo_action, checksum);
    sendto(fd,&output,strlen(output)+1,0,(struct sockaddr*)&addr,sizeof(addr));  
    close(fd);  

    return 0;
}
