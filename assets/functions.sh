#!/bin/bash

prompt_user() {
    local prompt_message="$1"
    local user_input

    while true; do
        #read -rp "$prompt_message (Y/N): " user_input
        read -rp "$(echo -e "${BOLD}$prompt_message (Y/N): ${NC}")" user_input
        user_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')

        case "$user_input" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) echo "Invalid input. Please enter Y or N." ;;
        esac
    done
}



# Define text variables.
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' #No Color