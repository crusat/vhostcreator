vhostcreator
============

Automatic virtual host creator for apache2. MUST BE STARTED AS ROOT!

First Run:

    $ chmod a+x ./vhostcreator.sh

Usage:

    $ sudo ./vhostcreator.sh -t <virtual_host_name> -u <username> -g <usergroup> -p <path_to_virtual_host>

OPTIONS:

    -h       Show this message
    -t       Virtual host name (for example, test.com or example.local), REQUIRED
    -u       Your username, REQUIRED
    -g       Your groupname, default equal with username
    -p       Absolute path for creating virtual host, default is "/var/www/<virtual_host_name>"
    -l       Just list virtual hosts (no need parameters)
    -r       Just remove this virtual host (need only -t parameter). USE CAREFUL!

Examples:

    $ sudo ./vhostcreator.sh -t mysite.com -u crusat

    $ sudo ./vhostcreator.sh -t mysite.com -u crusat -g users -p /home/crusat/my_sites/mysite.com

    $ ./vhostcreator.sh -l

    $ ./vhostcreator.sh -r -t mysite.com

Tested on Xubuntu 12.04, 12.10; Apache2.




Specially thanks to my brother Sergey for help.
