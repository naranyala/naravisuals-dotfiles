#!/usr/bin/bash

# Remove existing gems
gem uninstall rails --all
gem uninstall activesupport --all

# Clean up rbenv
rbenv rehash
rbenv versions

# Reinstall with clean environment
gem install rails --version 7.0.6

# Verify installation
rails --version
ruby -ractive_support -e "puts 'ActiveSupport loaded successfully'"
