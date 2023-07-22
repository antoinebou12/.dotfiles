#!/bin/bash

# Install neofetch if it is not installed
if ! command -v neofetch &> /dev/null; then
    echo "neofetch could not be found, installing..."
    sudo apt-get install neofetch -y
fi

# Create a custom MOTD with neofetch
echo "neofetch" > /etc/update-motd.d/10-neofetch
chmod +x /etc/update-motd.d/10-neofetch
