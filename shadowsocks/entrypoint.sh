#!/bin/bash

SS_CONFIG=${SS_CONFIG:-""}
SS_MODULE=${SS_MODULE:-"ss-server"}
KCP_MODULE=${KCP_MODULE:-"kcptun-server"}
KCP_CONFIG=${KCP_CONFIG:-""}
KCP_FLAG=${KCP_FLAG:-"false"}

while getopts "s:m:n:k:x" OPT; do
    case $OPT in
        s)
            SS_CONFIG=$OPTARG;;
        m)
            SS_MODULE=$OPTARG;;
	n)
 	    KCP_MODULE=$OPTARG;;
        k)
            KCP_CONFIG=$OPTARG;;
        x)
            KCP_FLAG="true";;
    esac
done

echo -e "\033[32mKCPINFO: $KCP_FLAG $KCP_CONFIG......\033[0m"

if [ "$KCP_FLAG" == "true" ] && [ "$KCP_CONFIG" != "" ]; then
    echo -e "\033[32mStarting kcptun......\033[0m"
    $KCP_MODULE $KCP_CONFIG 2>&1 &
else
    echo -e "\033[33mKcptun not started......\033[0m"
fi

echo -e "\033[32mStarting shadowsocks......\033[0m"
if [ "$SS_CONFIG" != "" ]; then
    $SS_MODULE $SS_CONFIG
else
    echo -e "\033[31mError: SS_CONFIG is blank!\033[0m"
    exit 1
fi
