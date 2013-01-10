#!/bin/sh

usage()
{
cat << EOF
usage: ./vhostcreator.sh options

This script creating virtual host on this computer. MUST BE STARTED AS ROOT!

OPTIONS:
   -h      Show this message
   -t      Virtual host name (for example, test.com or example.local), REQUIRED
   -u      Your username, REQUIRED
   -g      Your groupname, default equal with username
   -p      Absolute path for creating virtual host, default is "/var/www/<virtual_host_name>"
EOF
}

# default params

TITLE=
USER=
USERGROUP=
VHOST_PATH="/var/www/"

# get params

while getopts "ht:u:p:g:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         t)
             TITLE=$OPTARG
             ;;
         u)
             USER=$OPTARG
             ;;
         p)
             VHOST_PATH=$OPTARG
             ;;
         g)
             USERGROUP=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

# required params

if [ "$(whoami)" != "root" ]; then
	echo "Sorry, you are not root."
	exit 1
fi

if [ "$TITLE" = '' ] || [ "$USER" = '' ]
then
    usage
    exit
fi

# fixed params

if [ "$USERGROUP" = '' ]
then
    USERGROUP=$USER
fi
if [ "$VHOST_PATH" = '/var/www/' ]
then
    VHOST_PATH=$VHOST_PATH$TITLE
fi

echo "Creating Virtual Host"
cd /etc/apache2/sites-available
cat <<EOF >> "$TITLE.conf"
<VirtualHost *:80>
  ServerName $TITLE
  ServerAlias www.$TITLE
  DocumentRoot "$VHOST_PATH"
  <Directory "$VHOST_PATH">
    allow from all
    Options +Indexes
  </Directory>
</VirtualHost>
EOF
mkdir "$VHOST_PATH"
cd /etc/apache2/sites-enabled
ln -s "/etc/apache2/sites-available/$TITLE.conf" "$TITLE.conf"
echo "Editing /etc/hosts"
cat <<EOF >> "/etc/hosts"
127.0.0.1       $TITLE
EOF
echo "Set permissions"
chown -R "$USER:$USERGROUP" "$VHOST_PATH"
echo "Restarting Apache2"
/etc/init.d/apache2 restart
echo "Finished!"
echo "Local address: $VHOST_PATH"
echo "Web address: http://$TITLE"

exit 1




