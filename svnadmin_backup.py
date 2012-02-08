#!/usr/bin/env python
#
import os
from time import strftime

day = strftime("%a")

svn_home = "/Users/chris/svn"
backup_site = "/backup/svn"

for repo in os.listdir(svn_home):
        full_repo = svn_home + "/" + repo
        # Backup to 
        repo_backup = backup_site + repo + "-" + day + "-svn.gz"
        # Also scp to backup server
        command = "svnadmin dump %s | gzip > %s && scp %s backup2:/backup/" % (full_repo, repo_backup, repo_backup)
        os.system(command)
