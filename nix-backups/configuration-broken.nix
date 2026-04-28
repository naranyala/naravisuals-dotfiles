# NixOS Configuration — naranyala (GNOME / Wayland / 25.05)
#
# Setup:
#   sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager
#   sudo nix-channel --add https://github.com/nix-community/nix-snapd/archive/main.tar.gz nix-snapd
#   sudo nix-channel --update
#
# Commands:
#   switch: sudo nixos-rebuild switch (upgrade: add --upgrade, rollback: add --rollback)
#   boot: sudo nixos-rebuild boot
#   gc: sudo nix-collect-garbage -d
#
# Refs: https://search.nixos.org/options | https://search.nixos.org/packages | https://nixos.wiki

{ config, pkgs, ... }:
let
  # Custom AI AppImage Wrappers
  jan-ai = pkgs.appimageTools.wrapType2 {
    pname = "jan";
    version = "0.7.9";
    src = pkgs.fetchurl {
      url = "https://github.com/janhq/jan/releases/download/v0.7.9/Jan_0.7.9_amd64.AppImage";
      sha256 = ""; 
    };
    extraPkgs = pkgs: with pkgs; [ libsecret mesa vulkan-loader ];
  };

  lm-studio = pkgs.appimageTools.wrapType2 {
    pname = "lm-studio";
    version = "0.4.9";
    src = pkgs.fetchurl {
      url = "https://installers.lmstudio.ai/linux/x64/0.4.9-1/LM-Studio-0.4.9-1-x64.AppImage";
      sha256 = "";
    };
    extraPkgs = pkgs: with pkgs; [ ocl-icd libGL ];
  };

  helium = pkgs.appimageTools.wrapType2 {
    pname = "helium";
    version = "0.11.3.2";
    src = pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/0.11.3.2/helium-0.11.3.2-x86_64.AppImage";
      sha256 = "";
    };
    extraPkgs = pkgs: with pkgs; [ libsecret mesa vulkan-loader libGL ];
  };

  # Browser Repos
  zen-repo = import (builtins.fetchTarball {
    url = "https://github.com/0xc000022070/zen-browser-flake/archive/main.tar.gz";
  }) { inherit pkgs; };

  # LocalAI Binary
  localai = pkgs.stdenv.mkDerivation {
    pname = "local-ai";
    version = "4.1.3";
    src = pkgs.fetchurl {
      url = "https://github.com/mudler/LocalAI/releases/download/v4.1.3/local-ai-v4.1.3-linux-amd64";
      sha256 = "";
    };
    installPhase = '' install -m 755 $src $out/bin/local-ai '';
  };
in
{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
    (import <nix-snapd>).nixosModules.default
  ];

  # --- 1. Core System ---
  system.stateVersion = "25.05";

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    settings.auto-optimise-store = true;
    gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 7d"; };
    settings.keep-outputs = false;
    settings.keep-derivations = true;
  };

  boot.loader = { systemd-boot.enable = true; efi.canTouchEfiVariables = true; };
  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- 2. Networking & Security ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall = {
    allowedTCPPorts = [ 57621 ]; # Spotify Connect
    allowedUDPPorts = [ 5353 ];  # mDNS / Bonjour
  };
  security.rtkit.enable = true;

  # --- 3. Hardware & Formats ---
  hardware.opengl.enable = true;
  programs.appimage = { enable = true; binfmt = true; };
  programs.nix-ld.enable = true;

  # --- 4. Desktop Environment (GNOME) ---
  services.xserver = {
    enable = true;
    displayManager.gdm = { enable = true; wayland = true; };
    desktopManager.gnome.enable = true;
    xkb = { layout = "us"; variant = ""; };
  };

  xdg.portal = { enable = true; extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; };
  environment.gnome.excludePackages = with pkgs; [];
  services.gnome.gnome-keyring.enable = true;

  programs.dconf = {
    enable = true;
    profiles.user.databases = [{
      settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        cursor-theme = "Adwaita";
        locate-pointer = true;
      };
    }];
  };

  # --- 5. Multimedia ---
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig.pipewire."92-low-latency".context.properties = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 512;
      "default.clock.min-quantum" = 32;
      "default.clock.max-quantum" = 1024;
    };
    wireplumber.extraConfig."10-bluez".monitor.bluez.properties = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "headset_head_unit" "headset_audio_gateway" ];
    };
  };
  services.pulseaudio.enable = false;
  services.printing.enable = true;

  # --- 6. Users ---
  users.users.naranyala = {
    isNormalUser = true;
    description  = "naranyala";
    extraGroups  = [ "networkmanager" "wheel" ];
  };

  # --- 7. Environment & Packages ---
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # caution of big packages to download
    zen-repo.default floorp chromium helium
    spotify
    onlyoffice-desktopeditors blender freecad qgis
    jan-ai lm-studio # localai

    # Browsers / Audio / Office (Standard)
    easyeffects lsp-plugins rnnoise-plugin pavucontrol
    inkscape drawio
    docker
    # GNOME Tweaks
    gnome-tweaks gnomeExtensions.dash-to-panel gnomeExtensions.arc-menu gnomeExtensions.appindicator gnomeExtensions.blur-my-shell
    # Utils
    pkg-config ntfs3g steam-run-free adwaita-icon-theme libglibutil copyDesktopItems wrapGAppsHook4
  ];

  environment.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch";
    nix-clean  = "sudo nix-collect-garbage -d";
    nix-config = "nano /etc/nixos/configuration.nix";
    dir = "ls -alh";
    cls = "clear";
    explorer = "nautilus .";
    edit-nixos-ssd = "sudo nvim /etc/nixos/configuration.nix";
    edit-nixos-ext = "sudo nvim /media/naranyala/ext_root/etc/nixos/configuration.nix";
    goto-project-remote = "cd /media/naranyala/Data/projects-remote";
    goto-project-agentic = "cd /media/naranyala/Data/projects-agentic";
    goto-project-pi = "cd /media/naranyala/Data/projects-pi-ext";
    mergepdf-cwd = "bun /media/naranyala/Data/diskd-scripts/javascript/merge-all-pdf-in-current-dir.js";
    goto-diskd-bin = "cd /media/naranyala/Data/diskd-binaries";
    battery-health = "upower -i /org/freedesktop/UPower/devices/battery_BAT0";
    show-pi = "bat ~/.pi/agent/settings.json";
    gitlog = "git log --oneline --graph --decorate";
  };

  environment.variables = {
    EDITOR = "nano";
    BROWSER = "firefox";
    NPM_CONFIG_PREFIX = "$HOME/.npm-packages";
    PKG_CONFIG_PATH = "${pkgs.glib.dev}/lib/pkgconfig:${pkgs.glib.out}/lib/pkgconfig";
    CFLAGS = "-I${pkgs.glib.dev}/include/glib-2.0 -I${pkgs.glib.dev}/lib/glib-2.0/include";
    LDFLAGS = "-L${pkgs.glib.out}/lib -L${pkgs.gtk3.out}/lib";
    GIO_MODULE_DIR = "${pkgs.glib.out}/lib/gio/modules";
    GST_PLUGIN_PATH = "${pkgs.gst_all_1.gstreamer.out}/lib/gstreamer-1.0";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  environment.sessionVariables = {
    PATH = [
      "$HOME/.npm-packages/bin" "$HOME/.local/bin" "$HOME/bin" "$HOME/.bun/bin"
      "/media/naranyala/Data/diskd-binaries" "/media/naranyala/Data/diskd-binaries/v_linux"
      "/media/naranyala/Data/diskd-binaries/zig-x86_64-linux-0.15.2"
      "/media/naranyala/Data/diskd-binaries/odin-linux" "/media/naranyala/Data/diskd-binaries/c3-linux"
    ];
  };

  # --- 8. System Services ---
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    ensureDatabases = [ "mydatabase" ];
    ensureUsers = [{ name = "myuser"; }];
  };

  systemd.services.localai = {
    description = "LocalAI Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${localai}/bin/local-ai";
      Restart = "always";
      Environment = [ "MODELS_PATH=/var/lib/localai/models" ];
    };
  };

  # --- 9. Global Programs ---
  programs.firefox.enable = true;
  programs.starship.enable = true;

  # --- 10. Home Manager ---
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.naranyala = { pkgs, config, ... }: {
      home.stateVersion = "25.05";
      home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" "${config.home.homeDirectory}/.bun/bin" ];
      home.shellAliases = {
        nx-switch = "sudo nixos-rebuild switch";
        nx-edit = "sudo nvim /etc/nixos/configuration.nix";
        nx-gc = "sudo nix-collect-garbage -d";
        nx-clean = "sudo nix-collect-garbage -d && sudo nix-store --optimize";
        update = "sudo nixos-rebuild switch --upgrade";
        gs = "git status -sb";
        gp = "git push";
        ll = "ls -la";
      };
      programs.neovim = { enable = true; defaultEditor = true; viAlias = true; vimAlias = true; };
      programs.firefox.enable = true;
      home.packages = with pkgs; [
        # caution of big packages to download
        clang llvm ollama

        libGL glib dbus zenity kdePackages.kdialog
        gnome-tour cheese tali iagno hitori atomix
        epiphany geary gnome-music gnome-photos
        gnome-text-editor gnome-characters gnome-contacts
        gnome-calendar gnome-clocks gnome-weather
        gnome-maps simple-scan baobab evince totem
        gnome-software yelp
        nodejs_24 bun python314 uv ruff
        rustup cargo-tauri cmake zig odin vlang
        llama-cpp
        dbeaver-bin dbgate sqlite duckdb postgresql_17
        delta bat fd fzf ripgrep btop fastfetch
        starship xclip md2pdf vlc
        vim wget git unzip tree ncdu jq codex gedit
      ];
    };
  };
}
