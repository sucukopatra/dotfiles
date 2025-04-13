#!/bin/bash

# requires to be run as root, unless the user has access to the theme folder
if [[ `id -u` -ne 0 ]] ; then
	echo "Must be run as root!"
	exit
fi 

# this should be the directory of the clones repo
SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
# I accidentally deleted the above line once and it copied / into the theme folder, so lets prevent this
if [[ -z $SCRIPT_DIR ]] ; then echo "Something didn't work, exiting"; exit; fi

# check if the grub folder is called grub/ or grub2/
if [ -d /boot/grub ]    ; then
	grub_path="/boot/grub"
elif [ -d /boot/grub2 ] ; then
	grub_path="/boot/grub2"
else 
	echo "Can't find a /boot/grub or /boot/grub2 folder. Exiting."
	exit 
fi
theme_path="$grub_path/themes/minegrub"

## Prompts
echo
read -p "[?] Copy/Update the theme to '$theme_path'? [Y/n] " -en 1 copy_theme
if [[ "$copy_theme" =~ y|Y || -z "$copy_theme" ]]; then
    echo "[INFO] => Copying the theme files to boot partition:"
    # copy recursive, update, verbose
    cd $SCRIPT_DIR && cp -ruv ./minegrub $grub_path/themes/ | awk '$0 !~ /skipped/ { print "\t"$0 }'
else
    echo "[INFO] [Skipping] Copying the theme files to boot partition"
fi

echo 
read -p "[?] Do you want to install a systemd service to automatically update the splash texts and backgrounds after every boot? [y/N] " -en 1 skip_service_installation
if [[ "$skip_service_installation" =~ y|Y ]]; then
    echo -ne "[INFO] Installing systemd service to update splash and package labels on boot\n\t"
    cp -uv $SCRIPT_DIR/minegrub-update.service /etc/systemd/system/
    systemctl enable minegrub-update.service
else
    echo "[INFO] [Skipping] Systemd service installation"
fi

# Check if the GRUB_THEME line exists
if grep -q "^GRUB_THEME=" /etc/default/grub; then
    # If it exists, update the line
    sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$theme_path/theme.txt\"|" /etc/default/grub
else
    # If it doesn't exist, add the line at the end of the file
    echo "GRUB_THEME=\"$theme_path/theme.txt\"" | sudo tee -a /etc/default/grub > /dev/null
fi

sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo rm /background.png
sudo rm /boot_menu2_c.png
sudo rm /dejavu_14.pf2
sudo rm /droidlogo*
sudo rm /highlight*
sudo rm /preview.png
sudo rm /progress_highlight_c.png
sudo rm /theme.txt

