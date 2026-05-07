
#!/bin/bash

# Bash script to rename a Linux username and hostname
# Usage: sudo ./rename.sh <old_username> <new_username> <new_hostname>

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (use sudo)."
  exit 1
fi

if [ $# -ne 3 ]; then
  echo "Usage: $0 <old_username> <new_username> <new_hostname>"
  exit 1
fi

OLD_USER=$1
NEW_USER=$2
NEW_HOST=$3

echo "Renaming user '$OLD_USER' → '$NEW_USER'"
echo "Renaming hostname → '$NEW_HOST'"

# 1. Change the username
usermod -l "$NEW_USER" "$OLD_USER"

# 2. Rename the home directory
usermod -d /home/"$NEW_USER" -m "$NEW_USER"

# 3. Update ownership of files in home
chown -R "$NEW_USER":"$NEW_USER" /home/"$NEW_USER"

# 4. Change the hostname
hostnamectl set-hostname "$NEW_HOST"

# 5. Update /etc/hosts (optional but recommended)
sed -i "s/127.0.1.1.*/127.0.1.1\t$NEW_HOST/" /etc/hosts

echo "✅ Username and hostname updated successfully."
echo "Please log out and back in, or reboot, to apply changes."
