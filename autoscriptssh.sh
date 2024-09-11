#!/bin/bash

# Function to handle errors
error_exit() {
    echo "$1" 1>&2
    exit 1
}

# Define variables
REPO_URL="https://github.com/Emmkash20/autoscriptssh.git"
SCRIPT_NAME="setup.sh"
DOMAIN=""

# Update package lists and install Git
echo "Updating package lists and installing Git..."
sudo apt update || error_exit "Failed to update package lists."
sudo apt install -y git curl || error_exit "Failed to install Git and curl."

# Install Certbot
echo "Installing Certbot for SSL..."
sudo apt install -y certbot || error_exit "Failed to install Certbot."

# Clone the repository
echo "Cloning repository from $REPO_URL..."
git clone $REPO_URL || error_exit "Failed to clone repository."

# Navigate to the repository directory
REPO_NAME=$(basename $REPO_URL .git)
cd $REPO_NAME || error_exit "Failed to navigate to repository directory."

# Prompt user for the domain
read -p "Enter your domain (for SSL certificate): " DOMAIN

# Obtain SSL certificate
echo "Obtaining SSL certificate for $DOMAIN..."
sudo certbot certonly --standalone -d $DOMAIN || error_exit "Failed to obtain SSL certificate."

# Make the script executable
echo "Making $SCRIPT_NAME executable..."
chmod +x $SCRIPT_NAME || error_exit "Failed to make $SCRIPT_NAME executable."

# Run the setup script
sudo ./$SCRIPT_NAME || error_exit "Failed to run $SCRIPT_NAME."

# Display the menu
show_menu() {
    clear
    echo "================================================"
    echo "   Script by Emmkash Technologies - VPS Manager  "
    echo "================================================"
    echo " [01] ◇ CREATE USER             [11] ◇ SPEEDTEST"
    echo " [02] ◇ CREATE TEST USER        [12] ◇ BANNER"
    echo " [03] ◇ REMOVE USER             [13] ◇ NETWORK TRAFFIC"
    echo " [04] ◇ ONLINE USER MONITOR     [14] ◇ VPS OPTIMIZE"
    echo " [05] ◇ CHANGE DATE             [15] ◇ USER BACKUP"
    echo " [06] ◇ CHANGE LIMIT            [16] ◇ USER LIMITER ○"
    echo " [07] ◇ CHANGE PASSWORD         [17] ◇ BAD VPN ○"
    echo " [08] ◇ REMOVE EXPIRED          [18] ◇ VPS INFO"
    echo " [09] ◇ USER REPORT             [19] ◇ MORE OPTIONS >>>"
    echo " [10] ◇ CONNECTION MODE         [00] ◇ GET OUT <<<"
    echo "================================================"
    echo " [20] ◇ INSTALL V2RAY"
    echo "================================================"
    echo "Enter your choice: "
}

# Function to install V2Ray and configure SSL
install_v2ray() {
    echo "Installing V2Ray..."
    bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) || error_exit "Failed to install V2Ray."
    
    # Configure V2Ray to use SSL certificate
    echo "Configuring V2Ray to use SSL..."
    CONFIG_FILE="/usr/local/etc/v2ray/config.json"
    sudo sed -i "s/\"inbounds\": \[/\"inbounds\": \[\{\"port\": 443, \"protocol\": \"vmess\", \"settings\": \{\"clients\": \[{\"id\": \"$(uuidgen)\", \"alterId\": 64\}\]\}, \"streamSettings\": \{\"network\": \"ws\", \"security\": \"tls\", \"tlsSettings\": \{\"serverName\": \"$DOMAIN\", \"certificates\": \[{\"certificateFile\": \"/etc/letsencrypt/live/$DOMAIN/fullchain.pem\", \"keyFile\": \"/etc/letsencrypt/live/$DOMAIN/privkey.pem\"\}\]\}\}\},/" $CONFIG_FILE || error_exit "Failed to configure V2Ray for SSL."

    # Restart V2Ray service
    sudo systemctl restart v2ray || error_exit "Failed to restart V2Ray."
}

# Handle user input for the menu
read_menu_option() {
    local choice
    read choice
    case $choice in
        1) echo "Creating user...";;
        2) echo "Creating test user...";;
        3) echo "Removing user...";;
        4) echo "Monitoring online users...";;
        5) echo "Changing date...";;
        6) echo "Changing limit...";;
        7) echo "Changing password...";;
        8) echo "Removing expired users...";;
        9) echo "Generating user report...";;
        10) echo "Configuring connection mode...";;
        11) echo "Running speedtest...";;
        12) echo "Configuring banner...";;
        13) echo "Displaying network traffic...";;
        14) echo "Optimizing VPS...";;
        15) echo "Backing up user data...";;
        16) echo "Setting user limiter...";;
        17) echo "Configuring Bad VPN...";;
        18) echo "Displaying VPS info...";;
        19) echo "More options coming soon...";;
        20) install_v2ray;;
        0) exit 0;;
        *) echo "Invalid option. Please try again.";;
    esac
}

# Main menu loop
while true; do
    show_menu
    read_menu_option
done
