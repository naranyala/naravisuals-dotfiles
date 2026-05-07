#!/usr/bin/bash 

sudo apt remove ncurses-term foot 

sudo dpkg --configure -a

sudo apt-get -o Dpkg::Options::="--force-overwrite" install ncurses-term

sudo apt-get -f install
