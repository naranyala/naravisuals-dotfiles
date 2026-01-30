import subprocess
import sys

# --- Try importing tkinter ---
try:
    import tkinter as tk
    from tkinter import messagebox
except ImportError:
    print("Error: Tkinter is not installed or not available in this Python build.")
    print("👉 Hint: On Fedora, install Tk support with:")
    print("   sudo dnf install -y tk tk-devel")
    print("Then reinstall Python in your uv environment:")
    print("   uv python install --reinstall")
    sys.exit(1)

# --- Helper functions ---
def run_cmd(cmd):
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"Command failed: {e}")

def get_status():
    result = subprocess.run(["warp-cli", "status"], capture_output=True, text=True)
    if "Connected" in result.stdout:
        return "Connected"
    else:
        return "Disconnected"

def toggle_vpn():
    status = get_status()
    if status == "Connected":
        run_cmd(["warp-cli", "disconnect"])
        status_label.config(text="VPN Status: Disconnected", fg="red")
    else:
        run_cmd(["warp-cli", "connect"])
        status_label.config(text="VPN Status: Connected", fg="green")

# --- GUI setup ---
root = tk.Tk()
root.title("VPN Toggle")

status_label = tk.Label(root, text=f"VPN Status: {get_status()}", font=("Arial", 14))
status_label.pack(pady=10)

toggle_button = tk.Button(root, text="Toggle VPN", command=toggle_vpn, font=("Arial", 12))
toggle_button.pack(pady=10)

quit_button = tk.Button(root, text="Quit", command=root.quit, font=("Arial", 12))
quit_button.pack(pady=10)

root.mainloop()

