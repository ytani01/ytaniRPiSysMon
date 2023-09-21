#!/bin/sh
#
# Copyright (c) 2023 Yoichi Tanibayashi. All rights reserved.
#

INTERVAL_SEC=3

if which bc; then
    echo ""
else
    sudo apt install -y bc
fi

get_vcgencmd_val() {
    RES=`vcgencmd $*`
    echo $RES | sed 's/^.*=//'
}

hz2ghz() {
    echo "scale=2; $1 / 1000000000" | bc | sed 's/^\./0./'
}

while true; do
    TEMP_CPU=`get_vcgencmd_val measure_temp`
    
    VOLTS_CORE=`get_vcgencmd_val measure_volts core | sed 's/V$//'`
    THROTTLED=`get_vcgencmd_val get_throttled`

    HZ_ARM=`get_vcgencmd_val measure_clock arm`
    GHZ_ARM=`hz2ghz $HZ_ARM`

    HZ_CORE=`get_vcgencmd_val measure_clock core`
    GHZ_CORE=`hz2ghz $HZ_CORE`


    echo "CPU: $TEMP_CPU,  ARM: ${GHZ_ARM} GHz,  Core: ${GHZ_CORE} GHz  $VOLTS_CORE V  $THROTTLED"

    sleep $INTERVAL_SEC
done
