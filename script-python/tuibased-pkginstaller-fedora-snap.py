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

# Popular Snap packages
PACKAGES = [
    # Development Tools
    "code", "codium", "sublime-text", "atom", "brackets",
    "android-studio", "pycharm-community", "intellij-idea-community",
    "eclipse", "netbeans", "arduino", "postman", "insomnia",
    "gitkraken", "git-cola", "meld", "bcompare",
    "docker", "microk8s", "kubectl", "helm", "terraform",

    # Web Browsers
    "chromium", "firefox", "brave", "opera", "vivaldi",
    "microsoft-edge", "falkon", "midori",

    # Communication
    "slack", "discord", "telegram-desktop", "signal-desktop",
    "skype", "zoom-client", "teams", "element-desktop",
    "thunderbird", "mailspring", "geary",
    "whatsdesk", "whatsapp-for-linux",

    # Media Players
    "vlc", "mpv", "spotify", "clementine", "rhythmbox",
    "audacious", "strawberry", "lollypop", "gnome-music",
    "youtube-music-desktop-app", "nuclear",

    # Video Editors
    "obs-studio", "kdenlive", "openshot", "shotcut", "flowblade",
    "olive-editor", "blender", "lightworks",

    # Graphics & Design
    "gimp", "inkscape", "krita", "darktable", "rawtherapee",
    "scribus", "pencil2d", "synfigstudio", "natron",
    "figma-linux", "lunacy", "penpot",

    # 3D & Animation
    "blender", "freecad", "openscad", "sweethome3d",
    "wings3d", "dust3d",

    # Office & Productivity
    "libreoffice", "onlyoffice-desktopeditors", "wps-office",
    "freeoffice", "calligra", "abiword", "gnumeric",
    "notion-snap", "obsidian", "joplin-desktop",
    "simplenote", "notable", "zettlr", "marktext",
    "typora", "ghostwriter", "vnote",

    # Note Taking & Markdown
    "standard-notes", "trilium-notes", "cherrytree",
    "boostnote", "zim", "xournalpp",

    # PDF Tools
    "pdfarranger", "pdfmod", "okular", "evince",
    "xreader", "qpdfview", "masterpdfeditor",

    # E-Book Readers
    "calibre", "foliate", "bookworm", "fbreader",

    # Password Managers
    "bitwarden", "keepassxc", "enpass", "buttercup-desktop",
    "passky", "padloc",

    # Cloud Storage
    "dropbox", "megasync", "nextcloud-desktop",
    "onedrive-abraunegg", "pcloud", "tresorit",
    "syncthing", "rclone-browser",

    # File Managers
    "mc", "doublecmd", "krusader", "sunflower",

    # System Tools
    "htop", "baobab", "bleachbit", "stacer", "synaptic",
    "timeshift", "deja-dup", "pika-backup",
    "gparted", "gnome-disk-utility", "kdiskmark",
    "cpu-x", "hardinfo", "i-nex",

    # Terminal Emulators
    "alacritty", "kitty", "terminator", "tilix",
    "cool-retro-term", "hyper", "tabby",

    # Remote Desktop
    "remmina", "rustdesk", "anydesk", "teamviewer",
    "vnc-viewer", "realvnc-vnc-viewer",

    # VPN & Network
    "openvpn", "nordvpn", "expressvpn", "protonvpn",
    "wireguard", "zerotier-one", "tailscale",
    "wireshark", "zenmap", "angry-ip-scanner",

    # Download Managers
    "motrix", "persepolis", "uget", "flareget",
    "youtube-dl", "tartube",

    # Torrent Clients
    "transmission", "qbittorrent", "deluge", "fragments",

    # Audio Production
    "audacity", "ardour", "lmms", "musescore",
    "rosegarden", "tuxguitar", "hydrogen",
    "guitarix", "rakarrack", "calf-studio-gear",

    # Video Streaming
    "streamlink-twitch-gui", "gnome-twitch", "freetube",
    "minitube", "smtube", "youtube-dl-gui",

    # Screen Recording
    "peek", "simplescreenrecorder", "vokoscreen",
    "green-recorder", "kooha",

    # Image Viewers
    "gwenview", "eog", "nomacs", "gthumb",
    "photoqt", "xviewer", "mirage",

    # Screenshot Tools
    "flameshot", "shutter", "spectacle", "gnome-screenshot",
    "ksnip", "screengrab",

    # Gaming
    "steam", "retroarch", "lutris", "playonlinux",
    "itch", "gamehub", "minigalaxy", "heroic",
    "multimc", "prismlauncher", "goverlay", "mangohud",

    # Emulators
    "dolphin-emulator", "ppsspp", "pcsx2", "rpcs3",
    "cemu", "yuzu", "ryujin", "snes9x-gtk",

    # Education
    "anki", "celestia", "stellarium", "kstars",
    "scratch", "tux-paint", "gcompris", "kturtle",
    "moodle-desktop", "geogebra",

    # Finance
    "gnucash", "homebank", "moneydance", "skrooge",

    # Social Media
    "cawbird", "tootle", "whalebird", "choqok",
    "rambox", "franz", "ferdi", "hamsket",

    # RSS Readers
    "newsflash", "feedreader", "liferea", "rssguard",
    "akregator", "newsboat",

    # Email Clients
    "evolution", "kmail", "trojita", "claws-mail",

    # IRC Clients
    "hexchat", "konversation", "quassel", "srain",

    # Diff Tools
    "meld", "kdiff3", "diffuse", "kompare",

    # Hex Editors
    "ghex", "bless", "okteta", "wxhexeditor",

    # Database Tools
    "dbeaver-ce", "sqlitebrowser", "beekeeper-studio",
    "pgadmin4", "mysql-workbench-community",

    # API Testing
    "postman", "insomnia", "hoppscotch", "bruno",

    # Virtualization
    "multipass", "lxd", "virt-manager",

    # Backup Tools
    "duplicati", "timeshift", "deja-dup", "vorta",
    "restic", "duplicity",

    # Monitoring
    "gnome-system-monitor", "ksysguard", "conky",

    # Utilities
    "gnome-calculator", "qalculate-gtk", "speedcrunch",
    "converseen", "kcolorchooser", "gpick",
    "gnome-clocks", "kclock", "alarm-clock",
    "gnome-weather", "meteo-qt",

    # Containers
    "microk8s", "lxd", "docker", "podman-desktop",
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
            yield Label(f"📦 Install {len(self.packages)} snaps?", id="dialog-title")
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
                yield Button("📦 Install Selected", id="install_btn", variant="success")
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
            yield Label(f"📦 Installing {len(self.packages)} snaps...", id="install-title")
            with VerticalScroll(id="output-box"):
                yield Static("Starting installation...\n", id="output")
            yield Button("← Back", id="back_btn")
        yield Footer()

    def on_mount(self) -> None:
        self.run_worker(self.install_packages())

    async def install_packages(self) -> None:
        output = self.query_one("#output", Static)

        try:
            # Install packages one by one (snap doesn't support batch install well)
            for i, pkg in enumerate(self.packages, 1):
                output.update(f"Installing {i}/{len(self.packages)}: {pkg}\n\n")

                cmd = ["sudo", "snap", "install", pkg]

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
                        display = "\n".join(lines[-10:])
                        output.update(f"Installing {i}/{len(self.packages)}: {pkg}\n\n{display}")

                await process.wait()

                if process.returncode != 0:
                    output.update(output.renderable + f"\n\n❌ Failed to install: {pkg}")
                    self.notify(f"❌ Failed: {pkg}", severity="error")

            output.update(output.renderable + "\n\n✅ Installation completed!")
            self.notify("✅ All packages processed!")

        except Exception as e:
            output.update(f"💥 Error: {e}")
            self.notify(f"Error: {e}", severity="error")

    @on(Button.Pressed, "#back_btn")
    def go_back(self) -> None:
        self.app.pop_screen()

class SnapInstaller(App):
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

    TITLE = "Snap Package Installer"

    def on_mount(self) -> None:
        self.push_screen(MainScreen())

def main():
    # Check if snapd is installed
    try:
        result = subprocess.run(["snap", "version"], capture_output=True, check=True, text=True)
    except FileNotFoundError:
        print("❌ Snapd not found!")
        print("\n📥 Install snapd first on Fedora:")
        print("   sudo dnf install snapd")
        print("   sudo ln -s /var/lib/snapd/snap /snap")
        print("   sudo systemctl enable --now snapd.socket")
        print("\n💡 You may need to log out and back in for snap to work")
        sys.exit(1)
    except subprocess.CalledProcessError:
        print("⚠️  Snapd found but returned an error")
        print("💡 Make sure snapd service is running:")
        print("   sudo systemctl status snapd")
        sys.exit(1)

    app = SnapInstaller()
    app.run()

if __name__ == "__main__":
    main()
