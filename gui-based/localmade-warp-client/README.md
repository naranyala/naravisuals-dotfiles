# Warp VPN GUI Client

A modern GUI application for managing Cloudflare Warp VPN connections using Python and CustomTkinter.

## Features

- **Modern GUI**: Clean, dark-themed interface using CustomTkinter
- **One-Click Control**: Easy connect/disconnect functionality
- **Real-time Status**: Live connection status monitoring
- **Network Information**: Displays current IP and network interface
- **Error Handling**: Comprehensive error messages and status updates
- **Warp Detection**: Automatically checks if Warp CLI is installed

## Requirements

- Python 3.14+
- Cloudflare Warp CLI (`warp-cli`)
- Linux system with GUI support

## Installation

1. Install dependencies using uv:
   ```bash
   uv sync
   ```

2. Install Cloudflare Warp if not already installed:
   ```bash
   # For Ubuntu/Debian
   wget -q https://pkg.cloudflare.com/pubkey.gpg | sudo apt-key add -
   echo 'deb http://pkg.cloudflare.com/ focal main' | sudo tee /etc/apt/sources.list.d/cloudflare.list
   sudo apt update && sudo apt install cloudflare-warp

   # For other systems, visit: https://developers.cloudflare.com/warp-cli/get-started/
   ```

## Usage

Run the application:
```bash
uv run python main.py
```

### GUI Features

- **Status Indicator**: Shows current connection status with a progress bar
- **Connect/Disconnect Button**: Toggle Warp VPN connection
- **Network Info**: Displays current IP address and network interface
- **Error Display**: Shows detailed error messages when operations fail
- **Auto-refresh**: Status updates every 5 seconds

### Status Messages

- **Connected**: Warp VPN is active and protecting your connection
- **Disconnected**: Warp VPN is not active
- **Warp Not Available**: Warp CLI is not installed or not in PATH
- **Connecting/Disconnecting**: Operation in progress

## Troubleshooting

### "warp-cli not found"
- Install Cloudflare Warp CLI
- Ensure `warp-cli` is in your system PATH
- Try running `which warp-cli` to verify installation

### Connection Issues
- Check your internet connection
- Verify Warp service is running: `systemctl status cloudflare-warp`
- Restart Warp service: `sudo systemctl restart cloudflare-warp`

### Permission Issues
- Ensure your user has permissions to control Warp
- Try running with sudo: `sudo uv run python main.py`

## Development

This project uses:
- **CustomTkinter**: Modern GUI framework
- **psutil**: System and network information
- **uv**: Fast Python package manager

## License

This project is provided as-is for educational and personal use.