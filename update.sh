#!/usr/bin/env bash

# @file update.sh
# @brief update script for all configuration files

# @description update the install script to install all the configuration
update_install_script(){
    git pull
    bash install.sh
}

# @description update the vimrc for the git
update_vimrc(){
    local current_path=$(pwd)
	cd ~/.vim_runtime
	git pull --rebase
	python3 update_plugins.py
    cd $current_path
}

