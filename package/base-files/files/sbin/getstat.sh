#!/bin/sh -x

iface=$1
num=$2

# lock dirs/files
LOCKDIR="/tmp"
PIDFILE="${LOCKDIR}/STAT_PID${num}"
 

if (set -o noclobber; echo "$$" > "$PIDFILE") 2> /dev/null; then

    trap 'rm -f "$PIDFILE"; exit $?' INT TERM EXIT

    local UML295="$(cat /proc/bus/usb/devices | grep "Vendor=10a9 ProdID=6064")"
    [ -n "$UML295" ] && {
        curl http://192.168.32.2/condata > /tmp/conn.info
        let LTE_RSSI_TO_PERCENT=$(grep "signal strength" /tmp/conn.info  | sed 's/\(.*\)\(<percent>\)\(.*\)\(<\/percent>\)\(.*\)/\3/')
        local LTE_SIG=0
        [ -n "$LTE_RSSI_TO_PERCENT" ] && {
            [ $LTE_RSSI_TO_PERCENT -lt 0 ] && LTE_SIG=0
            [ $LTE_RSSI_TO_PERCENT -ge 0  ] &&  [ $LTE_RSSI_TO_PERCENT -lt 15  ] && LTE_SIG=0
            [ $LTE_RSSI_TO_PERCENT -ge 15  ] &&  [ $LTE_RSSI_TO_PERCENT -lt 32 ] && LTE_SIG=1
            [ $LTE_RSSI_TO_PERCENT -ge 32 ] &&  [ $LTE_RSSI_TO_PERCENT -lt 49 ] && LTE_SIG=2
            [ $LTE_RSSI_TO_PERCENT -ge 49 ] &&  [ $LTE_RSSI_TO_PERCENT -lt 66 ] && LTE_SIG=3
            [ $LTE_RSSI_TO_PERCENT -ge 66 ] &&  [ $LTE_RSSI_TO_PERCENT -le 83 ] && LTE_SIG=4
            [ $LTE_RSSI_TO_PERCENT -gt 83 ] && LTE_SIG=5
            nvram replace attr wan_wwan_probe_rule $2 signal "$LTE_RSSI_TO_PERCENT"
            nvram replace attr wan_wwan_probe_rule $2 sig "$LTE_SIG"
        }
        local LTE_PROVIDER=$(awk '/<network><serving><name>/,/<\/name>/' /tmp/conn.info | sed 's/\(.*\)\(<network><serving><name>\)\(.*\)\(<\/name>\)\(.*\)/\3/')
        nvram replace attr wan_wwan_probe_rule $2 provider "$LTE_PROVIDER"
        nvram replace attr wan_status_rule $2 trycount 0
        rm -f "$PIDFILE"
        trap - INT TERM EXIT
        exit
    }

    
    dev_name=$(nvram show wan_wwan_probe_rule $num devname)

    [ -z "$dev_name" ] && {
        dev_name=$(nvram show wan_wwan_rule $num devname)

    }

    ifctrl_num=$(nvram show wan_wwan_probe_rule $num ctrltty)

    [ -z "$ifctrl_num" ] && {
        ifctrl_num=$(nvram show wan_wwan_rule $num ctrltty)

    }



    /usr/sbin/ezpcom stats -d /dev/$1 > /tmp/3g_stats_tmp
    [ -s "/tmp/3g_stats_tmp" ] && {
        IMEI=$(cat /tmp/3g_stats_tmp | sed -n '1p' | awk '{FS=":";print $2}' | tr -d " ")
        # some datacards will return the IMEI value is ERROR, change it to UNKNOWN
        echo $IMEI | grep -q "ERROR" && IMEI='UNKNOWN'  
        PROVIDER=$(cat /tmp/3g_stats_tmp | sed -n '2p' | awk '{FS="\"";print $2}' | tr -d "\"")
        # sometimes, AT&T will be retrieved incorrectly as AT& or AT
        # if AT& or AT retrieved, we will fix it to AT&T
        echo $PROVIDER | grep -q "AT" && PROVIDER='AT&T'
        RSSI=$(cat /tmp/3g_stats_tmp | sed -n '3p' | awk '{FS=":";print $2$3}' | awk '{FS=",";print $1}' | tr -d " " | tr -d "+CSQ")
        FIRMWARE=$(cat /tmp/3g_stats_tmp | sed -n '4p' | awk '{FS=":";print $2}' | tr -d " ")
        APN=$(cat /tmp/3g_stats_tmp | sed -n '5p' | awk '{FS="\"";print $4}')
        let dBm=0
        let RSSI_TO_PERCENT="NA"
        [ -n "$RSSI" ] && {
            let dBm=$RSSI*2-113
            let RSSI_TO_PERCENT=$RSSI*100/31
            [ $RSSI -ge 0  ] &&  [ $RSSI -lt 6  ] && SIG=1
            [ $RSSI -ge 6  ] &&  [ $RSSI -lt 12 ] && SIG=2
            [ $RSSI -ge 12 ] &&  [ $RSSI -lt 18 ] && SIG=3                                                                          
            [ $RSSI -ge 18 ] &&  [ $RSSI -lt 24 ] && SIG=4                                                                          
            [ $RSSI -ge 24 ] &&  [ $RSSI -le 31 ] && SIG=5                                                                          
            [ $RSSI -eq 99 ] && SIG=0 && RSSI_TO_PERCENT=0                                                                          
        }                                                                                                                           
        [ "$RSSI_TO_PERCENT" = "NA" -o "$RSSI_TO_PERCENT" = "0" ] && {                                                              
            rm -f "$PIDFILE"
            exit                                                                                                                  
        }
        echo "RSSI:$RSSI_TO_PERCENT SIG:$SIG"                         
        nvram replace attr wan_wwan_probe_rule $num signal "$RSSI_TO_PERCENT"
        nvram replace attr wan_wwan_probe_rule $num sig "$SIG"               
        nvram replace attr wan_wwan_probe_rule $num imei "$IMEI"
        nvram replace attr wan_wwan_probe_rule $num provider "$PROVIDER"
        nvram replace attr wan_wwan_probe_rule $num firmware "$FIRMWARE"
        nvram replace attr wan_wwan_probe_rule $num apn "$APN"
        logger EZP_USR 3G Signal Strength [RSSI:$RSSI][\($dBm dBm\)]
    }

    rm -f "$PIDFILE"
    trap - INT TERM EXIT
else
    echo "Lock Exists: $PIDFILE owned by $(cat $PIDFILE)"
fi

