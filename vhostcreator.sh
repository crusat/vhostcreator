#!/bin/bash
echo "Creating Virtual Host"
cd /etc/apache2/sites-available
cat <<EOF >> "$1.conf"
<VirtualHost *:80>
  ServerName $1
  ServerAlias www.$1
  DocumentRoot "/var/www/$1"
  <Directory "/var/www/$1">
    allow from all
    Options +Indexes
  </Directory>
</VirtualHost>
EOF
mkdir "/var/www/$1"
cd /etc/apache2/sites-enabled
ln -s "/etc/apache2/sites-available/$1.conf" "$1.conf"
echo "Editing /etc/hosts"
cat <<EOF >> "/etc/hosts"
127.0.0.1       $1
EOF
echo "Set permissions"
chown -R "$2:$2" "/var/www/$1"
echo "Restarting Apache2"
/etc/init.d/apache2 restart
echo "Finished!"
echo "Local address: /var/www/$1"
echo "Web address: http://$1"