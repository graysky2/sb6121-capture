#!/bin/bash
# Script by graysky
# https://github.com/graysky2/bin/blob/master/sb6121-capture.sh
#

# PREFACE
# This very trivial script will log the downstream/upstream power levels as
# well as the respective SNR from your Arris SB6121 modem to individual csv
# values suitable for graphing.
#
# Use it to monitor power levels, frequencies, and SNR values over time to aid
# in troubleshooting connectivity with your ISP. The script is easily called
# from a cronjob at some appropriate interval (hourly for example).
#
# It is recommended that users simply call the script via a cronjob at the
# desired interval. Perhaps twice per hour is enough resolution.
#
# Note that the crude coreutils lines work fine on an Arris SB6121 running
# Firmware            : SB_KOMODO-1.0.6.16-SCM00-NOSH
# Firmware build time : Feb 16 2016 11:28:04

NOW=$(date +%Y-%m-%d" "%H:%M:%S)
FILE=/tmp/modemdump
LOG=$HOME/SB6121-dump.csv

[[ -f "$FILE" ]] && rm "$FILE"

# first the status
STATUS=$(curl -s http://192.168.100.1/indexData.htm | grep -A 1 'Cable Modem Status' | tail -n1 | sed -e s'|<TD>||' -e 's|</TD></TR>||' -e 's/ //g' -e s'|<ahref="cmLogsData.htm"style="color:#FF0000">||' -e 's|</a>||')

# now the levels
wget -q --mirror http://192.168.100.1/cmSignal.htm -O "$FILE"

# define arrays
mapfile -t SNRArr < <(grep 'dB&nbsp' "$FILE" | sed -e 's/[^0-9 ]*//g' -e 's/ /\n/g' | head -n4)
mapfile -t DPArr < <(grep -A 4 /SMALL "$FILE" | sed -e 's/[^-0-9 ]*//g' -e s'/--//' | tail -n +2 | tr '\n' ' ' | sed 's/  /\n/g' | head -n4)
mapfile -t UPArr < <(grep 'dBmV&nbsp' "$FILE" |  sed -e 's/[^0-9 ]*//g' -e 's/ /\n/g' | head -n4)

[[ -f "$LOG" ]] ||
	echo "Date,Status,SNR1,SNR2,SNR3,SNR4,Dpower1,Dpower2,Dpower3,Dpower4,Upower1,Upower2,Upower3,Upower4" > "$LOG"

echo "$NOW,$STATUS,${SNRArr[0]},${SNRArr[1]},${SNRArr[2]},${SNRArr[3]},${DPArr[0]},${DPArr[1]},${DPArr[2]},${DPArr[3]},${UPArr[0]},${UPArr[1]},${UPArr[2]},${UPArr[3]}" >> "$LOG"
