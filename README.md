# Local Setup Scripts

## .env File
Create a .env file and add the following variables
```
DB_PASSWORD=yourdbpw
WP_USER_EMAIL=user@example.com
WP_USER_PASSWORD=yousecrectpassword
```

## Make sure scripts are executable

Run `ls -la ~/.dev_scripts` and make sure the scripts have execute permission (denoted with x-es, e.g. `-rwxr-xr-x`).
If the scripts does not have execute permission run `chmod +x ~/.dev_scripts/*.sh`.
Run `ls -la ~/.dev_scripts` again to confirm execute permission has been applied.

## Add Shell Functions to your Shell Profile
To easily call the scripts, add the following Shell Functions to your `~/.zshrc`, `~/.bashrc` or `~/.bash_profile`.

```
wpsetup(){
  ~/.dev_scripts/wpsetup.sh "$1"
}

wpdb(){
  ~/.dev_scripts/wpdb.sh
}
```