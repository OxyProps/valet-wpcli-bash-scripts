# ================================ REFERENCE =============================================
#
# This script Repo: https://github.com/OxyProps/valet-wpcli-bash-scripts
#
# Homebrew :        https://brew.sh/
# Composer :        https://getcomposer.org/
# Laravel Valet :   https://laravel.com/docs/9.x/valet
# MariaDB:          https://mariadb.com/
# Sequel-ACE :      https://sequel-ace.com/                         An open source GUI for your DB
# WordPress CLI :   https://wp-cli.org/
# WP-CLI Valet :    https://aaemnnost.tv/wp-cli-commands/valet/
# OpenSSL:          https://www.openssl.org/
# WP-CLI Login :    https://aaemnnost.tv/wp-cli-commands/login/
#
# ======================================================================================== 

# Stores the path to Valet Websites - Change this to your actual Valet Parked directory
# Note : In the video, you saw me use the tilde ~ to refer to my home directory. In this
# version, I did create a constant $PARKED_PATH so You don't have to modify the path in
# many places. The tilde is replaced by the constant $HOME which is a much better practice.
PARKED_PATH=${HOME}/Code/wp-sites

# Give our Terminal a few text styles
NONE='\033[00m'             # Text reset
GREEN='\033[01;32m'         # Green Text
YELLOW='\033[01;33m'        # Yellow Text
BOLD='\033[1m'              # Bold Text

# if a username is given, use it, otherwise, user default value
if [ -z $2 ]
then
    USER="admin"
else
    USER=$2
fi

# if a password is given, use it, otherwise, generate a random one
if [ -z $3 ]
then
    PASS=$(openssl rand -hex 6)
else
    PASS=$3
fi

# Navigate to the sites directory
cd ${PARKED_PATH}

# Create a new WP site with Valet
wp valet new $1 --locale="en_US" --dbname="wp_$1" --dbuser="root" --dbpass="" --admin_user=${USER} --admin_password=${PASS} --admin_email="you@yourdomain.com" --unsecure

# Secure this site for use with https - alternatively, you can remove --unsecure from the command above and comment or delete this line
valet secure $1

# Navigate to the themes directory - Change this path to your actual
cd ${PARKED_PATH}
cd $1/wp-content/themes

# Copy all content from my themes folder
cp -a ${PARKED_PATH}/zips/themes/*.zip .
unzip '*.zip'
rm -rf __MACOSX/
rm *.zip

# Activate the themes premium licenses
wp db query 'INSERT INTO wp_options (option_name, option_value) VALUES("bricks_license_key", "YOUR_BRICKS_LICENSE_KEY")'

# Define themes settings
wp db query 'INSERT INTO wp_options (option_name, option_value) VALUES("bricks_global_settings", "a:1:{s:9:""postTypes"";a:1:{i:0;s:4:""page"";}}")'

# Activate my themes
wp theme activate bricks-child

# Delete default WordPress themes
wp theme delete twentytwentyone twentytwentytwo twentytwentythree

# Update all themes
wp theme update --all

# Navigate to the plugins directory
cd ${PARKED_PATH}
cd $1/wp-content/plugins

# Copy all content from my premium plugins directory
cp -a ${PARKED_PATH}/zips/plugins/*.zip .
unzip '*.zip'
rm -rf __MACOSX/
rm *.zip

# Delete WP default plugins
wp plugin delete hello
wp plugin delete akismet

# Install plugins from WP repository
wp plugin install meta-box

# Activate my premium plugins licenses
wp db query 'INSERT INTO wp_options (option_name, option_value) VALUES("oxyprops", "a:1:{s:7:""license"";a:2:{s:3:""key"";s:35:""YOUR_OXYPROPS_LICENSE_KEY"";s:5:""email"";s:0:"""";}}")'
wp db query 'INSERT INTO wp_options (option_name, option_value) VALUES("meta_box_updater", "a:1:{s:7:""api_key"";s:32:""YOUR_METABOX_LICENSE_KEY"";}")'

# Activate all plugins
wp plugin activate --all

# Update the plugins
wp plugin update --all

# Give user informations
echo "${GREEN}Your new website is ready${NONE}"
echo "${YELLOW}Front-end${NONE}: https://$1.test/"
echo "${YELLOW}Back-end${NONE}: https://$1.test/wp-admin/"
echo "${YELLOW}Username${NONE}: ${USER}"
echo "${YELLOW}Password${NONE}: ${PASS}"

# Launch the website
# Use this one if you don't want to install wp login and use magic links
# open https://$1.test/wp-admin

# Automatic login
# Use this one if you want to install wp login and use magic links
wp login install --activate
wp login as ${USER} --launch