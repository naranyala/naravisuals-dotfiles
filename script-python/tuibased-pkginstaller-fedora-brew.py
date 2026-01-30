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

# Popular Homebrew packages for Linux
PACKAGES = [
    # Development Tools
    "git", "gh", "gitlab-ci-local", "glab", "hub",
    "gcc", "llvm", "cmake", "make", "automake", "autoconf",
    "pkg-config", "libtool", "ninja", "meson",

    # Programming Languages
    "python", "python@3.11", "python@3.10", "pyenv", "pipenv", "poetry",
    "node", "nvm", "yarn", "pnpm", "deno", "bun",
    "go", "rust", "rustup-init", "cargo-nextest",
    "ruby", "rbenv", "ruby-build",
    "openjdk", "openjdk@17", "openjdk@11", "maven", "gradle",
    "php", "composer",
    "lua", "luarocks", "perl", "r",

    # CLI Tools & Utilities
    "htop", "btop", "bottom", "glances", "gotop",
    "neofetch", "fastfetch", "onefetch", "screenfetch",
    "curl", "wget", "httpie", "xh", "curlie",
    "tmux", "screen", "zellij", "byobu",
    "zsh", "fish", "bash", "starship", "oh-my-posh",
    "bat", "lsd", "exa", "eza", "colorls",
    "ripgrep", "ag", "ack", "fd", "fzf", "skim",
    "jq", "yq", "fx", "jid", "gojq",
    "tree", "broot", "dust", "duf", "ncdu", "gdu",
    "tldr", "tealdeer", "cheat", "navi",
    "z", "zoxide", "autojump", "fasd",
    "diff-so-fancy", "delta", "difftastic",

    # File Management
    "mc", "ranger", "nnn", "lf", "vifm",
    "rsync", "rclone", "syncthing", "restic", "borg",
    "7zip", "p7zip", "unrar", "pigz", "zstd",

    # Text Editors & IDEs
    "vim", "neovim", "emacs", "nano", "micro", "helix",
    "kakoune", "vis",

    # Version Control
    "git-delta", "git-lfs", "git-flow", "git-extras",
    "tig", "lazygit", "gitui", "gh-dash",
    "pre-commit", "commitizen",

    # Terminal & Shell
    "alacritty", "kitty", "wezterm",
    "fzf", "sk", "peco", "percol",
    "thefuck", "atuin", "mcfly", "hstr",

    # Monitoring & System
    "htop", "iotop", "nethogs", "bandwhich", "bmon",
    "procs", "pstree", "lsof",
    "ncdu", "dust", "duf", "gdu",
    "stress", "stress-ng", "sysbench",

    # Network Tools
    "nmap", "masscan", "rustscan",
    "mtr", "iperf3", "speedtest-cli", "fast",
    "dog", "drill", "q",
    "tcpdump", "wireshark", "tshark",
    "ssh-copy-id", "sshpass", "openssh",
    "openvpn", "wireguard-tools", "tailscale",
    "ngrok", "cloudflared", "frp",

    # Databases
    "postgresql", "mysql", "mariadb", "sqlite",
    "redis", "memcached", "mongodb-community",
    "duckdb", "clickhouse",

    # Database Clients
    "mycli", "pgcli", "litecli", "redis-cli",
    "usql", "sqlc", "sqlx-cli",

    # Container & Cloud
    "docker", "docker-compose", "podman",
    "kubectl", "k9s", "kubectx", "kubens", "helm",
    "kind", "minikube", "k3d", "tilt",
    "terraform", "terragrunt", "tflint", "infracost",
    "ansible", "vagrant", "packer",
    "aws-cli", "awscli@2", "azure-cli", "gcloud",
    "doctl", "linode-cli", "scaleway-cli",

    # CI/CD & DevOps
    "jenkins", "circleci", "gitlab-runner",
    "act", "actionlint", "gh-act-cache",
    "drone-cli", "argocd", "flux",

    # Build Tools
    "bazel", "buck", "scons", "ninja", "meson",
    "ccache", "sccache", "distcc",

    # Testing & QA
    "shellcheck", "shfmt", "hadolint",
    "yamllint", "jsonlint", "markdownlint-cli",
    "vale", "proselint", "write-good",

    # Security
    "gpg", "gnupg", "pass", "gopass", "bitwarden-cli",
    "age", "sops", "git-crypt", "transcrypt",
    "nmap", "masscan", "nikto", "sqlmap",
    "trivy", "grype", "syft", "cosign",

    # Media & Graphics
    "ffmpeg", "imagemagick", "graphicsmagick",
    "youtube-dl", "yt-dlp", "streamlink",
    "mpv", "vlc", "mplayer",

    # Document Processing
    "pandoc", "asciidoctor", "grip", "glow",
    "mdbook", "hugo", "jekyll", "zola",
    "pdfgrep", "poppler", "ghostscript",

    # Code Quality
    "prettier", "black", "ruff", "mypy",
    "eslint", "stylelint", "rubocop",
    "golangci-lint", "staticcheck", "gosec",
    "clippy", "rustfmt",

    # Package Managers
    "brew", "pipx", "npm", "yarn", "pnpm",
    "cargo-binstall", "cargo-update",

    # Benchmarking
    "hyperfine", "bench", "ab", "wrk", "hey",
    "bombardier", "vegeta",

    # JSON/YAML Tools
    "jq", "yq", "jid", "fx", "gron",
    "dasel", "xsv", "miller", "csvkit",

    # Modern Unix Replacements
    "bat", "lsd", "exa", "eza", "fd", "ripgrep",
    "sd", "procs", "dust", "tokei", "grex",
    "choose", "dog", "bandwhich", "zoxide",

    # Fun & Entertainment
    "cmatrix", "cowsay", "fortune", "figlet", "lolcat",
    "sl", "asciiquarium", "no-more-secrets",

    # Productivity
    "task", "taskwarrior-tui", "todo-txt",
    "remind", "calcurse", "khal",
    "vit", "timewarrior", "watson",
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
            yield Label(f"🍺 Install {len(self.packages)} packages?", id="dialog-title")
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
                yield Button("🍺 Install Selected", id="install_btn", variant="success")
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
            yield Label(f"🍺 Installing {len(self.packages)} packages...", id="install-title")
            with VerticalScroll(id="output-box"):
                yield Static("Starting installation...\n", id="output")
            yield Button("← Back", id="back_btn")
        yield Footer()

    def on_mount(self) -> None:
        self.run_worker(self.install_packages())

    async def install_packages(self) -> None:
        output = self.query_one("#output", Static)

        try:
            cmd = ["brew", "install"] + self.packages
            output.update(f"Running: brew install ...\n\n")

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
                output.update(output.renderable + "\n\n✅ Success!")
                self.notify("✅ Installation completed!")
            else:
                output.update(output.renderable + f"\n\n❌ Failed (code {process.returncode})")
                self.notify("❌ Installation failed", severity="error")

        except Exception as e:
            output.update(f"💥 Error: {e}")
            self.notify(f"Error: {e}", severity="error")

    @on(Button.Pressed, "#back_btn")
    def go_back(self) -> None:
        self.app.pop_screen()

class BrewInstaller(App):
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

    TITLE = "Homebrew Package Installer"

    def on_mount(self) -> None:
        self.push_screen(MainScreen())

def main():
    # Check if Homebrew is installed
    try:
        result = subprocess.run(["brew", "--version"], capture_output=True, check=True, text=True)
    except FileNotFoundError:
        print("❌ Homebrew not found!")
        print("\n📥 Install Homebrew first:")
        print('   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
        print("\n💡 After installation, add Homebrew to your PATH:")
        print('   echo \'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"\' >> ~/.bashrc')
        print('   eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"')
        sys.exit(1)
    except subprocess.CalledProcessError:
        print("⚠️  Homebrew found but returned an error")
        sys.exit(1)

    app = BrewInstaller()
    app.run()

if __name__ == "__main__":
    main()
