# LLIDS - Link layer Intrusion Detection System
Link layer Intrusion Detection System for home and SOHO

The system now is a single script that checks the ARP and IPv6 neighbourhood tables for new unknown hosts.
Upon detection of new host the event is logged and reported to relevent person with email.

The script is to be installed on the gateway of the LAN or on sensitive servers.

Invoke script with cron with interval at least once in 5 minets or more often.
Example (/etc/crontab):
*/5     *       *       *       *       root    /root/bin/report_new_hosts.sh


Tested on FreeBSD
