#!/usr/bin/env bash

# @file update.sh
# @brief update script for all configuration files


update_vimrc(){
	cd ~/.vim_runtime
	git pull --rebase
	python3 update_plugins.py
}

