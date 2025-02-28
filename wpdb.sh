#!/bin/bash

# Load external functions
source ~/.dev_scripts/assets/functions.sh

# Check for wp-config.php.
if [ ! -f wp-config.php ]; then
  echo -e "${RED}Warning:${NC} No wp-config.php found. Make a wp-config.php or consider using the wpsetup script instead."
  exit 1;
fi

# Paths to script files
SCRIPT_DIR="$HOME/.dev_scripts"
ENV_FILE="$SCRIPT_DIR/.env"

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo -e "${RED}Error:${NC} .env file not found in $SCRIPT_DIR!"
    exit 1
fi

# Get the current working directory (wp project folder)
PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

# Construct new local url.
NEW_URL="http://$PROJECT_NAME.localhost"

# Get old siteurl from options table.
OLD_URL=`wp option get siteurl`

if [[ "$OLD_URL" != "$NEW_URL" ]]; then
  ## wp search-replace CLI command.
  echo -e "${CYAN}Dry-run of search-replace${NC}"
  wp search-replace $OLD_URL $NEW_URL --dry-run --report-changed-only
  if prompt_user "Run \"wp search-replace $OLD_URL $NEW_URL\"?"; then
    wp search-replace $OLD_URL $NEW_URL --report-changed-only
  else
    echo 'Skipping search-replace'
  fi
else
  echo "No difference in URLs, skipping search-replace"
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