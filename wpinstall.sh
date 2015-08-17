#INSTRUCTIONS
# 1. Add the below lines to your .bashrc / .bash_profile in home directory
#----
# export MAMP_PHP=/Applications/MAMP/bin/php/php5.6.2/bin
# export PATH="$MAMP_PHP:$PATH"
# export PATH=$PATH:/Applications/MAMP/Library/bin/
# alias theme="cd wp-content/themes/MESH-Starter-Theme-master"
# alias wpboom="~/wpinstall.sh;theme;npm install grunt;npm install"
#----
#
# 2. Create Directory in htdocs MAMP folder
# 3. cd to directory and run command 'wpboom'  -- if error, run source ~/.bashrc or .bash_profile
 


#!/bin/bash -e
clear

echo "================================================================="
echo "BOOM - WordPress!!"
echo "================================================================="

# accept user input for the databse name
echo "Database Name: "
read -e dbname

# accept the name of our website
echo "Site Name: "
read -e sitename

# accept the admin username of our website
echo "Admin Username: "
read -e wpuser

# accept the admin password of our website
echo "Admin Password: "
read -e password

# accept a comma separated list of pages
echo "Add Pages: "
read -e allpages

# add a simple yes/no confirmation before we proceed
echo "Run Install? (y/n)"
read -e run

# if the user didn't say no, then go ahead an install
if [ "$run" == n ] ; then
exit
else

# download the WordPress core files
wp core download

# create the wp-config file with our standard setup
wp core config --dbname=$dbname --dbuser=root --dbpass=root --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'DISALLOW_FILE_EDIT', true );
PHP

# parse the current directory name
currentdirectory=${PWD##*/}

# create database, and install WordPress
wp db create
wp core install --url="http://localhost/$currentdirectory" --title="$sitename" --admin_user="$wpuser" --admin_password="$password" --admin_email="user@example.org"

# delete sample page, and create homepage
wp post delete $(wp post list --post_type=page --posts_per_page=1 --post_status=publish --pagename="sample-page" --field=ID --format=ids)
wp post create --post_type=page --post_title=Home --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids)

# set homepage as front page
wp option update show_on_front 'page'

# set homepage to be the new page
wp option update page_on_front $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=home --field=ID --format=ids)

# set time to UTC-5
wp option update timezone_string America/New_York

# create all pages
export IFS=","
for page in $allpages; do
	wp post create --post_type=page --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids) --post_title="$(echo $page | sed -e 's/^ *//' -e 's/ *$//')"
done

# set permalinks
wp rewrite structure '/%postname%/' --hard
wp rewrite flush --hard

# delete akismet and hello dolly
wp plugin delete akismet
wp plugin delete hello

# install PLUGINS
wp plugin install advanced-custom-fields --activate
wp plugin install google-sitemap-generator --activate
wp plugin install better-wp-security --activate

#ACF Repeater Plugin
wp plugin install https://www.dropbox.com/s/0fp2ji0q5i0bjyw/acf-repeater.zip?dl=1 --activate

#BackupBuddy Plugin
wp plugin install https://www.dropbox.com/s/e0xtgf2fkm0rf33/backupbuddy-5.0.3.3.zip?dl=1 --activate

#WP Pusher Plugin
wp plugin install https://www.dropbox.com/s/g59jg0kcf6jgj48/wppusher.zip?dl=1 --activate
 


# install the company starter theme from github
wp theme install https://github.com/MESH-Dev/MESH-Starter-Theme/archive/master.zip --activate

clear

echo "================================================================="
echo "Installation is complete. Your username/password is listed below."
echo ""
echo "Username: $wpuser"
echo "Password: $password"
echo ""
echo "================================================================="

# Open the new website with Google Chrome
/usr/bin/open -a "/Applications/Google Chrome.app" "http://localhost/$currentdirectory/wp-login.php"

fi
