#!/bin/bash
######################################################################
#Runs an nmap scan every 4 days of the specified subnets.  Compares
#the 2 most recent nmap scan xml output files via ndiff and posts the
#results to apache. Also parses each nmap xml output file with xsltproc,
#converts it to html, and posts it to apache.
######################################################################

NOW=$(date +"%Y%m%d-%H%M%S")

/usr/bin/sudo /usr/bin/nmap -oX $NOW 10.200.0.0/16 10.4.0.0/16 10.7.0.0/16 192.168.0.0/16  

for i in $(ls . | grep '^[0-9]'); do
	xsltproc $i -o $i.html && mv *.html /var/www/scans/ && mv $i /usr/local/nmap_xml/
done

xmla=$(/usr/bin/find /usr/local/nmap_xml -type f -mtime -1)
xmlb=$(/usr/bin/find /usr/local/nmap_xml -type f -mtime +1)

ndiff $xmlb $xmla > /usr/local/ndiff_results && cat /usr/local/ndiff_results | mail -s 'ndiff results' 'user1@example.com,user2@example.com'

mv /usr/local/ndiff_results /var/www/ndiffs/ndiff_$NOW

rm -rf $xmlb
