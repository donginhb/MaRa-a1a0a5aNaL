#!/bin/sh -x

iface=$1
num=$2

# lock dirs/files
LOCKDIR="/tmp"
PIDFILE="${LOCKDIR}/SIG_PID${num}"
 

if (set -o noclobber; echo "$$" > "$PIDFILE") 2> /dev/null; then

    trap 'rm -f "$PIDFILE"; exit $?' INT TERM EXIT
    
    dev_name=$(nvram show wan_wwan_probe_rule $num devname)

    [ -z "$dev_name" ] && {
        dev_name=$(nvram show wan_wwan_rule $num devname)

    }

    ifctrl_num=$(nvram show wan_wwan_probe_rule $num ctrltty)

    [ -z "$ifctrl_num" ] && {
        ifctrl_num=$(nvram show wan_wwan_rule $num ctrltty)

    }



    /usr/sbin/ezpcom sig -d /dev/$1 2> /dev/null > /tmp/3g_sig_tmp
    [ -s "/tmp/3g_sig_tmp" ] && {

        RSSI=$(cat /tmp/3g_sig_tmp | sed -n '1p' | awk '{FS=":";print $2$3}' | awk '{FS=",";print $1}' | tr -d " " | tr -d "+CSQ")

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
    }

    rm -f "$PIDFILE"
    trap - INT TERM EXIT
else
    echo "Lock Exists: $PIDFILE owned by $(cat $PIDFILE)"
fi

