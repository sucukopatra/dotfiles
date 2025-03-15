#!/bin/bash

# List of available scripts
scripts=("yay-install" "caps-to-a" "install-apps.sh" "install-grub-theme.sh" "autologin.sh" "install-zapret.sh")

# Display the list of scripts
echo "Select a script to run:"
select script in "${scripts[@]}"; do
    if [[ -n "$script" ]]; then
        echo "You selected $script"
        ./scripts/$script
        break
    else
        echo "Invalid selection. Please choose a valid option."
    fi
done

