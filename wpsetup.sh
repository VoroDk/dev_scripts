#!/bin/bash

# Load external functions
source ~/.dev_scripts/assets/functions.sh

# Ensure script is called with 1 argument
if [ $# -ne 1 ]; then
    echo "Usage: wpsetup <database_name>"
    exit 1
fi

# Get the database name from argument
DB_NAME="$1"

# Get the current working directory (wp project folder)
PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

# Paths to script files
SCRIPT_DIR="$HOME/.dev_scripts"
ENV_FILE="$SCRIPT_DIR/.env"
CONFIG_TEMPLATE="$SCRIPT_DIR/assets/wp-config-template.php"
CONFIG_FILE="$PROJECT_DIR/wp-config.php"
HTACCESS_TEMPLATE="$SCRIPT_DIR/assets/htaccess-template";
HTACCESS_FILE="$PROJECT_DIR/.htaccess"

NEW_URL="http://$PROJECT_NAME.localhost"

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo -e "${RED}Error:${NC} .env file not found in $SCRIPT_DIR!"
    exit 1
fi

# Check if DB_PASSWORD is set
if [ -z "$DB_PASSWORD" ]; then
    #echo "Error: DB_PASSWORD not set in .env file!"
    echo -e "${RED}Error:{NC} DB_PASSWORD not set in .env file";
    exit 1
fi

# Check if wp-config.php already exists
if [ -f "$CONFIG_FILE" ]; then
	EXSISTING_DB_NAME=`wp config get DB_NAME`
    echo -e "${YELLOW}wp-config.php already exists in $PROJECT_DIR with DB_NAME $EXSISTING_DB_NAME${NC}"
else
	# Create wp-config.php
	echo -e "${CYAN}Creating wp-config.php for $PROJECT_NAME with DB_NAME $DB_NAME and DB_PASSWORD $DB_PASSWORD${NC}"
	sed "s/{{DB_NAME}}/$DB_NAME/g; s/{{DB_PASSWORD}}/$DB_PASSWORD/g; s/{{ACF_KEY}}/$ACF_KEY/g" "$CONFIG_TEMPLATE" > "$CONFIG_FILE"
	echo -e "${GREEN}Success:${NC} wp-config.php created successfully in $PROJECT_DIR!"
fi

OLD_URL=`wp option get siteurl`

if [[ "$OLD_URL" != "$NEW_URL" ]]; then
	echo -e "${CYAN}Dry-run of search-replace${NC}"
	wp search-replace $OLD_URL $NEW_URL --dry-run --report-changed-only
	if prompt_user "Run \"wp search-replace $OLD_URL $NEW_URL\"?"; then
		wp search-replace $OLD_URL $NEW_URL --report-changed-only
	else
		echo 'Skipping search-replace'
	fi
else
	echo -e "${YELLOW}No difference in URLs, skipping search-replace${NC}"
fi

# Check if .htaccess already exists
if [ -f "$HTACCESS_FILE" ]; then
    echo ".htaccess already exists in $PROJECT_DIR"
else
	# Create .htaccess
	echo "Creating .htaccess for $PROJECT_NAME with image RewriteRule for $OLD_URL"
	sed "s|{{OLD_URL}}|$OLD_URL|g" "$HTACCESS_TEMPLATE" > "$HTACCESS_FILE"
	echo -e "${GREEN}Success:${NC} .htaccess created successfully in $PROJECT_DIR!"
fi

# Disable Emails.
if prompt_user "Install and activate \"disable-emails\" plugin?"; then
	wp plugin install disable-emails --activate
fi

# User password.
if [[ -n "$WP_USER_EMAIL" && -n "$WP_USER_PASSWORD" ]]; then
	if prompt_user "Update password for user \"$WP_USER_EMAIL\" to \"$WP_USER_PASSWORD\"?"; then
		wp user update $WP_USER_EMAIL --user_pass="$WP_USER_PASSWORD"
	fi    
fi

echo -e "${GREEN}Success:${NC} Go make something beautiful!"