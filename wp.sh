#!/bin/bash

read -p "Username : " user
read -p "Domain   : " domain

#------------ ADD DOMAIN IN VESTACP -----------------
/usr/local/vesta/bin/v-add-domain $user $domain

# bash generate random 32 character alphanumeric string (upper and lowercase) an                                                                             d
db_user=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)
db_pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

#------------ ADD DATABASE IN VESTACP -----------------
/usr/local/vesta/bin/v-add-database $user $db_user $db_user $db_pass

username=${user}_${db_user}
echo "DB Username : $username"
echo "DB Password : $db_pass"

cd /home/$user/web/$domain/public_html/
clear
echo "============================================"
echo "WordPress Install Script"
echo "============================================"
echo "============================================"
echo "A robot is now installing WordPress for you."
echo "============================================"
#download wordpress
curl -O https://wordpress.org/latest.tar.gz
#unzip wordpress
tar -zxvf latest.tar.gz
#change dir to wordpress
cd wordpress
#copy file to parent dir
cp -rf . ..
#move back to parent dir
cd ..
#remove files from wordpress folder
rm -R wordpress
#create wp config
cp wp-config-sample.php wp-config.php
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$username/g" wp-config.php
perl -pi -e "s/username_here/$username/g" wp-config.php
perl -pi -e "s/password_here/$db_pass/g" wp-config.php

#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php

#create uploads folder and set permissions
mkdir wp-content/uploads
chmod 775 wp-content/uploads
echo "Cleaning..."
#remove zip file
rm latest.tar.gz
#remove bash script
echo "========================="
echo "Installation is complete."
echo "========================="
