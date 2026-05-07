#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use 'sudo ./sync_time.sh'."
    exit 1
fi

# Install ntpdate if not installed (Debian/Ubuntu)
if ! command -v ntpdate &> /dev/null; then
    echo "ntpdate not found. Installing..."
    apt-get update && apt-get install -y ntpsec-ntpdate
fi

# Sync time with NTP server
echo "Syncing system time with internet..."
ntpdate pool.ntp.org

# Check if sync was successful
if [ $? -eq 0 ]; then
    echo "Time synced successfully!"
    date
else
    echo "Failed to sync time. Check your internet connection."
fi

