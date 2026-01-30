import customtkinter as ctk
import subprocess
import threading
import time
import psutil
import socket
import logging
import os
from datetime import datetime
from typing import Optional, Tuple, Dict, Any, Callable
from enum import Enum


class LogLevel:
    def __init__(self, value: str):
        self.value = value

    def __eq__(self, other):
        return self.value == other

    def __str__(self):
        return self.value


# Create LogLevel instances
INFO = LogLevel("INFO")
WARNING = LogLevel("WARNING")
ERROR = LogLevel("ERROR")
SUCCESS = LogLevel("SUCCESS")


class WarpLogger:
    """Enhanced logging system for Warp VPN operations"""

    def __init__(self):
        self.logs = []
        self.log_callback: Optional[callable] = None
        self.max_logs = 500  # Keep last 500 logs in memory

        # Setup file logging
        log_dir = os.path.expanduser("~/.warp-vpn-logs")
        os.makedirs(log_dir, exist_ok=True)
        log_file = os.path.join(
            log_dir, f"warp_{datetime.now().strftime('%Y%m%d')}.log"
        )

        logging.basicConfig(
            level=logging.DEBUG,
            format="%(asctime)s - %(levelname)s - %(message)s",
            handlers=[logging.FileHandler(log_file), logging.StreamHandler()],
        )
        self.logger = logging.getLogger("WarpVPN")

    def log(self, level: LogLevel, message: str, details: str = ""):
        """Add a log entry"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        log_entry = {
            "timestamp": timestamp,
            "level": level,
            "message": message,
            "details": details,
        }

        # Add to memory logs
        self.logs.append(log_entry)
        if len(self.logs) > self.max_logs:
            self.logs.pop(0)

        # Log to file
        log_message = f"{message}"
        if details:
            log_message += f" | {details}"

        if level.value == "ERROR":
            self.logger.error(log_message)
        elif level.value == "WARNING":
            self.logger.warning(log_message)
        elif level.value == "SUCCESS":
            self.logger.info(f"✅ {log_message}")
        else:
            self.logger.info(log_message)

        # Update GUI if callback is set
        if hasattr(self, "log_callback") and self.log_callback:
            self.log_callback(log_entry)

    def info(self, message: str, details: str = ""):
        self.log(INFO, message, details)

    def success(self, message: str, details: str = ""):
        self.log(SUCCESS, message, details)

    def warning(self, message: str, details: str = ""):
        self.log(WARNING, message, details)

    def error(self, message: str, details: str = ""):
        self.log(ERROR, message, details)

    def debug(self, message: str, details: str = ""):
        self.log(INFO, message, details)

    def clear_logs(self):
        """Clear all logs"""
        self.logs.clear()
        self.info("Logs cleared", "All log entries have been removed")

    def export_logs(self, filename: str = "") -> str:
        """Export logs to file"""
        if not filename:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"warp_logs_{timestamp}.txt"

        try:
            with open(filename, "w") as f:
                f.write("=== Warp VPN Client Logs ===\n")
                f.write(f"Exported: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

                for log in self.logs:
                    f.write(f"[{log['timestamp']}] {log['level']}: {log['message']}")
                    if log["details"]:
                        f.write(f" | {log['details']}")
                    f.write("\n")

            self.success("Logs exported", f"Saved to {filename}")
            return filename
        except Exception as e:
            self.error("Failed to export logs", str(e))
            return ""


class WarpClientGUI:
    def __init__(self):
        # Initialize logger
        self.warp_logger = WarpLogger()

        # Set appearance
        ctk.set_appearance_mode("dark")
        ctk.set_default_color_theme("blue")

        # Main window - fixed size for single screen
        self.root = ctk.CTk()
        self.root.title("🛡️ Warp VPN Client")
        self.root.geometry("800x700")
        self.root.resizable(True, True)
        self.root.minsize(600, 500)

        # Center window on screen
        self.root.update_idletasks()
        screen_width = self.root.winfo_screenwidth()
        screen_height = self.root.winfo_screenheight()
        x = (screen_width - 800) // 2
        y = (screen_height - 700) // 2
        self.root.geometry(f"800x700+{x}+{y}")

        # Configure grid weights
        self.root.grid_columnconfigure(0, weight=1)
        self.root.grid_rowconfigure(0, weight=1)

        # Status variables
        self.is_connected = False
        self.status_thread = None
        self.stop_status_check = False
        self.warp_available = False
        self.last_error = ""
        self.connection_time = 0
        self.traffic_stats = {"upload": 0, "download": 0}

        # Log section variables
        self.logs_visible = False
        self.log_filter_level = "ALL"

        # Set up logger callback
        self.warp_logger.log_callback = self.add_log_to_gui

        # Log startup
        self.warp_logger.info(
            "Warp VPN Client starting", "Initializing compact GUI layout"
        )

        # Create GUI elements
        self.setup_ui()

        # Start status checking
        self.start_status_check()

        self.warp_logger.success(
            "Application started", "Compact GUI initialized successfully"
        )

    def setup_ui(self):
        # Main container - no scrollable frame
        main_container = ctk.CTkFrame(self.root)
        main_container.grid(row=0, column=0, padx=10, pady=10, sticky="nsew")
        main_container.grid_columnconfigure(0, weight=1)
        main_container.grid_rowconfigure(4, weight=1)  # Give logs section weight

        # Header - compact
        header_frame = ctk.CTkFrame(main_container)
        header_frame.grid(row=0, column=0, padx=10, pady=(10, 5), sticky="ew")

        title_label = ctk.CTkLabel(
            header_frame,
            text="🛡️ Warp VPN Client",
            font=ctk.CTkFont(size=22, weight="bold"),
        )
        title_label.pack(pady=8)

        subtitle_label = ctk.CTkLabel(
            header_frame,
            text="Secure & Private Internet Access",
            font=ctk.CTkFont(size=12),
            text_color=("gray70", "gray30"),
        )
        subtitle_label.pack(pady=(0, 8))

        # Main Status Card - compact
        self.status_card = ctk.CTkFrame(main_container)
        self.status_card.grid(row=1, column=0, padx=10, pady=5, sticky="ew")

        # Status Header - compact
        status_header = ctk.CTkFrame(self.status_card)
        status_header.pack(fill="x", padx=10, pady=10)

        self.status_label = ctk.CTkLabel(
            status_header,
            text="🔄 Checking status...",
            font=ctk.CTkFont(size=16, weight="bold"),
        )
        self.status_label.pack(side="left", padx=8)

        self.status_badge = ctk.CTkLabel(
            status_header,
            text="●",
            font=ctk.CTkFont(size=14),
            text_color=("gray60", "gray40"),
        )
        self.status_badge.pack(side="right", padx=8)

        # Status Progress - thinner
        self.status_indicator = ctk.CTkProgressBar(self.status_card)
        self.status_indicator.pack(pady=5, padx=15, fill="x")
        self.status_indicator.set(0)

        # Connection Timer & Main Button in same row
        control_frame = ctk.CTkFrame(self.status_card)
        control_frame.pack(fill="x", padx=10, pady=5)

        # Timer on left
        self.timer_label = ctk.CTkLabel(
            control_frame,
            text="Connected for: --:--:--",
            font=ctk.CTkFont(size=11),
            text_color=("gray70", "gray30"),
        )
        self.timer_label.pack(side="left", padx=10, pady=5)

        # Main Control Button on right
        self.connect_button = ctk.CTkButton(
            control_frame,
            text="🚀 Connect",
            font=ctk.CTkFont(size=14, weight="bold"),
            command=self.toggle_connection,
            height=45,
            width=200,
            corner_radius=12,
        )
        self.connect_button.pack(side="right", padx=10, pady=5)

        # Network Info & Info Card in same row for space efficiency
        info_row_frame = ctk.CTkFrame(main_container)
        info_row_frame.grid(row=2, column=0, padx=10, pady=5, sticky="ew")
        info_row_frame.grid_columnconfigure(0, weight=1)
        info_row_frame.grid_columnconfigure(1, weight=1)

        # Network Info Card - smaller
        self.network_card = ctk.CTkFrame(info_row_frame)
        self.network_card.grid(row=0, column=0, padx=(5, 2), pady=5, sticky="ew")

        network_title = ctk.CTkLabel(
            self.network_card,
            text="📊 Network",
            font=ctk.CTkFont(size=14, weight="bold"),
        )
        network_title.pack(pady=(8, 5))

        # Compact network grid
        network_grid = ctk.CTkFrame(self.network_card)
        network_grid.pack(padx=8, pady=(0, 8), fill="x")

        # IP Address - compact
        ip_frame = ctk.CTkFrame(network_grid)
        ip_frame.pack(fill="x", pady=2)

        ctk.CTkLabel(
            ip_frame, text="🌐 IP:", font=ctk.CTkFont(size=10, weight="bold")
        ).pack(side="left", padx=5)
        self.ip_label = ctk.CTkLabel(
            ip_frame, text="Checking...", font=ctk.CTkFont(size=10)
        )
        self.ip_label.pack(side="right", padx=5)

        # Interface - compact
        interface_frame = ctk.CTkFrame(network_grid)
        interface_frame.pack(fill="x", pady=2)

        ctk.CTkLabel(
            interface_frame, text="🔌 IF:", font=ctk.CTkFont(size=10, weight="bold")
        ).pack(side="left", padx=5)
        self.interface_label = ctk.CTkLabel(
            interface_frame, text="Checking...", font=ctk.CTkFont(size=10)
        )
        self.interface_label.pack(side="right", padx=5)

        # Traffic - compact
        traffic_frame = ctk.CTkFrame(network_grid)
        traffic_frame.pack(fill="x", pady=2)

        ctk.CTkLabel(
            traffic_frame, text="⬆️↑:", font=ctk.CTkFont(size=10, weight="bold")
        ).pack(side="left", padx=5)
        self.upload_label = ctk.CTkLabel(
            traffic_frame, text="0 MB", font=ctk.CTkFont(size=10)
        )
        self.upload_label.pack(side="left", padx=(0, 15))

        ctk.CTkLabel(
            traffic_frame, text="⬇️↓:", font=ctk.CTkFont(size=10, weight="bold")
        ).pack(side="left", padx=5)
        self.download_label = ctk.CTkLabel(
            traffic_frame, text="0 MB", font=ctk.CTkFont(size=10)
        )
        self.download_label.pack(side="right", padx=5)

        # Status & Info Card - smaller
        self.info_card = ctk.CTkFrame(info_row_frame)
        self.info_card.grid(row=0, column=1, padx=(2, 5), pady=5, sticky="ew")

        info_title = ctk.CTkLabel(
            self.info_card, text="📋 Status", font=ctk.CTkFont(size=14, weight="bold")
        )
        info_title.pack(pady=(8, 5))

        self.info_label = ctk.CTkLabel(
            self.info_card,
            text="🔄 Initializing...",
            font=ctk.CTkFont(size=11),
            wraplength=200,
            justify="left",
        )
        self.info_label.pack(pady=2, padx=8)

        # Error Display - compact
        self.error_label = ctk.CTkLabel(
            self.info_card,
            text="",
            font=ctk.CTkFont(size=10),
            text_color=("red", "darkred"),
            wraplength=200,
        )
        self.error_label.pack(pady=(0, 8), padx=8)

        # Control Buttons - compact
        controls_frame = ctk.CTkFrame(main_container)
        controls_frame.grid(row=3, column=0, padx=10, pady=5, sticky="ew")

        button_frame = ctk.CTkFrame(controls_frame)
        button_frame.pack(pady=8)

        self.settings_button = ctk.CTkButton(
            button_frame,
            text="⚙️ Settings",
            font=ctk.CTkFont(size=11),
            command=self.open_settings,
            height=30,
            width=100,
        )
        self.settings_button.pack(side="left", padx=3)

        self.toggle_logs_button = ctk.CTkButton(
            button_frame,
            text="📋 Logs",
            font=ctk.CTkFont(size=11),
            command=self.toggle_logs_section,
            height=30,
            width=100,
        )
        self.toggle_logs_button.pack(side="left", padx=3)

        # Logs Section - takes remaining space
        self.logs_section = ctk.CTkFrame(main_container)

        # Logs Header - compact
        logs_header_frame = ctk.CTkFrame(self.logs_section)
        logs_header_frame.pack(fill="x", padx=8, pady=(8, 5))

        logs_title = ctk.CTkLabel(
            logs_header_frame, text="📋 Logs", font=ctk.CTkFont(size=14, weight="bold")
        )
        logs_title.pack(side="left", padx=5)

        # Log Controls - compact
        log_controls_frame = ctk.CTkFrame(logs_header_frame)
        log_controls_frame.pack(side="right", padx=5)

        # Filter dropdown - smaller
        self.log_filter_var = ctk.StringVar(value="ALL")
        self.log_filter_menu = ctk.CTkOptionMenu(
            log_controls_frame,
            values=["ALL", "INFO", "SUCCESS", "WARNING", "ERROR"],
            variable=self.log_filter_var,
            command=self.filter_logs,
            width=60,
        )
        self.log_filter_menu.pack(side="left", padx=2)

        # Clear logs button - smaller
        clear_logs_button = ctk.CTkButton(
            log_controls_frame, text="🗑️", width=30, command=self.clear_logs
        )
        clear_logs_button.pack(side="left", padx=2)

        # Export logs button - smaller
        export_logs_button = ctk.CTkButton(
            log_controls_frame, text="💾", width=30, command=self.export_logs
        )
        export_logs_button.pack(side="left", padx=2)

        # Logs Display - takes most of the remaining space
        self.logs_frame = ctk.CTkFrame(self.logs_section)
        self.logs_frame.pack(padx=8, pady=(0, 8), fill="both", expand=True)

        # Create text widget for logs
        self.logs_text = ctk.CTkTextbox(self.logs_frame)
        self.logs_text.pack(fill="both", expand=True, padx=5, pady=5)

        # Configure text tags for different log levels
        self.logs_text.tag_config("INFO", foreground="gray")
        self.logs_text.tag_config("SUCCESS", foreground="green")
        self.logs_text.tag_config("WARNING", foreground="orange")
        self.logs_text.tag_config("ERROR", foreground="red")

        # Initially hide logs
        self.logs_visible = False

    def add_log_to_gui(self, log_entry: dict):
        """Add log entry to GUI display"""
        try:
            timestamp = log_entry["timestamp"]
            level = log_entry["level"]
            message = log_entry["message"]
            details = log_entry.get("details", "")

            # Format log line - more compact
            log_line = f"[{timestamp}] {level}: {message}"
            if details:
                log_line += f" | {details[:50]}..."  # Truncate long details

            # Add to text widget
            self.logs_text.insert("end", log_line + "\n", level)

            # Auto-scroll to bottom
            self.logs_text.see("end")

            # Limit text widget content
            lines = self.logs_text.get("1.0", "end").split("\n")
            if len(lines) > 200:  # Keep last 200 lines in display
                self.logs_text.delete("1.0", "20.0")

        except Exception as e:
            print(f"Error adding log to GUI: {e}")

    def toggle_logs_section(self):
        """Toggle visibility of logs section"""
        if self.logs_visible:
            self.logs_section.grid_forget()
            self.toggle_logs_button.configure(text="📋 Logs")
            self.logs_visible = False
            self.warp_logger.info("Logs section hidden")
        else:
            self.logs_section.grid(row=4, column=0, padx=10, pady=5, sticky="nsew")
            self.toggle_logs_button.configure(text="📋 Hide")
            self.logs_visible = True
            self.warp_logger.info("Logs section shown")

    def filter_logs(self, selection):
        """Filter logs by level"""
        self.log_filter_level = selection
        self.refresh_logs_display()
        self.warp_logger.info("Log filter changed", f"Showing {selection} logs")

    def refresh_logs_display(self):
        """Refresh the logs display with current filter"""
        try:
            self.logs_text.delete("1.0", "end")

            for log_entry in self.warp_logger.logs:
                if (
                    self.log_filter_level == "ALL"
                    or log_entry["level"] == self.log_filter_level
                ):
                    self.add_log_to_gui(log_entry)

        except Exception as e:
            print(f"Error refreshing logs: {e}")

    def clear_logs(self):
        """Clear all logs"""
        self.warp_logger.clear_logs()
        self.logs_text.delete("1.0", "end")
        self.warp_logger.info("Logs cleared by user")

    def export_logs(self):
        """Export logs to file"""
        filename = self.warp_logger.export_logs()
        if filename:
            self.warp_logger.success("Logs exported successfully", f"File: {filename}")
        else:
            self.warp_logger.error("Failed to export logs")

    def run_warp_command(self, command: str) -> Tuple[bool, str]:
        """Run warp CLI command and return success status and output"""
        self.warp_logger.info("Executing warp command", f"Command: warp-cli {command}")

        try:
            result = subprocess.run(
                ["warp-cli", command], capture_output=True, text=True, timeout=10
            )

            success = result.returncode == 0
            output = result.stdout.strip() or result.stderr.strip()

            if success:
                self.warp_logger.success(
                    "Command executed successfully", f"Output: {output[:100]}..."
                )
            else:
                self.warp_logger.error("Command failed", f"Error: {output}")

            return success, output

        except subprocess.TimeoutExpired:
            error = "Command timed out"
            self.warp_logger.error(
                "Command timeout", f"warp-cli {command} timed out after 10 seconds"
            )
            return False, error
        except FileNotFoundError:
            error = "warp-cli not found. Please install Cloudflare Warp."
            self.warp_logger.error(
                "warp-cli not found",
                "Cloudflare Warp CLI is not installed or not in PATH",
            )
            return False, error
        except Exception as e:
            error = str(e)
            self.warp_logger.error("Command exception", f"Unexpected error: {error}")
            return False, error

    def check_warp_availability(self) -> bool:
        """Check if warp-cli is available"""
        self.warp_logger.info("Checking Warp availability")

        success, _ = self.run_warp_command("--help")

        if success:
            self.warp_logger.success(
                "Warp CLI is available", "warp-cli found and working"
            )
        else:
            self.warp_logger.error(
                "Warp CLI not available", "Install Cloudflare Warp CLI"
            )

        return success

    def get_network_info(self) -> Dict[str, Any]:
        """Get detailed network information"""
        self.warp_logger.info("Gathering network information")

        try:
            # Get network interfaces
            interfaces = psutil.net_if_stats()
            active_interfaces = [
                iface for iface, stats in interfaces.items() if stats.isup
            ]

            # Get primary interface
            primary_interface = active_interfaces[0] if active_interfaces else "Unknown"

            # Get IP information
            ip_info = self.get_ip_info()

            # Get traffic statistics
            traffic = self.get_traffic_stats()

            result = {
                "ip": ip_info["ip"],
                "interface": primary_interface,
                "upload": traffic["upload"],
                "download": traffic["download"],
                "is_private": ip_info["is_private"],
            }

            self.warp_logger.success(
                "Network info gathered",
                f"IP: {result['ip']}, Interface: {result['interface']}",
            )

            return result

        except Exception as e:
            error = str(e)
            self.warp_logger.error("Failed to get network info", error)
            return {
                "ip": "Error",
                "interface": "Error",
                "upload": 0,
                "download": 0,
                "is_private": False,
                "error": error,
            }

    def get_ip_info(self) -> Dict[str, Any]:
        """Get current IP information"""
        try:
            if self.is_connected:
                # When connected to Warp, get public IP info
                success, output = self.run_warp_command("account")
                if success:
                    return {"ip": "Protected", "is_private": True}
                else:
                    return {"ip": "Error", "is_private": False}
            else:
                # Get local IP
                s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                s.connect(("8.8.8.8", 80))
                local_ip = s.getsockname()[0]
                s.close()

                # Check if private IP
                is_private = (
                    local_ip.startswith("192.168.")
                    or local_ip.startswith("10.")
                    or local_ip.startswith("172.")
                    or local_ip == "127.0.0.1"
                )

                self.warp_logger.info(
                    "Local IP detected", f"{local_ip} (Private: {is_private})"
                )

                return {"ip": local_ip, "is_private": is_private}

        except Exception as e:
            self.warp_logger.error("Failed to get IP info", str(e))
            return {"ip": "Unknown", "is_private": False}

    def get_traffic_stats(self) -> Dict[str, float]:
        """Get network traffic statistics"""
        try:
            net_io = psutil.net_io_counters()
            stats = {
                "upload": net_io.bytes_sent / (1024 * 1024),  # Convert to MB
                "download": net_io.bytes_recv / (1024 * 1024),
            }

            self.warp_logger.debug(
                "Traffic stats updated",
                f"Upload: {stats['upload']:.1f}MB, Download: {stats['download']:.1f}MB",
            )

            return stats
        except Exception as e:
            self.warp_logger.error("Failed to get traffic stats", str(e))
            return {"upload": 0, "download": 0}

    def format_bytes(self, bytes_value: float) -> str:
        """Format bytes to human readable format"""
        if bytes_value < 1024:
            return f"{bytes_value:.0f}B"
        elif bytes_value < 1024 * 1024:
            return f"{bytes_value / 1024:.1f}KB"
        elif bytes_value < 1024 * 1024 * 1024:
            return f"{bytes_value / (1024 * 1024):.1f}MB"
        else:
            return f"{bytes_value / (1024 * 1024 * 1024):.1f}GB"

    def format_time(self, seconds: int) -> str:
        """Format seconds to HH:MM:SS"""
        hours = seconds // 3600
        minutes = (seconds % 3600) // 60
        secs = seconds % 60
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"

    def get_connection_status(self) -> bool:
        """Check current Warp connection status"""
        self.warp_logger.debug("Checking connection status")

        success, output = self.run_warp_command("status")
        is_connected = success and "Connected" in output

        if is_connected:
            self.warp_logger.success("Warp is connected", output[:50])
        else:
            self.warp_logger.debug("Warp is disconnected", output[:50])

        return is_connected

    def update_status_display(self):
        """Update the GUI status display with comprehensive information"""
        self.warp_logger.debug("Updating status display")

        try:
            # Check Warp availability first
            if not self.warp_available:
                self.warp_available = self.check_warp_availability()
                if not self.warp_available:
                    self.status_label.configure(text="❌ Warp Not Available")
                    self.status_badge.configure(text="●", text_color=("red", "darkred"))
                    self.status_indicator.set(0)
                    self.connect_button.configure(
                        text="📥 Install Warp",
                        state="disabled",
                        fg_color=("gray60", "gray40"),
                    )
                    self.info_label.configure(text="❌ Warp CLI not found")
                    self.error_label.configure(text="Install Cloudflare Warp CLI")
                    return
                else:
                    self.connect_button.configure(state="normal")
                    self.warp_logger.success(
                        "Warp became available", "GUI controls enabled"
                    )

            # Get network information
            network_info = self.get_network_info()

            # Check connection status
            if self.get_connection_status():
                if not self.is_connected:
                    self.connection_time = 0  # Reset timer on new connection
                    self.warp_logger.success(
                        "Connection established", "Warp VPN is now active"
                    )

                self.is_connected = True
                self.status_label.configure(text="🟢 Connected")
                self.status_badge.configure(text="●", text_color=("green", "darkgreen"))
                self.status_indicator.set(1)
                self.connect_button.configure(
                    text="🔌 Disconnect", fg_color=("red", "darkred")
                )
                self.info_label.configure(text="✅ VPN active")
                self.error_label.configure(text="")

                # Update connection timer
                self.connection_time += 1
                self.timer_label.configure(
                    text=f"⏱ {self.format_time(self.connection_time)}"
                )

            else:
                if self.is_connected:
                    self.warp_logger.warning(
                        "Connection lost", "Warp VPN disconnected unexpectedly"
                    )

                self.is_connected = False
                self.connection_time = 0
                self.status_label.configure(text="🔴 Disconnected")
                self.status_badge.configure(text="●", text_color=("gray60", "gray40"))
                self.status_indicator.set(0)
                self.connect_button.configure(text="🚀 Connect", fg_color=None)
                self.info_label.configure(text="🔄 Ready to connect")
                self.timer_label.configure(text="⏱ --:--:--")

                if self.last_error:
                    self.error_label.configure(text=f"Error: {self.last_error[:30]}...")

            # Update network information
            self.ip_label.configure(text=network_info["ip"][:15])  # Truncate long IPs
            self.interface_label.configure(
                text=network_info["interface"][:12]
            )  # Truncate long names

            # Format and update traffic stats
            upload_str = self.format_bytes(network_info["upload"] * 1024 * 1024)
            download_str = self.format_bytes(network_info["download"] * 1024 * 1024)
            self.upload_label.configure(text=upload_str)
            self.download_label.configure(text=download_str)

        except Exception as e:
            error_msg = f"Update error: {str(e)[:30]}..."
            self.warp_logger.error("Status update failed", str(e))
            self.error_label.configure(text=error_msg)

    def toggle_connection(self):
        """Toggle between connect and disconnect with enhanced feedback"""
        if self.is_connected:
            # Disconnect
            self.warp_logger.info("Disconnect initiated by user")
            self.info_label.configure(text="🔄 Disconnecting...")
            self.connect_button.configure(state="disabled", text="⏳ Disconnecting...")

            success, output = self.run_warp_command("disconnect")

            if success:
                self.last_error = ""
                self.info_label.configure(text="✅ Disconnected")
                self.warp_logger.success("Disconnection successful", output[:100])
            else:
                self.last_error = output
                self.error_label.configure(text=f"Failed: {output[:30]}...")
                self.info_label.configure(text="❌ Disconnect failed")
                self.warp_logger.error("Disconnection failed", output)
        else:
            # Connect
            self.warp_logger.info("Connection initiated by user")
            self.info_label.configure(text="🔄 Connecting...")
            self.connect_button.configure(state="disabled", text="⏳ Connecting...")

            success, output = self.run_warp_command("connect")

            if success:
                self.last_error = ""
                self.info_label.configure(text="✅ Connected")
                self.warp_logger.success("Connection successful", output[:100])
            else:
                self.last_error = output
                self.error_label.configure(text=f"Failed: {output[:30]}...")
                self.info_label.configure(text="❌ Connect failed")
                self.warp_logger.error("Connection failed", output)

        # Re-enable button and update status after a delay
        self.root.after(1500, lambda: self.connect_button.configure(state="normal"))
        self.root.after(2000, self.update_status_display)

    def open_settings(self):
        """Open settings dialog"""
        self.warp_logger.info("Settings dialog opened")

        settings_window = ctk.CTkToplevel(self.root)
        settings_window.title("⚙️ Settings")
        settings_window.geometry("350x250")
        settings_window.transient(self.root)
        settings_window.grab_set()

        # Settings content
        settings_label = ctk.CTkLabel(
            settings_window,
            text="Warp VPN Settings",
            font=ctk.CTkFont(size=18, weight="bold"),
        )
        settings_label.pack(pady=15)

        # Auto-connect setting
        auto_connect_var = ctk.BooleanVar(value=False)
        auto_connect_checkbox = ctk.CTkCheckBox(
            settings_window, text="Auto-connect on startup", variable=auto_connect_var
        )
        auto_connect_checkbox.pack(pady=8)

        # Dark mode setting
        dark_mode_var = ctk.BooleanVar(value=True)
        dark_mode_checkbox = ctk.CTkCheckBox(
            settings_window,
            text="Dark mode",
            variable=dark_mode_var,
            command=lambda: ctk.set_appearance_mode(
                "dark" if dark_mode_var.get() else "light"
            ),
        )
        dark_mode_checkbox.pack(pady=8)

        # Status refresh interval
        refresh_label = ctk.CTkLabel(
            settings_window, text="Refresh interval (seconds):"
        )
        refresh_label.pack(pady=(15, 5))

        refresh_slider = ctk.CTkSlider(
            settings_window, from_=1, to=30, number_of_steps=29, value=5
        )
        refresh_slider.pack(pady=5, padx=20, fill="x")

        # Close button
        close_button = ctk.CTkButton(
            settings_window, text="Close", command=settings_window.destroy
        )
        close_button.pack(pady=15)

    def status_check_loop(self):
        """Background thread to continuously check status"""
        self.warp_logger.info("Status checking thread started")

        while not self.stop_status_check:
            try:
                self.root.after(0, self.update_status_display)
                time.sleep(5)  # Check every 5 seconds
            except Exception as e:
                self.warp_logger.error("Status check loop error", str(e))
                break

        self.warp_logger.info("Status checking thread stopped")

    def start_status_check(self):
        """Start the status checking thread"""
        self.status_thread = threading.Thread(
            target=self.status_check_loop, daemon=True
        )
        self.status_thread.start()

    def run(self):
        """Start the GUI application"""
        try:
            self.warp_logger.info("Starting main GUI loop")
            self.root.mainloop()
        except Exception as e:
            self.warp_logger.error("Main loop error", str(e))
        finally:
            self.stop_status_check = True
            self.warp_logger.info("Application shutting down")


def main():
    app = WarpClientGUI()
    app.run()


if __name__ == "__main__":
    main()
