import asyncio
import subprocess
import sys
from typing import List
from textual import on
from textual.app import App, ComposeResult
from textual.containers import Vertical, VerticalScroll, Horizontal, Container
from textual.widgets import Header, Footer, Button, Checkbox, Static, Label
from textual.screen import Screen, ModalScreen
from textual.binding import Binding

# Comprehensive package list
PACKAGES = [
    # Development Tools
    "git", "gcc", "g++", "make", "cmake", "automake", "autoconf",
    "@development-tools", "kernel-devel", "rpm-build", "pkg-config",
    "python3", "python3-devel", "python3-pip", "python3-virtualenv",
    "nodejs", "npm", "yarn", "golang", "rust", "cargo",
    "java-latest-openjdk", "java-latest-openjdk-devel", "maven", "gradle",
    "ruby", "ruby-devel", "perl", "php", "php-cli",

    # CLI Tools
    "htop", "btop", "neofetch", "fastfetch", "curl", "wget",
    "tmux", "screen", "zsh", "fish", "bash-completion",
    "bat", "exa", "lsd", "ripgrep", "fd-find", "fzf",
    "jq", "yq", "httpie", "tree", "ncdu", "duf", "dust",
    "tldr", "thefuck", "z", "autojump", "zoxide",

    # Text Editors
    "vim-enhanced", "neovim", "emacs", "nano", "micro",
    "code", "vscodium", "gedit", "kate", "geany",

    # Media & Graphics
    "vlc", "mpv", "ffmpeg", "ffmpeg-free", "gstreamer1-plugins-good",
    "gstreamer1-plugins-bad-free", "gstreamer1-plugins-ugly-free",
    "gimp", "inkscape", "krita", "blender", "darktable",
    "obs-studio", "kdenlive", "shotcut", "audacity", "lmms",

    # Internet & Communication
    "firefox", "chromium", "google-chrome-stable", "brave-browser",
    "thunderbird", "evolution", "geary",
    "discord", "telegram-desktop", "pidgin", "hexchat",
    "transmission", "qbittorrent", "deluge", "aria2",
    "filezilla", "remmina", "vinagre",

    # Office & Productivity
    "libreoffice", "libreoffice-writer", "libreoffice-calc",
    "onlyoffice-desktopeditors", "calibre", "okular", "evince",
    "zathura", "zathura-pdf-mupdf", "keepassxc", "bitwarden",
    "gnome-calculator", "gnucash", "homebank",

    # System Tools
    "gparted", "gnome-disk-utility", "baobab", "filelight",
    "iotop", "iftop", "nethogs", "bmon", "nmap", "wireshark",
    "syncthing", "rsync", "rclone", "duplicity", "timeshift",
    "kdeconnect", "barrier", "dconf-editor", "gnome-tweaks",
    "flatpak", "snapd", "appstream", "fwupd",

    # Compression & Archives
    "p7zip", "p7zip-plugins", "unrar", "unzip", "zip",
    "tar", "gzip", "bzip2", "xz", "zstd",

    # Containers & Virtualization
    "podman", "podman-compose", "docker", "docker-compose",
    "buildah", "skopeo", "cri-o", "kubernetes", "kubectl",
    "virt-manager", "qemu-kvm", "libvirt", "vagrant",
    "virtualbox", "virtualbox-guest-additions",

    # Databases
    "mariadb", "mariadb-server", "postgresql", "postgresql-server",
    "redis", "mongodb", "sqlite", "sqlite-devel",

    # Web Servers & Tools
    "nginx", "httpd", "apache", "caddy",
    "certbot", "python3-certbot-nginx",

    # Security & Privacy
    "firejail", "apparmor", "selinux-policy", "fail2ban",
    "clamav", "clamav-update", "tor", "torsocks",
    "veracrypt", "cryptsetup", "gnupg2",

    # Network Tools
    "openssh", "openssh-server", "openvpn", "wireguard-tools",
    "net-tools", "iproute", "bind-utils", "traceroute",
    "tcpdump", "ethtool", "iperf3", "speedtest-cli",

    # Fonts
    "google-noto-fonts", "google-noto-emoji-fonts",
    "liberation-fonts", "dejavu-fonts", "fira-code-fonts",
    "jetbrains-mono-fonts", "powerline-fonts",

    # Gaming
    "steam", "lutris", "wine", "winetricks", "gamemode",
    "mangohud", "goverlay", "protonup-qt",

    # Multimedia Codecs
    "@multimedia", "gstreamer1-libav", "gstreamer1-vaapi",
    "mesa-va-drivers", "mesa-vdpau-drivers",

    # Desktop Environments (extras)
    "gnome-shell-extension-appindicator",
    "gnome-shell-extension-dash-to-dock",
    "papirus-icon-theme", "arc-theme", "numix-icon-theme",

    # Utilities
    "util-linux", "coreutils", "findutils", "grep", "sed", "awk",
    "less", "which", "file", "time", "watch", "lsof", "strace",
    "pciutils", "usbutils", "dmidecode", "smartmontools",
]

class PackageCheckbox(Checkbox):
    def __init__(self, pkg_name: str):
        super().__init__(label=pkg_name)
        self.pkg_name = pkg_name

class ConfirmDialog(ModalScreen[bool]):
    def __init__(self, packages: List[str]):
        super().__init__()
        self.packages = packages

    def compose(self) -> ComposeResult:
        with Container(id="dialog"):
            yield Label(f"📦 Install {len(self.packages)} packages?", id="dialog-title")
            with VerticalScroll(id="pkg-list"):
                for pkg in self.packages:
                    yield Label(f"  • {pkg}")
            with Horizontal(id="dialog-buttons"):
                yield Button("Install", variant="success", id="confirm")
                yield Button("Cancel", variant="default", id="cancel")

    @on(Button.Pressed, "#confirm")
    def confirm(self):
        self.dismiss(True)

    @on(Button.Pressed, "#cancel")
    def cancel(self):
        self.dismiss(False)

class MainScreen(Screen):
    BINDINGS = [
        Binding("ctrl+i", "install", "Install", show=True),
        Binding("ctrl+a", "select_all", "Select All", show=True),
        Binding("ctrl+d", "clear_all", "Clear All", show=True),
        Binding("ctrl+q", "quit", "Quit", show=True),
    ]

    def compose(self) -> ComposeResult:
        yield Header()

        with Vertical(id="main"):
            yield Label("Selected: 0 packages", id="counter")

            with VerticalScroll(id="package-list"):
                for pkg in sorted(PACKAGES):
                    yield PackageCheckbox(pkg)

            with Horizontal(id="actions"):
                yield Button("✅ Install Selected", id="install_btn", variant="success")
                yield Button("Select All", id="select_all_btn")
                yield Button("Clear All", id="clear_btn")
                yield Button("Quit", id="quit_btn", variant="error")

        yield Footer()

    def on_mount(self) -> None:
        self.update_counter()

    @on(Checkbox.Changed)
    def update_counter(self) -> None:
        count = sum(1 for cb in self.query(PackageCheckbox) if cb.value)
        total = len(PACKAGES)
        counter = self.query_one("#counter", Label)
        counter.update(f"Selected: {count} / {total} packages")

    @on(Button.Pressed, "#install_btn")
    async def install_selected(self) -> None:
        selected = [cb.pkg_name for cb in self.query(PackageCheckbox) if cb.value]
        if not selected:
            self.notify("⚠️ No packages selected", severity="warning")
            return

        confirmed = await self.app.push_screen_wait(ConfirmDialog(selected))
        if confirmed:
            self.app.push_screen(InstallScreen(selected))

    @on(Button.Pressed, "#select_all_btn")
    def action_select_all(self) -> None:
        for cb in self.query(PackageCheckbox):
            cb.value = True

    @on(Button.Pressed, "#clear_btn")
    def action_clear_all(self) -> None:
        for cb in self.query(PackageCheckbox):
            cb.value = False

    @on(Button.Pressed, "#quit_btn")
    def action_quit(self) -> None:
        self.app.exit()

class InstallScreen(Screen):
    def __init__(self, packages: List[str]):
        super().__init__()
        self.packages = packages

    def compose(self) -> ComposeResult:
        yield Header()
        with Vertical(id="install-box"):
            yield Label(f"⚙️ Installing {len(self.packages)} packages...", id="install-title")
            with VerticalScroll(id="output-box"):
                yield Static("Starting installation...\n", id="output")
            yield Button("← Back", id="back_btn")
        yield Footer()

    def on_mount(self) -> None:
        self.run_worker(self.install_packages())

    async def install_packages(self) -> None:
        output = self.query_one("#output", Static)

        try:
            cmd = ["sudo", "dnf", "install", "-y"] + self.packages
            output.update(f"Running: sudo dnf install -y ...\n\n")

            process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.STDOUT,
            )

            lines = []
            async for line in process.stdout:
                text = line.decode(errors="replace").strip()
                if text:
                    lines.append(text)
                    display = "\n".join(lines[-15:])
                    output.update(display)

            await process.wait()

            if process.returncode == 0:
                output.update(output.renderable + "\n\n✅ [green bold]Success![/green bold]")
                self.notify("✅ Installation completed!")
            else:
                output.update(output.renderable + f"\n\n❌ [red]Failed (code {process.returncode})[/red]")
                self.notify("❌ Installation failed", severity="error")

        except Exception as e:
            output.update(f"💥 Error: {e}")
            self.notify(f"Error: {e}", severity="error")

    @on(Button.Pressed, "#back_btn")
    def go_back(self) -> None:
        self.app.pop_screen()

class DnfInstaller(App):
    CSS = """
    Screen {
        background: $surface;
    }

    #main {
        width: 100%;
        height: 100%;
        padding: 1 2;
    }

    #counter {
        width: 100%;
        height: 3;
        content-align: center middle;
        background: $boost;
        border: round $primary;
        margin-bottom: 1;
        text-style: bold;
    }

    #package-list {
        width: 100%;
        height: 1fr;
        border: round $primary;
        padding: 1;
        margin-bottom: 1;
    }

    PackageCheckbox {
        width: 100%;
    }

    #actions {
        width: 100%;
        height: auto;
        align: center middle;
    }

    #actions Button {
        margin: 0 1;
        min-width: 16;
    }

    #install-box {
        width: 100%;
        height: 100%;
        padding: 2;
    }

    #install-title {
        text-align: center;
        color: $accent;
        margin-bottom: 1;
        text-style: bold;
    }

    #output-box {
        width: 100%;
        height: 1fr;
        border: round $primary;
        padding: 1;
        margin-bottom: 1;
    }

    #back_btn {
        width: 20;
        align: center middle;
    }

    ConfirmDialog {
        align: center middle;
    }

    #dialog {
        width: 50;
        height: auto;
        max-height: 25;
        background: $surface;
        border: thick $primary;
        padding: 2;
    }

    #dialog-title {
        text-align: center;
        color: $accent;
        margin-bottom: 1;
        text-style: bold;
    }

    #pkg-list {
        width: 100%;
        max-height: 12;
        border: round $primary;
        padding: 1;
        margin: 1 0;
    }

    #dialog-buttons {
        width: 100%;
        align: center middle;
    }

    #dialog-buttons Button {
        margin: 0 1;
        min-width: 12;
    }
    """

    TITLE = "Fedora DNF Installer"

    def on_mount(self) -> None:
        self.push_screen(MainScreen())

def main():
    if sys.platform != "linux":
        print("❌ Linux required (Fedora/RHEL/CentOS)")
        sys.exit(1)

    try:
        subprocess.run(["dnf", "--version"], capture_output=True, check=True)
    except (FileNotFoundError, subprocess.CalledProcessError):
        print("❌ DNF not found")
        sys.exit(1)

    app = DnfInstaller()
    app.run()

if __name__ == "__main__":
    main()
