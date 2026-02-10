# Local Dev Scripts

## Installation

### Clone repo
Clone the github repository into a directory named `.dev_scripts` in your home folder:
```
git clone git@github.com:VoroDk/dev_scripts.git ~/.dev_scripts && cd ~/.dev_scripts && git remote rm origin
```

### .env File
Create an `.env` file and add the following constants (copy the `.env-example` file):
```
DB_USERNAME=yourdbuser
DB_PASSWORD=yourdbpw
WP_USER_EMAIL=user@example.com
WP_USER_PASSWORD=yousecrectpassword
ACF_KEY=yourAcfProLicense
```

### Make sure scripts are executable

Run `ls -la ~/.dev_scripts` and make sure the scripts have execute permission (denoted with x-es, e.g. `-rwxr-xr-x`).
If the scripts does not have execute permission run
```
chmod +x ~/.dev_scripts/*.sh
```
Run `ls -la ~/.dev_scripts` again to confirm execute permission has been applied.

### Add alias and Shell Functions to your Shell Profile
To easily call the scripts, add the following alias and Shell Functions to your `~/.zshrc`.

```
alias web="~/.dev_scripts/open_wp_chrome.sh"

wpsetup(){
  ~/.dev_scripts/wpsetup.sh $1
}

wpdb(){
  ~/.dev_scripts/wpdb.sh
}
```

___

## Descriptions

### wpsetup.sh

#### Prerequisites:
> .env file with the following constants:
> - DB_USERNAME
> - DB_PASSWORD
> - WP_USER_EMAIL
> - WP_USER_PASSWORD
> - ACF_KEY
>
> A database and the name of the database

#### Parameters:
> The name of the database

#### Function Call (with shell functions setup as described above)
This function is called within the root folder of a WordPress project (where wp-admin/, wp-content/ and wp-includes/ is located).
The function is used to set up a new WP project that does not have a `wp-config.php` already.
```
wpsetup the-name-of-my-db
```
#### Running Steps
##### 1) wp-config.php
Creates a `wp-config.php` file within the directory the script is run and replaces `DB_USER`, `DB_PASSWORD` and `ACF_KEY` placeholders with the constants defined in `.env`.

If a `wp-config.php` already exists, this step is skipped.

##### 2) search-replace

Runs WP_CLI `search-replace` command for the "current" `site_url` in the database and replace it with the name of the folder which the function was called from and append `.localhost`.

If original `site_url` was "https://example.com" and the root directory of the local WP site is "my-local-example/"
The WP_CLI command would be
```
wp search-replace https://example.com http://my-local-example.localhost
```

##### 2) .htaccess
Creates an `.htaccess` file with Apache mod_rewrite rules that proxy missing local media by redirecting `/wp-content/uploads/*` to the old remote URL, then fall back to WordPress’s standard index.php front controller for pretty permalinks.

If a `.htaccess` already exists, this step is skipped.

##### 3) Install disable-emails
Installs and activates the disable-emails plugin.

##### 4) Update user
Updates a user password based on the constants `WP_USER_EMAIL` and `WP_USER_PASSWORD` defined in the `.env`.

### wpdb.sh

#### Prerequisites:
> .env file with the following constants:
> - WP_USER_EMAIL
> - WP_USER_PASSWORD

#### Function Call (with shell functions setup as described above)
This function is called within the root folder of a WordPress project (where wp-admin/, wp-content/ and wp-includes/ is located).
The function is used to replace the WordPress URLs of a WP site that does have a `wp-config.php` already and just needs the remote URLs replaced with the local URL.
```
wpdb
```

#### Running Steps
##### 1) search-replace
Runs the same as step 2 in `wpsetup.sh`

##### 2) Install disable-emails
Runs the same as step 3 in `wpsetup.sh`

##### 3) Update user
Runs the same as step 4 in `wpsetup.sh`