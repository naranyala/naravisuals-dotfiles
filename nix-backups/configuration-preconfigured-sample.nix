{
  description = "NixOS with Preconfigured GNOME Extensions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux"; # Change to your architecture if needed
      pkgs = nixpkgs.legacyPackages.${system};

      # Define your username here
      username = "yourusername"; # ← CHANGE THIS

    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit username; };

        modules = [
          # System configuration
          ({ config, pkgs, username, ... }: {
            # Boot loader
            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;

            # System state version
            system.stateVersion = "24.11"; # ← Adjust to your installed version

            # Networking
            networking.hostName = "nixos-gnome";
            networking.networkmanager.enable = true;

            # Locale
            time.timeZone = "UTC"; # ← CHANGE THIS to your timezone
            i18n.defaultLocale = "en_US.UTF-8";

            # Enable flakes
            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            # User configuration
            users.users.${username} = {
              isNormalUser = true;
              description = "Primary User";
              extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
              initialPassword = "changeme"; # ← Change on first login or use hashedPassword
            };

            # X11 and GNOME
            services.xserver = {
              enable = true;
              displayManager.gdm.enable = true;
              desktopManager.gnome.enable = true;
              xkb.layout = "us"; # ← CHANGE if needed
            };

            # Essential GNOME services
            services.dbus.packages = [ pkgs.dconf ];
            services.udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
            programs.dconf.enable = true;

            # Audio
            services.pulseaudio.enable = false;
            services.pipewire = {
              enable = true;
              alsa.enable = true;
              alsa.support32Bit = true;
              pulse.enable = true;
            };

            # System-wide packages including GNOME extensions
            # These will be available to all users but NOT automatically enabled
            environment.systemPackages = with pkgs; [
              # GNOME utilities
              gnome.gnome-tweaks
              gnome-extension-manager

              # Preinstalled extensions (installed but not auto-enabled without home-manager)
              gnomeExtensions.dash-to-dock
              gnomeExtensions.blur-my-shell
              gnomeExtensions.clipboard-indicator
              gnomeExtensions.caffeine
              gnomeExtensions.user-themes
              gnomeExtensions.appindicator
              gnomeExtensions.gsconnect
              gnomeExtensions.just-perfection
            ];

            # Exclude default GNOME packages you don't want
            environment.gnome.excludePackages = with pkgs; [
              gnome-tour
              gnome-user-docs
            ] ++ (with pkgs.gnome; [
              # Uncomment to remove more default apps:
              # cheese      # webcam tool
              # gnome-music
              # gedit       # text editor
              # epiphany    # web browser
              # geary       # email reader
              # gnome-characters
              # yelp        # help viewer
            ]);

            # Enable browser integration for extensions.gnome.org (optional)
            services.gnome.chrome-gnome-shell.enable = true;

            # Basic system packages
            environment.systemPackages = with pkgs; [
              git
              vim
              wget
              firefox
            ];
          })

          # Home Manager module integration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = { pkgs, ... }: {
              home.username = username;
              home.homeDirectory = "/home/${username}";
              home.stateVersion = "24.11"; # ← Match your home-manager version

              # Enable home-manager
              programs.home-manager.enable = true;

              # User packages
              home.packages = with pkgs; [
                # Add user-specific packages here
              ];

              # GNOME Extensions - PRECONFIGURED AND ENABLED
              # This is the key part that enables extensions by default
              dconf = {
                enable = true;
                settings = {
                  # Enable user extensions (required)
                  "org/gnome/shell" = {
                    disable-user-extensions = false;

                    # List of enabled extensions by UUID
                    # Use .extensionUuid attribute from nixpkgs packages
                    enabled-extensions = with pkgs.gnomeExtensions; [
                      dash-to-dock.extensionUuid
                      blur-my-shell.extensionUuid
                      clipboard-indicator.extensionUuid
                      caffeine.extensionUuid
                      user-themes.extensionUuid
                      appindicator.extensionUuid
                      gsconnect.extensionUuid
                      just-perfection.extensionUuid
                    ];

                    # Disable specific default extensions if desired
                    disabled-extensions = [
                      # Example: "native-window-placement@gnome-shell-extensions.gcampax.github.com"
                    ];

                    # Favorite apps in dock
                    favorite-apps = [
                      "firefox.desktop"
                      "org.gnome.Nautilus.desktop"
                      "org.gnome.Console.desktop"
                      "org.gnome.Settings.desktop"
                    ];
                  };

                  # === EXTENSION-SPECIFIC CONFIGURATIONS ===

                  # Dash to Dock settings
                  "org/gnome/shell/extensions/dash-to-dock" = {
                    dock-position = "LEFT";
                    show-apps-at-top = true;
                    dash-max-icon-size = 48;
                    show-favorites = true;
                    show-running = true;
                    show-mounts = true;
                    show-trash = true;
                    autohide = true;
                    intellihide = true;
                    intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
                    require-pressure-to-show = false;
                    animation-time = 0.2;
                  };

                  # Blur My Shell settings
                  "org/gnome/shell/extensions/blur-my-shell" = {
                    brightness = 0.75;
                    noise-amount = 0;
                    sigma = 30;
                  };

                  # Caffeine settings
                  "org/gnome/shell/extensions/caffeine" = {
                    show-indicator = true;
                    show-notification = true;
                  };

                  # Clipboard Indicator settings
                  "org/gnome/shell/extensions/clipboard-indicator" = {
                    toggle-menu = ["<Super>v"]; # Super+V to open clipboard
                    preview-size = 30;
                    cache-size = 50;
                  };

                  # Just Perfection settings (GNOME UI tweaks)
                  "org/gnome/shell/extensions/just-perfection" = {
                    animation = 2; # Faster animations
                    dash = true;
                    dash-app-running = true;
                    panel = true;
                    panel-in-overview = true;
                    workspace-switcher-should-show = true;
                  };

                  # GSConnect settings (KDE Connect for GNOME)
                  "org/gnome/shell/extensions/gsconnect" = {
                    show-indicator = true;
                  };

                  # === GENERAL GNOME SETTINGS ===

                  # Dark mode
                  "org/gnome/desktop/interface" = {
                    color-scheme = "prefer-dark";
                    enable-animations = true;
                    gtk-theme = "Adwaita-dark";
                    icon-theme = "Adwaita";
                    cursor-theme = "Adwaita";
                    font-name = "Cantarell 11";
                    document-font-name = "Sans 11";
                    monospace-font-name = "Monospace 11";
                  };

                  # Window management
                  "org/gnome/desktop/wm/preferences" = {
                    button-layout = "appmenu:minimize,maximize,close";
                    num-workspaces = 4;
                    workspace-names = ["Work" "Web" "Chat" "Misc"];
                  };

                  # Keyboard shortcuts
                  "org/gnome/settings-daemon/plugins/media-keys" = {
                    custom-keybindings = [
                      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
                    ];
                  };

                  # Custom keyboard shortcut (example: open terminal)
                  "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
                    name = "Terminal";
                    command = "kgx"; # GNOME Console (or use "gnome-terminal")
                    binding = "<Super>t";
                  };

                  # Screensaver/lock settings
                  "org/gnome/desktop/screensaver" = {
                    lock-enabled = true;
                    lock-delay = 300; # 5 minutes
                  };

                  # Session management
                  "org/gnome/desktop/session" = {
                    idle-delay = 600; # 10 minutes screen blank
                  };

                  # Power settings
                  "org/gnome/settings-daemon/plugins/power" = {
                    sleep-inactive-ac-timeout = 1800; # 30 min on AC
                    sleep-inactive-battery-timeout = 900; # 15 min on battery
                  };

                  # Nautilus (Files) settings
                  "org/gnome/nautilus/preferences" = {
                    show-hidden-files = true;
                    show-image-thumbnails = "always";
                    default-folder-viewer = "icon-view";
                  };

                  # GNOME Console settings
                  "org/gnome/Console" = {
                    theme = "night";
                  };
                };
              };

              # GTK configuration
              gtk = {
                enable = true;
                theme = {
                  name = "Adwaita-dark";
                  package = pkgs.gnome-themes-extra;
                };
                iconTheme = {
                  name = "Adwaita";
                  package = pkgs.adwaita-icon-theme;
                };
                cursorTheme = {
                  name = "Adwaita";
                  package = pkgs.adwaita-icon-theme;
                };
              };

              # Qt integration with GNOME
              qt = {
                enable = true;
                platformTheme = "gnome";
                style = "adwaita-dark";
              };

              # Git configuration
              programs.git = {
                enable = true;
                userName = "Your Name"; # ← CHANGE THIS
                userEmail = "your.email@example.com"; # ← CHANGE THIS
              };

              # Bash configuration
              programs.bash = {
                enable = true;
                enableCompletion = true;
                shellAliases = {
                  ll = "ls -la";
                  rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
                  update = "sudo nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#nixos";
                };
              };
            };
          }
        ];
      };
    };
}
