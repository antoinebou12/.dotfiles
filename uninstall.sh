#!/usr/bin/env bash

# @file uninstall.sh
# @bried uninstall script for all changes

# @description uninstall all the vimrc configuration but save backup
uninstall_vimrc(){
    rm -rf ~/.vim_runtime
    cp ~/.vimrc ~/.vimrc.backup
    rm -rf ~/.vimrc
}

# @description uninstall all the tmux configuration but save backup
uninstall_tmux(){
    cp ~/.tmux.conf ~/.tmux.conf.backup
    rm -rf .tmux.conf
}

# @description uninstall oh-my-zsh
uninstall_oh-my-zsh(){
    zsh -c -i "uninstall_oh-my-zsh"
}
