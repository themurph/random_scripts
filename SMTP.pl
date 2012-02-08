#!/usr/bin/perl

###############################################################
#
#	The Murph ( Chris Murphy )
#	April 18 2007
#  	Change SMTP server for each user's evolution client
#  	This is mostly useful for editing a lot of user's settings
#  	on a central NFS/Other server
#  	
#  	To work you're going to have to /bin/su - $username
#
#  	Also you're going to need edit the variables as needed
###############################################################	

use strict;

my $username = `whoami`;
my $home_dir = "/public/home";
my $backup_dir = "/SMTP/evolution-backup/";
my $temp_dir = "/SMTP/evolution/";
my $old_smtp_host = "old_smtp.example.com";
my $old_pop3_host = "old_pop3.example.com";
my $smtp_host = "smtp.example.com";
my $pop3_host = "pop3.example.com";
my $conf_check;
my $lock_file;

for($username){
	chomp($username);
		# check for evolution settings file
		$conf_check = "$home_dir/$username/.gconf/apps/evolution/mail/\%gconf.xml";
		print "$conf_check\n";
		if(-f $conf_check){
            # Make a backup, not really usefull because I can't import it, but hey, why not!!!
			print "Copying original\n";
			`/bin/cp -a $home_dir/$username/.gconf/apps/evolution/mail/\%gconf.xml $backup_dir/$username-\%gconf.xml`;

            # Make sure you can write to directory, cause if 
            # you can't, you're going to loose all information
		    $lock_file = "$backup_dir/$username-\%gconf.xml";
		    if(-f $lock_file){
			    print "Editing\n";
			        `/usr/bin/gconftool-2 --get /apps/evolution/mail/accounts | sed s/$old_smtp_host/$smtp_host/g | sed s/$old_smtp_host/$pop3_host/g > $temp_dir/$username.temp`;
			        `/usr/bin/gconftool-2 --unset /apps/evolution/mail/accounts`;

			    print "Updating SMTP settings\n";
                    `/usr/bin/gconftool-2 --type=list --list-type=string --set /apps/evolution/mail/accounts "\`cat $temp_dir/$username.temp\`"`;
		
			    print "Who's your daddy?\n";
		    }
	    }
}
exit
