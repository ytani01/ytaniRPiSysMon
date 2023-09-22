#!/bin/sh
#
# Copyright (c) 2023 Yoichi Tanibayashi. All rights reserved.
#

INTERVAL_SEC=0
if [ $# -gt 0 ]; then
    expr $1 + 1 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
       	INTERVAL_SEC=$1
    fi
fi
#echo "INTERVAL_SEC=$INTERVAL_SEC"

if which bc > /dev/null 2>& 1; then
    echo -n ""
else
    sudo apt install -y bc
fi

get_vcgencmd_val() {
    RES=`vcgencmd $*`
    echo $RES | sed 's/^.*=//'
}

hz2str() {
    RET_GHZ=`echo "scale=2; $1 / 1000000000" | bc | sed 's/^\./0./'`
    if [ `echo "$RET_GHZ >= 1" | bc` = 1 ]; then
	echo $RET_GHZ GHz
	return 0
    fi

    RET_MHZ=`echo "$RET_GHZ * 1000" | bc | sed 's/\..*$//'`
    echo $RET_MHZ MHz
    return 0
}

hz2mhz() {
    RET_MHZ=`echo "scale=0; $1 / 1000000" | bc`
    echo $RET_MHZ MHz
    return 0
}

while true; do
    TEMP_CPU=`get_vcgencmd_val measure_temp`
    
    VOLTS_CORE=`get_vcgencmd_val measure_volts core | sed 's/V$//'`
    THROTTLED=`get_vcgencmd_val get_throttled`

    HZ_ARM=`get_vcgencmd_val measure_clock arm`
    HZ_ARM_STR=`hz2mhz $HZ_ARM`

    HZ_CORE=`get_vcgencmd_val measure_clock core`
    HZ_CORE_STR=`hz2mhz $HZ_CORE`


    DATE_TIME=`date +'%Y/%m/%d %T'`

    echo "$DATE_TIME  CPU: $TEMP_CPU,  ARM: ${HZ_ARM_STR} ,  Core: ${HZ_CORE_STR}  $VOLTS_CORE V  $THROTTLED"

    if [ $INTERVAL_SEC -eq 0 ]; then
	break
    fi
    sleep $INTERVAL_SEC
done
