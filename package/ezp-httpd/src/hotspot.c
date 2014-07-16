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

void save_to_rw(char *path,char *value)
{
    FILE *fp;
    char dir[TMP_LEN] = "/tmp/jffs2/";
    char authinfo[TMP_LEN] = {0};
    unsigned long l = TMP_LEN;

    strcat(dir,path);
    strcat(dir,".txt");

    strcpy(authinfo,value);
    if(strcmp(path,"hs_uam_allow"))
    {
	    base64_decode((unsigned char *)value, strlen(value),(unsigned char *)authinfo, &l);
	    authinfo[l] = '\0';
    }

    fp = fopen(dir,"w"); 
    fprintf(fp,"%s",authinfo);
    fclose(fp);
}

int valid_hotspot(webs_t wp, char *value, struct variable *v)
{
    return TRUE;
}

int save_hotspot(webs_t wp, char *value, struct variable *v, struct service *s)
{
    char *hs_server_rule[]={
	"enable","mode",
	"ipaddr","mask",
	"uam_allow"
    };
    char *hs_server[]={
	"hs_enable","hs_mode",
	"hs_static_ipaddr","hs_static_mask",
	"hs_uam_allow"
    };
    char *hs_tos_rule[]={
	"tos_enable","tos_contents"
    };
    char *hs_tos[]={
	"hs_tos_enable","hs_tos_text"
    };
    char *hs_pages_rule[]={
	"pages_mode","title",
	"header_elements_contents",
	"header_contents","welcome_contents",
	"tos_agreement","advertisement_contents",
	"footer_contents"
    };
    char *hs_pages[]={
	"hs_pages_mode","hs_pages_title",
	"hs_page_header_elements_contents",
	"hs_page_header_contents","hs_page_welcome_message",
	"hs_page_tos_agreement","hs_page_ad_contents",
	"hs_page_footer_contents"
    };

    char tmp[TMP_LEN];
    char *data;
    int64_t map = 0;
    
    int x,change = 1;

    config_preaction(&map, v, s, "", "");
    for(x = 0; x < sizeof(hs_server) / sizeof(hs_server[0]) ; x++)
    {  
    	snprintf(tmp,sizeof(tmp),hs_server[x]);
    	data = websGetVar(wp, tmp, "");
	if( !strcmp(tmp,"hs_uam_allow"))
	    save_to_rw(&tmp,data);
	else
	    ezplib_replace_attr("hs_server_rule",0,hs_server_rule[x],data);
    }

    for(x = 0; x < sizeof(hs_tos) / sizeof(hs_tos[0]) ; x++)
    {  
    	snprintf(tmp,sizeof(tmp),hs_tos[x]);
    	data = websGetVar(wp, tmp, "");

	if( !strcmp(tmp,"hs_tos_text"))
	    save_to_rw(&tmp,data);
	else
	    ezplib_replace_attr("hs_tos_rule",0,hs_tos_rule[x],data);
    }

    for(x = 0; x < sizeof(hs_pages) / sizeof(hs_pages[0]) ; x++)
    {  
    	snprintf(tmp,sizeof(tmp),hs_pages[x]);
    	data = websGetVar(wp, tmp, "");

	if( !strcmp(tmp,"hs_pages_mode") || !strcmp(tmp,"hs_pages_title"))
	    ezplib_replace_attr("hs_pages_rule",0,hs_pages_rule[x],data);
	else
 	    save_to_rw(&tmp,data);
    }

    snprintf(tmp,sizeof(tmp),"hs_user_rule_num");
    data = websGetVar(wp, tmp, "");
    if (data)
	nvram_set("hs_user_rule_num", data);

    snprintf(tmp,sizeof(tmp),"hs_http_url");
    data = websGetVar(wp, tmp, "");
    if (data)
	nvram_set("hs_http_url", data);

    for(x = 0; x < 10;x++)
    {
	snprintf(tmp,sizeof(tmp),"hs_user_rule%d_enable",x);
	data = websGetVar(wp, tmp, "");
  	if (data)
	    ezplib_replace_attr("hs_user_rule",x,"enable",data); 

	snprintf(tmp,sizeof(tmp),"hs_user_rule%d_name",x);
	data = websGetVar(wp, tmp, "");
  	if (data)
	    ezplib_replace_attr("hs_user_rule",x,"name",data); 

	snprintf(tmp,sizeof(tmp),"hs_user_rule%d_password",x);
	data = websGetVar(wp, tmp, "");
  	if (data)
	    ezplib_replace_attr("hs_user_rule",x,"password",data); 
    }  
 
    config_postaction(map, s, "", "");
    return change;
}


