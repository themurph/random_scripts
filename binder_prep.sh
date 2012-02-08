#!/bin/bash

####################################################################
#  File:    binder_prep.sh
#  Author:  Chris Murphy
#  Purpose: This is an update of the binder push scripts for 
#	        documentation.
#
#  Notes:   Number 3 is a lot of info, but for servers
#           that have ldap configs that none of up could replicate
#	        easily, it might be a good idea
####################################################################


user=$(who am i | cut -d ' ' -f1);
unalias ls;

echo "###########################################################";
echo "#";
echo "# Hello  $user";
echo "#";
echo "# This script will automatically back-up some important";
echo "#  system configuration files. In addition you can print";
echo "#  config files to a text file.";
echo "# It will put all these files in /home/backup/system/";
echo "#";
echo "# If you don't have this directory, I'm gonna set it up ";
echo "#   for you";
echo "#";
echo "# How much extra backing up do you want to do?";
echo "# 1) Normal - all config files in /etc/";
echo "# 2) Expanded - recursive /etc/ search for configs";
echo "# 3) Help Me Jesus - recursive search for configs starting in";
echo "#		   / but excluding /usr and /tmp";
echo "#";
echo "#";
echo "# Number 3 is mostly for servers like batch with complex";
echo "# LDAP configurations";
echo "#";
echo "###########################################################";
echo ;
echo -n "Pick a number 1 , 2 , or 3 #  "
#echo -n "Or press C to cancel #  "

read choice

if [ $choice -gt 3 ]; then
        echo " $user";
        echo " I don't think you are smart enough to do a";
        echo " backup.";
        exit 1;
fi

echo ;
echo ;
echo ;
echo "##############################################################"
echo "# Good Job, apparently you can read directions!"  
echo "# The text file with the requested configs is going to" 
echo "# be stored in /home/backup/system/configs.txt.  If you run"
echo "# this script again it will overwrite previous backup files."
echo "##############################################################"
sleep 3


## Lets make sure the directory structure is there
install -d /home/backup/system/local_bin_scripts/
install -d /home/backup/system/sysadmin_scripts/

## If this file exists, then remove it before starting
outfile=/home/backup/system/configs.txt

if [ -f $outfile ]; then
	rm -f $outfile
fi

## Ok, Lets get some back-ups 
## Start off with the usual binder push files

for each in $(ls /var/spool/cron/); do
     /bin/cp /var/spool/cron/$each /home/backup/system/$each.cron
done

 
/sbin/iptables-save > /home/backup/system/iptables.txt
/sbin/ifconfig > /home/backup/system/ifconfig.txt
/sbin/route -n > /home/backup/system/route.txt
/bin/df -h > /home/backup/system/df-h.txt
/bin/cat /proc/cpuinfo > /home/backup/system/cpuinfo.txt
/bin/cat /proc/meminfo > /home/backup/system/meminfo.txt
/bin/cat /etc/fstab > /home/backup/system/etc-fstab
/bin/cat /etc/exports > /home/backup/system/etc-exports
/sbin/fdisk -l > /home/backup/system/fdisk-l.txt
/bin/cat /etc/samba/smb.conf > /home/backup/system/etc-smb.conf
/bin/rpm -qa | sort > /home/backup/system/rpm-qa
/sbin/chkconfig --list > /home/backup/system/chkconfig--list
/bin/cp -f /usr/local/bin/* /home/backup/system/local_bin_scripts/
/bin/cp -f /home/sysadmin/scripts/* /home/backup/system/sysadmin_scripts/
perl -MExtUtils::Installed -le'print join "\n", ExtUtils::Installed->new()->modules' > /home/backup/system/perl-modules.txt

## Now on to the Config files
if [ $choice = "1" ]; then
	outfile=/home/backup/system/configs.txt
	for filename in `ls -d /etc/*.conf`;
	do
		echo "----------------------------------------" >> $outfile
		echo "-  $filename" >> $outfile
		echo "----------------------------------------" >> $outfile
		cat $filename >> $outfile
			echo "--------------------------------">> $outfile;
			echo "------ EOF $filename ---" >> $outfile
			echo "--------------------------------" >> $outfile;
		done;
	
exit 0
fi
## End Choice 1

## Begin Choice 2
config=$(cd /etc/ && find -mount -name '*.conf');
if [ $choice = "2" ]; then

    ## Get to the etc directory
    cd /etc
        for files in $config; do
            echo "----------------------------------------" >> $outfile
            echo "- $files" >> $outfile
            echo "----------------------------------------" >> $outfile
            echo "  --------------------------------------" >> $outfile
            echo "  - $files" >> $outfile
            echo "  --------------------------------------" >> $outfile
                cat $files >> $outfile;
		    echo "----------------------------------------" >> $outfile
            echo "  --- EOF $files ---" >> $outfile
            echo "----------------------------------------" >> $outfile
	    done	
    exit 0
fi
## End Choice 2

## Begin Choice 3
##This is Mad Crazy config getting.  Really only for servers like batch that have ldap

if [ $choice = "3" ]; then

echo "Building list -- this is gonna take a bit.  Go get a sandwich or"
echo "somthing.........................."

configs=$(cd / && find -mount -name '*.conf' | grep -v '/usr' | grep -v '/tmp');

## Get to the root directory
    cd /
        for madfiles in $configs; do
	        echo "----------------------------------------" >> $outfile
	        echo "- $madfiles" >> $outfile
	        echo "----------------------------------------" >> $outfile
		    echo "	--------------------------------------" >> $outfile
		    echo "	- $madfiles" >> $outfile
		    echo "	--------------------------------------" >> $outfile
		        cat $madfiles >> $outfile;
		    echo "----------------------------------------" >> $outfile
		    echo "	--- EOF $madfiles ---" >> $outfile
		    echo "----------------------------------------" >> $outfile
	    done
    exit 0
fi

