### setup home-manager ###
# sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager
# sudo nix-channel --update

{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  # ────────────────────────────────────────────────
  # Boot & basics
  # ────────────────────────────────────────────────
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  ## fix ntfs partition??
  # boot.initrd.postDeviceCommands = ''
  #   ${pkgs.ntfs3g}/bin/ntfsfix /dev/sda2
  #   ${pkgs.ntfs3g}/bin/ntfsfix /dev/nvme0n1p4 
  # '';

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # 4. Firewall for Spotify Connect & Discovery
  networking.firewall = {
    allowedTCPPorts = [ 57621 ]; # Spotify Discovery
    allowedUDPPorts = [ 5353 ];  # mDNS for Spotify Connect
  };
  

  time.timeZone   = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  # ────────────────────────────────────────────────
  # GNOME / Wayland (minimal & de-bloated)
  # ────────────────────────────────────────────────
  services.xserver = {
    enable = true;

    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    desktopManager.gnome.enable = true;

    xkb = {
      layout  = "us";
      variant = "";
    };
  };


# pkgs.mkShell {
#   buildInputs = [
#     pkgs.nodejs
#     pkgs.chromium
#   ];
#
#   shellHook = ''
#     export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
#     export PUPPETEER_EXECUTABLE_PATH=${pkgs.chromium}/bin/chromium
#   '';
# }

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

# programs.nix-ld.enable = true;
# programs.nix-ld.libraries = with pkgs; [
#   # Add common libraries that generic binaries usually need
#   stdenv.cc.cc
#   openssl
#   # xorg.libX11
#   opencode
#
#   glib
# ];

## chromium fix
programs.nix-ld.enable = true;
programs.nix-ld.libraries = with pkgs; [
  nspr
  nss
  libdrm
  mesa
  alsa-lib
  atk
  at-spi2-atk
  at-spi2-core
  cairo
  cups
  dbus
  expat
  fontconfig
  freetype
  gdk-pixbuf
  glib
  gtk3
  libGL
  pango
  pciutils
  udev
  libdrm   
  libgbm 
  libxkbcommon

  xorg.libxcb
  xorg.libX11
  xorg.libXcomposite
  xorg.libXcursor
  xorg.libXdamage
  xorg.libXext
  xorg.libXfixes
  xorg.libXi
  xorg.libXrandr
  xorg.libXrender
  xorg.libXScrnSaver
  xorg.libXtst
  xorg.libxshmfence
];



  # Aggressive exclude of GNOME default apps (2025–2026 era safe list)
  # Covers games, legacy utils, viewers, and redundant tools.
  # Adjust / add back if something critical disappears after rebuild.
  environment.gnome.excludePackages = with pkgs; [
    # Games & fun stuff
    gnome-tour cheese tali iagno hitori atomix

    # Communication / legacy feel
    epiphany     # browser (you use firefox)
    geary        # email
    gnome-music
    gnome-photos

    # Productivity / viewers (most people replace these)
    gnome-text-editor
    gnome-characters
    gnome-contacts
    gnome-calendar
    gnome-clocks
    gnome-weather
    gnome-maps
    simple-scan   # scanner
    baobab        # disk usage
    evince        # pdf viewer (use firefox/pdf.js or add back if needed)
    totem         # old video → showtime may be default now
    gnome-software  # prefer flatpak / nix
    yelp            # help viewer



  ];


  programs.dconf.enable = true;

  programs.dconf.profiles.user.databases = [{
    settings = { 
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        cursor-theme = "Adwaita";
        locate-pointer = true; # Press Ctrl to find your cursor
      };

    };
  }];


  # Audio stack (modern PipeWire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

     # Low-Latency & Sampling Rate Tweaks
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 512;      # Balance between latency and CPU
        "default.clock.min-quantum" = 32;   # Minimum buffer
        "default.clock.max-quantum" = 1024; # Maximum buffer
      };
    };

    # Bluetooth Audio Quality Improvements
    wireplumber.extraConfig = {
      "10-bluez" = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "headset_head_unit" "headset_audio_gateway" ];
        };
      };
    };
  };
  services.pulseaudio.enable = false;

  # Printing — comment out entirely if you never print (saves ~150–250 MiB)
  services.printing.enable = true;

  # ────────────────────────────────────────────────
  # Users
  # ────────────────────────────────────────────────
  users.users.naranyala = {
    isNormalUser = true;
    description  = "naranyala";
    extraGroups  = [ "networkmanager" "wheel" ];
  };

  # ────────────────────────────────────────────────
  # Global packages — kept very lean
  # ────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;


# environment.systemPackages = with pkgs; [
 environment.systemPackages = let
   # Define the external package here
   zen-repo = import (builtins.fetchTarball "https://github.com/0xc000022070/zen-browser-flake/archive/main.tar.gz") {
     inherit pkgs;
   };
 in with pkgs; [
   # Include the variable we defined in the 'let' block
    zen-repo.default
    floorp

    # database-related
    dbeaver-bin
    dbgate
    sqlite
    postgresql_17  
    duckdb
    gcc
    gnumake
    cloudflare-warp

    spotify
    easyeffects      # The GUI Equalizer
    lsp-plugins      # Pro-grade filters for EasyEffects
    rnnoise-plugin   # AI-powered Noise Cancellation for Mic
    
    # Utilities
    pavucontrol      # Advanced Volume Control GUI

    sway
    waybar
    fuzzel
    wl-clipboard
    mako
    grim
    slurp
    foot
    swayidle
    swaylock

    ntfs3g 
    steam-run-free
    adwaita-icon-theme
    libglibutil
    pkg-config
    gcc
    clang
    llvm
    zig
    odin 
    vlang

    # GNOME tweaking (only one — add others only if really needed)
    gnome-tweaks
    gnomeExtensions.dash-to-panel
    gnomeExtensions.arc-menu
    gnomeExtensions.appindicator # For system tray icons
    gnomeExtensions.blur-my-shell

    onlyoffice-desktopeditors
    inkscape
    drawio

    chromium
    codex
    # opencode
    gemini-cli

    bat
    starship
    xclip
    md2pdf 


    nodejs_24 
    nodePackages.typescript
    nodePackages.typescript-language-server
    # nodePackages.opencode-ai

   baobab
   evince
   cargo
   rustup
   rustc
   ncdu
   fastfetch
   btop
   vlc
   gedit

    # Core CLI/dev (neovim lives in home-manager)
    vim wget git unzip btop fzf ripgrep
    nodejs bun   # keep if heavy JS/TS usage; else move to home.packages
  ];

environment.shellAliases = {
    # NixOS specific shortcuts
    nix-switch = "sudo nixos-rebuild switch";
    nix-clean = "sudo nix-collect-garbage -d";
    nix-config = "nano /etc/nixos/configuration.nix";

    # Windows-like shortcuts
    dir = "ls -alh";
    cls = "clear";
    explorer = "nautilus ."; # Opens current folder in GNOME file manager

    edit-nixos-ssd="sudo nvim /etc/nixos/configuration.nix";
    edit-nixos-ext="sudo nvim /run/media/naranyala/ext_root/etc/nixos/configuration.nix";
    goto-project-remote="cd /run/media/naranyala/Data/projects-remote";
    goto-project-agentic="cd /run/media/naranyala/Data/projects-agentic";
    mergepdf-cwd="bun /run/media/naranyala/Data/diskd-scripts/javascript/merge-all-pdf-in-current-dir.js";

    # Development
    gitlog = "git log --oneline --graph --decorate";
  };

environment.variables = {
    # Traditional environment variables
    EDITOR = "nano";
    BROWSER = "firefox";
    
    # Fix for your npm global installs (if using the prefix method mentioned before)
    NPM_CONFIG_PREFIX = "$HOME/.npm-packages";
  };

  # Explicitly append folders to the PATH string
  environment.sessionVariables = {
    PATH = [ 
      "$HOME/.npm-packages/bin"
      "$HOME/.local/bin"
      "$HOME/bin"
      "$HOME/.bun/bin"
      "/run/media/naranyala/Data/diskd-binaries/v_linux"
    ];
  };


  # ────────────────────────────────────────────────
  # Home Manager (user-level config)
  # ────────────────────────────────────────────────
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.naranyala = { pkgs, config, ... }: {

    # dconf.settings = {
    #   "org/gnome/desktop/background" = {
    #     picture-uri = "file://${pkgs.fetchurl {
    #       url = "https://github.com/naranyala/naranyala/blob/master/default-wallpaper.jpg";
    #       sha256 = "sha256-hash";
    #     }}";
    #     picture-options = "zoom";
    #   };
    # };



      home.stateVersion = "25.05";  # bump to "25.11" or "unstable" if channel upgraded

      # Minimal session path additions
      home.sessionPath = [
        "${config.home.homeDirectory}/.local/bin"
        "${config.home.homeDirectory}/.bun/bin"
      ];

      home.shellAliases = {
        # NixOS rebuild helpers
        nx-switch = "sudo nixos-rebuild switch";
        nx-edit   = "sudo nvim /etc/nixos/configuration.nix";
        nx-gc     = "sudo nix-collect-garbage -d";
        nx-clean  = "sudo nix-collect-garbage -d && sudo nix-store --optimize";
        update    = "sudo nixos-rebuild switch --upgrade";

        # Quick git
        gs = "git status -sb";
        gp = "git push";

        ll = "ls -la";
      };

      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };


      # Optional: move Firefox here for better per-user control / extensions
      # programs.firefox.enable = true;
    };
  };

  # System-wide Firefox (good default; comment out if using home-manager version)
  programs.firefox.enable = true;
  programs.starship = {
      enable = true;
      # enableBashIntegration = true;
      # enableZshIntegration = true;
  };


  # Enable GNOME keyring for secrets
  services.gnome.gnome-keyring.enable = true;

services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    ensureDatabases = [ "mydatabase" ];
    # Removed the 'ensurePermissions' option
    ensureUsers = [{
      name = "myuser";
    }];
  };

environment.etc."sway/config".text = ''
  # Basic keybindings
  set $mod Mod4

  bindsym $mod+Return exec foot
  bindsym $mod+d exec fuzzel
  bindsym $mod+Shift+q kill

  # Reload config
  bindsym $mod+Shift+c reload

  # Exit sway
  bindsym $mod+Shift+e exec "swaymsg exit"

  # Status bar
  bar {
    swaybar_command waybar
  }
'';

# Fuzzel config file managed declaratively
  environment.etc."fuzzel/fuzzel.ini".text = ''
    [main]
    font=JetBrains Mono 12
    terminal=foot
    layer=overlay
    prompt=Search: 

    [colors]
    background=#1e1e2e
    text=#cdd6f4
    selection=#89b4fa
  '';

programs.waybar.enable = true;


environment.etc."waybar/config".text = ''
  {
    "layer": "top",
    "position": "top",
    "modules-left": ["sway/workspaces", "sway/mode"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "battery", "tray"]
  }
'';

environment.etc."waybar/style.css".text = ''
  * {
    font-family: "JetBrains Mono", monospace;
    font-size: 12px;
  }
  #clock { color: #ffffff; }
  #battery { color: #00ff00; }
'';


  system.stateVersion = "25.05";  # bump on major upgrade (e.g. to "25.11")
}
