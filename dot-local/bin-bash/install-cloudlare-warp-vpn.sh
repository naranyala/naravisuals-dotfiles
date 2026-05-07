
#!/bin/bash
set -e

# ── Configurable options ────────────────────────────────────────────────
INSTALL_CMD="sudo apt install -y cloudflare-warp"
CHECK_CMD="warp-cli --version"
REGISTER_CMD="warp-cli register"
CONNECT_CMD="warp-cli connect"
VERIFY_CMD="wget https://www.cloudflare.com/cdn-cgi/trace | grep warp"
# VERIFY_CMD="curl -s https://www.cloudflare.com/cdn-cgi/trace | grep warp"
# VERIFY_CMD="/home/linuxbrew/.linuxbrew/bin/curl -s https://www.cloudflare.com/cdn-cgi/trace | grep warp"


# ── Prerequisites check ────────────────────────────────────────────────
echo "[+] Checking for required tools..."
for cmd in curl sudo apt; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "[-] Required command not found: $cmd"
        exit 1
    fi
done

# ── Install WARP CLI ────────────────────────────────────────────────
echo "[+] Installing Cloudflare WARP CLI..."
$INSTALL_CMD

# ── Register Client ────────────────────────────────────────────────
echo "[+] Registering WARP client..."
$REGISTER_CMD

# ── Connect ─────────────────────────────────────────────────────────
echo "[+] Connecting to WARP VPN..."
$CONNECT_CMD

# ── Verify ──────────────────────────────────────────────────────────
echo "[+] Verifying connection status..."
if $VERIFY_CMD; then
    echo "[✔] WARP VPN is active!"
else
    echo "[!] Connection failed or not verified."
fi
