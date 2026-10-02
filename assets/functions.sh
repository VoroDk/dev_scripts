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



# Check the scripts repo for updates and offer to pull before continuing.
check_for_updates() {
    local repo_dir="$HOME/.dev_scripts"
    local behind

    # Fetch quietly; skip the check if offline or the fetch fails.
    if ! git -C "$repo_dir" fetch --quiet origin master 2>/dev/null; then
        echo -e "${YELLOW}Warning:${NC} Could not check for script updates (offline?). Continuing..."
        return 0
    fi

    behind=$(git -C "$repo_dir" rev-list --count HEAD..origin/master 2>/dev/null)

    if [[ "${behind:-0}" -gt 0 ]]; then
        echo -e "${YELLOW}Update available:${NC} The dev scripts are $behind commit(s) behind origin/master."
        if prompt_user "Pull the latest scripts now?"; then
            if git -C "$repo_dir" pull --ff-only origin master; then
                echo -e "${GREEN}Success:${NC} Scripts updated. Please re-run your command."
                exit 0
            else
                echo -e "${RED}Error:${NC} Pull failed (local changes in $repo_dir?). Update manually and re-run."
                exit 1
            fi
        else
            echo -e "${YELLOW}Continuing with outdated scripts...${NC}"
        fi
    fi
}



# Define text color variables.
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' #No Color