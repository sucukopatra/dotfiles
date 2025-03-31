#!/bin/bash

# List of available scripts
scripts=("yay-install.sh" "caps-to-a.sh" "install-apps.sh" "install-grub-theme.sh" "autologin.sh" "install-zapret.sh" "changeto-r530.sh" "install-vesktop")

while true; do
    # Display the list of scripts
    echo "Select a script to run (or type 'Quit' to exit):"

    select script in "${scripts[@]}" "Quit"; do
        if [[ "$script" == "Quit" ]]; then
            echo "Exiting the script."
            exit 0  # Exit the script cleanly
        elif [[ -n "$script" ]]; then
            echo "You selected $script"
            
            # Check if the script exists before running
            if [[ -f "./scripts/$script" ]]; then
                ./scripts/$script
            else
                echo "Error: $script not found in the scripts directory."
            fi
            break
        else
            echo "Invalid selection. Please choose a valid option."
        fi
    done
done

