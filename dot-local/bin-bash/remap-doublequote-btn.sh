#!/usr/bin/env bash
# fix-quotes.sh — manual remap for single/double-quote key

set -euo pipefail

echo "→ Setting quote key remap manually using keyd…"

sudo mkdir -p /etc/keyd
sudo tee /etc/keyd/default.conf >/dev/null <<EOF
[ids]
*

[main]
48 = quote
EOF

sudo systemctl enable keyd
sudo systemctl restart keyd

echo "✅ Key remap applied. Test with ' and \""

