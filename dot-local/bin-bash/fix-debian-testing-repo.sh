#!/bin/bash

set -e

echo "📁 Backing up existing sources..."
timestamp=$(date +%F-%T)
cp /etc/apt/sources.list /etc/apt/sources.list.backup.$timestamp
echo "✅ Backup saved to: /etc/apt/sources.list.backup.$timestamp"

echo "🔍 Filtering existing sources..."
grep -v '^deb http://deb.debian.org/debian' /etc/apt/sources.list | \
grep -v '^deb-src http://deb.debian.org/debian' | \
grep -v '^deb http://security.debian.org/' | \
grep -v '^deb-src http://security.debian.org/' > /tmp/custom_repos.list

echo "🧠 Injecting Debian Testing sources..."
cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian testing main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian testing main contrib non-free non-free-firmware

deb http://security.debian.org/ testing-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/ testing-security main contrib non-free non-free-firmware
EOF

# Append preserved custom repos
cat /tmp/custom_repos.list >> /etc/apt/sources.list
rm /tmp/custom_repos.list

echo "🧩 Sources list now includes Debian Testing + your third-party repos."

read -p "🚀 Proceed with 'apt update && apt full-upgrade'? (y/n): " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    apt update
    apt full-upgrade
    echo "🎉 Migration complete. You're now tracking Debian Testing!"
else
    echo "👍 You can upgrade manually later. The sources list is ready."
fi

