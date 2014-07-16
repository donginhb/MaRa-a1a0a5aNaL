#ifndef NVRAM_EZPACKET_APP_K_H
#define NVRAM_EZPACKET_APP_K_H
#if (WL_NUM == 0)
    #define APPMGR_WLAN_K     "0"
#else
    #define APPMGR_WLAN_K     "1"
#endif
/* prod_cat=K for Storage-K series */
#define APPMGR_ISCSI_K    "0"
#define APPMGR_PPTP_K     "0"
#define APPMGR_L2TP_K     "0"
#define APPMGR_IPSEC_K    "0"
#define APPMGR_STORAGE_K  "1"
#define APPMGR_WWAN_K     "0"
#define APPMGR_WISP_K     "1"
#define APPMGR_PORTCFG_K  "0"
#define APPMGR_HWNAT_K    "0"
#define APPMGR_FIRMWARE_K "1"
#define APPMGR_IPHONE_K   "0"
#define APPMGR_BARRY_K    "0"
#define APPMGR_SMART_K    "0"
#define APPMGR_USBLED_K   "0"
#define APPMGR_WIMAX_K    "0"
#define APPMGR_BECEEM_K   "0"
#define APPMGR_GUEST_LAN_K     "1"
/*
#ifndef APPMGR_WLAN_K
#error "Not defined product cat" EZP_PROD_CAT
#endif
*/

#define APPMBG_RULE_K     APPMGR_WLAN_K"^"APPMGR_ISCSI_K"^"APPMGR_PPTP_K"^"APPMGR_L2TP_K"^"APPMGR_IPSEC_K"^"APPMGR_STORAGE_K"^"APPMGR_WWAN_K"^"APPMGR_WISP_K"^"APPMGR_PORTCFG_K"^"APPMGR_HWNAT_K"^"APPMGR_FIRMWARE_K"^"APPMGR_IPHONE_K"^"APPMGR_BARRY_K"^"APPMGR_SMART_K"^"APPMGR_USBLED_K"^"APPMGR_WIMAX_K"^"APPMGR_BECEEM_K"^"APPMGR_GUEST_LAN_K
#endif
