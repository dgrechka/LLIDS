#!/bin/sh

#config section
LOGPATH=/var/log/mac_log
WARNMAILADDR=root

now=`date`
SCRIPT=`readlink -f "$0"`
SCRIPTPATH=`dirname "$SCRIPT"`
MACSPATH=${SCRIPTPATH}/known_macs
#creating directory to store known MACs
if [ ! -d $MACSPATH ]; then
	mkdir $MACSPATH
fi

arplist_v4=`arp -a | awk '{print $1" "$2" "$4" "$6}'`
arplist_v6=`ndp -a -n | tail -n +2`
echo "$arplist_v4" | while read entry
do
	mac=`printf %s "$entry" | cut -w -f 3`
	hostname=`printf %s "$entry" | cut -w -f 1`
	ip=`printf %s "$entry" | cut -w -f 2`
	interface=`printf %s "$entry" | cut -w -f 4`
	if [ ! -f $MACSPATH/${mac}_${interface}_v4 ]; then
		mess="New device with MAC $mac at $ip identified as $hostname has been spoted in ARP table at interface $interface"
		echo "$now:	$mess" >> $LOGPATH
		echo "$mess" | mail -s 'Warning: possible LAN intrusion detected' $WARNMAILADDR
		touch $MACSPATH/${mac}_${interface}_v4
	fi
done
echo "$arplist_v6" | while read entry
do
	mac=`printf %s "$entry" | cut -w -f 2`
	if [ "$mac" == "(incomplete)" ]
	then
		continue
	fi
	ips=`printf %s "$arplist_v6" | grep $mac | awk '{print $1}' | xargs`
	hostnames=`printf %s "$arplist_v6" | grep $mac | awk '{print $1}' | xargs -I % host -t PTR % | cut -w -f 5  | grep -v '3(NXDOMAIN)' |  xargs`
	interface=`printf %s "$entry" | cut -w -f 3`
	if [ ! -f $MACSPATH/${mac}_${interface}_v6 ]; then
		hostname_str=''
		if [ -z "$hostnames" ]; then
			hostname_str=''
		else
			hostname_str="identified as $hostnames "
		fi
		mess="New device with MAC $mac at ips $ips ${hostname_str}has been spoted in IPv6 neighbourhood. Interface $interface"
		echo "$now:     $mess" >> $LOGPATH
		echo "$mess" | mail -s 'Warning: possible LAN intrusion detected' $WARNMAILADDR
                touch $MACSPATH/${mac}_${interface}_v6
	fi
done
