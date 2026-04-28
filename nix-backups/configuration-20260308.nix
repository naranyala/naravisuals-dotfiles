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

  boot.initrd.postDeviceCommands = ''
    ${pkgs.ntfs3g}/bin/ntfsfix /dev/sda2
    ${pkgs.ntfs3g}/bin/ntfsfix /dev/nvme0n1p4 
  '';

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

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



  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

programs.nix-ld.enable = true;
programs.nix-ld.libraries = with pkgs; [
  # Add common libraries that generic binaries usually need
  stdenv.cc.cc
  openssl
  # xorg.libX11
  opencode

  glib
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

  environment.systemPackages = with pkgs; [
    ntfs3g 
    steam-run-free
    adwaita-icon-theme
    libglibutil
    pkg-config

    # GNOME tweaking (only one — add others only if really needed)
    gnome-tweaks
    gnomeExtensions.dash-to-panel
    gnomeExtensions.arc-menu
    gnomeExtensions.appindicator # For system tray icons
    gnomeExtensions.blur-my-shell

    onlyoffice-desktopeditors
    chromium
    codex
    # opencode
    gemini-cli

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
    ];
  };


  # ────────────────────────────────────────────────
  # Home Manager (user-level config)
  # ────────────────────────────────────────────────
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.naranyala = { pkgs, config, ... }: {
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

  system.stateVersion = "25.05";  # bump on major upgrade (e.g. to "25.11")
}
