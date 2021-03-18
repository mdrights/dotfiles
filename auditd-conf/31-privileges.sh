##- Use of privileged commands (unsuccessful and successful)                                                 
## You can run the following commands to generate the rules:                                                 
find /bin -type f -perm -04000 2>/dev/null | awk '{ printf "-a always,exit -F path=%s -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged\n", $1 }' > /etc/audit/rules.d/31-priv.rules                                                
find /sbin -type f -perm -04000 2>/dev/null | awk '{ printf "-a always,exit -F path=%s -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged\n", $1 }' >> /etc/audit/rules.d/31-priv.rules                                              
find /usr/bin -type f -perm -04000 2>/dev/null | awk '{ printf "-a always,exit -F path=%s -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged\n", $1 }' >> /etc/audit/rules.d/31-priv.rules                                           
find /usr/sbin -type f -perm -04000 2>/dev/null | awk '{ printf "-a always,exit -F path=%s -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged\n", $1 }' >> /etc/audit/rules.d/31-priv.rules                                          

