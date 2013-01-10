#!/bin/sh

usage()
{
cat << EOF
Usage:

    ./vhostcreator.sh options

This script creating virtual host on this computer. MUST BE STARTED AS ROOT!

OPTIONS:

    -h       Show this message
    -t       Virtual host name (for example, test.com or example.local), REQUIRED
    -u       Your username, REQUIRED
    -g       Your groupname, default equal with username
    -p       Absolute path for creating virtual host, default is "/var/www/<virtual_host_name>"
    -l       Just list virtual hosts (no need parameters)
    -r       Just remove this virtual host (need only -t parameter)

TODO:

    -f       Framework ("yii" or "")
EOF
}

# default params

FRAMEWORK_YII_LAST_VERSION="http://yii.googlecode.com/files/yii-1.1.13.e9e4a0.tar.gz"

TITLE=
USER=
USERGROUP=
VHOST_PATH="/var/www/"
REMOVE=0
FRAMEWORK=
LIST=0

# get params

while getopts "ht:u:p:g:rf:l" OPTION
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
         r)
             REMOVE=1
             ;;
         f)
             FRAMEWORK=$OPTARG
             ;;
         l)
             LIST=1
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

# required params

if [ "$LIST" = 1 ]
then
    echo 'List of your virtual hosts:'
    awk '{if (/(\s*)ServerName.*/) print "    "$2}' /etc/apache2/sites-available/*
    exit
fi

if [ "$(whoami)" != "root" ]; then
	echo "Sorry, you are not root."
	exit 1
fi

if [ "$VHOST_PATH" = '/var/www/' ]
then
    VHOST_PATH=$VHOST_PATH$TITLE
fi

if [ "x$TITLE" != 'x' ] && [ "$REMOVE" = 1 ]
then
    echo "Removing Virtual Host"
    rm -f "/etc/apache2/sites-available/$TITLE.conf"
    rm -f "/etc/apache2/sites-enabled/$TITLE.conf"
    echo "Editing /etc/hosts"
    sed -r -i "/^127.0.0.1(\s+)$TITLE$/d" /etc/hosts
    echo "Restarting Apache2"
    /etc/init.d/apache2 restart
    echo "Removing www directory: $VHOST_PATH"
    rm -rf "$VHOST_PATH"
    exit
fi

if [ "x$TITLE" = 'x' ] || [ "x$USER" = 'x' ]
then
    usage
    exit 1
fi

# fixed params

if [ "x$USERGROUP" = 'x' ]
then
    USERGROUP=$USER
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
cat <<EOF >> "$VHOST_PATH/index.html"
Its work! Virtual host $TITLE created.
EOF

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

exit




