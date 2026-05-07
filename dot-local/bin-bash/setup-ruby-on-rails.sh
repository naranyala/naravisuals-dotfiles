#!/usr/bin/env bash
#
# Minimal Ruby on Rails dev setup for Fedora (dnf5 compatible)
# Includes fixes for Gem::Ext::BuildError by pre-installing common native deps
#
# Logs: ./rails_setup.log

set -euo pipefail
LOG_FILE="./rails_setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# --- CONFIG ---
RUBY_VERSION="3.3.4"   # Change as needed
NODE_VERSION="20"      # LTS
RAILS_VERSION="latest" # Or pin version
INSTALL_DB="postgres"  # postgres | mysql | none

# --- HELPERS ---
log() { echo -e "\n[INFO] $*"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

# --- INSTALL BASE PACKAGES ---
install_base_packages() {
    log "Installing base development tools and native library headers..."
    sudo dnf5 install -y \
        gcc gcc-c++ make \
        ruby ruby-devel \
        openssl-devel readline-devel zlib-devel libffi-devel \
        sqlite sqlite-devel \
        libxml2-devel libxslt-devel \
        postgresql-devel mysql-devel \
        git curl
}

# --- INSTALL RUBY ---
install_ruby() {
    if ! command_exists rbenv; then
        log "Installing rbenv..."
        git clone https://github.com/rbenv/rbenv.git ~/.rbenv
        cd ~/.rbenv && src/configure && make -C src
        echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
        source ~/.bashrc
        git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    fi

    if ! rbenv versions | grep -q "$RUBY_VERSION"; then
        log "Installing Ruby $RUBY_VERSION..."
        rbenv install "$RUBY_VERSION"
    fi

    rbenv global "$RUBY_VERSION"
    gem update --system
}

# --- INSTALL NODE & YARN ---
install_node_yarn() {
    if ! command_exists node; then
        log "Installing Node.js $NODE_VERSION..."
        curl -fsSL https://rpm.nodesource.com/setup_"$NODE_VERSION".x | sudo bash -
        sudo dnf5 install -y nodejs
    fi
    if ! command_exists yarn; then
        log "Installing Yarn..."
        sudo npm install -g yarn
    fi
}

# --- INSTALL DATABASE ---
install_db() {
    case "$INSTALL_DB" in
        postgres) sudo dnf5 install -y postgresql-server postgresql-contrib ;;
        mysql)    sudo dnf5 install -y mysql-server ;;
        none)     log "Skipping DB install." ;;
    esac
}

# --- INSTALL RAILS ---
install_rails() {
    log "Installing Rails..."
    if [ "$RAILS_VERSION" = "latest" ]; then
        gem install rails
    else
        gem install rails -v "$RAILS_VERSION"
    fi
    rbenv rehash
}

# --- MAIN ---
log "Starting Fedora Rails setup..."
install_base_packages
install_ruby
install_node_yarn
install_db
install_rails

log "Setup complete!"
ruby -v
rails -v
node -v
yarn -v

