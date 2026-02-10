FILE=wp-config.php
if [[ -f "$FILE" ]]; then
        echo "$FILE exists. Getting URL..."
        URL=$(wp option get siteurl)
        /usr/bin/open -a "/Applications/Google Chrome.app" "$URL"
else
        echo "$FILE does not exist in this directory."
fi
